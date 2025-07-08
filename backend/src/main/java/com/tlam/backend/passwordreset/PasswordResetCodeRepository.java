package com.tlam.backend.passwordreset;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface PasswordResetCodeRepository extends JpaRepository<PasswordResetCode, Long> {
    Optional<PasswordResetCode> findByEmailAndCodeAndIsUsedFalseAndExpiresAtAfter(String email, String code, LocalDateTime now);
}
