package com.shadisetu.entity;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "availability_slots")
public class AvailabilitySlot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vendor_id", nullable = false)
    private VendorProfile vendor;

    @Column(nullable = false)
    private LocalDate blockedDate;

    private String reason; // "Booked Offline", "Festival Holiday", etc.

    private boolean isFullDay = true;

    public AvailabilitySlot() {}

    public AvailabilitySlot(VendorProfile vendor, LocalDate blockedDate, String reason) {
        this.vendor = vendor;
        this.blockedDate = blockedDate;
        this.reason = reason;
        this.isFullDay = true;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public VendorProfile getVendor() { return vendor; }
    public void setVendor(VendorProfile vendor) { this.vendor = vendor; }

    public LocalDate getBlockedDate() { return blockedDate; }
    public void setBlockedDate(LocalDate blockedDate) { this.blockedDate = blockedDate; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public boolean isFullDay() { return isFullDay; }
    public void setFullDay(boolean fullDay) { isFullDay = fullDay; }
}
