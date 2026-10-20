package com.shadisetu.service;

import com.shadisetu.entity.*;
import com.shadisetu.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class VendorService {

    @Autowired
    private VendorProfileRepository vendorProfileRepository;

    @Autowired
    private ServicePackageRepository servicePackageRepository;

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private AvailabilitySlotRepository availabilitySlotRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    public VendorProfile getProfileByUser(User user) {
        return vendorProfileRepository.findByUser(user)
                .orElseThrow(() -> new RuntimeException("Vendor profile not found for user: " + user.getId()));
    }

    public VendorProfile getProfileById(Long id) {
        return vendorProfileRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vendor profile not found with id: " + id));
    }

    @Transactional
    public VendorProfile updateProfile(User user, VendorProfile updatedData) {
        VendorProfile profile = getProfileByUser(user);
        if (updatedData.getBusinessName() != null) profile.setBusinessName(updatedData.getBusinessName());
        if (updatedData.getBio() != null) profile.setBio(updatedData.getBio());
        if (updatedData.getAddress() != null) profile.setAddress(updatedData.getAddress());
        if (updatedData.getCity() != null) profile.setCity(updatedData.getCity());
        if (updatedData.getLatitude() != null) profile.setLatitude(updatedData.getLatitude());
        if (updatedData.getLongitude() != null) profile.setLongitude(updatedData.getLongitude());
        if (updatedData.getBankAccountNumber() != null) profile.setBankAccountNumber(updatedData.getBankAccountNumber());
        if (updatedData.getBankIfsc() != null) profile.setBankIfsc(updatedData.getBankIfsc());
        if (updatedData.getBankHolderName() != null) profile.setBankHolderName(updatedData.getBankHolderName());

        return vendorProfileRepository.save(profile);
    }

    @Transactional
    public VendorProfile submitKyc(User user, String licenseUrl, String idProofUrl, Long categoryId) {
        VendorProfile profile = getProfileByUser(user);
        profile.setBusinessLicenseUrl(licenseUrl);
        profile.setIdProofUrl(idProofUrl);
        if (categoryId != null) {
            categoryRepository.findById(categoryId).ifPresent(profile::setCategory);
        }
        profile.setKycStatus("PENDING");
        return vendorProfileRepository.save(profile);
    }

    public VendorProfile toggleOnlineStatus(User user) {
        VendorProfile profile = getProfileByUser(user);
        profile.setOnline(!profile.isOnline());
        return vendorProfileRepository.save(profile);
    }

    public List<ServicePackage> getPackages(User user) {
        VendorProfile profile = getProfileByUser(user);
        return servicePackageRepository.findByVendorAndActiveTrue(profile);
    }

    @Transactional
    public ServicePackage savePackage(User user, ServicePackage pkg) {
        VendorProfile profile = getProfileByUser(user);
        pkg.setVendor(profile);
        pkg.setActive(true);
        return servicePackageRepository.save(pkg);
    }

    @Transactional
    public void deletePackage(User user, Long packageId) {
        VendorProfile profile = getProfileByUser(user);
        ServicePackage pkg = servicePackageRepository.findById(packageId)
                .orElseThrow(() -> new RuntimeException("Package not found: " + packageId));
        if (pkg.getVendor().getId().equals(profile.getId())) {
            pkg.setActive(false);
            servicePackageRepository.save(pkg);
        }
    }

    public List<AvailabilitySlot> getBlockedDates(User user) {
        VendorProfile profile = getProfileByUser(user);
        return availabilitySlotRepository.findByVendor(profile);
    }

    @Transactional
    public AvailabilitySlot blockDate(User user, LocalDate date, String reason) {
        VendorProfile profile = getProfileByUser(user);
        if (availabilitySlotRepository.existsByVendorIdAndBlockedDate(profile.getId(), date)) {
            throw new RuntimeException("Date already blocked");
        }
        AvailabilitySlot slot = new AvailabilitySlot(profile, date, reason != null ? reason : "Unavailable");
        return availabilitySlotRepository.save(slot);
    }

    @Transactional
    public void unblockDate(User user, LocalDate date) {
        VendorProfile profile = getProfileByUser(user);
        availabilitySlotRepository.deleteByVendorIdAndBlockedDate(profile.getId(), date);
    }

    public List<Booking> getVendorBookings(User user) {
        VendorProfile profile = getProfileByUser(user);
        return bookingRepository.findByVendorOrderByCreatedAtDesc(profile);
    }

    @Transactional
    public Booking updateBookingStatus(User user, Long bookingId, String status, String note) {
        VendorProfile profile = getProfileByUser(user);
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Booking not found: " + bookingId));

        if (!booking.getVendor().getId().equals(profile.getId())) {
            throw new RuntimeException("Unauthorized booking action");
        }

        booking.setStatus(status.toUpperCase());
        if (note != null) {
            booking.setVendorNotes(note);
        }
        booking.setUpdatedAt(LocalDateTime.now());

        // When order is marked COMPLETED, release escrow to vendor's wallet
        if ("COMPLETED".equalsIgnoreCase(status) && "ESCROW_HELD".equals(booking.getPaymentStatus())) {
            booking.setPaymentStatus("RELEASED");
            double currentWallet = profile.getWalletBalance() != null ? profile.getWalletBalance() : 0.0;
            profile.setWalletBalance(currentWallet + (booking.getPayoutAmount() != null ? booking.getPayoutAmount() : 0.0));
            vendorProfileRepository.save(profile);
        }

        return bookingRepository.save(booking);
    }

    public Map<String, Object> getEarningsSummary(User user) {
        VendorProfile profile = getProfileByUser(user);
        List<Booking> bookings = bookingRepository.findByVendorOrderByCreatedAtDesc(profile);

        double totalEarned = bookings.stream()
                .filter(b -> "COMPLETED".equalsIgnoreCase(b.getStatus()))
                .mapToDouble(b -> b.getPayoutAmount() != null ? b.getPayoutAmount() : 0.0)
                .sum();

        long activeOrders = bookings.stream()
                .filter(b -> List.of("PENDING", "ACCEPTED", "IN_PROGRESS").contains(b.getStatus()))
                .count();

        long completedOrders = bookings.stream()
                .filter(b -> "COMPLETED".equalsIgnoreCase(b.getStatus()))
                .count();

        Map<String, Object> res = new HashMap<>();
        res.put("walletBalance", profile.getWalletBalance() != null ? profile.getWalletBalance() : 0.0);
        res.put("totalEarned", totalEarned);
        res.put("activeOrders", activeOrders);
        res.put("completedOrders", completedOrders);
        res.put("rating", profile.getRating());
        res.put("reviewCount", profile.getReviewCount());
        res.put("isOnline", profile.isOnline());
        return res;
    }
}
