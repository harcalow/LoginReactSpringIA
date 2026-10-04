package com.loginia.backend.user;

import com.loginia.backend.common.exception.ResourceNotFoundException;
import com.loginia.backend.user.dto.UserResponse;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping("/me")
    public UserResponse me(@AuthenticationPrincipal Jwt jwt) {
        return userRepository.findByEmailIgnoreCase(jwt.getSubject())
                .map(UserResponse::from)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));
    }
}
