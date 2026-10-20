package com.shadisetu.payload;

import java.util.List;
import java.util.Map;

public class DashboardStatsDto {
    private long totalUsers;
    private long totalCustomers;
    private long totalVendors;
    private long pendingKycCount;
    private long verifiedVendorsCount;
    private long totalBookings;
    private long pendingBookings;
    private long completedBookings;
    private Double grossMerchandiseValue;
    private Double platformCommissionEarned;
    private Double pendingPayouts;
    private long openSupportTickets;

    private List<Map<String, Object>> monthlyRevenue;
    private List<Map<String, Object>> categoryBreakdown;
    private List<Map<String, Object>> recentBookings;

    public DashboardStatsDto() {}

    public long getTotalUsers() { return totalUsers; }
    public void setTotalUsers(long totalUsers) { this.totalUsers = totalUsers; }

    public long getTotalCustomers() { return totalCustomers; }
    public void setTotalCustomers(long totalCustomers) { this.totalCustomers = totalCustomers; }

    public long getTotalVendors() { return totalVendors; }
    public void setTotalVendors(long totalVendors) { this.totalVendors = totalVendors; }

    public long getPendingKycCount() { return pendingKycCount; }
    public void setPendingKycCount(long pendingKycCount) { this.pendingKycCount = pendingKycCount; }

    public long getVerifiedVendorsCount() { return verifiedVendorsCount; }
    public void setVerifiedVendorsCount(long verifiedVendorsCount) { this.verifiedVendorsCount = verifiedVendorsCount; }

    public long getTotalBookings() { return totalBookings; }
    public void setTotalBookings(long totalBookings) { this.totalBookings = totalBookings; }

    public long getPendingBookings() { return pendingBookings; }
    public void setPendingBookings(long pendingBookings) { this.pendingBookings = pendingBookings; }

    public long getCompletedBookings() { return completedBookings; }
    public void setCompletedBookings(long completedBookings) { this.completedBookings = completedBookings; }

    public Double getGrossMerchandiseValue() { return grossMerchandiseValue; }
    public void setGrossMerchandiseValue(Double grossMerchandiseValue) { this.grossMerchandiseValue = grossMerchandiseValue; }

    public Double getPlatformCommissionEarned() { return platformCommissionEarned; }
    public void setPlatformCommissionEarned(Double platformCommissionEarned) { this.platformCommissionEarned = platformCommissionEarned; }

    public Double getPendingPayouts() { return pendingPayouts; }
    public void setPendingPayouts(Double pendingPayouts) { this.pendingPayouts = pendingPayouts; }

    public long getOpenSupportTickets() { return openSupportTickets; }
    public void setOpenSupportTickets(long openSupportTickets) { this.openSupportTickets = openSupportTickets; }

    public List<Map<String, Object>> getMonthlyRevenue() { return monthlyRevenue; }
    public void setMonthlyRevenue(List<Map<String, Object>> monthlyRevenue) { this.monthlyRevenue = monthlyRevenue; }

    public List<Map<String, Object>> getCategoryBreakdown() { return categoryBreakdown; }
    public void setCategoryBreakdown(List<Map<String, Object>> categoryBreakdown) { this.categoryBreakdown = categoryBreakdown; }

    public List<Map<String, Object>> getRecentBookings() { return recentBookings; }
    public void setRecentBookings(List<Map<String, Object>> recentBookings) { this.recentBookings = recentBookings; }
}
