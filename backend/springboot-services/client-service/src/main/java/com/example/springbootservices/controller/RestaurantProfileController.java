package com.example.springbootservices.controller;

import com.example.springbootservices.config.CurrentUserProvider;
import com.example.springbootservices.dto.*;
import com.example.springbootservices.service.RestaurantProfileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.nio.file.AccessDeniedException;
import java.util.UUID;

@Tag(name = "Restaurant Profile", description = "Quản lý thông tin hồ sơ nhà hàng")
@RestController
@RequestMapping("/restaurant/profile")
@RequiredArgsConstructor
public class RestaurantProfileController {

    @Autowired
    private final CurrentUserProvider currentUserProvider;

    @Autowired
    private final RestaurantProfileService restaurantProfileService;
    @Operation(
            summary = "Cập nhật thông tin nhà hàng",
            description = "Cập nhật các thông tin cơ bản của nhà hàng như tên, mô tả, ảnh, giờ mở cửa,..."
    )
    @ApiResponse(
            responseCode = "200",
            description = "Cập nhật thành công",
            content = @Content(schema = @Schema(example = "Cập nhật thông tin nhà hàng thành công!"))
    )
    @PutMapping("/{id}")
    public ResponseEntity<String> updateRestaurantProfile(
            @Parameter(description = "ID hồ sơ nhà hàng", required = true)
            @PathVariable UUID id,

            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Thông tin nhà hàng cần cập nhật",
                    required = true
            )
            @RequestBody UpdateRestaurantProfileRequest request
    ) {
        restaurantProfileService.update(id, request);
        return ResponseEntity.ok("Cập nhật thông tin nhà hàng thành công!");
    }

    @Operation(
            summary = "Tạo hồ sơ nhà hàng mới",
            description = "Khởi tạo hồ sơ nhà hàng dành cho người dùng có vai trò 'RESTAURANT'"
    )
    @PostMapping
    public ResponseEntity<?> createRestaurantProfile(
            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Thông tin nhà hàng cần tạo",
                    required = true
            )
            @RequestBody CreateRestaurantProfileRequest request
    ) throws AccessDeniedException {
        return ResponseEntity.ok("Tạo nhà hàng thành công");
    }

    @Operation(
            summary = "Lấy hồ sơ nhà hàng của tôi",
            description = "Trả về thông tin hồ sơ nhà hàng liên kết với người dùng hiện tại"
    )
    @PreAuthorize("hasRole('RESTAURANT')")
    @GetMapping("/me")
    public ResponseEntity<RestaurantProfileResponse> getMyRestaurantProfile() {
        UUID userId = currentUserProvider.getCurrentUserId();
        return ResponseEntity.ok(restaurantProfileService.getRestaurentByUserId(userId));
    }

    @Operation(
            summary = "Cập nhật vị trí nhà hàng",
            description = "Cập nhật vị trí địa lý (latitude, longitude) của nhà hàng"
    )
    @PatchMapping("/location")
    public ResponseEntity<?> updateLocation(
            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Toạ độ mới của nhà hàng",
                    required = true
            )
            @RequestBody UpdateLocationRequest request
    ) {
        restaurantProfileService.updateLocation(request.getLatitude(), request.getLongitude());
        return ResponseEntity.ok("Cập nhật vị trí thành công!");
    }

    @Operation(
            summary = "Cập nhật trạng thái mở cửa",
            description = "Bật hoặc tắt trạng thái mở cửa của nhà hàng"
    )
    @PatchMapping("/status")
    public ResponseEntity<?> updateStatusOpen(
            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Trạng thái mở cửa mới",
                    required = true
            )
            @RequestBody UpdateStatusRequest request
    ) {
        restaurantProfileService.updateStatus(request);
        return ResponseEntity.ok("Cập nhật trạng thái cửa hàng thành công");
    }
}
