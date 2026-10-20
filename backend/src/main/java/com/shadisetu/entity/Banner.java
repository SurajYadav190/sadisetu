package com.shadisetu.entity;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "banners")
public class Banner {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    private String subtitle;

    @Column(nullable = false)
    private String imageUrl;

    private String targetRoute; // e.g. "/services/photographers" or "promo_diwali"

    private boolean active = true;

    private LocalDate expiryDate;

    private Integer displayOrder = 1;

    public Banner() {}

    public Banner(String title, String subtitle, String imageUrl, String targetRoute, Integer displayOrder) {
        this.title = title;
        this.subtitle = subtitle;
        this.imageUrl = imageUrl;
        this.targetRoute = targetRoute;
        this.displayOrder = displayOrder;
        this.active = true;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getSubtitle() { return subtitle; }
    public void setSubtitle(String subtitle) { this.subtitle = subtitle; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getTargetRoute() { return targetRoute; }
    public void setTargetRoute(String targetRoute) { this.targetRoute = targetRoute; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public LocalDate getExpiryDate() { return expiryDate; }
    public void setExpiryDate(LocalDate expiryDate) { this.expiryDate = expiryDate; }

    public Integer getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(Integer displayOrder) { this.displayOrder = displayOrder; }
}
