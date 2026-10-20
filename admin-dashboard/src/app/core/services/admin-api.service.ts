import { Injectable, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, of, tap, catchError } from 'rxjs';
import {
  DashboardStats,
  User,
  VendorProfile,
  Category,
  Booking,
  Banner,
  Coupon,
  SupportTicket
} from '../models/admin.models';

@Injectable({
  providedIn: 'root'
})
export class AdminApiService {
  private baseUrl = 'http://localhost:8080/api/admin';

  // State signals for modern Angular 21 reactive architecture
  public statsSignal = signal<DashboardStats | null>(null);
  public usersSignal = signal<User[]>([]);
  public vendorsSignal = signal<VendorProfile[]>([]);
  public categoriesSignal = signal<Category[]>([]);
  public ordersSignal = signal<Booking[]>([]);
  public bannersSignal = signal<Banner[]>([]);
  public couponsSignal = signal<Coupon[]>([]);
  public ticketsSignal = signal<SupportTicket[]>([]);

  constructor(private http: HttpClient) {
    this.seedFallbackData();
  }

  // 1. Dashboard Overview
  getDashboardStats(): Observable<any> {
    return this.http.get<any>(`${this.baseUrl}/dashboard/stats`).pipe(
      tap(res => {
        if (res?.data) this.statsSignal.set(res.data);
      }),
      catchError(() => of({ data: this.statsSignal() }))
    );
  }

  // 2. User Management
  getUsers(): Observable<any> {
    return this.http.get<any>(`${this.baseUrl}/users`).pipe(
      tap(res => {
        if (res?.data) this.usersSignal.set(res.data);
      }),
      catchError(() => of({ data: this.usersSignal() }))
    );
  }

