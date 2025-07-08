package com.tlam.backend.auth;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
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
    public ResponseEntity<String> forgotPassword(
        @Valid 
         @io.swagger.v3.oas.annotations.parameters.RequestBody(
            description = "Email address for password reset",
            required = true,
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = ForgotPasswordRequest.class),
                examples = @ExampleObject(
                    value = "{ \"email\": \"user@example.com\" }"
                )
            )
        )
        @RequestBody ForgotPasswordRequest request) {
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

    @Operation(summary = "Verify password reset code", description = "Validates the 6-digit reset code sent to the user's email.")
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Reset code is valid",
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = String.class)
            )
        ),
        @ApiResponse(
            responseCode = "400",
            description = "Invalid or expired reset code",
            content = @Content(mediaType = "application/json")
        )
    })
    @PostMapping("/verify-reset-code")
    public ResponseEntity<String> verifyResetCode(
        @Valid 
        @io.swagger.v3.oas.annotations.parameters.RequestBody(
            description = "Email and 6-digit reset code for verification",
            required = true,
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = VerifyResetCodeRequest.class),
                examples = @ExampleObject(
                    value = "{ \"email\": \"user@example.com\", \"code\": \"123456\" }"
                )
            )
        )
        @RequestBody VerifyResetCodeRequest request) {
        try {
            log.info("Verifying reset code for email: {}", request.getEmail());
            
            // Validate the reset code
            boolean isValid = passwordResetService.validateResetCode(request.getEmail(), request.getCode());
            
            if (isValid) {
                log.info("Reset code verified successfully for email: {}", request.getEmail());
                return ResponseEntity.ok("Reset code is valid.");
            } else {
                log.warn("Invalid reset code for email: {}", request.getEmail());
                return ResponseEntity.badRequest().body("Invalid or expired reset code.");
            }
        } catch (Exception ex) {
            log.error("Error verifying reset code for email: {}", request.getEmail(), ex);
            throw ex; // Let the GlobalExceptionHandler handle it
        }
    }
}