package com.tlam.backend.pokemontcgapi;

import lombok.Data;

@Data
public class PokemonTCGSetDTO {
    private String id;
    private String name;
    private String series;
    private Integer printedTotal;
    private Integer total;
    private PokemonTCGSetLegalities legalities;
    private String ptcgoCode;
    private String releaseDate;
    private String updatedAt;
    private PokemonTCGSetImages images;
}
