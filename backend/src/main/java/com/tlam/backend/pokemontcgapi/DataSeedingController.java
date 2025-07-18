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
 * Controller for manual data seeding operations
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
    @PostMapping("/sets")
    public ResponseEntity<SuccessResponse> seedCardSets() {
        try {
            log.info("Starting manual card sets seeding via API endpoint");
            
            // This operation may take several minutes
            pokemonTCGService.fetchAndSaveAllSets();
            
            SuccessResponse response = new SuccessResponse(
                "Card sets have been successfully seeded from the Pokémon TCG API"
            );
            
            log.info("Manual card sets seeding completed successfully");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error during manual card sets seeding", e);
            throw new RuntimeException("Failed to seed card sets: " + e.getMessage());
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
    @PostMapping("/cards")
    public ResponseEntity<SuccessResponse> seedCards() {
        try {
            log.info("Starting manual cards seeding via API endpoint");

            // This operation may take several minutes
            pokemonTCGService.fetchAndSaveAllCards();

            SuccessResponse response = new SuccessResponse(
                "Cards have been successfully seeded from the Pokémon TCG API"
            );

            log.info("Manual card seeding completed successfully");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("Error during manual card seeding", e);
            throw new RuntimeException("Failed to seed cards: " + e.getMessage());
        }
    }
}