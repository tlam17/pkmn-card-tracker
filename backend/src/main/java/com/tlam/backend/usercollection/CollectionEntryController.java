package com.tlam.backend.usercollection;

import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tlam.backend.card.CardRepository;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/*
 * Controller for managing user collection entries
 * This controller will handle requests related to user collection entries, such as adding,
 * updating, deleting, and fetching collection entries.
 */
@Slf4j
@RestController
@RequestMapping("/api/collection")
@RequiredArgsConstructor
@Tag(name = "User Collection", description = "Operations related to user's Pokémon card collection")
public class CollectionEntryController {

    private final CollectionEntryRepository collectionEntryRepository;
    private final CardRepository cardRepository;

    @PostMapping("/add")
    @Operation(summary = "Add a card to user's collection", description = "Adds a card to the user's collection or updates the quantity if it already exists")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Card successfully added to collection"),
        @ApiResponse(responseCode = "200", description = "Card quantity updated in collection"),
        @ApiResponse(responseCode = "400", description = "Invalid request data"),
        @ApiResponse(responseCode = "404", description = "Card not found")
    })
    public ResponseEntity<CollectionEntry> addToCollection(@Valid @RequestBody AddEntryRequest request) {
        log.info("Adding card {} to user {}'s collection with quantity {}", 
                request.getCardId(), request.getUserId(), request.getQuantity());

        if (!cardRepository.existsById(request.getCardId())) {
            log.warn("Card with ID {} does not exist", request.getCardId());
            return ResponseEntity.notFound().build();
        }

        Optional<CollectionEntry> existingEntry = collectionEntryRepository
                .findByUserIdAndCardId(request.getUserId(), request.getCardId());

        if (existingEntry.isPresent()) {
            CollectionEntry entry = existingEntry.get();
            entry.setQuantity(request.getQuantity());
            CollectionEntry updatedEntry = collectionEntryRepository.save(entry);
            log.info("Updated existing collection entry with new quantity: {}", updatedEntry.getQuantity());
            return ResponseEntity.ok(updatedEntry);
        } else {
            CollectionEntry newEntry = CollectionEntry.builder()
                    .userId(request.getUserId())
                    .cardId(request.getCardId())
                    .quantity(request.getQuantity())
                    .build();
            CollectionEntry savedEntry = collectionEntryRepository.save(newEntry);
            log.info("Created new collection entry with ID: {}", savedEntry.getId());
            return ResponseEntity.status(HttpStatus.CREATED).body(savedEntry);
        }
    }
}
