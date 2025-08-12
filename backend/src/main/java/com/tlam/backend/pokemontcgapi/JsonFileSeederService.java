package com.tlam.backend.pokemontcgapi;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Stream;

import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
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
     * Seeds only cards from JSON files using Spring's resource loading
     */
    public void seedCardsFromJsonFiles() {
        log.info("Seeding cards from JSON files");

        try {
            // Use Spring's resource loading for better JAR compatibility
            String cardsBasePath = "pokemon-tcg-data/cards/en";
            
            // Get all JSON files in the cards directory
            // Note: This approach requires you to have a way to list files
            // Since we can't easily list files in a JAR, we'll try a different approach
            
            // For now, let's try to load specific known set files
            // You might need to maintain a list of set IDs or use a different approach
            List<String> knownSetIds = getKnownSetIds();
            
            List<Card> allCards = new ArrayList<>();

            for (String setId : knownSetIds) {
                try {
                    String resourcePath = cardsBasePath + "/" + setId + ".json";
                    Resource resource = new ClassPathResource(resourcePath);
                    
                    if (resource.exists()) {
                        List<Card> setCards = processSetCardsResource(resource, setId);
                        allCards.addAll(setCards);
                        log.debug("Processed {} cards for set: {}", setCards.size(), setId);
                    } else {
                        log.debug("Card file not found for set: {} ({})", setId, resourcePath);
                    }
                } catch (Exception e) {
                    log.error("Error processing set cards for set: {}", setId, e);
                }
            }

            // Save all cards to database
            saveCardsToDatabase(allCards);
            
        } catch (Exception e) {
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
            
            JsonNode setNode;
            
            // Try to read as regular file first, then as resource
            try {
                setNode = objectMapper.readTree(setFile.toFile());
            } catch (UnsupportedOperationException e) {
                // If toFile() fails (JAR environment), try as resource
                String fileName = setFile.getFileName().toString();
                Resource resource = new ClassPathResource("pokemon-tcg-data/sets/en/" + fileName);
                try (InputStream inputStream = resource.getInputStream()) {
                    setNode = objectMapper.readTree(inputStream);
                }
            }
            
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
     * Process a single set JSON resource containing all cards for that set
     */
    private List<Card> processSetCardsResource(Resource resource, String setId) {
        List<Card> cards = new ArrayList<>();
        
        log.debug("Processing cards resource for set: {}", setId);

        try (InputStream inputStream = resource.getInputStream()) {
            // Read the JSON file as an array of card objects
            JsonNode cardsArray = objectMapper.readTree(inputStream);
            
            if (!cardsArray.isArray()) {
                log.warn("Expected JSON array in cards resource for set: {}", setId);
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
                    log.error("Error processing individual card in set {}: {}", setId, e.getMessage());
                }
            }
        } catch (IOException e) {
            log.error("Error reading set cards resource for set: {}", setId, e);
        }

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
     * Get a list of known set IDs
     */
    private List<String> getKnownSetIds() {
        return List.of(
            // Base sets
            "base1", "base2", "basep", "base3", "base4", "base5",
            // Gym sets
            "gym1", "gym2",
            // Neo sets
            "neo1", "neo2", "si1", "neo3", "neo4", "base6",
            // E-Card sets
            "ecard1", "bp", "ecard2", "ecard3",
            // EX sets
            "ex1", "ex2", "np", "ex3", "ex4", "ex5", "tk1b", "tk1a", "ex6", "pop1", "ex7", "ex8", "ex9", "ex10", "pop2", "ex11", "ex12", "tk2b", "tk2a", "pop3", "ex13", "ex14", "pop4", "ex15", "ex16", "pop5",
            // Diamond & Pearl sets
            "dpp", "dp1", "dp2", "pop6", "dp3", "dp4", "pop7", "dp5", "dp6", "pop8", "dp7",
            // Platinum sets
            "pl1", "pop9", "pl2", "pl3", "pl4", "ru1",
            // HeartGold & SoulSilver sets
            "hsp", "hgss1", "hgss2", "hgss3", "hgss4", "col1",
            // Black & White sets
            "bwp", "bw1", "mcd11", "bw2", "bw3", "bw4", "bw5", "mcd12", "bw6", "dv1", "bw7", "bw8", "bw9", "bw10", "bw11", "mcd14", "mcd15", "mcd16",
            // X & Y sets
            "xyp", "xy0", "xy1", "xy2", "xy3", "xy4", "xy5", "dc1", "xy6", "xy7", "xy8", "xy9", "g1", "xy10", "xy11", "xy12",
            // Sun & Moon sets
            "smp", "sm1", "sm2", "sm3", "sm35", "sm4", "mcd17", "sm5", "sm6", "sm7", "sm75", "mcd18", "sm8", "sm9", "det1", "sm10", "sm11", "sm115", "sma", "mcd19", "sm12",
            // Sword & Shield sets
            "swshp", "swsh1", "swsh2", "swsh3", "fut20", "swsh35", "swsh4", "mcd21", "swsh45sv", "swsh45", "swsh5", "swsh6", "swsh7", "cel25c", "cel25", "swsh8", "swsh9", "swsh9tg", "swsh10", "swsh10tg", "pgo", "mcd22", "swsh11", "swsh11tg", "swsh12", "swsh12tg",
            // Scarlet & Violet sets
            "svp", "swsh12pt5", "swsh12pt5gg", "sve", "sv1", "sv2", "sv3", "sv3pt5", "sv4", "sv4pt5", "sv5", "sv6", "sv6pt5", "sv7", "sv8", "sv8pt5", "sv9", "sv10", "zsv10pt5", "rsv10pt5"
        );
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