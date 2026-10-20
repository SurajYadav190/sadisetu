package com.shadisetu.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "service_packages")
public class ServicePackage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vendor_id", nullable = false)
    private VendorProfile vendor;

    @Column(nullable = false)
    private String title;

    @Column(length = 2000)
    private String description;

    @Column(nullable = false)
    private Double price;

    private Double discountedPrice;

    @Column(columnDefinition = "TEXT")
    private String featuresJson; // e.g. ["Traditional & Candid Coverage", "Drone Shoot", "Teaser + Full Video"]

    @Column(columnDefinition = "TEXT")
    private String imageUrlsJson; // e.g. ["url1", "url2"]

    private Integer durationHours = 8;

    private boolean active = true;

    public ServicePackage() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public VendorProfile getVendor() { return vendor; }
    public void setVendor(VendorProfile vendor) { this.vendor = vendor; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Double getPrice() { return price; }
    public void setPrice(Double price) { this.price = price; }

    public Double getDiscountedPrice() { return discountedPrice; }
    public void setDiscountedPrice(Double discountedPrice) { this.discountedPrice = discountedPrice; }

    public String getFeaturesJson() { return featuresJson; }
    public void setFeaturesJson(String featuresJson) { this.featuresJson = featuresJson; }

    public String getImageUrlsJson() { return imageUrlsJson; }
    public void setImageUrlsJson(String imageUrlsJson) { this.imageUrlsJson = imageUrlsJson; }

    public Integer getDurationHours() { return durationHours; }
    public void setDurationHours(Integer durationHours) { this.durationHours = durationHours; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
