package com.tlam.backend.exception;

import org.springframework.http.HttpStatus;

import lombok.Getter;

/**
 * Custom exception class for handling authentication-related errors.
 * This exception can be thrown during user registration, login, or other authentication processes.
 */
@Getter
public class AuthenticationException extends RuntimeException {
    private final HttpStatus status;
    private final String error;

    public AuthenticationException(String message, HttpStatus status, String error) {
        super(message);
        this.status = status;
        this.error = error;
    }

    // Convenience constructors for common scenarios
    public static AuthenticationException userAlreadyExists() {
        return new AuthenticationException(
            "An account with this email address already exists",
            HttpStatus.CONFLICT,
            "Registration Failed"
        );
    }

    public static AuthenticationException invalidCredentials() {
        return new AuthenticationException(
            "Invalid email or password",
            HttpStatus.UNAUTHORIZED,
            "Authentication Failed"
        );
    }

    public static AuthenticationException accountLocked() {
        return new AuthenticationException(
            "Account is temporarily locked. Please try again later",
            HttpStatus.FORBIDDEN,
            "Account Locked"
        );
    }

    public static AuthenticationException weakPassword() {
        return new AuthenticationException(
            "Password does not meet security requirements",
            HttpStatus.BAD_REQUEST,
            "Weak Password"
        );
    }
}
