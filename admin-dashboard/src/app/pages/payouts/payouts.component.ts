import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminApiService } from '../../core/services/admin-api.service';
import { VendorProfile } from '../../core/models/admin.models';

@Component({
  selector: 'app-payouts',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div>
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <div>
          <h1 class="brand-font" style="font-size: 24px; color: var(--secondary); font-weight: 700;">6. Commission Rules & Vendor Payouts</h1>
          <p style="color: var(--text-muted); font-size: 13.5px;">Manage platform revenue splits, inspect vendor wallet balances, and disburse bank transfers.</p>
        </div>
      </div>

      <!-- COMMISSIONS SUMMARY -->
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; margin-bottom: 28px;">
        <div class="card" style="margin-bottom: 0;">
          <div class="card-title">Default Platform Commission</div>
          <div style="display: flex; align-items: baseline; gap: 8px;">
            <h2 style="font-size: 32px; font-weight: 800; color: var(--primary);">10.0%</h2>
            <span style="font-size: 13px; color: var(--text-muted);">Standard across wedding categories</span>
          </div>
          <p style="font-size: 12px; color: #64748b; margin-top: 8px;">Deducted automatically from gross order value upon customer checkout.</p>
        </div>

        <div class="card" style="margin-bottom: 0;">
          <div class="card-title">Escrow Held for Ongoing Events</div>
          <div style="display: flex; align-items: baseline; gap: 8px;">
            <h2 style="font-size: 32px; font-weight: 800; color: #b45309;">₹1,04,999</h2>
            <span class="badge badge-gold">Protected Escrow</span>
          </div>
          <p style="font-size: 12px; color: #64748b; margin-top: 8px;">Released to vendor wallet automatically once client ceremony is completed.</p>
        </div>
      </div>

      <!-- VENDORS WITH WITHDRAWABLE BALANCES -->
      <div class="card">
        <div class="card-title">
          <span>Vendor Wallet Balances & Bank Accounts</span>
        </div>
        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th>Merchant Name</th>
                <th>Category</th>
                <th>Bank Account & IFSC</th>
                <th>Commission %</th>
                <th>Available Balance</th>
                <th style="text-align: right;">Action</th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let v of vendors()">
                <td>
                  <strong>{{ v.businessName }}</strong>
                  <div style="font-size: 12px; color: var(--text-muted);">{{ v.user.fullName }} ({{ v.user.phone }})</div>
                </td>
                <td><span class="badge badge-info">{{ v.category?.name || 'Wedding' }}</span></td>
                <td>
                  <div>🏦 {{ v.bankAccountNumber || 'HDFC0001234 - 918237461928' }}</div>
                  <div style="font-size: 12px; color: var(--text-muted);">Holder: {{ v.bankHolderName || v.businessName }}</div>
                </td>
                <td>{{ v.commissionRate || 10 }}%</td>
                <td><strong style="color: #10b981; font-size: 15px;">₹{{ (v.walletBalance || 0) | number }}</strong></td>
                <td style="text-align: right;">
                  <button
                    class="btn btn-sm btn-primary"
                    [disabled]="(v.walletBalance || 0) <= 0"
                    (click)="openPayoutModal(v)">
                    Disburse Payout
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- DISBURSE PAYOUT MODAL -->
      <div class="modal-overlay" *ngIf="selectedVendor" (click)="closeModal()">
        <div class="modal-card" (click)="$event.stopPropagation()">
          <h3 class="brand-font" style="font-size: 20px; margin-bottom: 16px;">Trigger Bank Payout</h3>
          <p style="font-size: 14px; margin-bottom: 16px;">Merchant: <strong>{{ selectedVendor.businessName }}</strong></p>

          <div style="padding: 12px; background: #ecfdf5; border-radius: 8px; margin-bottom: 16px; font-size: 13px;">
            <p><strong>Available Wallet:</strong> ₹{{ selectedVendor.walletBalance | number }}</p>
            <p><strong>Beneficiary Bank:</strong> {{ selectedVendor.bankAccountNumber }} (IFSC: {{ selectedVendor.bankIfsc }})</p>
          </div>

          <div class="form-group">
            <label class="form-label">Transfer Amount (INR)</label>
            <input type="number" [(ngModel)]="payoutAmount" class="form-control" [max]="selectedVendor.walletBalance" />
          </div>

          <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px;">
            <button class="btn btn-outline" (click)="closeModal()">Cancel</button>
            <button class="btn btn-success" (click)="confirmPayout()">✓ Disburse Via IMPS / NEFT</button>
          </div>
        </div>
      </div>
    </div>
  `
})
export class PayoutsComponent implements OnInit {
  private api = inject(AdminApiService);
  vendors = this.api.vendorsSignal;
  selectedVendor: VendorProfile | null = null;
  payoutAmount = 0;

  ngOnInit() {
    this.api.getVendors().subscribe();
  }

  openPayoutModal(v: VendorProfile) {
    this.selectedVendor = v;
    this.payoutAmount = v.walletBalance;
  }

  closeModal() {
    this.selectedVendor = null;
  }

  confirmPayout() {
    if (!this.selectedVendor || this.payoutAmount <= 0) return;
    this.api.triggerPayout(this.selectedVendor.id, this.payoutAmount).subscribe(res => {
      alert(`Payout of ₹${this.payoutAmount} triggered successfully! Reference: ${res.transactionRef || 'PO-OK'}`);
      this.closeModal();
    });
  }
}
