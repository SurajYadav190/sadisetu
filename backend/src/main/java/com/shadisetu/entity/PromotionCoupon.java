package com.shadisetu.entity;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "coupons")
public class PromotionCoupon {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String code; // e.g. "SHADI2026", "WELCOME500"

    @Column(nullable = false)
    private Double discountPercent; // e.g. 15.0 (15%)

    private Double maxDiscountAmount; // max discount in INR

    private Double minBookingAmount = 0.0;

    private LocalDate validUntil;

    private Integer usageLimit = 1000;
    private Integer usageCount = 0;

    private boolean active = true;

    public PromotionCoupon() {}

    public PromotionCoupon(String code, Double discountPercent, Double maxDiscountAmount, Double minBookingAmount, LocalDate validUntil) {
        this.code = code;
        this.discountPercent = discountPercent;
        this.maxDiscountAmount = maxDiscountAmount;
        this.minBookingAmount = minBookingAmount;
        this.validUntil = validUntil;
        this.active = true;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public Double getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(Double discountPercent) { this.discountPercent = discountPercent; }

    public Double getMaxDiscountAmount() { return maxDiscountAmount; }
    public void setMaxDiscountAmount(Double maxDiscountAmount) { this.maxDiscountAmount = maxDiscountAmount; }

    public Double getMinBookingAmount() { return minBookingAmount; }
    public void setMinBookingAmount(Double minBookingAmount) { this.minBookingAmount = minBookingAmount; }

    public LocalDate getValidUntil() { return validUntil; }
    public void setValidUntil(LocalDate validUntil) { this.validUntil = validUntil; }

    public Integer getUsageLimit() { return usageLimit; }
    public void setUsageLimit(Integer usageLimit) { this.usageLimit = usageLimit; }

    public Integer getUsageCount() { return usageCount; }
    public void setUsageCount(Integer usageCount) { this.usageCount = usageCount; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
