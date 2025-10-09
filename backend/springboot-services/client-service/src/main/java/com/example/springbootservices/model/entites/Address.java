package com.example.springbootservices.model.entites;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.GenericGenerator;
import jakarta.persistence.Id;

import java.util.UUID;

@Entity
@Getter
@Setter
@AllArgsConstructor
@Table(name = "addresses")
@NoArgsConstructor
public class Address {

    @Id
    @GeneratedValue
    @org.hibernate.annotations.UuidGenerator
    private UUID id;


    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String street;
    private String ward;
    private String district;
    private String city;

    @Column(name = "is_default")
    private boolean isDefault;

}

