package com.tlam.backend.pokemontcgapi;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tlam.backend.auth.SuccessResponse;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * Enhanced controller for manual data seeding operations
 * Supports both API-based seeding and JSON file-based seeding
 * This should be used carefully in development/staging environments
 * Consider removing or securing this endpoint in production
 */
@Slf4j
@RestController
@RequestMapping("/api/admin/seed")
@RequiredArgsConstructor
@Tag(name = "Data Seeding", description = "Manual data seeding operations (Admin only)")
public class DataSeedingController {

    private final PokemonTCGService pokemonTCGService;
    private final JsonFileSeederService jsonFileSeederService;

    // ================= API-Based Seeding =================

    @Operation(
        summary = "Seed card sets from Pokémon TCG API", 
        description = "Fetches all sets from the Pokémon TCG API and saves them to the database. This operation may take several minutes to complete."
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Sets seeded successfully",
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = SuccessResponse.class)
            )
        ),
        @ApiResponse(
            responseCode = "500",
            description = "Error occurred during seeding",
            content = @Content(mediaType = "application/json")
        )
    })
    @PostMapping("/api/sets")
    public ResponseEntity<SuccessResponse> seedCardSetsFromAPI() {
        try {
            log.info("Starting manual card sets seeding from API");
            
            // This operation may take several minutes
            pokemonTCGService.fetchAndSaveAllSets();
            
            SuccessResponse response = new SuccessResponse(
                "Card sets have been successfully seeded from the Pokémon TCG API"
            );
            
            log.info("Manual card sets seeding from API completed successfully");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error during manual card sets seeding from API", e);
            throw new RuntimeException("Failed to seed card sets from API: " + e.getMessage());
        }
    }

    @Operation(
        summary = "Seed cards from Pokémon TCG API", 
        description = "Fetches all cards from the Pokémon TCG API and saves them to the database. This operation may take several minutes to complete."
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Cards seeded successfully",
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = SuccessResponse.class)
            )
        ),
        @ApiResponse(
            responseCode = "500",
            description = "Error occurred during seeding",
            content = @Content(mediaType = "application/json")
        )
    })
    @PostMapping("/api/cards")
    public ResponseEntity<SuccessResponse> seedCardsFromAPI() {
        try {
            log.info("Starting manual cards seeding from API");

            // This operation may take several minutes
            pokemonTCGService.fetchAndSaveAllCards();

            SuccessResponse response = new SuccessResponse(
                "Cards have been successfully seeded from the Pokémon TCG API"
            );

            log.info("Manual card seeding from API completed successfully");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("Error during manual card seeding from API", e);
            throw new RuntimeException("Failed to seed cards from API: " + e.getMessage());
        }
    }

    // ================= JSON File-Based Seeding =================

    @Operation(
        summary = "Seed all data from local JSON files", 
        description = "Seeds both sets and cards from local JSON files downloaded from the Pokémon TCG Data repository. " +
                     "This is useful when the API is down. JSON files should be placed in resources/pokemon-tcg-data/"
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Data seeded successfully from JSON files",
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = SuccessResponse.class)
            )
        ),
        @ApiResponse(
            responseCode = "500",
            description = "Error occurred during JSON file seeding",
            content = @Content(mediaType = "application/json")
        )
    })
    @PostMapping("/json/all")
    public ResponseEntity<SuccessResponse> seedAllFromJsonFiles() {
        try {
            log.info("Starting complete database seeding from JSON files");
            
            // This operation may take several minutes depending on file size
            jsonFileSeederService.seedFromJsonFiles();
            
            SuccessResponse response = new SuccessResponse(
                "All data (sets and cards) have been successfully seeded from local JSON files"
            );
            
            log.info("Complete JSON file seeding completed successfully");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error during complete JSON file seeding", e);
            throw new RuntimeException("Failed to seed from JSON files: " + e.getMessage());
        }
    }

    @Operation(
        summary = "Seed card sets from local JSON files", 
        description = "Seeds only card sets from local JSON files. Sets JSON files should be placed in resources/pokemon-tcg-data/sets/"
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Sets seeded successfully from JSON files",
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = SuccessResponse.class)
            )
        ),
        @ApiResponse(
            responseCode = "500",
            description = "Error occurred during JSON file seeding",
            content = @Content(mediaType = "application/json")
        )
    })
    @PostMapping("/json/sets")
    public ResponseEntity<SuccessResponse> seedSetsFromJsonFiles() {
        try {
            log.info("Starting card sets seeding from JSON files");
            
            jsonFileSeederService.seedSetsFromJsonFiles();
            
            SuccessResponse response = new SuccessResponse(
                "Card sets have been successfully seeded from local JSON files"
            );
            
            log.info("Card sets JSON file seeding completed successfully");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error during card sets JSON file seeding", e);
            throw new RuntimeException("Failed to seed sets from JSON files: " + e.getMessage());
        }
    }

    @Operation(
        summary = "Seed cards from local JSON files", 
        description = "Seeds only cards from local JSON files. Cards JSON files should be placed in resources/pokemon-tcg-data/cards/"
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Cards seeded successfully from JSON files",
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = SuccessResponse.class)
            )
        ),
        @ApiResponse(
            responseCode = "500",
            description = "Error occurred during JSON file seeding",
            content = @Content(mediaType = "application/json")
        )
    })
    @PostMapping("/json/cards")
    public ResponseEntity<SuccessResponse> seedCardsFromJsonFiles() {
        try {
            log.info("Starting cards seeding from JSON files");
            
            jsonFileSeederService.seedCardsFromJsonFiles();
            
            SuccessResponse response = new SuccessResponse(
                "Cards have been successfully seeded from local JSON files"
            );
            
            log.info("Cards JSON file seeding completed successfully");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error during cards JSON file seeding", e);
            throw new RuntimeException("Failed to seed cards from JSON files: " + e.getMessage());
        }
    }
}