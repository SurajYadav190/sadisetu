package com.shadisetu.data;

import com.shadisetu.entity.*;
import com.shadisetu.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
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
        if (userRepository.count() > 0) {
            return; // Data already seeded
        }

        System.out.println(">>> [Shaadi Setu] Seeding initial marketplace data...");

        // 1. Super Admin
        User admin = new User("Shaadi Setu Super Admin", "9999999999", "admin@shadisetu.com", passwordEncoder.encode("admin123"), Role.ROLE_ADMIN);
        userRepository.save(admin);

        // 2. Categories
        Category catPhoto = new Category("Camera & Photography", "camera-photography", "camera", "Candid wedding photographers, pre-wedding shoots, drone video and cinematic films.", 25000.0, "[{\"name\":\"droneCoverage\",\"type\":\"boolean\"},{\"name\":\"albumCount\",\"type\":\"number\"}]");
        Category catCars = new Category("Luxury Cars", "luxury-cars", "car", "Vintage Rolls Royce, Audi, BMW, Mercedes for groom entry and doli.", 15000.0, "[{\"name\":\"carModel\",\"type\":\"select\"},{\"name\":\"flowerDecorIncluded\",\"type\":\"boolean\"}]");
        Category catDj = new Category("DJ & Sound Systems", "dj-sound-systems", "disc", "Concert line-array sound systems, moving heads, LED walls, and celebrity DJs.", 30000.0, "[{\"name\":\"ledWallSize\",\"type\":\"string\"},{\"name\":\"bassCount\",\"type\":\"number\"}]");
        Category catDecor = new Category("Decorators & Mandap", "decorators-mandap", "flower", "Theme stages, floral mandap, grand entrance gates, and ambient lighting.", 50000.0, "[{\"name\":\"themeType\",\"type\":\"select\"}]");
        Category catBaaja = new Category("Baaja & Brass Band", "baaja-brass-band", "music", "Traditional royal brass band, Punjabi dhol, Tasha, and illuminating lights trolley.", 18000.0, "[{\"name\":\"musiciansCount\",\"type\":\"number\"}]");
        Category catCatering = new Category("Royal Catering", "royal-catering", "utensils", "Multi-cuisine live counters, dessert lounges, and traditional royal feast.", 600.0, "[{\"name\":\"perPlatePricing\",\"type\":\"boolean\"}]");

        categoryRepository.saveAll(List.of(catPhoto, catCars, catDj, catDecor, catBaaja, catCatering));

        // 3. Customers
        User customer1 = new User("Rahul Sharma", "9876543210", "rahul.sharma@example.com", passwordEncoder.encode("customer123"), Role.ROLE_CUSTOMER);
        User customer2 = new User("Pooja Verma", "9876543211", "pooja.verma@example.com", passwordEncoder.encode("customer123"), Role.ROLE_CUSTOMER);
        userRepository.saveAll(List.of(customer1, customer2));

        // 4. Vendors
        // Vendor 1: Photography
        User vendorUser1 = new User("Vikramaditya Studios", "9811122233", "vikram@lenscraft.com", passwordEncoder.encode("vendor123"), Role.ROLE_VENDOR);
        userRepository.save(vendorUser1);
        VendorProfile vpPhoto = new VendorProfile();
        vpPhoto.setUser(vendorUser1);
        vpPhoto.setCategory(catPhoto);
        vpPhoto.setBusinessName("LensCraft Cinematic Weddings");
        vpPhoto.setBio("Award-winning wedding photography collective capturing timeless emotions with 4K cinematography & drone.");
        vpPhoto.setCity("Delhi NCR");
        vpPhoto.setAddress("42 Connaught Place, New Delhi");
        vpPhoto.setLatitude(28.6328);
        vpPhoto.setLongitude(77.2197);
        vpPhoto.setKycStatus("VERIFIED");
        vpPhoto.setRating(4.9);
        vpPhoto.setReviewCount(48);
        vpPhoto.setCommissionRate(10.0);
        vpPhoto.setWalletBalance(45000.0);
        vpPhoto.setBankAccountNumber("918237461928");
        vpPhoto.setBankIfsc("HDFC0001234");
        vpPhoto.setBankHolderName("LensCraft Media LLP");
        vendorProfileRepository.save(vpPhoto);

        ServicePackage pkgPhotoGold = new ServicePackage();
        pkgPhotoGold.setVendor(vpPhoto);
        pkgPhotoGold.setTitle("Royal Cinematic 2-Day Package");
        pkgPhotoGold.setDescription("2 Candid Photographers + 2 Cinematographers + 4K Drone Coverage + 1 Teaser + 1 Full Length Film + 2 Premium Coffee Table Albums.");
        pkgPhotoGold.setPrice(95000.0);
        pkgPhotoGold.setDiscountedPrice(85000.0);
        pkgPhotoGold.setFeaturesJson("[\"2 Traditional + 2 Candid Shooters\",\"4K Drone Aerial Coverage\",\"Teaser + 45-min Film\",\"2 Luxury Matt Finish Photobooks\"]");
        pkgPhotoGold.setDurationHours(16);
        pkgPhotoGold.setImageUrlsJson("[\"https://images.unsplash.com/photo-1583939003579-730e3918a45a\",\"https://images.unsplash.com/photo-1519741497674-611481863552\"]");
        servicePackageRepository.save(pkgPhotoGold);

        // Vendor 2: Luxury Cars
        User vendorUser2 = new User("Rajputana Royal Wheels", "9822233344", "contact@royalwheels.com", passwordEncoder.encode("vendor123"), Role.ROLE_VENDOR);
        userRepository.save(vendorUser2);
        VendorProfile vpCars = new VendorProfile();
        vpCars.setUser(vendorUser2);
        vpCars.setCategory(catCars);
        vpCars.setBusinessName("Rajputana Luxury & Vintage Cars");
        vpCars.setBio("Chauffeured luxury cars for Baraat entries, vintage convertibles, Audi A6, Jaguar XF, and Mercedes E-Class.");
        vpCars.setCity("Jaipur");
        vpCars.setAddress("Tonk Road, Jaipur, Rajasthan");
        vpCars.setLatitude(26.9124);
        vpCars.setLongitude(75.7873);
        vpCars.setKycStatus("VERIFIED");
        vpCars.setRating(4.8);
        vpCars.setReviewCount(32);
        vpCars.setCommissionRate(10.0);
        vpCars.setWalletBalance(28000.0);
        vendorProfileRepository.save(vpCars);

        ServicePackage pkgCarAudi = new ServicePackage();
        pkgCarAudi.setVendor(vpCars);
        pkgCarAudi.setTitle("Audi A6 / BMW 5 Series Doli Ride");
        pkgCarAudi.setDescription("White luxury sedan with premium fresh floral decoration, uniform driver, fuel included for 80 km.");
        pkgCarAudi.setPrice(22000.0);
        pkgCarAudi.setDiscountedPrice(19999.0);
        pkgCarAudi.setFeaturesJson("[\"White Audi / BMW\",\"Fresh Orchid & Rose Floral Decor\",\"Chauffeured with white gloves\",\"80km / 8 Hours inclusive\"]");
        pkgCarAudi.setDurationHours(8);
        pkgCarAudi.setImageUrlsJson("[\"https://images.unsplash.com/photo-1549399542-7e3f8b79c341\"]");
        servicePackageRepository.save(pkgCarAudi);

        // Vendor 3: DJ & Sound
        User vendorUser3 = new User("DJ Aryan Sound", "9833344455", "aryan@djsound.com", passwordEncoder.encode("vendor123"), Role.ROLE_VENDOR);
        userRepository.save(vendorUser3);
        VendorProfile vpDj = new VendorProfile();
        vpDj.setUser(vendorUser3);
        vpDj.setCategory(catDj);
        vpDj.setBusinessName("DJ Aryan & Bass Mafia Productions");
        vpDj.setBio("High-octane sound setups, JBL VRX Line Arrays, CO2 Jets, Cold Pyros, and LED Trusses for Sangeet & Reception.");
        vpDj.setCity("Lucknow");
        vpDj.setAddress("Gomti Nagar, Lucknow");
        vpDj.setLatitude(26.8467);
        vpDj.setLongitude(80.9462);
        vpDj.setKycStatus("VERIFIED");
        vpDj.setRating(4.7);
        vpDj.setReviewCount(29);
        vpDj.setCommissionRate(10.0);
        vpDj.setWalletBalance(35000.0);
        vendorProfileRepository.save(vpDj);

        ServicePackage pkgDjSangeet = new ServicePackage();
        pkgDjSangeet.setVendor(vpDj);
        pkgDjSangeet.setTitle("Mega Sangeet Bash DJ Setup");
        pkgDjSangeet.setDescription("Dual 15-inch JBL Line Arrays + 4 Subwoofers + Sharpys Moving Heads + Cold Pyro Sparkulars + Live DJ.");
        pkgDjSangeet.setPrice(45000.0);
        pkgDjSangeet.setDiscountedPrice(40000.0);
        pkgDjSangeet.setFeaturesJson("[\"JBL Line Array + 4 Bass\",\"Sharpy Beam Lights & Smoke Machine\",\"4 Cold Pyro Firework Jets\",\"Bollywood / Punjabi Hit DJ\"]");
        pkgDjSangeet.setDurationHours(6);
        pkgDjSangeet.setImageUrlsJson("[\"https://images.unsplash.com/photo-1470225620780-dba8ba36b745\"]");
        servicePackageRepository.save(pkgDjSangeet);

        // 5. Promotional Banners
        Banner b1 = new Banner("Grand Wedding Season 2026", "Book Top Photographers & Luxury Cars with 15% Cashback", "https://images.unsplash.com/photo-1519741497674-611481863552", "/services/camera-photography", 1);
        Banner b2 = new Banner("Royal Baraat Entries", "Vintage & Luxury Cars starting at ₹14,999", "https://images.unsplash.com/photo-1549399542-7e3f8b79c341", "/services/luxury-cars", 2);
        Banner b3 = new Banner("Electric DJ & Live Sangeet", "Concert sound systems & celebrity DJs", "https://images.unsplash.com/photo-1470225620780-dba8ba36b745", "/services/dj-sound-systems", 3);
        bannerRepository.saveAll(List.of(b1, b2, b3));

        // 6. Discount Coupons
        PromotionCoupon c1 = new PromotionCoupon("SHADI2026", 15.0, 5000.0, 20000.0, LocalDate.now().plusMonths(6));
        PromotionCoupon c2 = new PromotionCoupon("WELCOME500", 10.0, 1000.0, 5000.0, LocalDate.now().plusMonths(12));
        couponRepository.saveAll(List.of(c1, c2));

        // 7. Initial Bookings
        Booking bkg1 = new Booking();
        bkg1.setBookingNumber("SS-2026001");
        bkg1.setCustomer(customer1);
        bkg1.setVendor(vpPhoto);
        bkg1.setServicePackage(pkgPhotoGold);
        bkg1.setBookingDate(LocalDate.now().plusDays(14));
        bkg1.setTimeSlot("10:00 AM - 11:00 PM");
        bkg1.setVenueAddress("The Grand Palace Resort, GT Karnal Road, Delhi");
        bkg1.setStatus("ACCEPTED");
        bkg1.setTotalAmount(85000.0);
        bkg1.setCommissionAmount(8500.0);
        bkg1.setPayoutAmount(76500.0);
        bkg1.setPaymentStatus("ESCROW_HELD");
        bkg1.setPaymentTransactionId("TXN-RAZOR-90812");
        bkg1.setCustomerNotes("Please ensure drone coverage during the varmala ceremony.");
        bkg1.setCreatedAt(LocalDateTime.now().minusDays(2));
        bookingRepository.save(bkg1);

        Booking bkg2 = new Booking();
        bkg2.setBookingNumber("SS-2026002");
        bkg2.setCustomer(customer2);
        bkg2.setVendor(vpCars);
        bkg2.setServicePackage(pkgCarAudi);
        bkg2.setBookingDate(LocalDate.now().plusDays(20));
        bkg2.setTimeSlot("4:00 PM - 12:00 AM");
        bkg2.setVenueAddress("Rambagh Palace Lawn, Jaipur");
        bkg2.setStatus("PENDING");
        bkg2.setTotalAmount(19999.0);
        bkg2.setCommissionAmount(1999.9);
        bkg2.setPayoutAmount(17999.1);
        bkg2.setPaymentStatus("ESCROW_HELD");
        bkg2.setPaymentTransactionId("TXN-UPI-44810");
        bkg2.setCustomerNotes("White flowers only for decor please.");
        bkg2.setCreatedAt(LocalDateTime.now().minusHours(4));
        bookingRepository.save(bkg2);

        System.out.println(">>> [Shaadi Setu] Seeding completed successfully!");
    }
}
