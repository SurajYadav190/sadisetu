import { Component, OnInit, signal, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminApiService } from '../../core/services/admin-api.service';
import { VendorProfile } from '../../core/models/admin.models';

@Component({
  selector: 'app-vendors',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div>
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <div>
          <h1 class="brand-font" style="font-size: 24px; color: var(--secondary); font-weight: 700;">3. Vendor KYC & Compliance Verification</h1>
          <p style="color: var(--text-muted); font-size: 13.5px;">Inspect business licenses, identity documents, and onboard wedding merchants.</p>
        </div>
      </div>

      <!-- FILTER TABS -->
      <div class="card" style="padding: 16px; margin-bottom: 20px;">
        <div style="display: flex; gap: 8px;">
          <button class="btn btn-sm" [ngClass]="kycFilter() === 'ALL' ? 'btn-primary' : 'btn-outline'" (click)="kycFilter.set('ALL')">All Vendors</button>
          <button class="btn btn-sm" [ngClass]="kycFilter() === 'PENDING' ? 'btn-primary' : 'btn-outline'" (click)="kycFilter.set('PENDING')">⏳ Pending Review</button>
          <button class="btn btn-sm" [ngClass]="kycFilter() === 'VERIFIED' ? 'btn-primary' : 'btn-outline'" (click)="kycFilter.set('VERIFIED')">✓ Verified & Live</button>
          <button class="btn btn-sm" [ngClass]="kycFilter() === 'REJECTED' ? 'btn-primary' : 'btn-outline'" (click)="kycFilter.set('REJECTED')">✕ Rejected</button>
        </div>
      </div>

      <!-- VENDORS LISTING -->
      <div class="card">
        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th>Merchant Details</th>
                <th>Category</th>
                <th>Location</th>
                <th>KYC Status</th>
                <th>Commission</th>
                <th>Wallet / Payout</th>
                <th style="text-align: right;">Review Document</th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let vendor of filteredVendors()">
                <td>
                  <strong style="color: var(--secondary); font-size: 14px;">{{ vendor.businessName }}</strong>
                  <div style="font-size: 12px; color: var(--text-muted);">
                    Contact: {{ vendor.user.fullName }} ({{ vendor.user.phone }})
                  </div>
                </td>
                <td>
                  <span class="badge badge-info">{{ vendor.category?.name || 'General Wedding' }}</span>
                </td>
                <td>{{ vendor.city || 'Delhi NCR' }}</td>
                <td>
                  <span class="badge" [ngClass]="{
                    'badge-warning': vendor.kycStatus === 'PENDING',
                    'badge-success': vendor.kycStatus === 'VERIFIED',
                    'badge-danger': vendor.kycStatus === 'REJECTED'
                  }">
                    {{ vendor.kycStatus }}
                  </span>
                </td>
                <td><strong>{{ vendor.commissionRate || 10 }}%</strong></td>
                <td>₹{{ (vendor.walletBalance || 0) | number }}</td>
                <td style="text-align: right;">
                  <button class="btn btn-sm btn-outline" (click)="openReviewModal(vendor)">
                    Review KYC Docs
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- KYC MODAL VIEWER -->
      <div class="modal-overlay" *ngIf="selectedVendor" (click)="closeModal()">
        <div class="modal-card" (click)="$event.stopPropagation()">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <h3 class="brand-font" style="font-size: 20px; color: var(--secondary);">Verify Merchant Documents</h3>
            <button class="btn btn-sm btn-outline" (click)="closeModal()">✕</button>
          </div>

          <div style="margin-bottom: 16px;">
            <p><strong>Business Name:</strong> {{ selectedVendor.businessName }}</p>
            <p><strong>Merchant Contact:</strong> {{ selectedVendor.user.fullName }} ({{ selectedVendor.user.phone }})</p>
            <p><strong>Category:</strong> {{ selectedVendor.category?.name }}</p>
            <p><strong>Bank Details:</strong> {{ selectedVendor.bankAccountNumber || 'HDFC0001234 - 918237461928' }}</p>
          </div>

          <!-- DOCUMENT PREVIEW TABS -->
          <div style="border: 1px dashed var(--border); border-radius: var(--radius-sm); padding: 16px; background: #f8fafc; margin-bottom: 20px;">
            <h4 style="font-size: 13px; font-weight: 700; margin-bottom: 10px;">Submitted GST / Trade License</h4>
            <img [src]="selectedVendor.businessLicenseUrl || 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600'" style="width: 100%; max-height: 220px; object-fit: cover; border-radius: 6px; border: 1px solid #cbd5e1;" />
          </div>

          <div class="form-group">
            <label class="form-label">Platform Commission Percentage (%)</label>
            <input type="number" [(ngModel)]="modalCommission" class="form-control" />
          </div>

          <div class="form-group">
            <label class="form-label">Rejection Remark (Mandatory if Rejecting)</label>
            <textarea [(ngModel)]="rejectionReason" class="form-control" rows="2" placeholder="e.g. GST certificate is blurred or expired..."></textarea>
          </div>

          <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px;">
            <button class="btn btn-danger" (click)="decideKyc('REJECTED')">✕ Reject Application</button>
            <button class="btn btn-success" (click)="decideKyc('VERIFIED')">✓ Approve & Activate Vendor</button>
          </div>
        </div>
      </div>
    </div>
  `
})
export class VendorsComponent implements OnInit {
  private api = inject(AdminApiService);
  kycFilter = signal<string>('ALL');
  vendors = this.api.vendorsSignal;
  selectedVendor: VendorProfile | null = null;
  rejectionReason = '';
  modalCommission = 10;

  filteredVendors = computed(() => {
    const filter = this.kycFilter();
    if (filter === 'ALL') return this.vendors();
    return this.vendors().filter(v => v.kycStatus === filter);
  });

  ngOnInit() {
    this.api.getVendors().subscribe();
  }

  openReviewModal(v: VendorProfile) {
    this.selectedVendor = v;
    this.modalCommission = v.commissionRate || 10;
    this.rejectionReason = v.kycRejectionReason || '';
  }

  closeModal() {
    this.selectedVendor = null;
  }

  decideKyc(status: 'VERIFIED' | 'REJECTED') {
    if (!this.selectedVendor) return;
    this.api.updateVendorKyc(
      this.selectedVendor.id,
      status,
      this.rejectionReason,
      this.modalCommission
    ).subscribe(() => {
      alert(`Vendor status updated to ${status}`);
      this.closeModal();
    });
  }
}
