package com.loginia.backend.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.loginia.backend.auth.dto.RegisterRequest;
import com.loginia.backend.common.exception.ResourceAlreadyExistsException;
import com.loginia.backend.user.User;
import com.loginia.backend.user.UserRepository;
import com.loginia.backend.user.dto.UserResponse;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.crypto.password.PasswordEncoder;

class AuthServiceTest {

    private final UserRepository userRepository = mock(UserRepository.class);
    private final PasswordEncoder passwordEncoder = mock(PasswordEncoder.class);
    private final AuthService authService = new AuthService(
            mock(AuthenticationManager.class), userRepository, passwordEncoder, mock(JwtService.class));

    @Test
    void registerNormalizesDataAndHashesPassword() {
        when(userRepository.existsByEmailIgnoreCase("ana@example.com")).thenReturn(false);
        when(passwordEncoder.encode("Secreta123")).thenReturn("{bcrypt}hash");
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));

        UserResponse response = authService.register(
                new RegisterRequest("  Ana@Example.com ", " Ana María ", " Pérez Gómez ", "Secreta123"));

        ArgumentCaptor<User> saved = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(saved.capture());
        assertThat(saved.getValue().getEmail()).isEqualTo("ana@example.com");
        assertThat(saved.getValue().getFirstName()).isEqualTo("Ana María");
        assertThat(saved.getValue().getLastName()).isEqualTo("Pérez Gómez");
        assertThat(saved.getValue().getPasswordHash()).isEqualTo("{bcrypt}hash");
        assertThat(response.email()).isEqualTo("ana@example.com");
    }

    @Test
    void registerRejectsDuplicatedEmail() {
        when(userRepository.existsByEmailIgnoreCase("ana@example.com")).thenReturn(true);

        assertThatThrownBy(() -> authService.register(
                new RegisterRequest("ana@example.com", "Ana", "Pérez", "Secreta123")))
                .isInstanceOf(ResourceAlreadyExistsException.class)
                .hasMessage("El correo ya está registrado");
        verify(userRepository, never()).save(any());
    }
}
