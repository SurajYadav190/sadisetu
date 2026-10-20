import { Component, OnInit, signal, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminApiService } from '../../core/services/admin-api.service';
import { User } from '../../core/models/admin.models';

@Component({
  selector: 'app-users',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div>
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <div>
          <h1 class="brand-font" style="font-size: 24px; color: var(--secondary); font-weight: 700;">2. User & Customer Management</h1>
          <p style="color: var(--text-muted); font-size: 13.5px;">Control registered customer accounts, view booking records, and handle account status.</p>
        </div>
      </div>

      <!-- FILTER BAR -->
      <div class="card" style="padding: 16px; margin-bottom: 20px;">
        <div style="display: flex; gap: 16px; align-items: center; flex-wrap: wrap;">
          <input
            type="text"
            [(ngModel)]="searchQuery"
            placeholder="Search by name, phone or email..."
            class="form-control"
            style="max-width: 320px;"
          />

          <div style="display: flex; gap: 8px;">
            <button
              class="btn btn-sm"
              [ngClass]="selectedRole() === 'ALL' ? 'btn-primary' : 'btn-outline'"
              (click)="selectedRole.set('ALL')">
              All Users
            </button>
            <button
              class="btn btn-sm"
              [ngClass]="selectedRole() === 'ROLE_CUSTOMER' ? 'btn-primary' : 'btn-outline'"
              (click)="selectedRole.set('ROLE_CUSTOMER')">
              Customers
            </button>
            <button
              class="btn btn-sm"
              [ngClass]="selectedRole() === 'ROLE_VENDOR' ? 'btn-primary' : 'btn-outline'"
              (click)="selectedRole.set('ROLE_VENDOR')">
              Vendors
            </button>
            <button
              class="btn btn-sm"
              [ngClass]="selectedRole() === 'ROLE_ADMIN' ? 'btn-primary' : 'btn-outline'"
              (click)="selectedRole.set('ROLE_ADMIN')">
              Admins
            </button>
          </div>
        </div>
      </div>

      <!-- USERS TABLE -->
      <div class="card">
        <div class="table-responsive">
          <table>
            <thead>
              <tr>
                <th>ID</th>
                <th>Full Name</th>
                <th>Contact Info</th>
                <th>Platform Role</th>
                <th>Registered Date</th>
                <th>Account Status</th>
                <th style="text-align: right;">Action</th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let user of filteredUsers()">
                <td>#{{ user.id }}</td>
                <td>
                  <div style="display: flex; align-items: center; gap: 10px;">
                    <div style="width: 32px; height: 32px; border-radius: 50%; background: #e2e8f0; display: flex; align-items: center; justify-content: center; font-weight: 700; color: #475569; font-size: 13px;">
                      {{ user.fullName.substring(0, 1) }}
                    </div>
                    <strong>{{ user.fullName }}</strong>
                  </div>
                </td>
                <td>
                  <div>📞 {{ user.phone }}</div>
                  <div style="font-size: 12px; color: var(--text-muted);">✉ {{ user.email || 'N/A' }}</div>
                </td>
                <td>
                  <span class="badge" [ngClass]="{
                    'badge-gold': user.role === 'ROLE_ADMIN',
                    'badge-info': user.role === 'ROLE_VENDOR',
                    'badge-success': user.role === 'ROLE_CUSTOMER'
                  }">
                    {{ user.role.replace('ROLE_', '') }}
                  </span>
                </td>
                <td>{{ user.createdAt }}</td>
                <td>
                  <span class="badge" [ngClass]="user.status === 'ACTIVE' ? 'badge-success' : 'badge-danger'">
                    {{ user.status }}
                  </span>
                </td>
                <td style="text-align: right;">
                  <button
                    *ngIf="user.role !== 'ROLE_ADMIN'"
                    class="btn btn-sm"
                    [ngClass]="user.status === 'ACTIVE' ? 'btn-danger' : 'btn-success'"
                    (click)="toggleStatus(user.id)">
                    {{ user.status === 'ACTIVE' ? 'Suspend' : 'Activate' }}
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  `
})
export class UsersComponent implements OnInit {
  private api = inject(AdminApiService);
  searchQuery = '';
  selectedRole = signal<string>('ALL');
  users = this.api.usersSignal;

  filteredUsers = computed(() => {
    let list = this.users();
    const role = this.selectedRole();
    const query = this.searchQuery.toLowerCase().trim();

    if (role !== 'ALL') {
      list = list.filter(u => u.role === role);
    }
    if (query) {
      list = list.filter(u =>
        u.fullName.toLowerCase().includes(query) ||
        u.phone.toLowerCase().includes(query) ||
        (u.email && u.email.toLowerCase().includes(query))
      );
    }
    return list;
  });

  ngOnInit() {
    this.api.getUsers().subscribe();
  }

  toggleStatus(userId: number) {
    if (confirm('Are you sure you want to toggle account status for this user?')) {
      this.api.toggleUserStatus(userId).subscribe();
    }
  }
}
