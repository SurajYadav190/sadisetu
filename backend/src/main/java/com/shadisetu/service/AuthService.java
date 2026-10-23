package com.shadisetu.service;

import com.shadisetu.config.JwtTokenProvider;
import com.shadisetu.entity.Category;
import com.shadisetu.entity.Role;
import com.shadisetu.entity.ServicePackage;
import com.shadisetu.entity.User;
import com.shadisetu.entity.VendorProfile;
import com.shadisetu.payload.AuthRequest;
import com.shadisetu.payload.AuthResponse;
import com.shadisetu.repository.CategoryRepository;
import com.shadisetu.repository.ServicePackageRepository;
import com.shadisetu.repository.UserRepository;
import com.shadisetu.repository.VendorProfileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private VendorProfileRepository vendorProfileRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private ServicePackageRepository servicePackageRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private SmsService smsService;

    // In-memory OTP storage with expiration
    private final Map<String, OtpEntry> otpCache = new ConcurrentHashMap<>();
    private final SecureRandom secureRandom = new SecureRandom();

    public static class OtpEntry {
        private final String code;
        private final LocalDateTime expiresAt;

        public OtpEntry(String code, LocalDateTime expiresAt) {
            this.code = code;
            this.expiresAt = expiresAt;
        }

        public boolean isExpired() {
            return LocalDateTime.now().isAfter(expiresAt);
        }

        public String getCode() {
            return code;
        }
    }

    /**
     * Generate 6-digit numeric OTP and send via Live SMS Gateway.
     * Validates that the number is already registered for the requested role (CUSTOMER or VENDOR).
     */
    public java.util.Map<String, String> generateAndSendOtp(String rawPhone, String roleRequested) {
        if (rawPhone == null || rawPhone.trim().isEmpty()) {
            throw new RuntimeException("मोबाइल नंबर आवश्यक है (Mobile number is required)");
        }

        String phone = sanitizePhone(rawPhone);
        if (phone.length() < 10) {
            throw new RuntimeException("कृपया मान्य 10 अंकों का मोबाइल नंबर दर्ज करें (Please enter a valid 10-digit mobile number)");
        }

        // 1. Check if user is registered in the database
        User user = userRepository.findByPhone(phone).orElse(null);
        if (user == null) {
            if ("VENDOR".equalsIgnoreCase(roleRequested) || "ROLE_VENDOR".equalsIgnoreCase(roleRequested)) {
                throw new RuntimeException("यह मोबाइल नंबर वेंडर के रूप में रजिस्टर नहीं है। कृपया पहले रजिस्टर करें। (Mobile number not registered as Vendor. Please register first.)");
            } else {
                throw new RuntimeException("यह मोबाइल नंबर रजिस्टर नहीं है। कृपया पहले रजिस्टर करें। (Mobile number not registered. Please register first.)");
            }
        }

        // 2. Check role compatibility
        boolean isVendorLogin = "VENDOR".equalsIgnoreCase(roleRequested) || "ROLE_VENDOR".equalsIgnoreCase(roleRequested);
        if (isVendorLogin) {
            if (user.getRole() != Role.ROLE_VENDOR && user.getRole() != Role.ROLE_ADMIN) {
                throw new RuntimeException("यह मोबाइल नंबर ग्राहक (User) के रूप में पंजीकृत है, वेंडर नहीं। (This number is registered as Customer, not Vendor. Please login as Customer or register as Vendor.)");
            }
        } else {
            // Customer / User login
            if (user.getRole() == Role.ROLE_VENDOR) {
                throw new RuntimeException("यह मोबाइल नंबर वेंडर (Vendor) के रूप में पंजीकृत है, यूजर नहीं। (This number is registered as Vendor, not Customer. Please login from Vendor portal.)");
            }
        }

        // Generate 6-digit random code (100000 - 999999)
        String otp = String.valueOf(100000 + secureRandom.nextInt(900000));

        // Store OTP with 10-minute validity
        otpCache.put(phone, new OtpEntry(otp, LocalDateTime.now().plusMinutes(10)));

        // Dispatch real SMS
        boolean sent = smsService.sendOtpSms(phone, otp);

        java.util.Map<String, String> result = new java.util.HashMap<>();
        result.put("phone", phone);
        result.put("smsDelivered", String.valueOf(sent));
        result.put("message", sent ? "Verification OTP sent to +91 " + phone : "OTP generated for +91 " + phone);
        return result;
    }

    public java.util.Map<String, String> generateAndSendOtp(String rawPhone) {
        return generateAndSendOtp(rawPhone, "CUSTOMER");
    }

    @Transactional
    public AuthResponse register(AuthRequest request) {
        String phone = sanitizePhone(request.getPhone());
        if (userRepository.existsByPhone(phone)) {
            throw new RuntimeException("यह मोबाइल नंबर पहले से ही पंजीकृत है (" + phone + ")। कृपया लॉगिन करें। (Phone number is already registered: " + phone + ")");
        }

        Role role = Role.ROLE_CUSTOMER;
        if ("VENDOR".equalsIgnoreCase(request.getRole()) || "ROLE_VENDOR".equalsIgnoreCase(request.getRole())) {
            role = Role.ROLE_VENDOR;
        }

        User user = new User();
        user.setFullName(request.getFullName() != null ? request.getFullName() : "User " + phone);
        user.setPhone(phone);
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
            String bName = request.getBusinessName() != null && !request.getBusinessName().isBlank()
                    ? request.getBusinessName()
                    : request.getFullName() + " Services";
            vendor.setBusinessName(bName);
            vendor.setCity(request.getCity() != null && !request.getCity().isBlank() ? request.getCity() : "Delhi NCR");
            vendor.setAddress(request.getAddress() != null && !request.getAddress().isBlank() ? request.getAddress() : "Main Market");
            vendor.setBio(request.getBio() != null && !request.getBio().isBlank() ? request.getBio() : "Verified wedding service partner on Shaadi Setu.");
            vendor.setStartingPrice(request.getStartingPrice() != null ? request.getStartingPrice() : 15000.0);
            vendor.setRating(5.0);
            vendor.setReviewCount(1);
            vendor.setOnline(true);
            vendor.setKycStatus("VERIFIED");

            // Associate category
            Category cat = null;
            if (request.getCategoryId() != null) {
                cat = categoryRepository.findById(request.getCategoryId()).orElse(null);
            }
            if (cat == null && request.getCategoryName() != null && !request.getCategoryName().isBlank()) {
                cat = categoryRepository.findByName(request.getCategoryName()).orElse(null);
            }
            if (cat == null) {
                cat = categoryRepository.findAll().stream().findFirst().orElse(null);
            }
            vendor.setCategory(cat);
            vendor = vendorProfileRepository.save(vendor);
            vendorId = vendor.getId();
            kycStatus = vendor.getKycStatus();

            // Create default service package for this vendor so customer can book right away
            ServicePackage pkg = new ServicePackage();
            pkg.setVendor(vendor);
            if (cat != null && cat.getName().toLowerCase().contains("camera")) {
                pkg.setTitle("Royal 4K Cinematic & Drone Wedding Package");
                pkg.setDescription("2 Candid Shooters + 2 Cinematographers + 4K Drone Coverage + 1 Teaser + 1 Full Length Highlight.");
                pkg.setPrice(vendor.getStartingPrice() != null && vendor.getStartingPrice() > 0 ? vendor.getStartingPrice() : 45000.0);
                pkg.setDiscountedPrice(pkg.getPrice() > 5000 ? pkg.getPrice() - 5000 : pkg.getPrice());
                pkg.setFeaturesJson("[\"4K Drone Aerial Coverage\",\"Candid & Traditional Shooters\",\"Teaser Trailer + 45-min Film\"]");
                pkg.setDurationHours(12);
            } else {
                pkg.setTitle(vendor.getBusinessName() + " Signature Wedding Package");
                pkg.setDescription("Complete premium service execution with on-site coordinators.");
                pkg.setPrice(vendor.getStartingPrice() != null && vendor.getStartingPrice() > 0 ? vendor.getStartingPrice() : 25000.0);
                pkg.setDiscountedPrice(pkg.getPrice() > 3000 ? pkg.getPrice() - 3000 : pkg.getPrice());
                pkg.setFeaturesJson("[\"VIP On-site Coordinator\",\"Complete Ritual Support\",\"100% Satisfaction Escrow Guarantee\"]");
                pkg.setDurationHours(8);
            }
            servicePackageRepository.save(pkg);
        }

        String token = jwtTokenProvider.generateToken(user.getPhone(), user.getRole().name());
        return new AuthResponse(token, user, vendorId, kycStatus);
    }

    public AuthResponse login(AuthRequest request) {
        String identifier = request.getPhone() != null ? sanitizePhone(request.getPhone()) : request.getEmail();
        User user = userRepository.findByPhone(identifier)
                .or(() -> userRepository.findByEmail(request.getEmail() != null ? request.getEmail() : identifier))
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

    @Transactional
    public AuthResponse verifyOtp(String rawPhone, String otp, String roleRequested) {
        String phone = sanitizePhone(rawPhone);

        // Strict validation: ONLY the exact OTP sent to mobile is valid
        OtpEntry entry = otpCache.get(phone);
        if (entry == null) {
            throw new RuntimeException("No active OTP found for +91 " + phone + ". Please tap 'Resend OTP'.");
        }
        if (entry.isExpired()) {
            otpCache.remove(phone);
            throw new RuntimeException("OTP has expired. Please tap 'Resend OTP'.");
        }
        if (!entry.getCode().equals(otp != null ? otp.trim() : "")) {
            throw new RuntimeException("गलत OTP दर्ज किया गया है। केवल आपके मोबाइल पर भेजा गया OTP ही मान्य है। (Invalid OTP entered)");
        }
        otpCache.remove(phone); // Burn after successful use

        // Strict verification: User MUST already be registered. NO auto-registration during login!
        User user = userRepository.findByPhone(phone).orElseThrow(() ->
                new RuntimeException("यह मोबाइल नंबर रजिस्टर नहीं है। कृपया पहले रजिस्टर करें। (User not registered. Please register first.)")
        );

        boolean isVendorLogin = "VENDOR".equalsIgnoreCase(roleRequested) || "ROLE_VENDOR".equalsIgnoreCase(roleRequested);
        if (isVendorLogin) {
            if (user.getRole() != Role.ROLE_VENDOR && user.getRole() != Role.ROLE_ADMIN) {
                throw new RuntimeException("यह खाता वेंडर पार्टनर के रूप में पंजीकृत नहीं है। (This account is not registered as a Vendor Partner.)");
            }
        } else {
            if (user.getRole() == Role.ROLE_VENDOR) {
                throw new RuntimeException("यह खाता वेंडर के रूप में पंजीकृत है। कृपया वेंडर पार्टनर पोर्टल से लॉगिन करें। (This account is registered as Vendor.)");
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

    private String sanitizePhone(String phone) {
        if (phone == null) return "";
        String digits = phone.replaceAll("[^0-9]", "");
        if (digits.length() > 10) {
            return digits.substring(digits.length() - 10);
        }
        return digits;
    }
}
