package com.tlam.backend.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class VerifyResetCodeRequest {
    @NotBlank(message = "Email is required and cannot be empty")
    @Email(message = "Please provide a valid email address (e.g., user@example.com)")
    @Size(max = 100, message = "Email must not exceed 100 characters")
    private String email;

    @NotBlank(message = "Reset code is required and cannot be empty")
    @Size(min = 6, max = 6, message = "Reset code must be exactly 6 characters long")
    private String code;
}
