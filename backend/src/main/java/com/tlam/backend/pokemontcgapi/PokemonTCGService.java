package com.tlam.backend.pokemontcgapi;

import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * Service for interacting with the Pokémon TCG API
 * This service handles fetching set data from the external API and saving it to our database
 * 
 * Authentication is handled via X-Api-Key header for higher rate limits
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PokemonTCGService {

    private final PokemonTCGConfigProperties configProperties;
    private final WebClient webClient;
}
