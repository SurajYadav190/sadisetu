import { Component, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AdminAuthService } from '../../core/services/admin-auth.service';

@Component({
  selector: 'app-admin-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="login-page">
      <div class="login-card">
        <!-- Logo Header -->
        <div class="brand-header">
          <div class="brand-logo">श</div>
          <h1 class="brand-title">Shaadi Setu</h1>
          <span class="admin-badge">Super Admin Console</span>
          <p class="login-sub">Platform Administration & Master Governance Portal</p>
        </div>

        <!-- Security Warning Notice -->
        <div class="security-banner">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="banner-icon">
            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
          </svg>
          <div class="banner-text">
            <strong>Restricted Access</strong>
            <span>Only verified platform administrators can enter. Customers & Vendors are prohibited.</span>
          </div>
        </div>

        <!-- Error Message Banner -->
        <div *ngIf="errorMessage()" class="error-banner">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="error-icon">
            <circle cx="12" cy="12" r="10"/>
            <line x1="12" y1="8" x2="12" y2="12"/>
            <line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
          <span>{{ errorMessage() }}</span>
        </div>

        <!-- Login Form -->
        <form (ngSubmit)="handleLogin()" class="login-form">
          <div class="form-group">
            <label>Administrator Email / Identifier</label>
            <div class="input-wrap">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="input-icon">
                <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                <polyline points="22,6 12,13 2,6"/>
              </svg>
              <input
                type="text"
                [(ngModel)]="email"
                name="email"
                placeholder="admin@shadisetu.com"
                required
                [disabled]="loading()"
              />
            </div>
          </div>

          <div class="form-group">
            <label>Master Security Password</label>
            <div class="input-wrap">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="input-icon">
                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
              </svg>
              <input
                type="password"
                [(ngModel)]="password"
                name="password"
                placeholder="••••••••"
                required
                [disabled]="loading()"
              />
            </div>
          </div>

          <!-- Quick Test Fill Button -->
          <div class="quick-fill-row">
            <button type="button" class="btn-quick-fill" (click)="fillDemoAdmin()">
              ⚡ Auto-Fill Demo Admin (admin&#64;shadisetu.com)
            </button>
          </div>

          <button type="submit" class="btn-submit" [disabled]="loading()">
            <span *ngIf="!loading()">Authenticate & Enter Console</span>
            <span *ngIf="loading()">Verifying Master Credentials...</span>
          </button>
        </form>

        <div class="footer-note">
          <p>Protected by Spring Boot Stateless JWT & Role-Based Access Control.</p>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .login-page {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background: radial-gradient(circle at top right, #1e1b4b, #0f172a, #030712);
      padding: 24px;
      font-family: 'Plus Jakarta Sans', system-ui, -apple-system, sans-serif;
    }

    .login-card {
      width: 100%;
      max-width: 440px;
      background: #ffffff;
      border-radius: 20px;
      padding: 36px 32px;
      box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.4), 0 0 0 1px rgba(255, 255, 255, 0.1);
    }

    .brand-header {
      text-align: center;
      margin-bottom: 24px;
    }

    .brand-logo {
      width: 60px;
      height: 60px;
      margin: 0 auto 12px;
      background: linear-gradient(135deg, #d4af37, #9b1b30);
      color: #fff;
      font-size: 32px;
      font-weight: 900;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 16px;
      box-shadow: 0 8px 16px rgba(155, 27, 48, 0.35);
    }

    .brand-title {
      font-size: 26px;
      font-weight: 800;
      color: #0f172a;
      letter-spacing: -0.5px;
      margin: 0 0 6px 0;
    }

    .admin-badge {
      display: inline-block;
      padding: 3px 10px;
      background: #fef3c7;
      color: #92400e;
      border: 1px solid #fde68a;
      border-radius: 12px;
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 8px;
    }

    .login-sub {
      font-size: 13px;
      color: #64748b;
      margin: 0;
    }

    .security-banner {
      display: flex;
      align-items: flex-start;
      gap: 12px;
      background: #f8fafc;
      border: 1px solid #e2e8f0;
      border-left: 4px solid #d4af37;
      padding: 12px 14px;
      border-radius: 10px;
      margin-bottom: 20px;
    }

    .banner-icon {
      width: 20px;
      height: 20px;
      color: #b45309;
      flex-shrink: 0;
      margin-top: 1px;
    }

    .banner-text {
      font-size: 11.5px;
      line-height: 1.4;
      color: #475569;
    }

    .banner-text strong {
      display: block;
      color: #0f172a;
      font-size: 12px;
    }

    .error-banner {
      display: flex;
      align-items: flex-start;
      gap: 10px;
      background: #fef2f2;
      border: 1px solid #fecaca;
      color: #991b1b;
      padding: 12px 14px;
      border-radius: 10px;
      font-size: 12.5px;
      margin-bottom: 18px;
      line-height: 1.4;
    }

    .error-icon {
      width: 18px;
      height: 18px;
      flex-shrink: 0;
      margin-top: 1px;
    }

    .form-group {
      margin-bottom: 18px;
    }

    .form-group label {
      display: block;
      font-size: 12.5px;
      font-weight: 600;
      color: #334155;
      margin-bottom: 6px;
    }

    .input-wrap {
      position: relative;
      display: flex;
      align-items: center;
    }

    .input-icon {
      position: absolute;
      left: 14px;
      width: 17px;
      height: 17px;
      color: #94a3b8;
    }

    .input-wrap input {
      width: 100%;
      padding: 12px 14px 12px 42px;
      border: 1px solid #cbd5e1;
      border-radius: 10px;
      font-size: 14px;
      color: #0f172a;
      transition: all 0.2s ease;
      outline: none;
    }

    .input-wrap input:focus {
      border-color: #9b1b30;
      box-shadow: 0 0 0 3px rgba(155, 27, 48, 0.12);
    }

    .quick-fill-row {
      margin-bottom: 20px;
      text-align: right;
    }

    .btn-quick-fill {
      background: #f1f5f9;
      border: 1px solid #e2e8f0;
      color: #475569;
      font-size: 11.5px;
      font-weight: 600;
      padding: 6px 10px;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.2s ease;
    }

    .btn-quick-fill:hover {
      background: #e2e8f0;
      color: #0f172a;
    }

    .btn-submit {
      width: 100%;
      padding: 14px;
      background: linear-gradient(135deg, #9b1b30, #7b1525);
      color: #ffffff;
      border: none;
      border-radius: 10px;
      font-size: 14px;
      font-weight: 700;
      cursor: pointer;
      transition: all 0.2s ease;
      box-shadow: 0 4px 12px rgba(155, 27, 48, 0.3);
    }

    .btn-submit:hover:not(:disabled) {
      opacity: 0.95;
      transform: translateY(-1px);
    }

    .btn-submit:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }

    .footer-note {
      margin-top: 24px;
      text-align: center;
      font-size: 11px;
      color: #94a3b8;
    }
  `]
})
export class AdminLoginComponent {
  private auth = inject(AdminAuthService);
  private router = inject(Router);

  email = 'admin@shadisetu.com';
  password = '';
  loading = signal(false);
  errorMessage = signal<string | null>(null);

  fillDemoAdmin(): void {
    this.email = 'admin@shadisetu.com';
    this.password = 'admin123';
    this.errorMessage.set(null);
  }

  handleLogin(): void {
    if (!this.email || !this.password) {
      this.errorMessage.set('Please provide both administrator email and password.');
      return;
    }

    this.loading.set(true);
    this.errorMessage.set(null);

    this.auth.login(this.email, this.password).subscribe({
      next: res => {
        this.loading.set(false);
        if (res.success) {
          this.router.navigate(['/dashboard']);
        } else {
          this.errorMessage.set(res.message || 'Login failed.');
        }
      },
      error: () => {
        this.loading.set(false);
        this.errorMessage.set('An unexpected authentication error occurred.');
      }
    });
  }
}
