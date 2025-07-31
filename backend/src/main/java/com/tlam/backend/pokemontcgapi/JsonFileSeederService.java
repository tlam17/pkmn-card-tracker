package com.tlam.backend.pokemontcgapi;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Stream;

import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tlam.backend.card.Card;
import com.tlam.backend.card.CardRepository;
import com.tlam.backend.cardset.CardSet;
import com.tlam.backend.cardset.Language;
import com.tlam.backend.cardset.CardSetRepository;

import lombok.extern.slf4j.Slf4j;

/**
 * Service for seeding the database from local JSON files
 * This is useful when the Pokémon TCG API is down or for initial data loading
 * 
 * Download the JSON files from: https://github.com/PokemonTCG/pokemon-tcg-data
 * Place them in the resources/pokemon-tcg-data directory
 */
@Slf4j
@Service
public class JsonFileSeederService {

    private final CardSetRepository cardSetRepository;
    private final CardRepository cardRepository;
    private final ObjectMapper objectMapper;

    // Date formatter for parsing API date format (YYYY/MM/DD)
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy/MM/dd");

    public JsonFileSeederService(CardSetRepository cardSetRepository, CardRepository cardRepository) {
        this.cardSetRepository = cardSetRepository;
        this.cardRepository = cardRepository;
        this.objectMapper = new ObjectMapper();
    }

    /**
     * Seeds the database from local JSON files
     * Expected directory structure:
     * resources/pokemon-tcg-data/
     *   ├── sets/
     *   │   ├── en/
     *   │   │   ├── base1.json
     *   │   │   ├── base2.json
     *   │   │   └── ...
     *   └── cards/
     *       └── en/
     *           ├── base1.json (contains array of all cards for base1 set)
     *           ├── base2.json (contains array of all cards for base2 set)
     *           └── ...
     */
    public void seedFromJsonFiles() {
        log.info("Starting database seeding from local JSON files");

        try {
            // First seed sets, then cards
            seedSetsFromJsonFiles();
            seedCardsFromJsonFiles();
            
            log.info("Successfully completed database seeding from JSON files");
        } catch (Exception e) {
            log.error("Error during JSON file seeding", e);
            throw new RuntimeException("Failed to seed database from JSON files", e);
        }
    }

    /**
     * Seeds only sets from JSON files
     */
    public void seedSetsFromJsonFiles() {
        log.info("Seeding sets from JSON files");

        try {
            // Get the sets directory path (English sets)
            Path setsPath = getResourcePath("pokemon-tcg-data/sets/en");
            
            if (!Files.exists(setsPath)) {
                log.error("Sets directory not found at: {}", setsPath);
                throw new RuntimeException("Sets directory not found. Please download and place JSON files in resources/pokemon-tcg-data/sets/en/");
            }

            List<CardSet> allSets = new ArrayList<>();

            // Process each set JSON file
            try (Stream<Path> files = Files.list(setsPath)) {
                files.filter(path -> path.toString().endsWith(".json"))
                     .forEach(setFile -> {
                         try {
                             CardSet cardSet = processSetFile(setFile);
                             if (cardSet != null) {
                                 allSets.add(cardSet);
                             }
                         } catch (Exception e) {
                             log.error("Error processing set file: {}", setFile, e);
                         }
                     });
            }

            // Save all sets to database
            saveSetsToDatabase(allSets);
            
        } catch (IOException e) {
            log.error("Error reading sets directory", e);
            throw new RuntimeException("Failed to read sets directory", e);
        }
    }

    /**
     * Seeds only cards from JSON files
     */
    public void seedCardsFromJsonFiles() {
        log.info("Seeding cards from JSON files");

        try {
            // Get the cards directory path (English cards)
            Path cardsPath = getResourcePath("pokemon-tcg-data/cards/en");
            
            if (!Files.exists(cardsPath)) {
                log.error("Cards directory not found at: {}", cardsPath);
                throw new RuntimeException("Cards directory not found. Please download and place JSON files in resources/pokemon-tcg-data/cards/en/");
            }

            List<Card> allCards = new ArrayList<>();

            // Process each set JSON file under cards/en/
            try (Stream<Path> cardFiles = Files.list(cardsPath)) {
                cardFiles.filter(path -> path.toString().endsWith(".json"))
                         .forEach(cardFile -> {
                             try {
                                 List<Card> setCards = processSetCardsFile(cardFile);
                                 allCards.addAll(setCards);
                             } catch (Exception e) {
                                 log.error("Error processing set cards file: {}", cardFile, e);
                             }
                         });
            }

            // Save all cards to database
            saveCardsToDatabase(allCards);
            
        } catch (IOException e) {
            log.error("Error reading cards directory", e);
            throw new RuntimeException("Failed to read cards directory", e);
        }
    }

    /**
     * Process a single set JSON file
     */
    private CardSet processSetFile(Path setFile) {
        try {
            log.debug("Processing set file: {}", setFile.getFileName());
            
            JsonNode setNode = objectMapper.readTree(setFile.toFile());
            
            return CardSet.builder()
                    .id(getStringValue(setNode, "id"))
                    .name(getStringValue(setNode, "name"))
                    .series(getStringValue(setNode, "series"))
                    .language(Language.ENGLISH) // Default to English, can be extended later
                    .symbolUrl(getImageValue(setNode, "symbol"))
                    .logoUrl(getImageValue(setNode, "logo"))
                    .printedTotal(getIntValue(setNode, "printedTotal"))
                    .totalCards(getIntValue(setNode, "total"))
                    .releaseDate(parseReleaseDate(getStringValue(setNode, "releaseDate")))
                    .build();
                    
        } catch (Exception e) {
            log.error("Error processing set file: {}", setFile, e);
            return null;
        }
    }

