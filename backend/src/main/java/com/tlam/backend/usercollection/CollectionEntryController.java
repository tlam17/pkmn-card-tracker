package com.tlam.backend.usercollection;

import java.util.List;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tlam.backend.card.Card;
import com.tlam.backend.card.CardDTO;
import com.tlam.backend.card.CardRepository;
import com.tlam.backend.user.UserRepository;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
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
    private final UserRepository userRepository;

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

    @GetMapping("/user/{userId}")
    @Operation(summary = "Get all entries in a user's collection", description = "Retrieves all collection entries for a specific user")
    @ApiResponses( value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved collection entries"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    public ResponseEntity<List<CollectionEntryDTO>> getUserCollection(
        @Parameter(
            description = "ID of the user whose collection is to be retrieved", 
            example = "1",
            required = true
        )
        @PathVariable Long userId
    ) {
        log.info("Fetching collection entries for user ID: {}", userId);

        // Check if user exists
        if (!userRepository.existsById(userId)) {
            log.warn("User with ID {} does not exist", userId);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        // Fetch collection entries
        List<CollectionEntry> entries = collectionEntryRepository.findByUserId(userId);

        // Convert to DTOs
        List<CollectionEntryDTO> entryDTOs = entries.stream()
                .map(this::convertToDTO)
                .toList();
        
        log.info("Retrieved {} collection entries for user ID: {}", entryDTOs.size(), userId);
        return ResponseEntity.ok(entryDTOs);
    }

    private CollectionEntryDTO convertToDTO(CollectionEntry entry) {
        // Fetch card associated with the collection entry
        Card card = cardRepository.findById(entry.getCardId())
        .orElseThrow(() -> {
            log.error("Card with ID {} not found for collection entry {}", 
                entry.getCardId(), entry.getId());
            return new RuntimeException("Card not found: " + entry.getCardId());
        });

        CardDTO cardDTO = CardDTO.builder()
                .id(card.getId())
                .name(card.getName())
                .number(card.getNumber())
                .rarity(card.getRarity())
                .smallImageUrl(card.getSmallImageUrl())
                .largeImageUrl(card.getLargeImageUrl())
                .build();
        
        return CollectionEntryDTO.builder()
                .id(entry.getId())
                .userId(entry.getUserId())
                .quantity(entry.getQuantity())
                .acquiredDate(entry.getAcquiredDate())
                .card(cardDTO)
                .build();
    }

    @DeleteMapping("/delete/{entryId}")
    @Operation(summary = "Delete a collection entry", description = "Deletes a specific collection entry by its ID" )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Collection entry successfully deleted"),
        @ApiResponse(responseCode = "404", description = "Collection entry not found")
    })
    public ResponseEntity<Void> removeFromCollection(
        @Parameter(
            description = "ID of the collection entry to be deleted", 
            example = "1",
            required = true
        )
        @PathVariable Long entryId
    ) {
        log.info("Attempting to delete collection entry with ID: {}", entryId);

        Optional<CollectionEntry> entry = collectionEntryRepository.findById(entryId);

        if (entry.isPresent()) {
            collectionEntryRepository.deleteById(entryId);
            log.info("Successfully deleted collection entry with ID: {}", entryId);
            return ResponseEntity.noContent().build();
        } else {
            log.warn("Collection entry with ID {} not found", entryId);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }
}
