package com.example.springbootservices.controller;

import com.example.springbootservices.model.entites.User;
import com.example.springbootservices.model.projection.CustomerAdminView;
import com.example.springbootservices.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@PreAuthorize("hasRole('ADMIN')")
@RestController
@RequestMapping("/admin")
@Tag(name = "Admin User Controller", description = "Quản lý người dùng dành cho ADMIN")
public class AdminUserController {

    @Autowired
    UserService userService;

    @GetMapping("/list-user")
    public List<User> allUser() {
        return userService.getAllUser();
    }

    @GetMapping("/all-customers")
    public ResponseEntity<Page<CustomerAdminView>> getAllCustomers(
            @Parameter(description = "Số trang", example = "0")
            @RequestParam(defaultValue = "0") int page,

            @Parameter(description = "Kích thước trang", example = "500")
            @RequestParam(defaultValue = "500") int size
    ) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<CustomerAdminView> customers = userService.getAllCustomerView(pageable);
        return ResponseEntity.ok(customers);
    }
}