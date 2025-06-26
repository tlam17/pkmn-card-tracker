package com.tlam.backend.auth;


import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.tlam.backend.config.JWTService;
import com.tlam.backend.user.User;
import com.tlam.backend.user.UserRepository;

import lombok.RequiredArgsConstructor;

/*
 * AuthenticationService is responsible for handling user authentication and registration.
 * It provides methods for registering a new user and logging in an existing user.
 * It uses UserRepository to interact with the database, PasswordEncoder for hashing passwords,
 * and JWTService for generating JWT tokens.
 */
@Service
@RequiredArgsConstructor
public class AuthenticationService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JWTService jwtService;
    private final AuthenticationManager authenticationManager;

    // Registers a new user and generates a JWT token for them
    public AuthenticationResponse register(SignupRequest request) {
        var user = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .build();

        userRepository.save(user);

        var jwtToken = jwtService.generateToken(user);
        return AuthenticationResponse.builder()
                .token(jwtToken)
                .build();
    }


    // Logs in an existing user by authenticating their credentials and generating a JWT token
    public AuthenticationResponse login(LoginRequest request) {
        authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(
                request.getEmail(),
                request.getPassword()
            )
        );

        var user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

        var jwtToken = jwtService.generateToken(user);
        return AuthenticationResponse.builder()
                .token(jwtToken)
                .build();
    }
}
