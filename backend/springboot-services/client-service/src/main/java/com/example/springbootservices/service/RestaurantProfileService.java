package com.example.springbootservices.service;

import com.example.springbootservices.config.CurrentUserProvider;
import com.example.springbootservices.dto.CreateRestaurantProfileRequest;
import com.example.springbootservices.dto.RestaurantProfileResponse;
import com.example.springbootservices.dto.UpdateRestaurantProfileRequest;
import com.example.springbootservices.dto.UpdateStatusRequest;
import com.example.springbootservices.model.entites.RestaurantProfile;
import com.example.springbootservices.model.entites.User;
import com.example.springbootservices.reponsitory.RestaurantProfileRepository;
import com.example.springbootservices.reponsitory.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.NotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.nio.file.AccessDeniedException;
import java.util.UUID;

@Service
public class RestaurantProfileService {
    @Autowired
    RestaurantProfileRepository restaurantProfileRepository;
    @Autowired
    UserRepository userRepository;
    @Autowired
    CurrentUserProvider currentUserProvider;

    public void create(CreateRestaurantProfileRequest request) throws AccessDeniedException {
        UUID currentUserId = currentUserProvider.getCurrentUserId();


        User currentUser = userRepository.findById(currentUserId)
                .orElseThrow(() -> new NotFoundException("User not found"));

        // Đảm bảo chỉ 1 nhà hàng cho mỗi user
        if (restaurantProfileRepository.existsByUserId(currentUserId)) {
            throw new IllegalStateException("Nhà hàng đã được tạo");
        }

        if (!currentUser.getRole().getName().equalsIgnoreCase("RESTAURANT")) {
            throw new AccessDeniedException("Chỉ user có quyền RESTAURANT mới được tạo nhà hàng");
        }

        RestaurantProfile profile = new RestaurantProfile();
        profile.setName(request.getName());
        profile.setDescription(request.getDescription());
        profile.setImageUrl(request.getImageUrl());
        profile.setAddress(request.getAddress());
        profile.setOpeningHours(request.getOpeningHours());
        profile.setUser(currentUser);

        restaurantProfileRepository.save(profile);
    }

    public void update(UUID id, UpdateRestaurantProfileRequest request) {
        RestaurantProfile profile = restaurantProfileRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Restaurant not found"));

        profile.setName(request.getName());
        profile.setDescription(request.getDescription());
        profile.setImageUrl(request.getImageUrl());
        profile.setAddress(request.getAddress());
        profile.setOpeningHours(request.getOpeningHours());

        restaurantProfileRepository.save(profile);
    }


    @Transactional
    public void updateLocation(Double latitude, Double longitude) {
        UUID currentUserId = currentUserProvider.getCurrentUserId();

        RestaurantProfile profile = restaurantProfileRepository
                .findByUserId(currentUserId).orElseThrow(() -> new EntityNotFoundException("RestaurantProfile not found for user " + currentUserId)); ;

        profile.setLatitude(latitude);
        profile.setLongitude(longitude);

        restaurantProfileRepository.save(profile);
    }


    public void updateStatus(UpdateStatusRequest request) {
        UUID currentUserId = currentUserProvider.getCurrentUserId();

        RestaurantProfile profile = restaurantProfileRepository.findByUserId(currentUserId).orElseThrow(() -> new EntityNotFoundException("RestaurantProfile not found for user " + currentUserId)); ;

        profile.setIsOpen(request.getStatus());
        restaurantProfileRepository.save(profile);
    }

    public RestaurantProfile getByUserId(UUID userId) {
        return restaurantProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new EntityNotFoundException("RestaurantProfile not found for user " + userId));
    }


    public RestaurantProfileResponse getRestaurentByUserId(UUID userId) {
        RestaurantProfileResponse restaurantProfileResponse = new RestaurantProfileResponse();
        return restaurantProfileResponse.mapToDto(restaurantProfileRepository.findByUserId(userId).orElseThrow(() -> new EntityNotFoundException("RestaurantProfile not found for user " + userId)));
    }
}