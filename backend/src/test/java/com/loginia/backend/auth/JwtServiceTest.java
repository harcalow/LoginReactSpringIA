package com.loginia.backend.auth;

import static org.assertj.core.api.Assertions.assertThat;

import com.loginia.backend.config.JwtProperties;
import com.loginia.backend.config.SecurityConfig;
import com.loginia.backend.user.User;
import java.time.Duration;
import java.util.Base64;
import java.util.UUID;
import javax.crypto.SecretKey;
import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.test.util.ReflectionTestUtils;

class JwtServiceTest {

    private final SecurityConfig securityConfig = new SecurityConfig();
    private final JwtProperties properties = new JwtProperties(
            Base64.getEncoder().encodeToString(new byte[32]), "test-issuer", Duration.ofMinutes(15));
    private final SecretKey key = securityConfig.jwtSecretKey(properties);
    private final JwtService jwtService = new JwtService(securityConfig.jwtEncoder(key), properties);
    private final JwtDecoder decoder = securityConfig.jwtDecoder(key);

    @Test
    void generatedTokenContainsExpectedClaims() {
        User user = new User("ana@example.com", "hash", "Ana", "Pérez");
        ReflectionTestUtils.setField(user, "id", UUID.randomUUID());

        Jwt jwt = decoder.decode(jwtService.generateToken(user));

        assertThat(jwt.getSubject()).isEqualTo("ana@example.com");
        assertThat(jwt.getClaimAsString("iss")).isEqualTo("test-issuer");
        assertThat(jwt.getClaimAsStringList("roles")).containsExactly("USER");
        assertThat(jwtService.expirationSeconds()).isEqualTo(900);
    }
}
