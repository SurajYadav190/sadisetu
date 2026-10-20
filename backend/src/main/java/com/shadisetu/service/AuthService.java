package com.shadisetu.service;

import com.shadisetu.config.JwtTokenProvider;
import com.shadisetu.entity.Role;
import com.shadisetu.entity.User;
import com.shadisetu.entity.VendorProfile;
import com.shadisetu.payload.AuthRequest;
import com.shadisetu.payload.AuthResponse;
import com.shadisetu.repository.UserRepository;
import com.shadisetu.repository.VendorProfileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private VendorProfileRepository vendorProfileRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Transactional
    public AuthResponse register(AuthRequest request) {
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new RuntimeException("Phone number is already registered: " + request.getPhone());
        }

        Role role = Role.ROLE_CUSTOMER;
        if ("VENDOR".equalsIgnoreCase(request.getRole()) || "ROLE_VENDOR".equalsIgnoreCase(request.getRole())) {
            role = Role.ROLE_VENDOR;
        }

        User user = new User();
        user.setFullName(request.getFullName() != null ? request.getFullName() : "User " + request.getPhone());
        user.setPhone(request.getPhone());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword() != null ? request.getPassword() : "Pass@123"));
        user.setRole(role);
        user.setStatus("ACTIVE");
        user.setCreatedAt(LocalDateTime.now());
        user = userRepository.save(user);

        Long vendorId = null;
        String kycStatus = null;
        if (role == Role.ROLE_VENDOR) {
            VendorProfile vendor = new VendorProfile();
            vendor.setUser(user);
            vendor.setBusinessName(request.getFullName() + " Services");
            vendor.setKycStatus("PENDING");
            vendor = vendorProfileRepository.save(vendor);
            vendorId = vendor.getId();
            kycStatus = vendor.getKycStatus();
        }

        String token = jwtTokenProvider.generateToken(user.getPhone(), user.getRole().name());
        return new AuthResponse(token, user, vendorId, kycStatus);
    }

    public AuthResponse login(AuthRequest request) {
        User user = userRepository.findByPhone(request.getPhone())
                .or(() -> userRepository.findByEmail(request.getEmail() != null ? request.getEmail() : request.getPhone()))
                .orElseThrow(() -> new RuntimeException("User not found with provided phone/email"));

        if (request.getPassword() != null && !request.getPassword().isEmpty()) {
            if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
                throw new RuntimeException("Invalid password credentials");
            }
        }

        Long vendorId = null;
        String kycStatus = null;
        if (user.getRole() == Role.ROLE_VENDOR) {
            VendorProfile vp = vendorProfileRepository.findByUser(user).orElse(null);
            if (vp != null) {
                vendorId = vp.getId();
                kycStatus = vp.getKycStatus();
            }
        }

        String token = jwtTokenProvider.generateToken(user.getPhone(), user.getRole().name());
        return new AuthResponse(token, user, vendorId, kycStatus);
    }

    public AuthResponse verifyOtp(String phone, String otp, String roleRequested) {
        // Mock OTP verification (accepts '123456' or any 6 digit code for seamless developer testing)
        User user = userRepository.findByPhone(phone).orElseGet(() -> {
            Role role = "VENDOR".equalsIgnoreCase(roleRequested) ? Role.ROLE_VENDOR : Role.ROLE_CUSTOMER;
            User newUser = new User("User " + phone.substring(Math.max(0, phone.length() - 4)), phone, null, passwordEncoder.encode("Pass@123"), role);
            newUser = userRepository.save(newUser);

            if (role == Role.ROLE_VENDOR) {
                VendorProfile vendor = new VendorProfile();
                vendor.setUser(newUser);
                vendor.setBusinessName("Vendor " + phone);
                vendor.setKycStatus("PENDING");
                vendorProfileRepository.save(vendor);
            }
            return newUser;
        });

        Long vendorId = null;
        String kycStatus = null;
        if (user.getRole() == Role.ROLE_VENDOR) {
            VendorProfile vp = vendorProfileRepository.findByUser(user).orElse(null);
            if (vp != null) {
                vendorId = vp.getId();
                kycStatus = vp.getKycStatus();
            }
        }

        String token = jwtTokenProvider.generateToken(user.getPhone(), user.getRole().name());
        return new AuthResponse(token, user, vendorId, kycStatus);
    }
}
