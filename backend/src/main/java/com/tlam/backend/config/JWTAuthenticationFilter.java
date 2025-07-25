package com.tlam.backend.config;

import java.io.IOException;

import org.springframework.http.MediaType;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tlam.backend.exception.ErrorResponse;

import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * JWTAuthenticationFilter intercepts every incoming HTTP request once,
 * checks for a valid Authorization header containing a JWT,
 * and proceeds accordingly.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JWTAuthenticationFilter extends OncePerRequestFilter {

    private final JWTService jwtService;
    private final UserDetailsService userDetailsService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    // This method is called once per request to apply custom filtering logic.
    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response, @NonNull FilterChain filterChain)
            throws ServletException, IOException {
        final String authHeader = request.getHeader("Authorization");
        final String jwt;
        final String email;

        // If the header is missing or doesn't start with "Bearer ", skip this filter
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        try {
            // Extract the JWT from the header and validate it
            jwt = authHeader.substring(7);
            email = jwtService.extractUsername(jwt);

            /*  
            If the email is not null and there is no existing authentication in the context,
            load the user details and validate the JWT
            If valid, set the authentication in the security context
            This allows the application to recognize the user for the duration of the request
            If the JWT is valid, create an authentication token and set it in the security context 
            */
            if (email != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                UserDetails userDetails = this.userDetailsService.loadUserByUsername(email);
                if (jwtService.isTokenValid(jwt, userDetails)) {
                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        userDetails, 
                        null, 
                        userDetails.getAuthorities()
                );
                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            }
            // Continue the filter chain to the next filter or the target resource
            filterChain.doFilter(request, response);
        } catch (ExpiredJwtException ex) {
            log.warn("JWT token expired for request: {}", request.getRequestURI());
            handleJwtException(response, "Token expired", "Your session has expired. Please login again.", 401);
        } catch (JwtException ex) {
            log.warn("Invalid JWT token for request: {}", request.getRequestURI());
            handleJwtException(response, "Invalid token", "Invalid authentication token. Please login again.", 401);
        } catch (Exception ex) {
            log.error("Unexpected error processing JWT: {}", ex.getMessage(), ex);
            handleJwtException(response, "Authentication error", "Authentication failed. Please try again.", 401);
        }
    }

    private void handleJwtException(HttpServletResponse response, String error, String message, int status) throws IOException {
        ErrorResponse errorResponse = ErrorResponse.builder()
                .status(status)
                .error(error)
                .message(message)
                .timestamp(System.currentTimeMillis())
                .build();
        
        response.setStatus(status);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.getWriter().write(objectMapper.writeValueAsString(errorResponse));
    }
}
