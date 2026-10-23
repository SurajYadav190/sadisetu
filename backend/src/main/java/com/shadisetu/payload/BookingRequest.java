package com.shadisetu.payload;

import java.time.LocalDate;

public class BookingRequest {
    private Long vendorId;
    private Long packageId;
    private LocalDate bookingDate;
    private String timeSlot;
    private String venueAddress;
    private String customerNotes;
    private String promoCode;
    private String selectedVarieties;
    private Integer durationHours;
    private Double customTotalAmount;

    public BookingRequest() {}

    public Long getVendorId() { return vendorId; }
    public void setVendorId(Long vendorId) { this.vendorId = vendorId; }

    public Long getPackageId() { return packageId; }
    public void setPackageId(Long packageId) { this.packageId = packageId; }

    public LocalDate getBookingDate() { return bookingDate; }
    public void setBookingDate(LocalDate bookingDate) { this.bookingDate = bookingDate; }

    public String getTimeSlot() { return timeSlot; }
    public void setTimeSlot(String timeSlot) { this.timeSlot = timeSlot; }

    public String getVenueAddress() { return venueAddress; }
    public void setVenueAddress(String venueAddress) { this.venueAddress = venueAddress; }

    public String getCustomerNotes() { return customerNotes; }
    public void setCustomerNotes(String customerNotes) { this.customerNotes = customerNotes; }

    public String getPromoCode() { return promoCode; }
    public void setPromoCode(String promoCode) { this.promoCode = promoCode; }

    public String getSelectedVarieties() { return selectedVarieties; }
    public void setSelectedVarieties(String selectedVarieties) { this.selectedVarieties = selectedVarieties; }

    public Integer getDurationHours() { return durationHours; }
    public void setDurationHours(Integer durationHours) { this.durationHours = durationHours; }

    public Double getCustomTotalAmount() { return customTotalAmount; }
    public void setCustomTotalAmount(Double customTotalAmount) { this.customTotalAmount = customTotalAmount; }
}
