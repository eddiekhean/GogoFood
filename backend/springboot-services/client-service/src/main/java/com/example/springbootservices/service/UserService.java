package com.example.springbootservices.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.example.springbootservices.dto.Address;
import com.example.springbootservices.dto.RegisterRequest;
import com.example.springbootservices.dto.UserDto;
import com.example.springbootservices.model.entites.Role;
import com.example.springbootservices.model.entites.User;
import com.example.springbootservices.model.enums.Status;
import com.example.springbootservices.model.projection.CustomerAdminView;
import com.example.springbootservices.reponsitory.RoleRepository;
import com.example.springbootservices.reponsitory.UserRepository;
import jakarta.mail.MessagingException;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private Cloudinary cloudinary;

    @Autowired
    private OtpService otpService;

    @Autowired
    PasswordEncoder passwordEncoder;

    @Transactional
    public User register(RegisterRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username already exists");
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        Role role = roleRepository.findByName("CUSTOMER")
                .orElseThrow(() -> new RuntimeException("Role not found"));

        User user = new User();
        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        user.setPhone(request.getPhone());
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setStatus(Status.INACTIVE);
        user.setRole(role);
        return userRepository.save(user);
    }
    @Transactional
    public User getUserByUsername(String username) {
        return userRepository.findByUsername(username).orElseThrow(() -> new RuntimeException("User not found"));
    }
    @Transactional
    public Boolean activateUserByID(UUID id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new UsernameNotFoundException("Không tìm thấy user"));

        user.setStatus(Status.ACTIVE);
        save(user);
        return true;
    }
    @Transactional
    public void save(User user) {
        userRepository.save(user);
    }
    @Transactional
    public UserDto convertToDto(User user) {
        UserDto dto = new UserDto();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setEmail(user.getEmail());
        dto.setFullName(user.getFullName());
        dto.setPhone(user.getPhone());
        dto.setStatus(user.getStatus());
        dto.setCreatedAt(user.getCreatedAt());
        dto.setUpdatedAt(user.getUpdatedAt());
        dto.setRole(user.getRole().getName());
        dto.setAvatarUrl(user.getAvatarUrl());
        dto.setDateOfBirth(user.getDateOfBirth());
        dto.setGender(user.getGender());

        List<Address> addresses = user.getAddresses().stream()
                .map(address -> new Address(
                        address.getId(),
                        address.getStreet(),
                        address.getWard(),
                        address.getDistrict(),
                        address.getCity(),
                        address.isDefault()
                ))
                .collect(Collectors.toList());

        dto.setAddresses(addresses);
        return dto;
    }
    public Optional<User> findByEmail(String mail) {
        return Optional.ofNullable(userRepository.findByEmail(mail)
                .orElseThrow(() -> new UsernameNotFoundException("Không tìm thấy user")));
    }
    @Transactional
    public Boolean uploadAvatar(MultipartFile file, User user) throws IOException {
        Map uploadResult = cloudinary.uploader().upload(file.getBytes(), ObjectUtils.emptyMap());
        String avatarLink = uploadResult.get("secure_url").toString();
        if (uploadResult != null) {
            getUserByUsername(user.getUsername()).setAvatarUrl(avatarLink);
            return true;
        }
        return false;
    }

    public List<User> getAllUser() {
        return  userRepository.findAll();
    }
    public Page<CustomerAdminView> getAllCustomerView(Pageable pageable) {
        return userRepository.findAllCustomersForAdmin(pageable);
    }

    public User getUserByID(UUID uuid) {
        return userRepository.getUserById(uuid);
    }
    @Transactional
    public User registerRestaurant(RegisterRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username already exists");
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        Role role = roleRepository.findByName("RESTAURANT")
                .orElseThrow(() -> new RuntimeException("Role not found"));

        User user = new User();
        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        user.setPhone(request.getPhone());
        user.setUsername(request.getUsername());
        user.setPassword(request.getPassword());
        user.setStatus(Status.INACTIVE);
        user.setRole(role);
        return userRepository.save(user);
    }
    @Transactional
    public User sendVerificationOtp(UUID userID) throws MessagingException {
        User user = userRepository.findById(userID).orElseThrow(() -> new UsernameNotFoundException("User not found"));
        otpService.sendOtp(user.getEmail());
        return user;
    }
}

