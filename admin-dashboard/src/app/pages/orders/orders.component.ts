import { Component, OnInit, signal, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminApiService } from '../../core/services/admin-api.service';
import { Booking } from '../../core/models/admin.models';

@Component({
  selector: 'app-orders',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div>
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <div>
          <h1 class="brand-font" style="font-size: 24px; color: var(--secondary); font-weight: 700;">5. Master Order Desk & Dispatch</h1>
          <p style="color: var(--text-muted); font-size: 13.5px;">Monitor transactions, manage escrow release, inspect booking itineraries and execute admin overrides.</p>
        </div>
      </div>

      <!-- FILTER TABS -->
      <div class="card" style="padding: 16px; margin-bottom: 20px;">
        <div style="display: flex; gap: 8px; flex-wrap: wrap;">
          <button class="btn btn-sm" [ngClass]="statusFilter() === 'ALL' ? 'btn-primary' : 'btn-outline'" (click)="statusFilter.set('ALL')">All Orders</button>
          <button class="btn btn-sm" [ngClass]="statusFilter() === 'PENDING' ? 'btn-primary' : 'btn-outline'" (click)="statusFilter.set('PENDING')">⏳ Pending</button>
          <button class="btn btn-sm" [ngClass]="statusFilter() === 'ACCEPTED' ? 'btn-primary' : 'btn-outline'" (click)="statusFilter.set('ACCEPTED')">✓ Accepted</button>
          <button class="btn btn-sm" [ngClass]="statusFilter() === 'IN_PROGRESS' ? 'btn-primary' : 'btn-outline'" (click)="statusFilter.set('IN_PROGRESS')">⚡ In-Progress</button>
          <button class="btn btn-sm" [ngClass]="statusFilter() === 'COMPLETED' ? 'btn-primary' : 'btn-outline'" (click)="statusFilter.set('COMPLETED')">★ Completed</button>
          <button class="btn btn-sm" [ngClass]="statusFilter() === 'CANCELLED' ? 'btn-primary' : 'btn-outline'" (click)="statusFilter.set('CANCELLED')">✕ Cancelled</button>
        </div>
      </div>

      <!-- ORDERS TABLE -->
      <div class="card">
        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th>Booking ID</th>
                <th>Client</th>
                <th>Assigned Vendor</th>
                <th>Event Date & Slot</th>
                <th>Gross Total</th>
                <th>Escrow Status</th>
                <th>Order State</th>
                <th style="text-align: right;">Admin Action</th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let order of filteredOrders()">
                <td>
                  <strong style="color: var(--primary);">{{ order.bookingNumber }}</strong>
                  <div style="font-size: 11px; color: var(--text-muted);">{{ order.createdAt }}</div>
                </td>
                <td>
                  <strong>{{ order.customer.fullName }}</strong>
                  <div style="font-size: 12px; color: var(--text-muted);">📞 {{ order.customer.phone }}</div>
                </td>
                <td>
                  <strong>{{ order.vendor.businessName }}</strong>
                  <div style="font-size: 12px; color: var(--text-muted);">Category: {{ order.vendor.category?.name || 'Wedding' }}</div>
                </td>
                <td>
                  <div>📅 {{ order.bookingDate }}</div>
                  <div style="font-size: 12px; color: var(--text-muted);">⏰ {{ order.timeSlot }}</div>
                </td>
                <td>
                  <strong>₹{{ order.totalAmount | number }}</strong>
                  <div style="font-size: 11px; color: #b45309;">Comm: ₹{{ order.commissionAmount | number }}</div>
                </td>
                <td>
                  <span class="badge" [ngClass]="order.paymentStatus === 'RELEASED' ? 'badge-success' : 'badge-gold'">
                    🛡 {{ order.paymentStatus }}
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
                <td style="text-align: right;">
                  <button class="btn btn-sm btn-outline" (click)="openOverrideModal(order)">
                    Override Status
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- OVERRIDE MODAL -->
      <div class="modal-overlay" *ngIf="selectedOrder" (click)="closeModal()">
        <div class="modal-card" (click)="$event.stopPropagation()">
          <h3 class="brand-font" style="font-size: 20px; margin-bottom: 16px;">Admin Order Status Override</h3>
          <p style="margin-bottom: 12px; font-size: 13.5px;">Override order: <strong>{{ selectedOrder.bookingNumber }}</strong></p>

          <div class="form-group">
            <label class="form-label">New Order State</label>
            <select [(ngModel)]="newStatus" class="form-control">
              <option value="ACCEPTED">ACCEPTED (Confirm Vendor Dispatch)</option>
              <option value="IN_PROGRESS">IN_PROGRESS (Event Ongoing)</option>
              <option value="COMPLETED">COMPLETED (Release Escrow to Vendor)</option>
              <option value="CANCELLED">CANCELLED (Initiate Refund)</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label">Audit Reason for Manual Intervention</label>
            <textarea [(ngModel)]="overrideReason" class="form-control" rows="3" placeholder="Reason for status change..."></textarea>
          </div>

          <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px;">
            <button class="btn btn-outline" (click)="closeModal()">Cancel</button>
            <button class="btn btn-primary" (click)="saveOverride()">Confirm Override</button>
          </div>
        </div>
      </div>
    </div>
  `
})
export class OrdersComponent implements OnInit {
  private api = inject(AdminApiService);
  statusFilter = signal<string>('ALL');
  orders = this.api.ordersSignal;
  selectedOrder: Booking | null = null;
  newStatus = 'COMPLETED';
  overrideReason = '';

  filteredOrders = computed(() => {
    const f = this.statusFilter();
    if (f === 'ALL') return this.orders();
    return this.orders().filter(o => o.status === f);
  });

  ngOnInit() {
    this.api.getOrders().subscribe();
  }

  openOverrideModal(o: Booking) {
    this.selectedOrder = o;
    this.newStatus = o.status;
    this.overrideReason = '';
  }

  closeModal() {
    this.selectedOrder = null;
  }

  saveOverride() {
    if (!this.selectedOrder) return;
    this.api.overrideOrder(this.selectedOrder.id, this.newStatus, this.overrideReason).subscribe(() => {
      alert(`Order ${this.selectedOrder?.bookingNumber} updated to ${this.newStatus}`);
      this.closeModal();
    });
  }
}
