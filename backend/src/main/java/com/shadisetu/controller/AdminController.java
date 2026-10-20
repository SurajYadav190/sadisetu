package com.shadisetu.controller;

import com.shadisetu.entity.*;
import com.shadisetu.payload.ApiResponse;
import com.shadisetu.payload.DashboardStatsDto;
import com.shadisetu.payload.StatusUpdateRequest;
import com.shadisetu.service.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private AdminService adminService;

    // 1. Dashboard Overview
    @GetMapping("/dashboard/stats")
    public ResponseEntity<ApiResponse<DashboardStatsDto>> getDashboardStats() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getDashboardStats()));
    }

    // 2. User Management
    @GetMapping("/users")
    public ResponseEntity<ApiResponse<List<User>>> getAllUsers() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getAllUsers()));
    }

    @PostMapping("/users/{id}/toggle-status")
    public ResponseEntity<ApiResponse<User>> toggleUserStatus(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok("User status updated", adminService.toggleUserStatus(id)));
    }

    // 3. Vendor KYC & Approval
    @GetMapping("/vendors")
    public ResponseEntity<ApiResponse<List<VendorProfile>>> getVendors(@RequestParam(required = false) String kycStatus) {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getVendorsByKycStatus(kycStatus)));
    }

    @PutMapping("/vendors/{id}/kyc-status")
    public ResponseEntity<ApiResponse<VendorProfile>> updateVendorKyc(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body) {
        String status = (String) body.get("status");
        String reason = (String) body.get("reason");
        Double commRate = body.get("commissionRate") != null ? Double.valueOf(body.get("commissionRate").toString()) : null;
        return ResponseEntity.ok(ApiResponse.ok("Vendor KYC updated", adminService.updateVendorKyc(id, status, reason, commRate)));
    }

    // 4. Category Management
    @GetMapping("/categories")
    public ResponseEntity<ApiResponse<List<Category>>> getCategories() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getAllCategories()));
    }

    @PostMapping("/categories")
    public ResponseEntity<ApiResponse<Category>> saveCategory(@RequestBody Category category) {
        return ResponseEntity.ok(ApiResponse.ok("Category saved", adminService.saveCategory(category)));
    }

    @DeleteMapping("/categories/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteCategory(@PathVariable Long id) {
        adminService.deleteCategory(id);
        return ResponseEntity.ok(ApiResponse.ok("Category deleted", null));
    }

    // 5. Master Order Desk
    @GetMapping("/orders")
    public ResponseEntity<ApiResponse<List<Booking>>> getAllOrders() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getAllOrders()));
    }

    @PutMapping("/orders/{id}/override")
    public ResponseEntity<ApiResponse<Booking>> overrideOrder(
            @PathVariable Long id,
            @RequestBody StatusUpdateRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Order overridden", adminService.adminOverrideOrderStatus(id, request.getStatus(), request.getReasonOrNotes())));
    }

    // 6. Commission & Payouts
    @PostMapping("/payouts/trigger")
    public ResponseEntity<ApiResponse<Map<String, Object>>> triggerPayout(@RequestBody Map<String, Object> body) {
        Long vendorId = Long.valueOf(body.get("vendorId").toString());
        Double amount = Double.valueOf(body.get("amount").toString());
        return ResponseEntity.ok(ApiResponse.ok("Payout processed", adminService.triggerVendorPayout(vendorId, amount)));
    }

    // 7. Banner & Content CMS
    @GetMapping("/banners")
    public ResponseEntity<ApiResponse<List<Banner>>> getAllBanners() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getAllBanners()));
    }

    @PostMapping("/banners")
    public ResponseEntity<ApiResponse<Banner>> saveBanner(@RequestBody Banner banner) {
        return ResponseEntity.ok(ApiResponse.ok("Banner saved", adminService.saveBanner(banner)));
    }

    @DeleteMapping("/banners/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteBanner(@PathVariable Long id) {
        adminService.deleteBanner(id);
        return ResponseEntity.ok(ApiResponse.ok("Banner deleted", null));
    }

    // 8. Promotions & Coupons
    @GetMapping("/coupons")
    public ResponseEntity<ApiResponse<List<PromotionCoupon>>> getAllCoupons() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getAllCoupons()));
    }

    @PostMapping("/coupons")
    public ResponseEntity<ApiResponse<PromotionCoupon>> saveCoupon(@RequestBody PromotionCoupon coupon) {
        return ResponseEntity.ok(ApiResponse.ok("Coupon saved", adminService.saveCoupon(coupon)));
    }

    @DeleteMapping("/coupons/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteCoupon(@PathVariable Long id) {
        adminService.deleteCoupon(id);
        return ResponseEntity.ok(ApiResponse.ok("Coupon deleted", null));
    }

    // 9. Support & Dispute Portal
    @GetMapping("/disputes")
    public ResponseEntity<ApiResponse<List<SupportTicket>>> getDisputes(@RequestParam(required = false) String status) {
        return ResponseEntity.ok(ApiResponse.ok(adminService.getAllTickets(status)));
    }

    @PutMapping("/disputes/{id}/resolve")
    public ResponseEntity<ApiResponse<SupportTicket>> resolveDispute(
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        String notes = body.get("resolutionNotes");
        String action = body.get("action"); // e.g. "REFUND" or "RESOLVE"
        return ResponseEntity.ok(ApiResponse.ok("Dispute resolved", adminService.resolveTicket(id, notes, action)));
    }
}
