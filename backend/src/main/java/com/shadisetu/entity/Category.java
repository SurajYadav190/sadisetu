package com.shadisetu.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "categories")
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String name;

    @Column(nullable = false, unique = true)
    private String slug;

    private String icon;

    @Column(length = 1000)
    private String description;

    private Double startingPrice = 0.0;

    private boolean active = true;

    @Column(columnDefinition = "TEXT")
    private String dynamicFieldsJson; // e.g. [{"name":"carModel","type":"select"}, {"name":"droneCoverage","type":"boolean"}]

    public Category() {}

    public Category(String name, String slug, String icon, String description, Double startingPrice, String dynamicFieldsJson) {
        this.name = name;
        this.slug = slug;
        this.icon = icon;
        this.description = description;
        this.startingPrice = startingPrice;
        this.dynamicFieldsJson = dynamicFieldsJson;
        this.active = true;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Double getStartingPrice() { return startingPrice; }
    public void setStartingPrice(Double startingPrice) { this.startingPrice = startingPrice; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public String getDynamicFieldsJson() { return dynamicFieldsJson; }
    public void setDynamicFieldsJson(String dynamicFieldsJson) { this.dynamicFieldsJson = dynamicFieldsJson; }
}