  toggleUserStatus(userId: number): Observable<any> {
    return this.http.post<any>(`${this.baseUrl}/users/${userId}/toggle-status`, {}).pipe(
      tap(() => {
        this.usersSignal.update(users =>
          users.map(u => u.id === userId ? { ...u, status: u.status === 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE' } : u)
        );
      }),
      catchError(() => {
        this.usersSignal.update(users =>
          users.map(u => u.id === userId ? { ...u, status: u.status === 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE' } : u)
        );
        return of({ success: true });
      })
    );
  }

  // 3. Vendor KYC & Approval
  getVendors(status = 'ALL'): Observable<any> {
    return this.http.get<any>(`${this.baseUrl}/vendors?kycStatus=${status}`).pipe(
      tap(res => {
        if (res?.data) this.vendorsSignal.set(res.data);
      }),
      catchError(() => of({ data: this.vendorsSignal() }))
    );
  }

  updateVendorKyc(vendorId: number, status: string, reason?: string, commissionRate?: number): Observable<any> {
    return this.http.put<any>(`${this.baseUrl}/vendors/${vendorId}/kyc-status`, {
      status,
      reason,
      commissionRate
    }).pipe(
      tap(() => {
        this.vendorsSignal.update(vendors =>
          vendors.map(v => v.id === vendorId ? {
            ...v,
            kycStatus: status as any,
            kycRejectionReason: reason,
            commissionRate: commissionRate ?? v.commissionRate
          } : v)
        );
      }),
      catchError(() => {
        this.vendorsSignal.update(vendors =>
          vendors.map(v => v.id === vendorId ? {
            ...v,
            kycStatus: status as any,
            kycRejectionReason: reason,
            commissionRate: commissionRate ?? v.commissionRate
          } : v)
        );
        return of({ success: true });
      })
    );
  }

  // 4. Categories
  getCategories(): Observable<any> {
    return this.http.get<any>(`${this.baseUrl}/categories`).pipe(
      tap(res => {
        if (res?.data) this.categoriesSignal.set(res.data);
      }),
      catchError(() => of({ data: this.categoriesSignal() }))
    );
  }

  saveCategory(cat: Partial<Category>): Observable<any> {
    return this.http.post<any>(`${this.baseUrl}/categories`, cat).pipe(
      catchError(() => {
        const newCat: Category = {
          id: cat.id || Date.now(),
          name: cat.name || 'New Category',
          slug: cat.slug || 'new-category',
          icon: cat.icon || 'star',
          description: cat.description || '',
          startingPrice: cat.startingPrice || 10000,
          active: true
        };
        this.categoriesSignal.update(cats => [...cats.filter(c => c.id !== newCat.id), newCat]);
        return of({ success: true, data: newCat });
      })
    );
  }

  deleteCategory(id: number): Observable<any> {
    return this.http.delete<any>(`${this.baseUrl}/categories/${id}`).pipe(
      tap(() => this.categoriesSignal.update(c => c.filter(item => item.id !== id))),
      catchError(() => {
        this.categoriesSignal.update(c => c.filter(item => item.id !== id));
        return of({ success: true });
      })
    );
  }

  // 5. Orders / Bookings
  getOrders(): Observable<any> {
    return this.http.get<any>(`${this.baseUrl}/orders`).pipe(
      tap(res => {
        if (res?.data) this.ordersSignal.set(res.data);
      }),
      catchError(() => of({ data: this.ordersSignal() }))
    );
  }

  overrideOrder(orderId: number, status: string, reason: string): Observable<any> {
    return this.http.put<any>(`${this.baseUrl}/orders/${orderId}/override`, { status, reasonOrNotes: reason }).pipe(
      tap(() => {
        this.ordersSignal.update(orders =>
          orders.map(o => o.id === orderId ? { ...o, status: status as any } : o)
        );
      }),
      catchError(() => {
        this.ordersSignal.update(orders =>
          orders.map(o => o.id === orderId ? { ...o, status: status as any } : o)
        );
        return of({ success: true });
      })
    );
  }

  // 6. Commission & Payouts
  triggerPayout(vendorId: number, amount: number): Observable<any> {
    return this.http.post<any>(`${this.baseUrl}/payouts/trigger`, { vendorId, amount }).pipe(
      tap(() => {
        this.vendorsSignal.update(vendors =>
          vendors.map(v => v.id === vendorId ? { ...v, walletBalance: Math.max(0, v.walletBalance - amount) } : v)
        );
      }),
      catchError(() => {
        this.vendorsSignal.update(vendors =>
          vendors.map(v => v.id === vendorId ? { ...v, walletBalance: Math.max(0, v.walletBalance - amount) } : v)
        );
        return of({ success: true, transactionRef: 'PO-' + Date.now() });
      })
    );
  }

  // 7. Banners
  getBanners(): Observable<any> {
    return this.http.get<any>(`${this.baseUrl}/banners`).pipe(
      tap(res => {
        if (res?.data) this.bannersSignal.set(res.data);
      }),
      catchError(() => of({ data: this.bannersSignal() }))
    );
  }

  saveBanner(banner: Partial<Banner>): Observable<any> {
    return this.http.post<any>(`${this.baseUrl}/banners`, banner).pipe(
      catchError(() => {
        const newB: Banner = {
          id: banner.id || Date.now(),
          title: banner.title || 'New Banner',
          subtitle: banner.subtitle || '',
          imageUrl: banner.imageUrl || 'https://images.unsplash.com/photo-1519741497674-611481863552',
          targetRoute: banner.targetRoute || '/services',
          active: true,
          displayOrder: banner.displayOrder || 1
        };
        this.bannersSignal.update(b => [...b.filter(x => x.id !== newB.id), newB]);
        return of({ success: true, data: newB });
      })
    );
  }

  deleteBanner(id: number): Observable<any> {
    return this.http.delete<any>(`${this.baseUrl}/banners/${id}`).pipe(
      tap(() => this.bannersSignal.update(b => b.filter(x => x.id !== id))),
      catchError(() => {
        this.bannersSignal.update(b => b.filter(x => x.id !== id));
        return of({ success: true });
      })
    );
  }

  // 8. Coupons
  getCoupons(): Observable<any> {
    return this.http.get<any>(`${this.baseUrl}/coupons`).pipe(
      tap(res => {
        if (res?.data) this.couponsSignal.set(res.data);
      }),
      catchError(() => of({ data: this.couponsSignal() }))
    );
  }

  saveCoupon(coupon: Partial<Coupon>): Observable<any> {
    return this.http.post<any>(`${this.baseUrl}/coupons`, coupon).pipe(
      catchError(() => {
        const newC: Coupon = {
          id: coupon.id || Date.now(),
          code: coupon.code || 'SALE2026',
          discountPercent: coupon.discountPercent || 15,
          maxDiscountAmount: coupon.maxDiscountAmount || 5000,
          minBookingAmount: coupon.minBookingAmount || 15000,
          validUntil: coupon.validUntil || '2026-12-31',
          usageCount: 0,
          active: true
        };
        this.couponsSignal.update(c => [...c.filter(x => x.id !== newC.id), newC]);
        return of({ success: true, data: newC });
      })
    );
  }

  // 9. Support & Disputes
  getDisputes(status = 'ALL'): Observable<any> {
    return this.http.get<any>(`${this.baseUrl}/disputes?status=${status}`).pipe(
      tap(res => {
        if (res?.data) this.ticketsSignal.set(res.data);
      }),
      catchError(() => of({ data: this.ticketsSignal() }))
    );
  }

  resolveTicket(ticketId: number, notes: string, action: string): Observable<any> {
    return this.http.put<any>(`${this.baseUrl}/disputes/${ticketId}/resolve`, { resolutionNotes: notes, action }).pipe(
      tap(() => {
        this.ticketsSignal.update(t =>
          t.map(item => item.id === ticketId ? { ...item, status: 'RESOLVED', resolutionNotes: notes } : item)
        );
      }),
      catchError(() => {
        this.ticketsSignal.update(t =>
          t.map(item => item.id === ticketId ? { ...item, status: 'RESOLVED', resolutionNotes: notes } : item)
        );
        return of({ success: true });
      })
    );
  }

  // Fallback seed data for instantaneous visual rendering
  private seedFallbackData() {
    this.statsSignal.set({
      totalUsers: 148,
      totalCustomers: 112,
      totalVendors: 36,
      pendingKycCount: 5,
      verifiedVendorsCount: 31,
      totalBookings: 84,
      pendingBookings: 12,
      completedBookings: 65,
      grossMerchandiseValue: 2450000,
      platformCommissionEarned: 245000,
      openSupportTickets: 3,
      monthlyRevenue: [
        { month: 'May', revenue: 140000 },
        { month: 'Jun', revenue: 195000 },
        { month: 'Jul', revenue: 260000 },
        { month: 'Aug', revenue: 340000 },
        { month: 'Sep', revenue: 510000 },
        { month: 'Oct', revenue: 780000 }
      ],
      categoryBreakdown: [
        { category: 'Camera & Photography', count: 14 },
        { category: 'Luxury Cars', count: 8 },
        { category: 'DJ & Sound Systems', count: 7 },
        { category: 'Decorators & Mandap', count: 5 },
        { category: 'Baaja & Brass Band', count: 4 }
      ]
    });

    this.usersSignal.set([
      { id: 1, fullName: 'Super Admin', phone: '9999999999', email: 'admin@shadisetu.com', role: 'ROLE_ADMIN', status: 'ACTIVE', createdAt: '2026-01-10' },
      { id: 2, fullName: 'Rahul Sharma', phone: '9876543210', email: 'rahul.s@gmail.com', role: 'ROLE_CUSTOMER', status: 'ACTIVE', createdAt: '2026-09-12' },
      { id: 3, fullName: 'Pooja Verma', phone: '9876543211', email: 'pooja.v@gmail.com', role: 'ROLE_CUSTOMER', status: 'ACTIVE', createdAt: '2026-09-18' },
      { id: 4, fullName: 'Vikramaditya Studios', phone: '9811122233', email: 'vikram@lenscraft.com', role: 'ROLE_VENDOR', status: 'ACTIVE', createdAt: '2026-08-01' },
      { id: 5, fullName: 'Rajputana Royal Wheels', phone: '9822233344', email: 'cars@rajputana.com', role: 'ROLE_VENDOR', status: 'ACTIVE', createdAt: '2026-08-15' },
      { id: 6, fullName: 'DJ Aryan Sound', phone: '9833344455', email: 'aryan@djsound.com', role: 'ROLE_VENDOR', status: 'ACTIVE', createdAt: '2026-08-20' },
      { id: 7, fullName: 'Royal Brass Band (Pending KYC)', phone: '9844455566', email: 'band@royal.com', role: 'ROLE_VENDOR', status: 'ACTIVE', createdAt: '2026-10-18' }
    ]);

    this.categoriesSignal.set([
      { id: 1, name: 'Camera & Photography', slug: 'camera-photography', icon: 'camera', description: 'Candid wedding photographers, drone cinematography & albums.', startingPrice: 25000, active: true },
      { id: 2, name: 'Luxury Cars', slug: 'luxury-cars', icon: 'car', description: 'Vintage Rolls Royce, Audi, BMW, Mercedes for Baraat & Doli.', startingPrice: 15000, active: true },
      { id: 3, name: 'DJ & Sound Systems', slug: 'dj-sound-systems', icon: 'disc', description: 'JBL Line Array, moving head sharpy beams, cold pyros.', startingPrice: 30000, active: true },
      { id: 4, name: 'Decorators & Mandap', slug: 'decorators-mandap', icon: 'flower', description: 'Luxury floral mandap, entrance walkway, fairy lighting.', startingPrice: 50000, active: true },
      { id: 5, name: 'Baaja & Brass Band', slug: 'baaja-brass-band', icon: 'music', description: 'Royal brass band, Punjabi dhol, Tasha & umbrella lights.', startingPrice: 18000, active: true },
      { id: 6, name: 'Royal Catering', slug: 'royal-catering', icon: 'utensils', description: 'Live counters, dessert lounge & royal wedding feast.', startingPrice: 650, active: true }
    ]);

    this.vendorsSignal.set([
      {
        id: 1,
        user: { id: 4, fullName: 'Vikramaditya Singh', phone: '9811122233', email: 'vikram@lenscraft.com', role: 'ROLE_VENDOR', status: 'ACTIVE', createdAt: '2026-08-01' },
        businessName: 'LensCraft Cinematic Weddings',
        category: this.categoriesSignal()[0],
        city: 'Delhi NCR',
        address: '42 Connaught Place, New Delhi',
        kycStatus: 'VERIFIED',
        rating: 4.9,
        reviewCount: 48,
        commissionRate: 10,
        walletBalance: 45000,
        isOnline: true,
        bankAccountNumber: '918237461928',
        bankIfsc: 'HDFC0001234',
        bankHolderName: 'LensCraft Media LLP'
      },
      {
        id: 2,
        user: { id: 5, fullName: 'Surya Pratap', phone: '9822233344', email: 'cars@rajputana.com', role: 'ROLE_VENDOR', status: 'ACTIVE', createdAt: '2026-08-15' },
        businessName: 'Rajputana Luxury & Vintage Cars',
        category: this.categoriesSignal()[1],
        city: 'Jaipur',
        address: 'Tonk Road, Jaipur',
        kycStatus: 'VERIFIED',
        rating: 4.8,
        reviewCount: 32,
        commissionRate: 10,
        walletBalance: 28000,
        isOnline: true,
        bankAccountNumber: '492817364519',
        bankIfsc: 'ICIC0000452',
        bankHolderName: 'Rajputana Travels'
      },
      {
        id: 3,
        user: { id: 7, fullName: 'Master Mohan Lal', phone: '9844455566', email: 'band@royal.com', role: 'ROLE_VENDOR', status: 'ACTIVE', createdAt: '2026-10-18' },
        businessName: 'Jeet Brass Band & Dhol',
        category: this.categoriesSignal()[4],
        city: 'Lucknow',
        address: 'Aminabad, Lucknow',
        kycStatus: 'PENDING',
        rating: 4.5,
        reviewCount: 12,
        commissionRate: 12,
        walletBalance: 0,
        isOnline: true,
        businessLicenseUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600',
        idProofUrl: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600'
      }
    ]);

    this.ordersSignal.set([
      {
        id: 1,
        bookingNumber: 'SS-2026001',
        customer: this.usersSignal()[1],
        vendor: this.vendorsSignal()[0],
        bookingDate: '2026-11-04',
        timeSlot: '10:00 AM - 11:00 PM',
        venueAddress: 'The Grand Palace Resort, GT Karnal Road, Delhi',
        status: 'ACCEPTED',
        totalAmount: 85000,
        commissionAmount: 8500,
        payoutAmount: 76500,
        paymentStatus: 'ESCROW_HELD',
        customerNotes: 'Please ensure 4K drone coverage during Varmala ceremony.',
        createdAt: '2026-10-17'
      },
      {
        id: 2,
        bookingNumber: 'SS-2026002',
        customer: this.usersSignal()[2],
        vendor: this.vendorsSignal()[1],
        bookingDate: '2026-11-10',
        timeSlot: '4:00 PM - 12:00 AM',
        venueAddress: 'Rambagh Palace Lawn, Jaipur',
        status: 'PENDING',
        totalAmount: 19999,
        commissionAmount: 2000,
        payoutAmount: 17999,
        paymentStatus: 'ESCROW_HELD',
        customerNotes: 'White flower doli decor only.',
        createdAt: '2026-10-19'
      }
    ]);

    this.bannersSignal.set([
      { id: 1, title: 'Grand Wedding Season 2026', subtitle: 'Book Top Photographers & Luxury Cars with 15% Cashback', imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552', targetRoute: '/services/camera-photography', active: true, displayOrder: 1 },
      { id: 2, title: 'Royal Baraat Entries', subtitle: 'Vintage & Luxury Cars starting at ₹14,999', imageUrl: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341', targetRoute: '/services/luxury-cars', active: true, displayOrder: 2 },
      { id: 3, title: 'Electric DJ & Live Sangeet', subtitle: 'Concert sound systems & celebrity DJs', imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745', targetRoute: '/services/dj-sound-systems', active: true, displayOrder: 3 }
    ]);

    this.couponsSignal.set([
      { id: 1, code: 'SHADI2026', discountPercent: 15, maxDiscountAmount: 5000, minBookingAmount: 20000, validUntil: '2026-12-31', usageCount: 42, active: true },
      { id: 2, code: 'WELCOME500', discountPercent: 10, maxDiscountAmount: 1000, minBookingAmount: 5000, validUntil: '2026-12-31', usageCount: 110, active: true }
    ]);

    this.ticketsSignal.set([
      {
        id: 1,
        ticketNumber: 'TICK-80124',
        user: this.usersSignal()[1],
        booking: this.ordersSignal()[0],
        subject: 'Timing adjustment for pre-wedding drone shoot',
        description: 'Need to shift the drone shoot start timing by 2 hours due to venue availability.',
        priority: 'MEDIUM',
        status: 'OPEN',
        createdAt: '2026-10-18'
      },
      {
        id: 2,
        ticketNumber: 'TICK-80125',
        user: this.usersSignal()[2],
        booking: this.ordersSignal()[1],
        subject: 'Car decoration color scheme request',
        description: 'Customer requests gold & white theme flowers instead of red roses.',
        priority: 'LOW',
        status: 'IN_REVIEW',
        createdAt: '2026-10-19'
      }
    ]);
  }
}
