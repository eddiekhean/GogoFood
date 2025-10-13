package com.example.springbootservices.controller;

import com.example.springbootservices.config.CurrentUserProvider;
import com.example.springbootservices.dto.*;
import com.example.springbootservices.model.entites.User;
import com.example.springbootservices.model.enums.Status;
import com.example.springbootservices.service.OtpService;
import com.example.springbootservices.service.UserService;
import com.example.springbootservices.utils.JwtUtil;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.mail.MessagingException;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.Duration;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private UserService userService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    CurrentUserProvider currentUserProvider;

    @Autowired
    RedisTemplate<String, String> redisTemplate;

    @Autowired
    OtpService otpService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody @Valid LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
        );
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        String accessToken = jwtUtil.generateAccessToken(userDetails);
        String refreshToken = jwtUtil.generateRefreshToken(userDetails);
        String redisKey = "auth:refresh:" + userDetails.getId();
        redisTemplate.opsForValue().set(redisKey, refreshToken, Duration.ofDays(7));
        Map<String, Object> response = Map.of(
                "tokenType", "Bearer",
                "accessToken", accessToken,
                "refreshToken", refreshToken
        );
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(
            @RequestParam(defaultValue = "customer") String type,
            @RequestBody RegisterRequest request
    ) {
        switch (type.toLowerCase()) {
            case "restaurant":
                userService.registerRestaurant(request);
                return ResponseEntity.ok("Đăng ký tài khoản nhà hàng thành công");
            case "customer":
                userService.register(request);
                return ResponseEntity.ok("Đăng ký khách hàng thành công!");
            default:
                return ResponseEntity.badRequest().body("Loại tài khoản không hợp lệ!");
        }
    }
    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser() {
        User user = userService.getUserByID(currentUserProvider.getCurrentUserId());
        UserDto userDto = userService.convertToDto(user);
        return ResponseEntity.ok(userDto);
    }

    @PutMapping("/me")
    public ResponseEntity<?> updateCurrentUser(@RequestBody UpdateUserRequest request) {
        User user = userService.getUserByID(currentUserProvider.getCurrentUserId());

        user.setFullName(request.getFullName());
        user.setPhone(request.getPhone());
        user.setAvatarUrl(request.getAvatarUrl());
        user.setDateOfBirth(request.getDateOfBirth());
        user.setGender(request.getGender());
        user.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

        userService.save(user);
        UserDto userDto = userService.convertToDto(user);
        return ResponseEntity.ok(userDto);
    }

    @PutMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody ChangePasswordRequest request) {
        User user = userService.getUserByID(currentUserProvider.getCurrentUserId());

        if (!passwordEncoder.matches(request.getOldPassword(), user.getPassword())) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Mật khẩu cũ không đúng");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        user.setUpdatedAt(new Timestamp(System.currentTimeMillis()));
        userService.save(user);

        return ResponseEntity.ok("Đổi mật khẩu thành công");
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(
            @RequestParam String to) throws MessagingException {
        Map<String, String> response = new HashMap<>();
        Optional<User> optionalUser = userService.findByEmail(to);
        if (optionalUser.isEmpty()) {
            response.put("message", "Email không tồn tại trong hệ thống");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        otpService.sendOtp(to);
        response.put("message", "OTP đã được gửi qua email" );
        return ResponseEntity.ok(response);
    }

    @PostMapping("/reset-password")
    public ResponseEntity<Map<String, String>> resetPassword(@RequestBody ResetPasswordRequest request) {
        Map<String, String> response = new HashMap<>();

//         1. Kiểm tra OTP
        boolean validOtp = otpService.verifyOtp(request.getEmail(), request.getOtp());
        if (!validOtp) {
            response.put("message", "OTP không hợp lệ hoặc đã hết hạn");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }

        // 2. Tìm user
        Optional<User> optionalUser = userService.findByEmail(request.getEmail());
        if (optionalUser.isEmpty()) {
            response.put("message", "Email không tồn tại");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }

        User user = optionalUser.get();

        // 3. Mã hóa mật khẩu mới
        String hashedPassword = passwordEncoder.encode(request.getNewPassword());
        user.setPassword(hashedPassword);
        userService.save(user); // hoặc userRepository.save(user);

        response.put("message", "Đặt lại mật khẩu thành công");
        return ResponseEntity.ok(response);
    }

    @PutMapping("/me/delete")
    public ResponseEntity<?> deleteCurrentUser() {
        User user = userService.getUserByID(currentUserProvider.getCurrentUserId());
        user.setUpdatedAt(new Timestamp(System.currentTimeMillis()));
        user.setStatus(Status.DELETED);
        userService.save(user);
        UserDto userDto = userService.convertToDto(user);
        return ResponseEntity.ok(userDto);
    }

    @PutMapping("/me/upload-avatar")
    public ResponseEntity<?> uploadAvatar( @RequestParam("avatar") MultipartFile file){
        User user = userService.getUserByID(currentUserProvider.getCurrentUserId());
        try{
            userService.uploadAvatar(file,user);
            return ResponseEntity.ok("Upload thành công");
        } catch (IOException e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Lỗi khi upload ảnh: " + e.getMessage());
        }
    }
    @PostMapping("/verify/send")
    public ResponseEntity<?> sendVerificationOtp() throws MessagingException {
        User user = userService.getUserByID(currentUserProvider.getCurrentUserId());
        userService.sendVerificationOtp(user.getId());
        return ResponseEntity.ok(Map.of("message", "OTP đã được gửi đến email của bạn"));
    }
    @PostMapping("/verify/confirm")
    public ResponseEntity<?> confirmOtp(@RequestParam String otp) {
        UUID userId = currentUserProvider.getCurrentUserId();
        String email = userService.getUserByID(userId).getEmail();
        boolean validOtp = otpService.verifyOtp(email, otp);
        if (validOtp) {
            userService.activateUserByID(userId); // đánh dấu user đã xác minh
            return ResponseEntity.ok(Map.of("message", "Xác minh thành công"));
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", "Mã OTP không hợp lệ hoặc đã hết hạn"));
        }
    }


}
