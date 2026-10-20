package com.shadisetu.payload;

import com.shadisetu.entity.User;

public class AuthResponse {
    private String token;
    private String tokenType = "Bearer";
    private Long id;
    private String fullName;
    private String phone;
    private String email;
    private String role;
    private Long vendorProfileId;
    private String kycStatus;

    public AuthResponse() {}

    public AuthResponse(String token, User user, Long vendorProfileId, String kycStatus) {
        this.token = token;
        this.id = user.getId();
        this.fullName = user.getFullName();
        this.phone = user.getPhone();
        this.email = user.getEmail();
        this.role = user.getRole().name();
        this.vendorProfileId = vendorProfileId;
        this.kycStatus = kycStatus;
    }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getTokenType() { return tokenType; }
    public void setTokenType(String tokenType) { this.tokenType = tokenType; }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Long getVendorProfileId() { return vendorProfileId; }
    public void setVendorProfileId(Long vendorProfileId) { this.vendorProfileId = vendorProfileId; }

    public String getKycStatus() { return kycStatus; }
    public void setKycStatus(String kycStatus) { this.kycStatus = kycStatus; }
}
