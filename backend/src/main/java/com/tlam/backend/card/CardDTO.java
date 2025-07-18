package com.tlam.backend.card;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Data Transfer Object for Card API responses
 * Contains only the fields needed by the frontend
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CardDTO {
    private String id;
    private String name;
    private String number;
    private String smallImageUrl;
    private String largeImageUrl;
}
