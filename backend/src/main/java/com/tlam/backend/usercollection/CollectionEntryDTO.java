package com.tlam.backend.usercollection;

import java.time.LocalDateTime;

import com.tlam.backend.card.CardDTO;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Data Transfer Object for CollectionEntry API responses
 * Contains only the fields needed by the frontend
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CollectionEntryDTO {
    private Long id;
    private Long userId;
    private Integer quantity;
    private LocalDateTime acquiredDate;
    private CardDTO card;
}
