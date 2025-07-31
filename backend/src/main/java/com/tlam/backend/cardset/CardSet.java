package com.tlam.backend.cardset;

import java.time.LocalDate;
import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "card_sets")
public class CardSet {
    @Id
    @NotBlank
    private String id;

    @NotBlank
    @Column(nullable = false)
    private String name;

    @NotBlank
    @Column(nullable = false)
    private String series;

    @NotNull
    @Column(nullable = false)
    @Enumerated(value = EnumType.STRING)
    private Language language;

    @Column(name = "symbol_url")
    private String symbolUrl;

    @Column(name = "logo_url")
    private String logoUrl;

    @PositiveOrZero
    @Column(nullable = false, name = "printed_total")
    private Integer printedTotal;

    @NotNull
    @PositiveOrZero
    @Column(nullable = false, name = "total_cards")
    private Integer totalCards;

    @Column(nullable = false, name = "release_date")
    private LocalDate releaseDate;

    @CreationTimestamp
    @Column(updatable = false, name = "created_at")
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}