package com.shadisetu.controller;

import com.shadisetu.entity.*;
import com.shadisetu.payload.ApiResponse;
import com.shadisetu.payload.BookingRequest;
import com.shadisetu.payload.ReviewRequest;
import com.shadisetu.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/customer")
public class CustomerController {

    @Autowired
    private CustomerService customerService;

    @GetMapping("/categories")
    public ResponseEntity<ApiResponse<List<Category>>> getCategories() {
        return ResponseEntity.ok(ApiResponse.ok(customerService.getAllCategories()));
    }

    @GetMapping("/banners")
    public ResponseEntity<ApiResponse<List<Banner>>> getBanners() {
        return ResponseEntity.ok(ApiResponse.ok(customerService.getActiveBanners()));
    }

    @GetMapping("/vendors")
    public ResponseEntity<ApiResponse<List<VendorProfile>>> getVendors(
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String search) {
        return ResponseEntity.ok(ApiResponse.ok(customerService.getVendors(categoryId, city, search)));
    }

    @GetMapping("/vendors/{id}")
    public ResponseEntity<ApiResponse<VendorProfile>> getVendorById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(customerService.getVendorById(id)));
    }

    @GetMapping("/vendors/{id}/packages")
    public ResponseEntity<ApiResponse<List<ServicePackage>>> getVendorPackages(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(customerService.getVendorPackages(id)));
    }

    @GetMapping("/vendors/{id}/availability")
    public ResponseEntity<ApiResponse<List<AvailabilitySlot>>> getVendorAvailability(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(customerService.getVendorAvailability(id)));
    }

    @GetMapping("/vendors/{id}/check-slot")
    public ResponseEntity<ApiResponse<Map<String, Object>>> checkDateAvailability(
            @PathVariable Long id, @RequestParam String date) {
        boolean blocked = customerService.isDateBlocked(id, LocalDate.parse(date));
        return ResponseEntity.ok(ApiResponse.ok(Map.of("available", !blocked, "date", date)));
    }

    @GetMapping("/vendors/{id}/reviews")
    public ResponseEntity<ApiResponse<List<Review>>> getVendorReviews(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(customerService.getVendorReviews(id)));
    }

    @PostMapping("/bookings")
    public ResponseEntity<ApiResponse<Booking>> createBooking(
            @AuthenticationPrincipal User customer,
            @RequestBody BookingRequest request) {
        Booking booking = customerService.createBooking(customer, request);
        return ResponseEntity.ok(ApiResponse.ok("Booking placed successfully and escrow held", booking));
    }

    @GetMapping("/bookings")
    public ResponseEntity<ApiResponse<List<Booking>>> getCustomerBookings(@AuthenticationPrincipal User customer) {
        return ResponseEntity.ok(ApiResponse.ok(customerService.getCustomerBookings(customer)));
    }

    @GetMapping("/bookings/{id}")
    public ResponseEntity<ApiResponse<Booking>> getBookingById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(customerService.getBookingById(id)));
    }

    @PostMapping("/reviews")
    public ResponseEntity<ApiResponse<Review>> addReview(
            @AuthenticationPrincipal User customer,
            @RequestBody ReviewRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Review submitted", customerService.addReview(customer, request)));
    }

    @PostMapping("/support/tickets")
    public ResponseEntity<ApiResponse<SupportTicket>> createTicket(
            @AuthenticationPrincipal User customer,
            @RequestBody Map<String, Object> body) {
        String subject = (String) body.get("subject");
        String desc = (String) body.get("description");
        Long bookingId = body.get("bookingId") != null ? Long.valueOf(body.get("bookingId").toString()) : null;
        String priority = (String) body.get("priority");
        SupportTicket t = customerService.createTicket(customer, subject, desc, bookingId, priority);
        return ResponseEntity.ok(ApiResponse.ok("Ticket opened", t));
    }
}
