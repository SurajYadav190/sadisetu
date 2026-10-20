package com.shadisetu.repository;

import com.shadisetu.entity.Booking;
import com.shadisetu.entity.User;
import com.shadisetu.entity.VendorProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface BookingRepository extends JpaRepository<Booking, Long> {
    Optional<Booking> findByBookingNumber(String bookingNumber);
    List<Booking> findByCustomerOrderByCreatedAtDesc(User customer);
    List<Booking> findByCustomerIdOrderByCreatedAtDesc(Long customerId);
    List<Booking> findByVendorOrderByCreatedAtDesc(VendorProfile vendor);
    List<Booking> findByVendorIdOrderByCreatedAtDesc(Long vendorId);
    List<Booking> findByVendorIdAndBookingDate(Long vendorId, LocalDate bookingDate);

    long countByStatus(String status);

    @Query("SELECT COALESCE(SUM(b.totalAmount), 0.0) FROM Booking b WHERE b.paymentStatus IN ('ESCROW_HELD', 'RELEASED')")
    Double sumTotalGrossRevenue();

    @Query("SELECT COALESCE(SUM(b.commissionAmount), 0.0) FROM Booking b WHERE b.paymentStatus = 'RELEASED'")
    Double sumTotalPlatformCommission();

    @Query("SELECT COALESCE(SUM(b.payoutAmount), 0.0) FROM Booking b WHERE b.vendor.id = :vendorId AND b.paymentStatus = 'RELEASED'")
    Double sumTotalVendorEarnings(Long vendorId);
}
