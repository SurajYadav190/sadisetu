package com.shadisetu.repository;

import com.shadisetu.entity.AvailabilitySlot;
import com.shadisetu.entity.VendorProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface AvailabilitySlotRepository extends JpaRepository<AvailabilitySlot, Long> {
    List<AvailabilitySlot> findByVendor(VendorProfile vendor);
    List<AvailabilitySlot> findByVendorId(Long vendorId);
    boolean existsByVendorIdAndBlockedDate(Long vendorId, LocalDate blockedDate);
    void deleteByVendorIdAndBlockedDate(Long vendorId, LocalDate blockedDate);
}