    /**
     * Process a single set JSON file containing all cards for that set
     */
    private List<Card> processSetCardsFile(Path setCardsFile) {
        List<Card> cards = new ArrayList<>();
        String fileName = setCardsFile.getFileName().toString();
        String setId = fileName.substring(0, fileName.lastIndexOf('.'));
        
        log.debug("Processing cards file for set: {} ({})", setId, fileName);

        try {
            // Read the JSON file as an array of card objects
            JsonNode cardsArray = objectMapper.readTree(setCardsFile.toFile());
            
            if (!cardsArray.isArray()) {
                log.warn("Expected JSON array in cards file: {}", setCardsFile);
                return cards;
            }

            // Process each card in the array
            for (JsonNode cardNode : cardsArray) {
                try {
                    Card card = processCardJson(cardNode);
                    if (card != null) {
                        cards.add(card);
                    }
                } catch (Exception e) {
                    log.error("Error processing individual card in file {}: {}", setCardsFile, e.getMessage());
                }
            }
        } catch (IOException e) {
            log.error("Error reading set cards file: {}", setCardsFile, e);
        }

        log.debug("Processed {} cards for set: {}", cards.size(), setId);
        return cards;
    }

    /**
     * Process a single card JSON node from the cards array
     */
    private Card processCardJson(JsonNode cardNode) {
        try {
            String cardId = getStringValue(cardNode, "id");
            String setId = null;
            
            // Extract set ID from the card ID (e.g., "base1-1" -> "base1")
            if (cardId != null && cardId.contains("-")) {
                setId = cardId.substring(0, cardId.lastIndexOf('-'));
            }
            
            // Fallback: try to get set ID from nested set object
            if (setId == null) {
                JsonNode setNode = cardNode.get("set");
                if (setNode != null) {
                    setId = getStringValue(setNode, "id");
                }
            }
            
            return Card.builder()
                    .id(cardId)
                    .name(getStringValue(cardNode, "name"))
                    .number(getStringValue(cardNode, "number"))
                    .setId(setId)
                    .rarity(getStringValue(cardNode, "rarity"))
                    .smallImageUrl(getImageValue(cardNode, "small"))
                    .largeImageUrl(getImageValue(cardNode, "large"))
                    .build();
                    
        } catch (Exception e) {
            log.error("Error processing card JSON: {}", e.getMessage());
            return null;
        }
    }

    /**
     * Helper method to get string values from JSON nodes
     */
    private String getStringValue(JsonNode node, String fieldName) {
        JsonNode fieldNode = node.get(fieldName);
        return fieldNode != null && !fieldNode.isNull() ? fieldNode.asText() : null;
    }

    /**
     * Helper method to get integer values from JSON nodes
     */
    private Integer getIntValue(JsonNode node, String fieldName) {
        JsonNode fieldNode = node.get(fieldName);
        return fieldNode != null && !fieldNode.isNull() ? fieldNode.asInt() : null;
    }

    /**
     * Helper method to get image URLs from JSON nodes
     * Handles both direct string fields and nested image objects
     */
    private String getImageValue(JsonNode node, String fieldName) {
        // First try direct field
        JsonNode fieldNode = node.get(fieldName);
        if (fieldNode != null && !fieldNode.isNull()) {
            return fieldNode.asText();
        }
        
        // Then try nested images object
        JsonNode imagesNode = node.get("images");
        if (imagesNode != null) {
            JsonNode imageFieldNode = imagesNode.get(fieldName);
            if (imageFieldNode != null && !imageFieldNode.isNull()) {
                return imageFieldNode.asText();
            }
        }
        
        return null;
    }

    /**
     * Get resource path for JSON files
     */
    private Path getResourcePath(String relativePath) {
        try {
            // Try to get from resources folder
            var resource = this.getClass().getClassLoader().getResource(relativePath);
            if (resource != null) {
                return Paths.get(resource.toURI());
            }
            
            // Fallback to current directory
            return Paths.get("src/main/resources/" + relativePath);
        } catch (Exception e) {
            // Fallback to current directory
            return Paths.get("src/main/resources/" + relativePath);
        }
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

    /**
     * Saves sets to database, handling duplicates gracefully
     */
    private void saveSetsToDatabase(List<CardSet> sets) {
        log.info("Saving {} sets to database from JSON files", sets.size());
        
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
     * Saves cards to database, handling duplicates gracefully
     */
    private void saveCardsToDatabase(List<Card> cards) {
        log.info("Saving {} cards to database from JSON files", cards.size());
        
        int savedCount = 0;
        int skippedCount = 0;

        for (Card card : cards) {
            try {
                // Check if card already exists
                if (cardRepository.existsById(card.getId())) {
                    log.debug("Card {} already exists, skipping", card.getId());
                    skippedCount++;
                } else {
                    cardRepository.save(card);
                    savedCount++;
                    log.debug("Saved card: {} ({}) - Set: {}", 
                             card.getName(), card.getId(), card.getSetId());
                }
            } catch (Exception e) {
                log.error("Failed to save card {} ({}): {}", card.getId(), card.getName(), e.getMessage());
                // Continue with other cards
            }
        }

        log.info("Database save complete: {} new cards saved, {} existing cards skipped", 
                savedCount, skippedCount);
    }
}