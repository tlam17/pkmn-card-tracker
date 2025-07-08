package com.tlam.backend.auth;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.tlam.backend.exception.AuthenticationException;
import com.tlam.backend.passwordreset.PasswordResetCode;
import com.tlam.backend.passwordreset.PasswordResetCodeRepository;
import com.tlam.backend.user.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/*
 * PasswordResetService is responsible for handling password reset functionality.
 * It will manage the creation and validation of password reset codes
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PasswordResetService {

    @Value("${PASSWORD_RESET_EXPIRATION_MINUTES}")
    private int codeExpirationMinutes;

    private final PasswordResetCodeRepository passwordResetCodeRepository;
    private final UserRepository userRepository;
    private final EmailService emailService;

    // Secure random for code generation
    private final SecureRandom secureRandom = new SecureRandom();

    // Generate and store 6-digit password reset code
    public void initiatePasswordReset(String email) {
        try {
            String normalizedEmail = email.toLowerCase().trim();

            // Check if the user exists
            if (!userRepository.findByEmail(normalizedEmail).isPresent()) {
                 log.warn("Password reset requested for non-existent user: {}", normalizedEmail);
                 throw AuthenticationException.invalidCredentials();
            }

            invalidateExistingCodes(normalizedEmail);

            String code = generateSecureCode();

            PasswordResetCode resetCode = PasswordResetCode.builder()
                    .email(normalizedEmail)
                    .code(code)
                    .expiresAt(LocalDateTime.now().plusMinutes(codeExpirationMinutes))
                    .build();

            passwordResetCodeRepository.save(resetCode);
            log.info("Password reset code generated for user: {}", normalizedEmail);

            // Send the reset code via email
            boolean emailSent = emailService.sendPasswordResetEmail(normalizedEmail, code);
            if (!emailSent) {
                log.error("Failed to send password reset email to: {}", normalizedEmail);
                throw new RuntimeException("Failed to send password reset email");
            }
            
            log.info("Password reset email sent successfully to: {}", normalizedEmail);
        } catch (AuthenticationException ex) {
            throw ex;
        } catch (Exception ex) {
            log.error("Unexpected error during password reset initiation for email: {}", email, ex);
            throw new RuntimeException("Failed to initiate password reset due to an unexpected error");
        }
    }

    // Validate the code against the stored code
    public boolean validateResetCode(String email, String code) {
        try {
            String normalizedEmail = email.toLowerCase().trim();
            LocalDateTime now = LocalDateTime.now();

            // Check if the code exists and is valid
            Optional<PasswordResetCode> resetCodeOpt = passwordResetCodeRepository
                    .findByEmailAndCodeAndIsUsedFalseAndExpiresAtAfter(normalizedEmail, code, now);
            
            if (resetCodeOpt.isPresent()) {
                log.info("Valid password reset code for user: {}", normalizedEmail);
                return true;
            } else {
                log.warn("Invalid or expired password reset code for user: {}", normalizedEmail);
                return false;
            }
        } catch (Exception ex) {
            log.error("Unexpected error during reset code validation for email: {}", email, ex);
            return false;
        }
    }

    // // Change the user's password if the code is valid
    // public void resetPassword(String email, String code, String newPassword) {}

    // // Clean up expired codes
    // public void cleanupExpiredCodes() {}

    // Invalidate all existing reset codes for the user
    private void invalidateExistingCodes(String email) {
        try {
            passwordResetCodeRepository.markAllCodesAsUsedForEmail(email);
            log.debug("Invalidated existing reset codes for user: {}", email);
        } catch (Exception ex) {
            log.warn("Failed to invalidate existing codes for user: {}", email, ex);
            // Don't fail the entire operation for this
        }
    }

    // Generate a secure 6-digit code
    private String generateSecureCode() {
        int code = 100000 + secureRandom.nextInt(900000);
        return String.valueOf(code);
    }
}
