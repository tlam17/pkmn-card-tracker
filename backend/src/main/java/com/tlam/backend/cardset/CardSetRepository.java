package com.tlam.backend.cardset;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface CardSetRepository extends JpaRepository<CardSet, String> {
    List<CardSet> findBySeriesOrderByReleaseDateDesc(String series);
}
