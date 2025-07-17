package com.tlam.backend.pokemontcgapi;

import java.util.List;

import lombok.Data;

@Data
public class PokemonTCGCardDTO {
    private String id;
    private String name;
    private String supertype;
    private List<String> subtypes;
    private String level;
    private String hp;
    private List<String> types;
    private String evolvesFrom;
    private List<String> evolvesTo;
    private List<String> rules;
    private PokemonTCGAncientTrait ancientTrait;
    private List<PokemonTCGAbility> abilities;
    private List<PokemonTCGAttack> attacks;
    private List<PokemonTCGWeakness> weaknesses;
    private List<PokemonTCGResistance> resistances;
    private List<String> retreatCost;
    private Integer convertedRetreatCost;
    private PokemonTCGSetDTO set;
    private String number;
    private String artist;
    private String rarity;
    private String flavorText;
    private List<Integer> nationalPokedexNumbers;
    private PokemonTCGLegalities legalities;
    private String regulationMark;
    private PokemonTCGCardImages images;
    private PokemonTCGTcgPlayer tcgplayer;
    private PokemonTCGCardMarket cardmarket;
}

// Supporting DTOs for nested objects

@Data
class PokemonTCGAncientTrait {
    private String name;
    private String text;
}

@Data
class PokemonTCGAbility {
    private String name;
    private String text;
    private String type;
}

@Data
class PokemonTCGAttack {
    private List<String> cost;
    private String name;
    private String text;
    private String damage;
    private Integer convertedEnergyCost;
}

@Data
class PokemonTCGWeakness {
    private String type;
    private String value;
}

@Data
class PokemonTCGResistance {
    private String type;
    private String value;
}

@Data
class PokemonTCGLegalities {
    private String standard;
    private String expanded;
    private String unlimited;
}

@Data
class PokemonTCGCardImages {
    private String small;
    private String large;
}

@Data
class PokemonTCGTcgPlayer {
    private String url;
    private String updatedAt;
    private PokemonTCGTcgPlayerPrices prices;
}

@Data
class PokemonTCGTcgPlayerPrices {
    private PokemonTCGPriceDetail normal;
    private PokemonTCGPriceDetail holofoil;
    private PokemonTCGPriceDetail reverseHolofoil;
    private PokemonTCGPriceDetail firstEditionHolofoil;
    private PokemonTCGPriceDetail firstEditionNormal;
}

@Data
class PokemonTCGPriceDetail {
    private Double low;
    private Double mid;
    private Double high;
    private Double market;
    private Double directLow;
}

@Data
class PokemonTCGCardMarket {
    private String url;
    private String updatedAt;
    private PokemonTCGCardMarketPrices prices;
}

@Data
class PokemonTCGCardMarketPrices {
    private Double averageSellPrice;
    private Double lowPrice;
    private Double trendPrice;
    private Double germanProLow;
    private Double suggestedPrice;
    private Double reverseHoloSell;
    private Double reverseHoloLow;
    private Double reverseHoloTrend;
    private Double lowPriceExPlus;
    private Double avg1;
    private Double avg7;
    private Double avg30;
    private Double reverseHoloAvg1;
    private Double reverseHoloAvg7;
    private Double reverseHoloAvg30;
}
