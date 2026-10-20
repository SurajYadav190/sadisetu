import { Routes } from '@angular/router';
import { LayoutComponent } from './layout/layout.component';
import { DashboardComponent } from './pages/dashboard/dashboard.component';
import { UsersComponent } from './pages/users/users.component';
import { VendorsComponent } from './pages/vendors/vendors.component';
import { CategoriesComponent } from './pages/categories/categories.component';
import { OrdersComponent } from './pages/orders/orders.component';
import { PayoutsComponent } from './pages/payouts/payouts.component';
import { BannersComponent } from './pages/banners/banners.component';
import { CouponsComponent } from './pages/coupons/coupons.component';
import { DisputesComponent } from './pages/disputes/disputes.component';
import { AnalyticsComponent } from './pages/analytics/analytics.component';

export const routes: Routes = [
  {
    path: '',
    component: LayoutComponent,
    children: [
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
      { path: 'dashboard', component: DashboardComponent, title: 'Shaadi Setu | 1. Dashboard' },
      { path: 'users', component: UsersComponent, title: 'Shaadi Setu | 2. Users' },
      { path: 'vendors', component: VendorsComponent, title: 'Shaadi Setu | 3. Vendor KYC' },
      { path: 'categories', component: CategoriesComponent, title: 'Shaadi Setu | 4. Categories' },
      { path: 'orders', component: OrdersComponent, title: 'Shaadi Setu | 5. Master Order Desk' },
      { path: 'payouts', component: PayoutsComponent, title: 'Shaadi Setu | 6. Commission & Payouts' },
      { path: 'banners', component: BannersComponent, title: 'Shaadi Setu | 7. Banner CMS' },
      { path: 'coupons', component: CouponsComponent, title: 'Shaadi Setu | 8. Promotions & Coupons' },
      { path: 'disputes', component: DisputesComponent, title: 'Shaadi Setu | 9. Support & Disputes' },
      { path: 'analytics', component: AnalyticsComponent, title: 'Shaadi Setu | 10. Analytics & Reports' },
    ]
  },
  { path: '**', redirectTo: '' }
];
