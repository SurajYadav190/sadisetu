package com.shadisetu.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class HomeController {

    @GetMapping("/")
    public ResponseEntity<Map<String, Object>> home() {
        return ResponseEntity.ok(Map.of(
            "status", "UP",
            "service", "Shaadi Setu Backend API",
            "message", "Backend is successfully deployed and running on Render!",
            "version", "1.0.0",
            "swaggerDocs", "/swagger-ui/index.html",
            "authApi", "/api/auth"
        ));
    }
}
