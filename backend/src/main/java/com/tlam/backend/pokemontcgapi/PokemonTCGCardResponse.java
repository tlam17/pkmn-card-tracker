package com.tlam.backend.pokemontcgapi;

import java.util.List;

import lombok.Data;

@Data
public class PokemonTCGCardResponse {
    private List<PokemonTCGCardDTO> data;
    private Integer page;
    private Integer pageSize;
    private Integer count;
    private Integer totalCount;
}
