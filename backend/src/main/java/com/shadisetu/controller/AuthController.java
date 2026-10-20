package com.shadisetu.controller;

import com.shadisetu.entity.User;
import com.shadisetu.payload.ApiResponse;
import com.shadisetu.payload.AuthRequest;
import com.shadisetu.payload.AuthResponse;
import com.shadisetu.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@RequestBody AuthRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.ok(ApiResponse.ok("Registration successful", response));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@RequestBody AuthRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.ok("Login successful", response));
    }

    @PostMapping("/otp-verify")
    public ResponseEntity<ApiResponse<AuthResponse>> verifyOtp(@RequestBody AuthRequest request) {
        AuthResponse response = authService.verifyOtp(request.getPhone(), request.getOtp(), request.getRole());
        return ResponseEntity.ok(ApiResponse.ok("OTP verified successfully", response));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<User>> getCurrentUser(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.ok(user));
    }
}
