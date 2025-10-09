package com.example.springbootservices;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
public class SpringbootServicesApplication {

    public static void main(String[] args) {
        SpringApplication.run(SpringbootServicesApplication.class, args);
    }

}
