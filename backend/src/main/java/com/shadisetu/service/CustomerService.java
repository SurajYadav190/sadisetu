package com.shadisetu.service;

import com.shadisetu.entity.*;
import com.shadisetu.payload.BookingRequest;
import com.shadisetu.payload.ReviewRequest;
import com.shadisetu.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class CustomerService {

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private VendorProfileRepository vendorProfileRepository;

    @Autowired
    private ServicePackageRepository servicePackageRepository;

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private AvailabilitySlotRepository availabilitySlotRepository;

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private BannerRepository bannerRepository;

    @Autowired
    private PromotionCouponRepository couponRepository;

    @Autowired
    private SupportTicketRepository supportTicketRepository;

    public List<Category> getAllCategories() {
        return categoryRepository.findByActiveTrue();
    }

    public List<Banner> getActiveBanners() {
        return bannerRepository.findByActiveTrueOrderByDisplayOrderAsc();
    }

    public List<VendorProfile> getVendors(Long categoryId, String city, String search) {
        return vendorProfileRepository.searchVerifiedVendors(categoryId, city, search);
    }

    public VendorProfile getVendorById(Long id) {
        return vendorProfileRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vendor not found with id: " + id));
    }

    public List<ServicePackage> getVendorPackages(Long vendorId) {
        return servicePackageRepository.findByVendorIdAndActiveTrue(vendorId);
    }

    public List<AvailabilitySlot> getVendorAvailability(Long vendorId) {
        return availabilitySlotRepository.findByVendorId(vendorId);
    }

    public boolean isDateBlocked(Long vendorId, LocalDate date) {
        return availabilitySlotRepository.existsByVendorIdAndBlockedDate(vendorId, date);
    }

    public List<Review> getVendorReviews(Long vendorId) {
        return reviewRepository.findByVendorIdOrderByCreatedAtDesc(vendorId);
    }

    @Transactional
    public Booking createBooking(User customer, BookingRequest request) {
        VendorProfile vendor = vendorProfileRepository.findById(request.getVendorId())
                .orElseThrow(() -> new RuntimeException("Vendor not found"));

        ServicePackage pkg = servicePackageRepository.findById(request.getPackageId())
                .orElseThrow(() -> new RuntimeException("Package not found"));

        if (availabilitySlotRepository.existsByVendorIdAndBlockedDate(vendor.getId(), request.getBookingDate())) {
            throw new RuntimeException("The selected vendor is not available on " + request.getBookingDate());
        }

        double baseAmount = pkg.getDiscountedPrice() != null ? pkg.getDiscountedPrice() : pkg.getPrice();
        double discount = 0.0;

        if (request.getPromoCode() != null && !request.getPromoCode().isBlank()) {
            PromotionCoupon coupon = couponRepository.findByCodeIgnoreCaseAndActiveTrue(request.getPromoCode()).orElse(null);
            if (coupon != null && (coupon.getValidUntil() == null || !coupon.getValidUntil().isBefore(LocalDate.now()))) {
                if (baseAmount >= (coupon.getMinBookingAmount() != null ? coupon.getMinBookingAmount() : 0.0)) {
                    discount = (baseAmount * coupon.getDiscountPercent()) / 100.0;
                    if (coupon.getMaxDiscountAmount() != null && discount > coupon.getMaxDiscountAmount()) {
                        discount = coupon.getMaxDiscountAmount();
                    }
                    coupon.setUsageCount(coupon.getUsageCount() + 1);
                    couponRepository.save(coupon);
                }
            }
        }

        double finalAmount;
        if (request.getCustomTotalAmount() != null && request.getCustomTotalAmount() > 0) {
            finalAmount = request.getCustomTotalAmount();
        } else {
            finalAmount = Math.max(0.0, baseAmount - discount);
        }
        double platformCommission = (finalAmount * (vendor.getCommissionRate() != null ? vendor.getCommissionRate() : 10.0)) / 100.0;
        double vendorPayout = finalAmount - platformCommission;

        Booking booking = new Booking();
        booking.setBookingNumber("SS-" + System.currentTimeMillis() % 10000000);
        booking.setCustomer(customer);
        booking.setVendor(vendor);
        booking.setServicePackage(pkg);
        booking.setBookingDate(request.getBookingDate());
        booking.setTimeSlot(request.getTimeSlot() != null ? request.getTimeSlot() : "Full Day");
        booking.setVenueAddress(request.getVenueAddress());
        booking.setStatus("PENDING");
        booking.setSelectedVarieties(request.getSelectedVarieties());
        booking.setDurationHours(request.getDurationHours() != null ? request.getDurationHours() : (pkg.getDurationHours() != null ? pkg.getDurationHours() : 8));
        booking.setTotalAmount(finalAmount);
        booking.setCommissionAmount(platformCommission);
        booking.setPayoutAmount(vendorPayout);
        booking.setPaymentStatus("ESCROW_HELD"); // Held in escrow until job completion
        booking.setPaymentTransactionId("TXN-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        booking.setCustomerNotes(request.getCustomerNotes());
        booking.setCreatedAt(LocalDateTime.now());
        booking.setUpdatedAt(LocalDateTime.now());

        return bookingRepository.save(booking);
    }

    public List<Booking> getCustomerBookings(User customer) {
        return bookingRepository.findByCustomerOrderByCreatedAtDesc(customer);
    }

    public Booking getBookingById(Long id) {
        return bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking not found: " + id));
    }

    @Transactional
    public Review addReview(User customer, ReviewRequest request) {
        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new RuntimeException("Booking not found: " + request.getBookingId()));

        if (!booking.getCustomer().getId().equals(customer.getId())) {
            throw new RuntimeException("You can only review your own bookings");
        }

        Review review = new Review();
        review.setBooking(booking);
        review.setCustomer(customer);
        review.setVendor(booking.getVendor());
        review.setRating(request.getRating());
        review.setComment(request.getComment());
        review.setMediaUrlsJson(request.getMediaUrlsJson());
        review.setCreatedAt(LocalDateTime.now());
        review = reviewRepository.save(review);

        // Recalculate vendor average rating
        List<Review> allReviews = reviewRepository.findByVendorIdOrderByCreatedAtDesc(booking.getVendor().getId());
        double avg = allReviews.stream().mapToInt(Review::getRating).average().orElse(5.0);
        VendorProfile vp = booking.getVendor();
        vp.setRating(Math.round(avg * 10.0) / 10.0);
        vp.setReviewCount(allReviews.size());
        vendorProfileRepository.save(vp);

        return review;
    }

    public SupportTicket createTicket(User user, String subject, String description, Long bookingId, String priority) {
        SupportTicket ticket = new SupportTicket();
        ticket.setTicketNumber("TICK-" + (System.currentTimeMillis() % 1000000));
        ticket.setUser(user);
        if (bookingId != null) {
            bookingRepository.findById(bookingId).ifPresent(ticket::setBooking);
        }
        ticket.setSubject(subject);
        ticket.setDescription(description);
        ticket.setPriority(priority != null ? priority : "MEDIUM");
        ticket.setStatus("OPEN");
        ticket.setCreatedAt(LocalDateTime.now());
        return supportTicketRepository.save(ticket);
    }
}
