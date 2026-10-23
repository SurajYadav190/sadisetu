package com.shadisetu.data;

import com.shadisetu.entity.*;
import com.shadisetu.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired private UserRepository userRepository;
    @Autowired private CategoryRepository categoryRepository;
    @Autowired private VendorProfileRepository vendorProfileRepository;
    @Autowired private ServicePackageRepository servicePackageRepository;
    @Autowired private BookingRepository bookingRepository;
    @Autowired private BannerRepository bannerRepository;
    @Autowired private PromotionCouponRepository couponRepository;
    @Autowired private PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(String... args) {
        System.out.println("====================================================================");
        System.out.println(">>> [Shaadi Setu] MySQL Database 'shadisetu_db' Connected Successfully!");

        // 1. Ensure Super Admin exists
        if (!userRepository.existsByPhone("9999999999")) {
            User admin = new User("Shaadi Setu Super Admin", "9999999999", "admin@shadisetu.com", passwordEncoder.encode("admin123"), Role.ROLE_ADMIN);
            userRepository.save(admin);
        }

        // 2. Ensure Categories exist
        if (categoryRepository.count() == 0) {
            Category catPhoto = new Category("Camera & Photography", "camera-photography", "camera", "Candid wedding photographers, pre-wedding shoots, drone video and cinematic films.", 25000.0, "[{\"name\":\"droneCoverage\",\"type\":\"boolean\"},{\"name\":\"albumCount\",\"type\":\"number\"}]");
            Category catCars = new Category("Luxury Cars", "luxury-cars", "car", "Vintage Rolls Royce, Audi, BMW, Mercedes for groom entry and doli.", 15000.0, "[{\"name\":\"carModel\",\"type\":\"select\"},{\"name\":\"flowerDecorIncluded\",\"type\":\"boolean\"}]");
            Category catDj = new Category("DJ & Sound Systems", "dj-sound-systems", "disc", "Concert line-array sound systems, moving heads, LED walls, and celebrity DJs.", 30000.0, "[{\"name\":\"ledWallSize\",\"type\":\"string\"},{\"name\":\"bassCount\",\"type\":\"number\"}]");
            Category catDecor = new Category("Decorators & Mandap", "decorators-mandap", "flower", "Theme stages, floral mandap, grand entrance gates, and ambient lighting.", 50000.0, "[{\"name\":\"themeType\",\"type\":\"select\"}]");
            Category catBaaja = new Category("Baaja & Brass Band", "baaja-brass-band", "music", "Traditional royal brass band, Punjabi dhol, Tasha, and illuminating lights trolley.", 18000.0, "[{\"name\":\"musiciansCount\",\"type\":\"number\"}]");
            Category catCatering = new Category("Royal Catering", "royal-catering", "utensils", "Multi-cuisine live counters, dessert lounges, and traditional royal feast.", 600.0, "[{\"name\":\"perPlatePricing\",\"type\":\"boolean\"}]");

            categoryRepository.saveAll(List.of(catPhoto, catCars, catDj, catDecor, catBaaja, catCatering));
        }

        // 3. Ensure Banners exist
        if (bannerRepository.count() == 0) {
            Banner b1 = new Banner("Grand Wedding Season 2026", "Book Top Photographers & Luxury Cars with 15% Cashback", "https://images.unsplash.com/photo-1519741497674-611481863552", "/services/camera-photography", 1);
            Banner b2 = new Banner("Royal Baraat Entries", "Vintage & Luxury Cars starting at ₹14,999", "https://images.unsplash.com/photo-1549399542-7e3f8b79c341", "/services/luxury-cars", 2);
            Banner b3 = new Banner("Electric DJ & Live Sangeet", "Concert sound systems & celebrity DJs", "https://images.unsplash.com/photo-1470225620780-dba8ba36b745", "/services/dj-sound-systems", 3);
            bannerRepository.saveAll(List.of(b1, b2, b3));
        }

        // 4. Ensure Coupons exist
        if (couponRepository.count() == 0) {
            PromotionCoupon c1 = new PromotionCoupon("SHADI2026", 15.0, 5000.0, 20000.0, LocalDate.now().plusMonths(6));
            PromotionCoupon c2 = new PromotionCoupon("WELCOME500", 10.0, 1000.0, 5000.0, LocalDate.now().plusMonths(12));
            couponRepository.saveAll(List.of(c1, c2));
        }

        System.out.println(">>> [Shaadi Setu] Clean state ready: All dummy vendors, users and bookings removed.");
        System.out.println(">>> [Shaadi Setu] Ready for live Customer and Vendor registration on both sides!");
        System.out.println("====================================================================");
    }
}
