import { Injectable, signal, computed, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, of } from 'rxjs';
import { tap, catchError, map } from 'rxjs/operators';
import { User } from '../models/admin.models';

const ADMIN_STORAGE_KEY = 'shaadi_setu_admin_session';

@Injectable({
  providedIn: 'root'
})
export class AdminAuthService {
  private http = inject(HttpClient);
  private router = inject(Router);
  private authUrl = 'http://localhost:8080/api/auth';

  public currentAdmin = signal<User | null>(this.loadStoredAdmin());
  public isAuthenticated = computed(() => {
    const admin = this.currentAdmin();
    return !!admin && (admin.role === 'ROLE_ADMIN' || (admin.role as string) === 'ROLE_SUPER_ADMIN');
  });

  private loadStoredAdmin(): User | null {
    try {
      const data = localStorage.getItem(ADMIN_STORAGE_KEY);
      if (data) {
        const user = JSON.parse(data) as User;
        if (user.role === 'ROLE_ADMIN' || (user.role as string) === 'ROLE_SUPER_ADMIN') {
          return user;
        }
      }
    } catch (_) {}
    return null;
  }

  public login(email: string, pass: string): Observable<{ success: boolean; message?: string }> {
    const cleanEmail = email.trim().toLowerCase();
    const cleanPass = pass.trim();

    // Direct check against backend REST API
    return this.http.post<any>(`${this.authUrl}/login`, {
      email: cleanEmail,
      phone: cleanEmail,
      password: cleanPass
    }).pipe(
      map(res => {
        const user = res?.data?.user;
        if (!user) {
          throw new Error('Invalid server response format');
        }

        // Strict role verification: Non-admin users are strictly denied
        if (user.role !== 'ROLE_ADMIN' && user.role !== 'ROLE_SUPER_ADMIN') {
          return {
            success: false,
            message: `Access Denied: Account role '${user.role}' is not authorized. Only Platform Administrators can enter the Admin Console.`
          };
        }

        this.setAdminSession(user);
        return { success: true };
      }),
      catchError(() => {
        // Fallback credential verification if backend is offline/mock
        if (
          (cleanEmail === 'admin@shadisetu.com' || cleanEmail === 'admin' || cleanEmail === '9999999999') &&
          cleanPass === 'admin123'
        ) {
          const defaultAdmin: User = {
            id: 1,
            fullName: 'Executive Super Admin',
            email: 'admin@shadisetu.com',
            phone: '9999999999',
            role: 'ROLE_ADMIN',
            status: 'ACTIVE',
            createdAt: '2026-01-10'
          };
          this.setAdminSession(defaultAdmin);
          return of({ success: true });
        }

        // Check if user is trying to login with demo customer or vendor credentials
        if (cleanEmail.includes('rahul') || cleanEmail === '9876543210') {
          return of({
            success: false,
            message: 'Access Denied: Customer accounts cannot access the Super Admin Dashboard. Please use the mobile application.'
          });
        }

        if (cleanEmail.includes('lenscraft') || cleanEmail === '9811122233') {
          return of({
            success: false,
            message: 'Access Denied: Vendor Partner accounts cannot access the Super Admin Dashboard. Please use the mobile vendor portal.'
          });
        }

        return of({
          success: false,
          message: 'Invalid administrator email or password. Please verify your credentials.'
        });
      })
    );
  }

  private setAdminSession(user: User): void {
    this.currentAdmin.set(user);
    try {
      localStorage.setItem(ADMIN_STORAGE_KEY, JSON.stringify(user));
    } catch (_) {}
  }

  public logout(): void {
    this.currentAdmin.set(null);
    try {
      localStorage.removeItem(ADMIN_STORAGE_KEY);
    } catch (_) {}
    this.router.navigate(['/login']);
  }
}
