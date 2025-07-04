package com.tlam.backend.auth;


import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.tlam.backend.config.JWTService;
import com.tlam.backend.exception.AuthenticationException;
import com.tlam.backend.user.User;
import com.tlam.backend.user.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/*
 * AuthenticationService is responsible for handling user authentication and registration.
 * It provides methods for registering a new user and logging in an existing user.
 * It uses UserRepository to interact with the database, PasswordEncoder for hashing passwords,
 * and JWTService for generating JWT tokens.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthenticationService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JWTService jwtService;
    private final AuthenticationManager authenticationManager;
    private final EmailService emailService;

    // Registers a new user and generates a JWT token for them
    public AuthenticationResponse register(SignupRequest request) {
        try {
            // Check if the user already exists
            if (userRepository.findByEmail(request.getEmail()).isPresent()) {
                throw AuthenticationException.userAlreadyExists();
            }

            var user = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .build();

            userRepository.save(user);
            log.info("User registered successfully: {}", user.getEmail());

            var jwtToken = jwtService.generateToken(user);

            sendWelcomeEmailAsync(user);
            
            return AuthenticationResponse.builder()
                    .token(jwtToken)
                    .build();
        } catch (DataIntegrityViolationException ex) {
            log.warn("Registration failed due to data integrity violation: {}", ex.getMessage());
            throw AuthenticationException.userAlreadyExists();
        } catch (AuthenticationException ex) {
            throw ex;
        } catch (Exception ex) {
            log.error("Registration failed due to unexpected error: {}", ex.getMessage(), ex);
            throw new RuntimeException("Registration failed due to an unexpected error");
        }
    }

    // Logs in an existing user by authenticating their credentials and generating a JWT token
    public AuthenticationResponse login(LoginRequest request) {
        try {
            String email = request.getEmail().toLowerCase().trim();

            authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                    email,
                    request.getPassword()
                )
            );

            var user = userRepository.findByEmail(email)
                    .orElseThrow(() -> {
                        log.warn("Login attempt for non-existent user: {}", email);
                        return AuthenticationException.invalidCredentials();
                    });
            log.info("User logged in successfully: {}", user.getEmail());

            var jwtToken = jwtService.generateToken(user);
            return AuthenticationResponse.builder()
                    .token(jwtToken)
                    .build();


        } catch (BadCredentialsException ex) {
            log.warn("Login failed due to bad credentials for email: {}", request.getEmail());
            throw AuthenticationException.invalidCredentials();
        } catch (AuthenticationException ex) {
            throw ex;
        } catch (Exception ex) {
            log.error("Unexpected error during login: {}", ex.getMessage(), ex);
            throw new RuntimeException("Login failed due to an unexpected error");
        }
    }

    // Sends a welcome email to the user asynchronously after successful registration
    private void sendWelcomeEmailAsync(User user) {
        // Run email sending in a separate thread to avoid blocking registration
        Thread.ofVirtual().start(() -> {
            try {
                boolean emailSent = emailService.sendWelcomeEmail(user);
                if (emailSent) {
                    log.info("Welcome email sent successfully to: {}", user.getEmail());
                } else {
                    log.warn("Failed to send welcome email to: {} (but registration was successful)", user.getEmail());
                }
            } catch (Exception e) {
                log.error("Error sending welcome email to: {} (but registration was successful): {}", 
                         user.getEmail(), e.getMessage(), e);
            }
        });
    }
}
