import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminApiService } from '../../core/services/admin-api.service';
import { Banner } from '../../core/models/admin.models';

@Component({
  selector: 'app-banners',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div>
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <div>
          <h1 class="brand-font" style="font-size: 24px; color: var(--secondary); font-weight: 700;">7. Banner & Content CMS</h1>
          <p style="color: var(--text-muted); font-size: 13.5px;">Update home screen hero carousels, seasonal wedding deals, and promotional advertising banners.</p>
        </div>
        <button class="btn btn-primary" (click)="openModal()">+ Add New Banner</button>
      </div>

      <!-- BANNERS GRID -->
      <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 24px;">
        <div *ngFor="let banner of banners()" class="card" style="margin-bottom: 0; padding: 0; overflow: hidden;">
          <img [src]="banner.imageUrl" style="width: 100%; height: 160px; object-fit: cover;" />
          <div style="padding: 20px;">
            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px;">
              <h3 style="font-size: 16px; font-weight: 700; color: var(--secondary);">{{ banner.title }}</h3>
              <span class="badge" [ngClass]="banner.active ? 'badge-success' : 'badge-danger'">{{ banner.active ? 'Active' : 'Hidden' }}</span>
            </div>
            <p style="font-size: 13px; color: var(--text-muted); margin-bottom: 12px;">{{ banner.subtitle }}</p>
            <div style="font-size: 12px; color: #475569; margin-bottom: 16px;">
              Target: <code style="background: #e2e8f0; padding: 2px 6px; border-radius: 4px;">{{ banner.targetRoute }}</code>
            </div>
            <div style="display: flex; justify-content: flex-end; gap: 8px;">
              <button class="btn btn-sm btn-outline" (click)="openModal(banner)">Edit</button>
              <button class="btn btn-sm btn-danger" (click)="deleteBanner(banner.id)">Delete</button>
            </div>
          </div>
        </div>
      </div>

      <!-- MODAL -->
      <div class="modal-overlay" *ngIf="showModal" (click)="closeModal()">
        <div class="modal-card" (click)="$event.stopPropagation()">
          <h3 class="brand-font" style="font-size: 20px; margin-bottom: 20px;">
            {{ editingBanner.id ? 'Edit Banner' : 'Create Home Screen Banner' }}
          </h3>

          <div class="form-group">
            <label class="form-label">Banner Title</label>
            <input type="text" [(ngModel)]="editingBanner.title" class="form-control" placeholder="e.g. Grand Wedding Season 2026" />
          </div>

          <div class="form-group">
            <label class="form-label">Subtitle / Offer Text</label>
            <input type="text" [(ngModel)]="editingBanner.subtitle" class="form-control" placeholder="e.g. Book Top Photographers with 15% Cashback" />
          </div>

          <div class="form-group">
            <label class="form-label">Image URL</label>
            <input type="text" [(ngModel)]="editingBanner.imageUrl" class="form-control" />
          </div>

          <div class="form-group">
            <label class="form-label">Target Route / Category</label>
            <input type="text" [(ngModel)]="editingBanner.targetRoute" class="form-control" placeholder="/services/camera-photography" />
          </div>

          <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px;">
            <button class="btn btn-outline" (click)="closeModal()">Cancel</button>
            <button class="btn btn-primary" (click)="saveBanner()">Save Banner</button>
          </div>
        </div>
      </div>
    </div>
  `
})
export class BannersComponent implements OnInit {
  private api = inject(AdminApiService);
  banners = this.api.bannersSignal;
  showModal = false;
  editingBanner: Partial<Banner> = {};

  ngOnInit() {
    this.api.getBanners().subscribe();
  }

  openModal(b?: Banner) {
    this.editingBanner = b ? { ...b } : {
      active: true,
      displayOrder: 1,
      imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552',
      targetRoute: '/services/camera-photography'
    };
    this.showModal = true;
  }

  closeModal() {
    this.showModal = false;
  }

  saveBanner() {
    this.api.saveBanner(this.editingBanner).subscribe(() => {
      this.closeModal();
    });
  }

  deleteBanner(id: number) {
    if (confirm('Delete this banner?')) {
      this.api.deleteBanner(id).subscribe();
    }
  }
}
