package com.tlam.backend.cardset;

import java.util.List;

import lombok.Data;

@Data
public class PokemonTCGSetResponse {
    private List<PokemonTCGSetDTO> data;
    private Integer page;
    private Integer pageSize;
    private Integer count;
    private Integer totalCount;
}
