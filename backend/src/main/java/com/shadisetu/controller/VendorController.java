package com.shadisetu.controller;

import com.shadisetu.entity.*;
import com.shadisetu.payload.ApiResponse;
import com.shadisetu.payload.StatusUpdateRequest;
import com.shadisetu.service.VendorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/vendor")
public class VendorController {

    @Autowired
    private VendorService vendorService;

    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<VendorProfile>> getProfile(@AuthenticationPrincipal User vendorUser) {
        return ResponseEntity.ok(ApiResponse.ok(vendorService.getProfileByUser(vendorUser)));
    }

    @PutMapping("/profile")
    public ResponseEntity<ApiResponse<VendorProfile>> updateProfile(
            @AuthenticationPrincipal User vendorUser,
            @RequestBody VendorProfile updatedData) {
        return ResponseEntity.ok(ApiResponse.ok(vendorService.updateProfile(vendorUser, updatedData)));
    }

    @PostMapping("/kyc")
    public ResponseEntity<ApiResponse<VendorProfile>> submitKyc(
            @AuthenticationPrincipal User vendorUser,
            @RequestBody Map<String, Object> body) {
        String licenseUrl = (String) body.get("businessLicenseUrl");
        String idProofUrl = (String) body.get("idProofUrl");
        Long categoryId = body.get("categoryId") != null ? Long.valueOf(body.get("categoryId").toString()) : null;
        return ResponseEntity.ok(ApiResponse.ok("KYC submitted for verification", vendorService.submitKyc(vendorUser, licenseUrl, idProofUrl, categoryId)));
    }

    @PostMapping("/toggle-online")
    public ResponseEntity<ApiResponse<VendorProfile>> toggleOnline(@AuthenticationPrincipal User vendorUser) {
        return ResponseEntity.ok(ApiResponse.ok(vendorService.toggleOnlineStatus(vendorUser)));
    }

    @GetMapping("/packages")
    public ResponseEntity<ApiResponse<List<ServicePackage>>> getPackages(@AuthenticationPrincipal User vendorUser) {
        return ResponseEntity.ok(ApiResponse.ok(vendorService.getPackages(vendorUser)));
    }

    @PostMapping("/packages")
    public ResponseEntity<ApiResponse<ServicePackage>> savePackage(
            @AuthenticationPrincipal User vendorUser,
            @RequestBody ServicePackage pkg) {
        return ResponseEntity.ok(ApiResponse.ok("Package saved", vendorService.savePackage(vendorUser, pkg)));
    }

    @DeleteMapping("/packages/{id}")
    public ResponseEntity<ApiResponse<Void>> deletePackage(
            @AuthenticationPrincipal User vendorUser,
            @PathVariable Long id) {
        vendorService.deletePackage(vendorUser, id);
        return ResponseEntity.ok(ApiResponse.ok("Package deleted", null));
    }

    @GetMapping("/calendar")
    public ResponseEntity<ApiResponse<List<AvailabilitySlot>>> getCalendar(@AuthenticationPrincipal User vendorUser) {
        return ResponseEntity.ok(ApiResponse.ok(vendorService.getBlockedDates(vendorUser)));
    }

    @PostMapping("/calendar/block")
    public ResponseEntity<ApiResponse<AvailabilitySlot>> blockDate(
            @AuthenticationPrincipal User vendorUser,
            @RequestBody Map<String, String> body) {
        LocalDate date = LocalDate.parse(body.get("date"));
        String reason = body.get("reason");
        return ResponseEntity.ok(ApiResponse.ok("Date blocked successfully", vendorService.blockDate(vendorUser, date, reason)));
    }

    @PostMapping("/calendar/unblock")
    public ResponseEntity<ApiResponse<Void>> unblockDate(
            @AuthenticationPrincipal User vendorUser,
            @RequestBody Map<String, String> body) {
        LocalDate date = LocalDate.parse(body.get("date"));
        vendorService.unblockDate(vendorUser, date);
        return ResponseEntity.ok(ApiResponse.ok("Date unblocked", null));
    }

    @GetMapping("/bookings")
    public ResponseEntity<ApiResponse<List<Booking>>> getBookings(@AuthenticationPrincipal User vendorUser) {
        return ResponseEntity.ok(ApiResponse.ok(vendorService.getVendorBookings(vendorUser)));
    }

    @PutMapping("/bookings/{id}/status")
    public ResponseEntity<ApiResponse<Booking>> updateBookingStatus(
            @AuthenticationPrincipal User vendorUser,
            @PathVariable Long id,
            @RequestBody StatusUpdateRequest request) {
        Booking updated = vendorService.updateBookingStatus(vendorUser, id, request.getStatus(), request.getReasonOrNotes());
        return ResponseEntity.ok(ApiResponse.ok("Booking status updated to " + request.getStatus(), updated));
    }

    @GetMapping("/earnings")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getEarnings(@AuthenticationPrincipal User vendorUser) {
        return ResponseEntity.ok(ApiResponse.ok(vendorService.getEarningsSummary(vendorUser)));
    }
}
