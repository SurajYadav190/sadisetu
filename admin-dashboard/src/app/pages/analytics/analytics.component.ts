import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AdminApiService } from '../../core/services/admin-api.service';

@Component({
  selector: 'app-analytics',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div>
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <div>
          <h1 class="brand-font" style="font-size: 24px; color: var(--secondary); font-weight: 700;">10. Analytics & Business Intelligence</h1>
          <p style="color: var(--text-muted); font-size: 13.5px;">Platform performance audits, top revenue-generating vendors, and printable PDF/CSV export tools.</p>
        </div>
        <div style="display: flex; gap: 10px;">
          <button class="btn btn-outline" (click)="exportCSV()">📥 Export Orders CSV</button>
          <button class="btn btn-primary" (click)="printReport()">🖨 Print Executive Summary</button>
        </div>
      </div>

      <!-- KEY METRICS GRID -->
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 20px; margin-bottom: 24px;">
        <div class="card" style="margin-bottom: 0;">
          <div class="card-title">Average Order Value (AOV)</div>
          <h2 style="font-size: 32px; font-weight: 800; color: var(--secondary);">₹38,500</h2>
          <p style="font-size: 12px; color: var(--text-muted); margin-top: 6px;">Peak season wedding bookings average across categories</p>
        </div>

        <div class="card" style="margin-bottom: 0;">
          <div class="card-title">Booking Conversion Rate</div>
          <h2 style="font-size: 32px; font-weight: 800; color: #10b981;">68.4%</h2>
          <p style="font-size: 12px; color: var(--text-muted); margin-top: 6px;">Inquiries converted to confirmed escrow deposits</p>
        </div>

        <div class="card" style="margin-bottom: 0;">
          <div class="card-title">Customer Satisfaction Index</div>
          <h2 style="font-size: 32px; font-weight: 800; color: #b45309;">4.85 ★</h2>
          <p style="font-size: 12px; color: var(--text-muted); margin-top: 6px;">Based on 140+ verified client event reviews</p>
        </div>
      </div>

      <!-- TOP VENDORS RANKING TABLE -->
      <div class="card">
        <div class="card-title">
          <span>Top Revenue-Generating Wedding Merchants</span>
          <span class="badge badge-success">Q3 / Q4 Leaderboard</span>
        </div>
        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th>Rank</th>
                <th>Merchant Name</th>
                <th>Category</th>
                <th>City</th>
                <th>Rating</th>
                <th>Orders Completed</th>
                <th>Total GMV Delivered</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><strong>#1 🥇</strong></td>
                <td><strong>LensCraft Cinematic Weddings</strong></td>
                <td><span class="badge badge-info">Camera & Photography</span></td>
                <td>Delhi NCR</td>
                <td><strong style="color: #b45309;">4.9 ★</strong> (48)</td>
                <td>24 Events</td>
                <td><strong>₹12,40,000</strong></td>
              </tr>
              <tr>
                <td><strong>#2 🥈</strong></td>
                <td><strong>Rajputana Luxury & Vintage Cars</strong></td>
                <td><span class="badge badge-info">Luxury Cars</span></td>
                <td>Jaipur</td>
                <td><strong style="color: #b45309;">4.8 ★</strong> (32)</td>
                <td>19 Events</td>
                <td><strong>₹6,80,000</strong></td>
              </tr>
              <tr>
                <td><strong>#3 🥉</strong></td>
                <td><strong>DJ Aryan Sound & Bass Mafia</strong></td>
                <td><span class="badge badge-info">DJ & Sound Systems</span></td>
                <td>Lucknow</td>
                <td><strong style="color: #b45309;">4.7 ★</strong> (29)</td>
                <td>15 Events</td>
                <td><strong>₹5,20,000</strong></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  `
})
export class AnalyticsComponent {
  constructor(private api: AdminApiService) {}

  exportCSV() {
    const orders = this.api.ordersSignal();
    let csv = 'BookingID,Customer,Vendor,EventDate,Amount,Commission,Status\n';
    orders.forEach(o => {
      csv += `"${o.bookingNumber}","${o.customer.fullName}","${o.vendor.businessName}","${o.bookingDate}",${o.totalAmount},${o.commissionAmount},"${o.status}"\n`;
    });
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `shaadi-setu-orders-${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
  }

  printReport() {
    window.print();
  }
}
