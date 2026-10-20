package com.shadisetu.service;

import com.shadisetu.entity.*;
import com.shadisetu.payload.DashboardStatsDto;
import com.shadisetu.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Service
public class AdminService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private VendorProfileRepository vendorProfileRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private BannerRepository bannerRepository;

    @Autowired
    private PromotionCouponRepository couponRepository;

    @Autowired
    private SupportTicketRepository ticketRepository;

    public DashboardStatsDto getDashboardStats() {
        DashboardStatsDto stats = new DashboardStatsDto();
        stats.setTotalUsers(userRepository.count());
        stats.setTotalCustomers(userRepository.countByRole(Role.ROLE_CUSTOMER));
        stats.setTotalVendors(userRepository.countByRole(Role.ROLE_VENDOR));
        stats.setPendingKycCount(vendorProfileRepository.countByKycStatus("PENDING"));
        stats.setVerifiedVendorsCount(vendorProfileRepository.countByKycStatus("VERIFIED"));

        stats.setTotalBookings(bookingRepository.count());
        stats.setPendingBookings(bookingRepository.countByStatus("PENDING"));
        stats.setCompletedBookings(bookingRepository.countByStatus("COMPLETED"));

        Double gmv = bookingRepository.sumTotalGrossRevenue();
        stats.setGrossMerchandiseValue(gmv != null ? gmv : 0.0);

        Double commission = bookingRepository.sumTotalPlatformCommission();
        stats.setPlatformCommissionEarned(commission != null ? commission : 0.0);

        stats.setOpenSupportTickets(ticketRepository.countByStatus("OPEN") + ticketRepository.countByStatus("IN_REVIEW"));

        // Mock monthly revenue distribution
        List<Map<String, Object>> monthly = new ArrayList<>();
        String[] months = {"May", "Jun", "Jul", "Aug", "Sep", "Oct"};
        double[] revs = {125000.0, 180000.0, 240000.0, 310000.0, 450000.0, 680000.0};
        for (int i = 0; i < months.length; i++) {
            Map<String, Object> m = new HashMap<>();
            m.put("month", months[i]);
            m.put("revenue", revs[i]);
            monthly.add(m);
        }
        stats.setMonthlyRevenue(monthly);

        // Category breakdown
        List<Map<String, Object>> catStats = new ArrayList<>();
        for (Category c : categoryRepository.findAll()) {
            Map<String, Object> cm = new HashMap<>();
            cm.put("category", c.getName());
            cm.put("count", vendorProfileRepository.findByCategoryIdAndKycStatus(c.getId(), "VERIFIED").size());
            catStats.add(cm);
        }
        stats.setCategoryBreakdown(catStats);

        return stats;
    }

    // 2. User Management
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @Transactional
    public User toggleUserStatus(Long userId) {
        User u = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found: " + userId));
        u.setStatus("ACTIVE".equalsIgnoreCase(u.getStatus()) ? "SUSPENDED" : "ACTIVE");
        return userRepository.save(u);
    }

    // 3. Vendor KYC & Approval
    public List<VendorProfile> getVendorsByKycStatus(String status) {
        if (status == null || status.isBlank() || "ALL".equalsIgnoreCase(status)) {
            return vendorProfileRepository.findAll();
        }
        return vendorProfileRepository.findByKycStatus(status.toUpperCase());
    }

    @Transactional
    public VendorProfile updateVendorKyc(Long vendorId, String status, String reason, Double commissionRate) {
        VendorProfile vp = vendorProfileRepository.findById(vendorId)
                .orElseThrow(() -> new RuntimeException("Vendor not found: " + vendorId));
        vp.setKycStatus(status.toUpperCase());
        if (reason != null) vp.setKycRejectionReason(reason);
        if (commissionRate != null) vp.setCommissionRate(commissionRate);
        return vendorProfileRepository.save(vp);
    }

    // 4. Category Management
    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }

    @Transactional
    public Category saveCategory(Category category) {
        if (category.getSlug() == null || category.getSlug().isBlank()) {
            category.setSlug(category.getName().toLowerCase().replaceAll("[^a-z0-9]", "-"));
        }
        return categoryRepository.save(category);
    }

    @Transactional
    public void deleteCategory(Long categoryId) {
        categoryRepository.deleteById(categoryId);
    }

    // 5. Master Order Desk
    public List<Booking> getAllOrders() {
        return bookingRepository.findAll();
    }

    @Transactional
    public Booking adminOverrideOrderStatus(Long orderId, String newStatus, String reason) {
        Booking booking = bookingRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Booking not found: " + orderId));
        booking.setStatus(newStatus.toUpperCase());
        booking.setCustomerNotes((booking.getCustomerNotes() != null ? booking.getCustomerNotes() + " | " : "") + "Admin Note: " + reason);
        booking.setUpdatedAt(LocalDateTime.now());
        return bookingRepository.save(booking);
    }

    // 6. Commission & Payouts
    @Transactional
    public Map<String, Object> triggerVendorPayout(Long vendorId, Double amount) {
        VendorProfile vp = vendorProfileRepository.findById(vendorId)
                .orElseThrow(() -> new RuntimeException("Vendor not found"));
        double balance = vp.getWalletBalance() != null ? vp.getWalletBalance() : 0.0;
        if (amount > balance) {
            throw new RuntimeException("Requested payout amount exceeds vendor wallet balance");
        }
        vp.setWalletBalance(balance - amount);
        vendorProfileRepository.save(vp);

        Map<String, Object> res = new HashMap<>();
        res.put("success", true);
        res.put("vendorId", vendorId);
        res.put("payoutAmount", amount);
        res.put("remainingWalletBalance", vp.getWalletBalance());
        res.put("transactionRef", "PO-" + System.currentTimeMillis());
        return res;
    }

    // 7. Banner CMS
    public List<Banner> getAllBanners() {
        return bannerRepository.findAllByOrderByDisplayOrderAsc();
    }

    @Transactional
    public Banner saveBanner(Banner banner) {
        return bannerRepository.save(banner);
    }

    @Transactional
    public void deleteBanner(Long bannerId) {
        bannerRepository.deleteById(bannerId);
    }

    // 8. Promotions & Coupons
    public List<PromotionCoupon> getAllCoupons() {
        return couponRepository.findAll();
    }

    @Transactional
    public PromotionCoupon saveCoupon(PromotionCoupon coupon) {
        return couponRepository.save(coupon);
    }

    @Transactional
    public void deleteCoupon(Long couponId) {
        couponRepository.deleteById(couponId);
    }

    // 9. Support & Disputes
    public List<SupportTicket> getAllTickets(String status) {
        if (status != null && !status.isBlank() && !"ALL".equalsIgnoreCase(status)) {
            return ticketRepository.findByStatusOrderByCreatedAtDesc(status.toUpperCase());
        }
        return ticketRepository.findAllByOrderByCreatedAtDesc();
    }

    @Transactional
    public SupportTicket resolveTicket(Long ticketId, String resolutionNotes, String action) {
        SupportTicket t = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new RuntimeException("Ticket not found: " + ticketId));
        t.setStatus("RESOLVED");
        t.setResolutionNotes(resolutionNotes);
        t.setResolvedAt(LocalDateTime.now());

        if ("REFUND".equalsIgnoreCase(action) && t.getBooking() != null) {
            Booking b = t.getBooking();
            b.setPaymentStatus("REFUNDED");
            b.setStatus("CANCELLED");
            bookingRepository.save(b);
        }

        return ticketRepository.save(t);
    }
}
