package com.tlam.backend.card;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/*
 * Controller for managing cards
 * This controller will handle requests related to cards, such as fetching cards by sets
 * and other related operations.
 */
@Slf4j
@RestController
@RequestMapping("/api/cards")
@RequiredArgsConstructor
@Tag(name = "Cards", description = "Operations related to Pokémon cards")
public class CardController {
    private final CardRepository cardRepository;

    @GetMapping("/set/{setID}")
    public ResponseEntity<List<CardDTO>> getCardsBySet(
        @Parameter(
            description = "ID of the set to retrieve cards for", 
            example = "sv1",
            required = true
        )
        @PathVariable String setID
    ) {
        try {
            log.info("Fetching cards for set with ID: {}", setID);

            // Fetch cards from repository
            List<Card> cards = cardRepository.findBySetIdOrderByNumberAsc(setID);

            if (cards.isEmpty()) {
                log.info("No cards found for set with ID: {}", setID);
                return ResponseEntity.noContent().build();
            }

            // Convert entities to DTOs
            List<CardDTO> cardDTOs = cards.stream()
                .map(this::convertToDTO)
                .toList();

            log.info("Successfully retrieved {} cards for set with ID: {}", cardDTOs.size(), setID);
            return ResponseEntity.ok(cardDTOs);
        } catch (Exception e) {
            log.error("Error retrieving cards for set with ID: {}", setID, e);
            throw new RuntimeException("Failed to retrieve cards for set with ID: " + setID);
        }
    }

    private CardDTO convertToDTO(Card card) {
        return CardDTO.builder()
                .id(card.getId())
                .name(card.getName())
                .number(card.getNumber())
                .smallImageUrl(card.getSmallImageUrl())
                .largeImageUrl(card.getLargeImageUrl())
                .build();
    }
}
