package com.shadisetu.repository;

import com.shadisetu.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    List<Review> findByVendorIdOrderByCreatedAtDesc(Long vendorId);
    List<Review> findByCustomerIdOrderByCreatedAtDesc(Long customerId);
    boolean existsByBookingId(Long bookingId);
}
