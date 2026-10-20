import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminApiService } from '../../core/services/admin-api.service';
import { Category } from '../../core/models/admin.models';

@Component({
  selector: 'app-categories',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div>
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <div>
          <h1 class="brand-font" style="font-size: 24px; color: var(--secondary); font-weight: 700;">4. Wedding Category Management</h1>
          <p style="color: var(--text-muted); font-size: 13.5px;">Dynamically configure event service categories, base starting pricing, and custom specifications.</p>
        </div>
        <button class="btn btn-primary" (click)="openModal()">+ Add New Category</button>
      </div>

      <!-- CATEGORIES GRID -->
      <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 20px;">
        <div *ngFor="let cat of categories()" class="card" style="margin-bottom: 0;">
          <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px;">
            <div style="display: flex; align-items: center; gap: 12px;">
              <div style="width: 44px; height: 44px; border-radius: 10px; background: #fdf2f4; color: var(--primary); display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: 700;">
                ★
              </div>
              <div>
                <h3 style="font-size: 16px; font-weight: 700; color: var(--secondary);">{{ cat.name }}</h3>
                <span style="font-size: 12px; color: var(--text-muted);">Slug: /{{ cat.slug }}</span>
              </div>
            </div>
            <span class="badge" [ngClass]="cat.active ? 'badge-success' : 'badge-danger'">{{ cat.active ? 'Active' : 'Disabled' }}</span>
          </div>

          <p style="font-size: 13px; color: #475569; margin-bottom: 16px; min-height: 40px;">
            {{ cat.description }}
          </p>

          <div style="padding: 12px; background: #f8fafc; border-radius: 8px; border: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <span style="font-size: 12px; color: var(--text-muted);">Market Starting Price</span>
            <strong style="color: var(--secondary); font-size: 15px;">₹{{ cat.startingPrice | number }}</strong>
          </div>

          <div style="display: flex; justify-content: flex-end; gap: 8px;">
            <button class="btn btn-sm btn-outline" (click)="openModal(cat)">Edit</button>
            <button class="btn btn-sm btn-danger" (click)="deleteCategory(cat.id)">Delete</button>
          </div>
        </div>
      </div>

      <!-- CATEGORY ADD/EDIT MODAL -->
      <div class="modal-overlay" *ngIf="showModal" (click)="closeModal()">
        <div class="modal-card" (click)="$event.stopPropagation()">
          <h3 class="brand-font" style="font-size: 20px; margin-bottom: 20px;">
            {{ editingCategory.id ? 'Edit Category' : 'Create New Wedding Category' }}
          </h3>

          <div class="form-group">
            <label class="form-label">Category Name</label>
            <input type="text" [(ngModel)]="editingCategory.name" class="form-control" placeholder="e.g. Baaja & Brass Band" />
          </div>

          <div class="form-group">
            <label class="form-label">URL Slug</label>
            <input type="text" [(ngModel)]="editingCategory.slug" class="form-control" placeholder="e.g. baaja-brass-band" />
          </div>

          <div class="form-group">
            <label class="form-label">Starting Price Benchmark (INR)</label>
            <input type="number" [(ngModel)]="editingCategory.startingPrice" class="form-control" />
          </div>

          <div class="form-group">
            <label class="form-label">Description</label>
            <textarea [(ngModel)]="editingCategory.description" class="form-control" rows="3"></textarea>
          </div>

          <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px;">
            <button class="btn btn-outline" (click)="closeModal()">Cancel</button>
            <button class="btn btn-primary" (click)="saveCategory()">Save Category</button>
          </div>
        </div>
      </div>
    </div>
  `
})
export class CategoriesComponent implements OnInit {
  private api = inject(AdminApiService);
  categories = this.api.categoriesSignal;
  showModal = false;
  editingCategory: Partial<Category> = {};

  ngOnInit() {
    this.api.getCategories().subscribe();
  }

  openModal(cat?: Category) {
    this.editingCategory = cat ? { ...cat } : { startingPrice: 15000, active: true };
    this.showModal = true;
  }

  closeModal() {
    this.showModal = false;
  }

  saveCategory() {
    this.api.saveCategory(this.editingCategory).subscribe(() => {
      this.closeModal();
    });
  }

  deleteCategory(id: number) {
    if (confirm('Delete this category?')) {
      this.api.deleteCategory(id).subscribe();
    }
  }
}
