package com.tlam.backend.auth;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class SuccessResponse {
    private String message;
    private long timestamp;
    
    // Convenience constructor for just message
    public SuccessResponse(String message) {
        this.message = message;
        this.timestamp = System.currentTimeMillis();
    }
}
