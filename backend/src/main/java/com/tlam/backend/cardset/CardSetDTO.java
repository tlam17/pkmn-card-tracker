package com.tlam.backend.cardset;

import java.time.LocalDate;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Data Transfer Object for CardSet API responses
 * Contains only the fields needed by the frontend
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CardSetDTO {
    private String id;
    private String name;
    private String series;
    private String language;
    private String symbolUrl;
    private String logoUrl;
    private Integer printedTotal;
    private Integer totalCards;
    private LocalDate releaseDate;
}
