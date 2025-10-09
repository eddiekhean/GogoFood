package com.example.springbootservices.model.entites;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.GenericGenerator;

import java.util.UUID;


@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "restaurant_profiles")
public class RestaurantProfile {

    @Id
    @GeneratedValue
    @org.hibernate.annotations.UuidGenerator
    private UUID id;

    private String name;             // Tên nhà hàng

    private String description;

    private String imageUrl;         // Ảnh đại diện

    private String address;

    private String openingHours;     // Giờ mở cửa, vd "08:00 - 22:00"

    private Double latitude;         // Định vị

    private Double longitude;

    private Boolean isOpen;          // Trạng thái mở cửa (toggle)

    @OneToOne
    @JoinColumn(name = "user_id", unique = true)
    private User user;


}