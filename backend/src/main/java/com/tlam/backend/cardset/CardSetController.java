package com.tlam.backend.cardset;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/*
 * Controller for managing card sets
 * This controller will handle requests related to card sets, such as fetching sets by series
 * and other related operations.
 */
@Slf4j
@RestController
@RequestMapping("/api/sets")
@RequiredArgsConstructor
@Tag(name = "Card Sets", description = "Operations related to Pokémon card sets")
public class CardSetController {

    private final CardSetRepository cardSetRepository;

    @Operation(
        summary = "Get card sets by series", 
        description = "Retrieves all card sets for a specific series, ordered by release date (newest first). " +
                     "Series names are case-sensitive and should match exactly (e.g., 'Sword & Shield', 'Scarlet & Violet')."
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Card sets retrieved successfully",
            content = @Content(
                mediaType = "application/json",
                array = @ArraySchema(schema = @Schema(implementation = CardSetDTO.class))
            )
        ),
        @ApiResponse(
            responseCode = "400",
            description = "Invalid series name provided",
            content = @Content(mediaType = "application/json")
        ),
        @ApiResponse(
            responseCode = "404",
            description = "No sets found for the specified series",
            content = @Content(mediaType = "application/json")
        )
    })
    @GetMapping("/series/{series}")
    public ResponseEntity<List<CardSetDTO>> getSetsBySeries(
        @Parameter(
            description = "Name of the series to retrieve sets for", 
            example = "Scarlet & Violet",
            required = true
        )
        @PathVariable String series
    ) {
        try {
            log.info("Fetching card sets for series: {}", series);

            // Fetch sets from repository
            List<CardSet> sets = cardSetRepository.findBySeriesOrderByReleaseDateDesc(series);

            if (sets.isEmpty()) {
                log.info("No card sets found for series: {}", series);
                return ResponseEntity.noContent().build();
            }

            // Convert entities to DTOs
            List<CardSetDTO> cardSetDTOs = sets.stream()
                .map(this::convertToDTO)
                .toList();
            
            log.info("Successfully retrieved {} card sets for series: {}", cardSetDTOs.size(), series);
            return ResponseEntity.ok(cardSetDTOs);
        } catch (Exception e) {
            log.error("Error retrieving card sets for series: {}", series, e);
            throw new RuntimeException("Failed to retrieve card sets for series: " + series);
        }
    }

    private CardSetDTO convertToDTO(CardSet cardSet) {
        return CardSetDTO.builder()
                .id(cardSet.getId())
                .name(cardSet.getName())
                .series(cardSet.getSeries())
                .language(cardSet.getLanguage().name())
                .symbolUrl(cardSet.getSymbolUrl())
                .logoUrl(cardSet.getLogoUrl())
                .totalCards(cardSet.getTotalCards())
                .releaseDate(cardSet.getReleaseDate())
                .build();
    }
}
