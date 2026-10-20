import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { AdminApiService } from '../../core/services/admin-api.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink],
  template: `
    <div>
      <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 28px;">
        <div>
          <h1 class="brand-font" style="font-size: 26px; color: var(--secondary); font-weight: 700;">Executive Business Overview</h1>
          <p style="color: var(--text-muted); font-size: 14px;">Real-time metrics, active escrow balances, and category operations across Shaadi Setu.</p>
        </div>
        <div style="display: flex; gap: 10px;">
          <a routerLink="/orders" class="btn btn-primary">Master Order Desk</a>
          <a routerLink="/vendors" class="btn btn-outline">KYC Approvals</a>
        </div>
      </div>

      <!-- METRIC CARDS GRID -->
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr)); gap: 20px; margin-bottom: 28px;">
        <div class="card" style="margin-bottom: 0; border-left: 4px solid #9b1b30;">
          <span style="font-size: 12px; color: var(--text-muted); font-weight: 600; text-transform: uppercase;">Gross Merchandise (GMV)</span>
          <h2 style="font-size: 26px; font-weight: 800; color: var(--secondary); margin-top: 6px;">₹{{ (stats()?.grossMerchandiseValue || 2450000) | number }}</h2>
          <div style="display: flex; align-items: center; gap: 6px; margin-top: 8px;">
            <span class="badge badge-success" style="font-size: 11px;">+28% this month</span>
            <span style="font-size: 11px; color: var(--text-muted);">across all bookings</span>
          </div>
        </div>

        <div class="card" style="margin-bottom: 0; border-left: 4px solid var(--gold);">
          <span style="font-size: 12px; color: var(--text-muted); font-weight: 600; text-transform: uppercase;">Platform Net Commission</span>
          <h2 style="font-size: 26px; font-weight: 800; color: #b45309; margin-top: 6px;">₹{{ (stats()?.platformCommissionEarned || 245000) | number }}</h2>
          <div style="display: flex; align-items: center; gap: 6px; margin-top: 8px;">
            <span class="badge badge-gold" style="font-size: 11px;">10% Platform Cut</span>
            <span style="font-size: 11px; color: var(--text-muted);">auto escrow share</span>
          </div>
        </div>

        <div class="card" style="margin-bottom: 0; border-left: 4px solid #10b981;">
          <span style="font-size: 12px; color: var(--text-muted); font-weight: 600; text-transform: uppercase;">Total Active Bookings</span>
          <h2 style="font-size: 26px; font-weight: 800; color: var(--secondary); margin-top: 6px;">{{ stats()?.totalBookings || 84 }}</h2>
          <div style="display: flex; align-items: center; gap: 6px; margin-top: 8px;">
            <span class="badge badge-info" style="font-size: 11px;">{{ stats()?.pendingBookings || 12 }} Pending Dispatch</span>
          </div>
        </div>

        <div class="card" style="margin-bottom: 0; border-left: 4px solid #f59e0b;">
          <span style="font-size: 12px; color: var(--text-muted); font-weight: 600; text-transform: uppercase;">Verified Vendors & KYC</span>
          <h2 style="font-size: 26px; font-weight: 800; color: var(--secondary); margin-top: 6px;">{{ stats()?.verifiedVendorsCount || 31 }} <span style="font-size: 14px; color: var(--text-muted); font-weight: 400;">/ {{ stats()?.totalVendors || 36 }}</span></h2>
          <div style="display: flex; align-items: center; gap: 6px; margin-top: 8px;">
            <span class="badge badge-warning" style="font-size: 11px;">{{ stats()?.pendingKycCount || 5 }} Need KYC Review</span>
          </div>
        </div>
      </div>

      <!-- CHARTS & DISTRIBUTION -->
      <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px; margin-bottom: 28px;">
        <!-- MONTHLY REVENUE BARS -->
        <div class="card" style="margin-bottom: 0;">
          <div class="card-title">
            <span>Monthly Revenue Growth (INR)</span>
            <span class="badge badge-success">Wedding Season Spike</span>
          </div>
          <div style="display: flex; align-items: flex-end; justify-content: space-between; height: 200px; padding-top: 20px; border-bottom: 1px solid var(--border);">
            <div *ngFor="let item of stats()?.monthlyRevenue" style="display: flex; flex-direction: column; align-items: center; gap: 8px; flex: 1;">
              <span style="font-size: 11px; font-weight: 600; color: var(--text-muted);">₹{{ (item.revenue / 1000) | number:'1.0-0' }}k</span>
              <div [style.height.px]="(item.revenue / 800000) * 140" style="width: 38px; background: linear-gradient(180deg, #9b1b30, #d4af37); border-radius: 6px 6px 0 0; transition: height 0.5s;"></div>
              <span style="font-size: 12px; font-weight: 600; color: var(--secondary);">{{ item.month }}</span>
            </div>
          </div>
        </div>

        <!-- CATEGORY DISTRIBUTION -->
        <div class="card" style="margin-bottom: 0;">
          <div class="card-title">
            <span>Category Vendor Distribution</span>
          </div>
          <div style="display: flex; flex-direction: column; gap: 14px; margin-top: 10px;">
            <div *ngFor="let cat of stats()?.categoryBreakdown">
              <div style="display: flex; justify-content: space-between; font-size: 13px; font-weight: 600; margin-bottom: 4px;">
                <span>{{ cat.category }}</span>
                <span style="color: var(--primary);">{{ cat.count }} Vendors</span>
              </div>
              <div style="height: 8px; background: #e2e8f0; border-radius: 4px; overflow: hidden;">
                <div [style.width.%]="(cat.count / 20) * 100" style="height: 100%; background: #9b1b30; border-radius: 4px;"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- RECENT ORDERS TABLE -->
      <div class="card">
        <div class="card-title">
          <span>Recent Platform Bookings</span>
          <a routerLink="/orders" class="btn btn-outline btn-sm">View All Orders</a>
        </div>
        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th>Booking Ref</th>
                <th>Customer</th>
                <th>Vendor Service</th>
                <th>Event Date</th>
                <th>Amount (INR)</th>
                <th>Escrow Status</th>
                <th>Order Status</th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let order of orders().slice(0, 5)">
                <td><strong style="color: var(--primary);">{{ order.bookingNumber }}</strong></td>
                <td>{{ order.customer.fullName }}</td>
                <td>{{ order.vendor.businessName }}</td>
                <td>{{ order.bookingDate }} ({{ order.timeSlot }})</td>
                <td><strong>₹{{ order.totalAmount | number }}</strong></td>
                <td>
                  <span class="badge" [ngClass]="order.paymentStatus === 'RELEASED' ? 'badge-success' : 'badge-gold'">
                    {{ order.paymentStatus }}
                  </span>
                </td>
                <td>
                  <span class="badge" [ngClass]="{
                    'badge-success': order.status === 'COMPLETED' || order.status === 'ACCEPTED',
                    'badge-warning': order.status === 'PENDING' || order.status === 'IN_PROGRESS',
                    'badge-danger': order.status === 'CANCELLED' || order.status === 'REJECTED'
                  }">
                    {{ order.status }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  `
})
export class DashboardComponent implements OnInit {
  private api = inject(AdminApiService);
  stats = this.api.statsSignal;
  orders = this.api.ordersSignal;

  ngOnInit() {
    this.api.getDashboardStats().subscribe();
    this.api.getOrders().subscribe();
  }
}
