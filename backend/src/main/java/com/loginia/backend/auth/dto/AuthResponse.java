package com.loginia.backend.auth.dto;

import com.loginia.backend.user.dto.UserResponse;

public record AuthResponse(String accessToken, String tokenType, long expiresIn, UserResponse user) {
}
