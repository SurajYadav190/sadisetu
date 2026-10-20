import { Component, OnInit, signal, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminApiService } from '../../core/services/admin-api.service';
import { SupportTicket } from '../../core/models/admin.models';

@Component({
  selector: 'app-disputes',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div>
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <div>
          <h1 class="brand-font" style="font-size: 24px; color: var(--secondary); font-weight: 700;">9. Support & Dispute Resolution Portal</h1>
          <p style="color: var(--text-muted); font-size: 13.5px;">Manage client inquiries, resolve vendor booking conflicts, and execute mediated refunds.</p>
        </div>
      </div>

      <!-- STATUS FILTER -->
      <div class="card" style="padding: 16px; margin-bottom: 20px;">
        <div style="display: flex; gap: 8px;">
          <button class="btn btn-sm" [ngClass]="ticketFilter() === 'ALL' ? 'btn-primary' : 'btn-outline'" (click)="ticketFilter.set('ALL')">All Inquiries</button>
          <button class="btn btn-sm" [ngClass]="ticketFilter() === 'OPEN' ? 'btn-primary' : 'btn-outline'" (click)="ticketFilter.set('OPEN')">🚨 Open Tickets</button>
          <button class="btn btn-sm" [ngClass]="ticketFilter() === 'IN_REVIEW' ? 'btn-primary' : 'btn-outline'" (click)="ticketFilter.set('IN_REVIEW')">⚡ In Review</button>
          <button class="btn btn-sm" [ngClass]="ticketFilter() === 'RESOLVED' ? 'btn-primary' : 'btn-outline'" (click)="ticketFilter.set('RESOLVED')">✓ Resolved</button>
        </div>
      </div>

      <!-- TICKETS TABLE -->
      <div class="card">
        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th>Ticket ID</th>
                <th>Raised By</th>
                <th>Subject & Details</th>
                <th>Linked Booking</th>
                <th>Priority</th>
                <th>Status</th>
                <th style="text-align: right;">Action</th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let t of filteredTickets()">
                <td><strong style="color: var(--primary);">{{ t.ticketNumber }}</strong></td>
                <td>
                  <strong>{{ t.user.fullName }}</strong>
                  <div style="font-size: 12px; color: var(--text-muted);">{{ t.user.phone }}</div>
                </td>
                <td style="max-width: 320px;">
                  <strong style="color: var(--secondary); display: block; margin-bottom: 2px;">{{ t.subject }}</strong>
                  <span style="font-size: 12px; color: var(--text-muted);">{{ t.description }}</span>
                </td>
                <td>
                  <span *ngIf="t.booking" class="badge badge-info">{{ t.booking.bookingNumber }}</span>
                  <span *ngIf="!t.booking" style="color: var(--text-muted); font-size: 12px;">General Query</span>
                </td>
                <td>
                  <span class="badge" [ngClass]="{
                    'badge-danger': t.priority === 'URGENT' || t.priority === 'HIGH',
                    'badge-warning': t.priority === 'MEDIUM',
                    'badge-info': t.priority === 'LOW'
                  }">
                    {{ t.priority }}
                  </span>
                </td>
                <td>
                  <span class="badge" [ngClass]="t.status === 'RESOLVED' ? 'badge-success' : 'badge-warning'">
                    {{ t.status }}
                  </span>
                </td>
                <td style="text-align: right;">
                  <button class="btn btn-sm btn-outline" (click)="openResolveModal(t)">
                    Mediate / Resolve
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- RESOLUTION MODAL -->
      <div class="modal-overlay" *ngIf="selectedTicket" (click)="closeModal()">
        <div class="modal-card" (click)="$event.stopPropagation()">
          <h3 class="brand-font" style="font-size: 20px; margin-bottom: 16px;">Resolve Dispute / Support Ticket</h3>
          <p><strong>Ticket:</strong> {{ selectedTicket.ticketNumber }} - {{ selectedTicket.subject }}</p>
          <p style="font-size: 13px; color: var(--text-muted); margin-bottom: 16px;">Customer: {{ selectedTicket.user.fullName }}</p>

          <div class="form-group">
            <label class="form-label">Resolution Notes (Logged to Audit Trail)</label>
            <textarea [(ngModel)]="resolutionNotes" class="form-control" rows="3" placeholder="Enter mediation resolution notes..."></textarea>
          </div>

          <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px;">
            <button class="btn btn-outline" (click)="closeModal()">Cancel</button>
            <button *ngIf="selectedTicket.booking" class="btn btn-danger" (click)="resolveTicket('REFUND')">
              Cancel & Refund Escrow
            </button>
            <button class="btn btn-success" (click)="resolveTicket('RESOLVE')">
              ✓ Mark Resolved
            </button>
          </div>
        </div>
      </div>
    </div>
  `
})
export class DisputesComponent implements OnInit {
  private api = inject(AdminApiService);
  ticketFilter = signal<string>('ALL');
  tickets = this.api.ticketsSignal;
  selectedTicket: SupportTicket | null = null;
  resolutionNotes = '';

  filteredTickets = computed(() => {
    const f = this.ticketFilter();
    if (f === 'ALL') return this.tickets();
    return this.tickets().filter(t => t.status === f);
  });

  ngOnInit() {
    this.api.getDisputes().subscribe();
  }

  openResolveModal(t: SupportTicket) {
    this.selectedTicket = t;
    this.resolutionNotes = t.resolutionNotes || '';
  }

  closeModal() {
    this.selectedTicket = null;
  }

  resolveTicket(action: string) {
    if (!this.selectedTicket) return;
    this.api.resolveTicket(this.selectedTicket.id, this.resolutionNotes, action).subscribe(() => {
      alert(`Ticket ${this.selectedTicket?.ticketNumber} resolved successfully (${action})`);
      this.closeModal();
    });
  }
}
