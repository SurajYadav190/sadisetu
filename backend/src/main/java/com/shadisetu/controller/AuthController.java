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
        try {
            AuthResponse response = authService.register(request);
            return ResponseEntity.ok(ApiResponse.ok("Registration successful", response));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@RequestBody AuthRequest request) {
        try {
            AuthResponse response = authService.login(request);
            return ResponseEntity.ok(ApiResponse.ok("Login successful", response));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/send-otp")
    public ResponseEntity<ApiResponse<java.util.Map<String, String>>> sendOtp(@RequestBody AuthRequest request) {
        try {
            java.util.Map<String, String> data = authService.generateAndSendOtp(request.getPhone(), request.getRole());
            return ResponseEntity.ok(ApiResponse.ok(data.get("message"), data));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/otp-verify")
    public ResponseEntity<ApiResponse<AuthResponse>> verifyOtp(@RequestBody AuthRequest request) {
        try {
            AuthResponse response = authService.verifyOtp(request.getPhone(), request.getOtp(), request.getRole());
            return ResponseEntity.ok(ApiResponse.ok("OTP verified successfully", response));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<User>> getCurrentUser(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.ok(user));
    }
}
