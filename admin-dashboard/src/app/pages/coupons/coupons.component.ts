import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminApiService } from '../../core/services/admin-api.service';
import { Coupon } from '../../core/models/admin.models';

@Component({
  selector: 'app-coupons',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div>
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <div>
          <h1 class="brand-font" style="font-size: 24px; color: var(--secondary); font-weight: 700;">8. Promotions & Discount Vouchers</h1>
          <p style="color: var(--text-muted); font-size: 13.5px;">Create promotional discount codes and broadcast push alerts to mobile user apps.</p>
        </div>
        <button class="btn btn-primary" (click)="openModal()">+ Generate New Coupon</button>
      </div>

      <!-- COUPONS TABLE -->
      <div class="card">
        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th>Coupon Code</th>
                <th>Discount Rate</th>
                <th>Max Cap</th>
                <th>Min Order Required</th>
                <th>Redemption Count</th>
                <th>Valid Until</th>
                <th style="text-align: right;">Action</th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let c of coupons()">
                <td>
                  <span style="font-family: monospace; font-size: 15px; font-weight: 700; background: #fdf2f4; color: var(--primary); padding: 4px 10px; border-radius: 6px; border: 1px dashed var(--primary);">
                    {{ c.code }}
                  </span>
                </td>
                <td><strong>{{ c.discountPercent }}% OFF</strong></td>
                <td>₹{{ c.maxDiscountAmount | number }}</td>
                <td>₹{{ c.minBookingAmount | number }}</td>
                <td><span class="badge badge-info">{{ c.usageCount }} times redeemed</span></td>
                <td>{{ c.validUntil }}</td>
                <td style="text-align: right;">
                  <button class="btn btn-sm btn-outline" (click)="broadcastPush(c)">
                    📢 Push Alert
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- MODAL -->
      <div class="modal-overlay" *ngIf="showModal" (click)="closeModal()">
        <div class="modal-card" (click)="$event.stopPropagation()">
          <h3 class="brand-font" style="font-size: 20px; margin-bottom: 20px;">Generate Wedding Coupon</h3>

          <div class="form-group">
            <label class="form-label">Coupon Code (Uppercase)</label>
            <input type="text" [(ngModel)]="newCoupon.code" class="form-control" placeholder="e.g. DIWALI2026" />
          </div>

          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
            <div class="form-group">
              <label class="form-label">Discount Percentage (%)</label>
              <input type="number" [(ngModel)]="newCoupon.discountPercent" class="form-control" />
            </div>
            <div class="form-group">
              <label class="form-label">Max Discount Cap (INR)</label>
              <input type="number" [(ngModel)]="newCoupon.maxDiscountAmount" class="form-control" />
            </div>
          </div>

          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
            <div class="form-group">
              <label class="form-label">Min Booking Amount (INR)</label>
              <input type="number" [(ngModel)]="newCoupon.minBookingAmount" class="form-control" />
            </div>
            <div class="form-group">
              <label class="form-label">Valid Until Date</label>
              <input type="date" [(ngModel)]="newCoupon.validUntil" class="form-control" />
            </div>
          </div>

          <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px;">
            <button class="btn btn-outline" (click)="closeModal()">Cancel</button>
            <button class="btn btn-primary" (click)="saveCoupon()">Publish Coupon</button>
          </div>
        </div>
      </div>
    </div>
  `
})
export class CouponsComponent implements OnInit {
  private api = inject(AdminApiService);
  coupons = this.api.couponsSignal;
  showModal = false;
  newCoupon: Partial<Coupon> = {};

  ngOnInit() {
    this.api.getCoupons().subscribe();
  }

  openModal() {
    this.newCoupon = {
      code: 'WEDDING2026',
      discountPercent: 12,
      maxDiscountAmount: 4000,
      minBookingAmount: 15000,
      validUntil: '2026-12-31'
    };
    this.showModal = true;
  }

  closeModal() {
    this.showModal = false;
  }

  saveCoupon() {
    this.api.saveCoupon(this.newCoupon).subscribe(() => {
      this.closeModal();
    });
  }

  broadcastPush(c: Coupon) {
    alert(`📢 Push notification scheduled for all active users with code: ${c.code} (${c.discountPercent}% OFF)!`);
  }
}
