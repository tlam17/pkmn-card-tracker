package com.tlam.backend.passwordreset;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

public interface PasswordResetCodeRepository extends JpaRepository<PasswordResetCode, Long> {
    Optional<PasswordResetCode> findByEmailAndCodeAndIsUsedFalseAndExpiresAtAfter(String email, String code, LocalDateTime now);

    @Modifying
    @Transactional
    @Query("UPDATE PasswordResetCode p SET p.isUsed = true WHERE p.email = :email")
    void markAllCodesAsUsedForEmail(@Param("email") String email);
}
