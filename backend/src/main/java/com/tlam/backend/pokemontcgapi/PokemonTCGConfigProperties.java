package com.tlam.backend.pokemontcgapi;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

@Data
@Component
@ConfigurationProperties(prefix = "pokemon-tcg")
public class PokemonTCGConfigProperties {
    private String apiKey;
    private String baseUrl = "https://api.pokemontcg.io/v2/";
    private int connectTimeout = 30000;
    private int readTimeout = 30000;
    private int maxPageSize = 250;
    private long requestDelay = 100;
}
