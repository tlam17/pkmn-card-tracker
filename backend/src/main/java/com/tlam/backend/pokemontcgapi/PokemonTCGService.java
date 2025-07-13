package com.tlam.backend.pokemontcgapi;

import java.time.Duration;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;

import com.tlam.backend.cardset.CardSet;
import com.tlam.backend.cardset.Language;
import com.tlam.backend.cardset.CardSetRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * Service for interacting with the Pokémon TCG API
 * This service handles fetching set data from the external API and saving it to our database
 * 
 * Authentication is handled via X-Api-Key header for higher rate limits
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PokemonTCGService {

    private final CardSetRepository cardSetRepository;
    private final PokemonTCGConfigProperties configProperties;
    private final WebClient webClient;

    private static final String SETS_ENDPOINT = "/sets";

    // Date formatter for parsing API date format (YYYY/MM/DD)
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy/MM/dd");

    /**
     * Constructor creates a configured WebClient instance with authentication
     */
    public PokemonTCGService(CardSetRepository cardSetRepository, PokemonTCGConfigProperties configProperties) {
        this.cardSetRepository = cardSetRepository;
        this.configProperties = configProperties;

        // Validate API key
        if (!StringUtils.hasText(configProperties.getApiKey())) {
            throw new IllegalArgumentException("Pokemon TCG API key not configured! Requests will have reduced rate limits.");
        }

        // Build WebClient with authentication and configuration
        this.webClient = WebClient.builder()
                .baseUrl(configProperties.getBaseUrl())
                .defaultHeader("Content-Type", "application/json")
                .defaultHeader("X-Api-Key", configProperties.getApiKey())
                .codecs(configurer -> configurer.defaultCodecs().maxInMemorySize(10 * 1024 * 1024))
                .build();

        log.info("PokemonTcgService initialized with base URL: {}", configProperties.getBaseUrl());
    }

    /**
     * Fetches all sets from the Pokémon TCG API and saves them to the database
     * This method handles pagination automatically and includes authentication
     */
    public void fetchAndSaveAllSets() {
        log.info("Starting to fetch all sets from Pokémon TCG API with authentication");

        try {
            List<CardSet> allSets = new ArrayList<>();
            int currentPage = 1;
            int pageSize = configProperties.getMaxPageSize();
            boolean hasMorePages = true;

            while (hasMorePages) {
                log.info("Fetching sets page {} with page size {}", currentPage, pageSize);

                PokemonTCGSetResponse response = fetchSetsPage(currentPage, pageSize);

                if (response != null && response.getData() != null) {
                    // Convert DTOs to CardSet entities
                    List<CardSet> pageSets = convertDtosToEntities(response.getData());
                    allSets.addAll(pageSets);

                    log.info("Fetched {} sets from page {} (Total in response: {})", 
                            pageSets.size(), currentPage, response.getTotalCount());
                    
                    // Check if we have more pages
                    hasMorePages = response.getPage() * response.getPageSize() < response.getTotalCount();
                    currentPage++;

                    // Add delay between requests to be respectful to the API
                    if (hasMorePages) {
                        Thread.sleep(configProperties.getRequestDelay());
                    }
                } else {
                    log.warn("Received null or empty response for page {}", currentPage);
                    hasMorePages = false;
                }
            }

            saveSetsToDatabase(allSets);
            log.info("Successfully fetched and saved {} sets total", allSets.size());
        } catch (Exception e) {
            log.error("Error fetching sets from Pokémon TCG API", e);
            throw new RuntimeException("Failed to fetch sets from Pokémon TCG API", e);
        }
    }

    /**
     * Fetches a specific page of sets from the API with authentication
     */
    private PokemonTCGSetResponse fetchSetsPage(int page, int pageSize) {
        try {
            log.debug("Making authenticated WebClient request to {}{} with page={}, pageSize={}", 
                     configProperties.getBaseUrl(), SETS_ENDPOINT, page, pageSize);

            return webClient
                    .get()
                    .uri(uriBuilder -> uriBuilder
                            .path(SETS_ENDPOINT)
                            .queryParam("page", page)
                            .queryParam("pageSize", pageSize)
                            .queryParam("orderBy", "releaseDate")
                            .build())
                    .retrieve()
                    .bodyToMono(PokemonTCGSetResponse.class)
                    .timeout(Duration.ofMillis(configProperties.getReadTimeout()))
                    .block(); // Convert to synchronous call

        } catch (WebClientResponseException e) {
            log.error("HTTP error fetching sets page {}: Status={}, Body={}", 
                     page, e.getStatusCode(), e.getResponseBodyAsString());
            
            // Check for authentication issues
            if (e.getStatusCode().value() == 401) {
                log.error("Authentication failed! Check your Pokemon TCG API key.");
            } else if (e.getStatusCode().value() == 429) {
                log.error("Rate limit exceeded! Consider adding delays between requests.");
            }
            
            throw new RuntimeException("HTTP error fetching sets: " + e.getStatusCode(), e);
        } catch (Exception e) {
            log.error("Unexpected error fetching sets page {}", page, e);
            throw new RuntimeException("Failed to fetch sets from API", e);
        }
    }

    /**
     * Converts Pokémon TCG API DTOs to CardSet entities
     */
    private List<CardSet> convertDtosToEntities(List<PokemonTCGSetDTO> dtos) {
        List<CardSet> cardSets = new ArrayList<>();

        for (PokemonTCGSetDTO dto : dtos) {
            try {
                CardSet cardSet = CardSet.builder()
                        .id(dto.getId())
                        .name(dto.getName())
                        .series(dto.getSeries())
                        .language(Language.ENGLISH) // Default to English, can be extended later
                        .symbolUrl(dto.getImages() != null ? dto.getImages().getSymbol() : null)
                        .logoUrl(dto.getImages() != null ? dto.getImages().getLogo() : null)
                        .totalCards(dto.getTotal() != null ? dto.getTotal() : dto.getPrintedTotal())
                        .releaseDate(parseReleaseDate(dto.getReleaseDate()))
                        .build();
                
                cardSets.add(cardSet);
                log.debug("Converted set: {} ({}) - {} cards", 
                         cardSet.getName(), cardSet.getId(), cardSet.getTotalCards());
            } catch (Exception e) {
                log.warn("Failed to convert set DTO to entity: {} - {}", dto.getId(), e.getMessage());
            }
        }

        return cardSets;
    }

    /**
     * Saves sets to database, handling duplicates gracefully
     */
    private void saveSetsToDatabase(List<CardSet> sets) {
        log.info("Saving {} sets to database", sets.size());
        
        int savedCount = 0;
        int skippedCount = 0;

        for (CardSet set : sets) {
            try {
                // Check if set already exists
                if (cardSetRepository.existsById(set.getId())) {
                    log.debug("Set {} already exists, skipping", set.getId());
                    skippedCount++;
                } else {
                    cardSetRepository.save(set);
                    savedCount++;
                    log.debug("Saved set: {} ({}) - {} cards", 
                             set.getName(), set.getId(), set.getTotalCards());
                }
            } catch (Exception e) {
                log.error("Failed to save set {} ({}): {}", set.getId(), set.getName(), e.getMessage());
                // Continue with other sets
            }
        }

        log.info("Database save complete: {} new sets saved, {} existing sets skipped", 
                savedCount, skippedCount);
    }

    /**
     * Parses the release date from the API format (YYYY/MM/DD) to LocalDate
     */
    private LocalDate parseReleaseDate(String dateString) {
        if (dateString == null || dateString.trim().isEmpty()) {
            log.warn("Release date is null or empty, using current date");
            return LocalDate.now();
        }

        try {
            return LocalDate.parse(dateString, DATE_FORMATTER);
        } catch (Exception e) {
            log.warn("Failed to parse release date '{}', using current date", dateString);
            return LocalDate.now();
        }
    }
}
