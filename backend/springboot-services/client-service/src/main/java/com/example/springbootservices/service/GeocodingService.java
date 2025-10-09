package com.example.springbootservices.service;

import com.example.springbootservices.dto.OpenStreetMapResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;

@Service
@RequiredArgsConstructor
public class GeocodingService {

    private final WebClient.Builder webClientBuilder;

    public List<OpenStreetMapResponse> searchAddress(String query) {
        WebClient webClient = webClientBuilder
                .baseUrl("https://nominatim.openstreetmap.org")
                .build();

        return webClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/search")
                        .queryParam("q", query)
                        .queryParam("format", "json")
                        .build())
                .retrieve()
                .bodyToFlux(OpenStreetMapResponse.class)
                .collectList()
                .block();
    }
}

