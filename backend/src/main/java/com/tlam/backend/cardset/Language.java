package com.tlam.backend.cardset;

public enum Language {
    ENGLISH("EN"),
    JAPANESE("JP");

    private final String code;

    Language(String code) {
        this.code = code;
    }

    public String getCode() {
        return code;
    }

    public static Language fromCode(String code) {
        for (Language lang : values()) {
            if (lang.getCode().equalsIgnoreCase(code)) {
                return lang;
            }
        }
        throw new IllegalArgumentException("Unknown language code: " + code);
    }
}
