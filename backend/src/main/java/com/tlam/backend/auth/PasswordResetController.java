package com.tlam.backend.auth;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * Controller for handling password reset requests.
 * Currently implements the initial step: sending reset codes via email.
 */
@Slf4j
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "Password Reset", description = "Password reset functionality")
public class PasswordResetController {

    private final PasswordResetService passwordResetService;

    @Operation(summary = "Request password reset", description = "Sends a 6-digit reset code to the user's email if the account exists.")
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Reset code sent successfully (or email doesn't exist - for security)",
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = String.class)
            )
        ),
        @ApiResponse(
            responseCode = "400",
            description = "Invalid email format",
            content = @Content(mediaType = "application/json")
        )
    })
    @PostMapping("/forgot-password")
    public ResponseEntity<String> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        try {
            log.info("Password reset requested for email: {}", request.getEmail());
            
            // Call the service to initiate password reset
            passwordResetService.initiatePasswordReset(request.getEmail());
            
            // Always return success message for security (prevents email enumeration)
            String successMessage = "If an account with that email exists, we've sent you a reset code.";
            log.info("Password reset process completed for email: {}", request.getEmail());
            
            return ResponseEntity.ok(successMessage);
            
        } catch (Exception ex) {
            log.error("Error processing password reset request for email: {}", request.getEmail(), ex);
            
            // For security, don't reveal specific error details to the client
            // The GlobalExceptionHandler will handle the specific exception types
            throw ex;
        }
    }
}