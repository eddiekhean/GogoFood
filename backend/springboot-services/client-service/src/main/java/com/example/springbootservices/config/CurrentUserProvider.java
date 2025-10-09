package com.example.springbootservices.config;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Component;
import java.util.UUID;

@Component
public class CurrentUserProvider {

    private final HttpServletRequest request;

    public CurrentUserProvider(HttpServletRequest request) {
        this.request = request;
    }

    public UUID getCurrentUserId() {
        String userId = request.getHeader("X-User-Id");
        return userId != null ? UUID.fromString(userId) : null;
    }

    public String getUsername() {
        return request.getHeader("X-User-Name");
    }
}
