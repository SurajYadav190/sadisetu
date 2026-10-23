import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AdminAuthService } from '../core/services/admin-auth.service';

@Component({
  selector: 'app-layout',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive, RouterOutlet],
  template: `
    <div class="dashboard-container">
      <!-- SIDEBAR -->
      <aside class="sidebar">
        <div class="sidebar-header">
          <div class="sidebar-logo">श</div>
          <div>
            <h2 class="brand-font" style="font-size: 19px; color: #fff; letter-spacing: 0.5px;">Shaadi Setu</h2>
            <p style="font-size: 11px; color: var(--gold); font-weight: 600; text-transform: uppercase;">Super Admin Console</p>
          </div>
        </div>

        <nav class="sidebar-menu">
          <a routerLink="/dashboard" routerLinkActive="active" class="nav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="9"/><rect x="14" y="3" width="7" height="5"/><rect x="14" y="12" width="7" height="9"/><rect x="3" y="16" width="7" height="5"/></svg>
            <span>1. Executive Dashboard</span>
          </a>

          <a routerLink="/users" routerLinkActive="active" class="nav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            <span>2. User Management</span>
          </a>

          <a routerLink="/vendors" routerLinkActive="active" class="nav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
            <span>3. Vendor KYC & Approval</span>
          </a>

          <a routerLink="/categories" routerLinkActive="active" class="nav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
            <span>4. Category Management</span>
          </a>

          <a routerLink="/orders" routerLinkActive="active" class="nav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
            <span>5. Master Order Desk</span>
          </a>

          <a routerLink="/payouts" routerLinkActive="active" class="nav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
            <span>6. Commission & Payouts</span>
          </a>

          <a routerLink="/banners" routerLinkActive="active" class="nav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
            <span>7. Banner & CMS</span>
          </a>

          <a routerLink="/coupons" routerLinkActive="active" class="nav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>
            <span>8. Promotions & Coupons</span>
          </a>

          <a routerLink="/disputes" routerLinkActive="active" class="nav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            <span>9. Support & Disputes</span>
          </a>

          <a routerLink="/analytics" routerLinkActive="active" class="nav-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>
            <span>10. Analytics & Reports</span>
          </a>
        </nav>

        <div style="padding: 16px 20px; border-top: 1px solid #1e293b; font-size: 11.5px; color: #64748b;">
          <div style="display: flex; align-items: center; justify-content: space-between;">
            <span>System Status</span>
            <span style="display: inline-block; width: 8px; height: 8px; border-radius: 50%; background: #10b981;"></span>
          </div>
          <p style="margin-top: 4px; color: #94a3b8;">Spring Boot API: Online</p>
        </div>
      </aside>

      <!-- MAIN WRAPPER -->
      <div class="main-content">
        <!-- TOPBAR -->
        <header class="topbar">
          <div style="display: flex; align-items: center; gap: 16px;">
            <span class="badge badge-gold" style="font-size: 12px; padding: 6px 12px;">
              👑 Super Admin Production Portal
            </span>
          </div>

          <div style="display: flex; align-items: center; gap: 20px;">
            <div style="display: flex; align-items: center; gap: 12px;">
              <div style="width: 38px; height: 38px; border-radius: 50%; background: linear-gradient(135deg, #9b1b30, #d4af37); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700;">
                SA
              </div>
              <div>
                <p style="font-size: 13.5px; font-weight: 700; line-height: 1.2;">{{ auth.currentAdmin()?.fullName || 'Super Admin' }}</p>
                <p style="font-size: 11.5px; color: var(--text-muted);">{{ auth.currentAdmin()?.email || 'admin@shadisetu.com' }}</p>
              </div>
            </div>

            <!-- Sign Out Button -->
            <button class="btn-logout" (click)="handleLogout()" title="Terminate Admin Session">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 15px; height: 15px;">
                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                <polyline points="16 17 21 12 16 7"/>
                <line x1="21" y1="12" x2="9" y2="12"/>
              </svg>
              <span>Sign Out</span>
            </button>
          </div>
        </header>

        <!-- ROUTER BODY -->
        <main class="content-body">
          <router-outlet></router-outlet>
        </main>
      </div>
    </div>
  `,
  styles: [`
    .btn-logout {
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 7px 14px;
      background: #fef2f2;
      border: 1px solid #fecaca;
      color: #991b1b;
      font-size: 12.5px;
      font-weight: 700;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.2s ease;
    }

    .btn-logout:hover {
      background: #fee2e2;
      color: #7f1d1d;
      transform: translateY(-1px);
    }
  `]
})
export class LayoutComponent {
  public auth = inject(AdminAuthService);

  handleLogout(): void {
    if (confirm('Are you sure you want to log out of the Admin Console?')) {
      this.auth.logout();
    }
  }
}
