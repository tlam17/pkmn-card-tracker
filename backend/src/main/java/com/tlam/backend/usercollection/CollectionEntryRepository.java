package com.tlam.backend.usercollection;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface CollectionEntryRepository extends JpaRepository<CollectionEntry, Long> {
    // Find all collection entries for a specific user
    List<CollectionEntry> findByUserId(Long userId);

    // Find a specific collection entry by userId and cardId
    Optional<CollectionEntry> findByUserIdAndCardId(Long userId, String cardId);

    // Find all collections entries for a specific set
    @Query("SELECT ce FROM CollectionEntry ce WHERE ce.userId = :userId AND ce.cardId LIKE CONCAT(:setId, '-%')")
    List<CollectionEntry> findByUserIdAndCardSetId(@Param("userId") Long userId, @Param("setId") String setId);

    // Delete a specific collection entry by userId and cardId
    void deleteByUserIdAndCardId(Long userId, String cardId);

    // Count unique cards in a user's collection
    @Query("SELECT COUNT(DISTINCT ce.cardId) FROM CollectionEntry ce WHERE ce.userId = :userId")
    Long countUniqueCardsByUserId(@Param("userId") Long userId);

    // Count total cards in a user's collection
    @Query("SELECT COALESCE(SUM(ce.quantity), 0) FROM CollectionEntry ce WHERE ce.userId = :userId")
    Long countTotalCardsByUserId(@Param("userId") Long userId);

    // Count unique cards in a user's collection for a specific set
    @Query("SELECT COUNT(DISTINCT ce.cardId) FROM CollectionEntry ce WHERE ce.userId = :userId AND ce.cardId LIKE CONCAT(:setId, '-%')")
    Long countUniqueCardsByUserIdAndSetId(@Param("userId") Long userId, @Param("setId") String setId);
}
