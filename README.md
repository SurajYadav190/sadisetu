# 💍 Shaadi Setu - Wedding & Event Services Marketplace Platform

A complete, production-grade Dual-Ecosystem Wedding & Event Services Booking Platform built according to the **Figma UI/UX Architecture Blueprint** and **Project Quotation Specification**.

---

## 🏛️ System Architecture Overview

```
d:\sadi setu project\
├── backend/                  # Java 21 + Spring Boot 3.3.4 + MySQL / H2 + WebSockets STOMP
│   ├── src/main/java/com/shadisetu/
│   │   ├── config/           # Security, Stateless JWT, WebSockets, CORS
│   │   ├── entity/           # User, VendorProfile, Category, Package, Booking, Escrow, Reviews, Banners
│   │   ├── repository/       # Spring Data JPA Repositories
│   │   ├── service/          # AuthService, CustomerService, VendorService, AdminService, ChatService
│   │   ├── controller/       # Auth, Customer, Vendor, Admin (10 screens), Chat
│   │   └── data/             # DataInitializer (Pre-seeds categories, vendors, packages, banners, orders)
│   ├── pom.xml
│   └── mvnw.cmd              # Bundled Maven wrapper (Java 21 ready)
│
├── admin-dashboard/          # Angular 21 Standalone Components + Signals + Luxury Styling
│   ├── src/app/
│   │   ├── core/             # Models, AdminApiService with reactive state signals & live fallback
│   │   ├── layout/           # Super Admin sidebar, top bar, breadcrumbs, status indicator
│   │   └── pages/            # 10 Dedicated Super Admin Modules:
│   │       ├── dashboard/    # 1. Executive Business Overview & Revenue Growth Charts
│   │       ├── users/        # 2. User & Customer Management (Block/Unblock, history)
│   │       ├── vendors/      # 3. Vendor KYC & Compliance Verification (Doc viewer, Approve/Reject)
│   │       ├── categories/   # 4. Category Management (Dynamic categories & benchmark prices)
│   │       ├── orders/       # 5. Master Order Desk & Dispatch (Escrow status, Admin overrides)
│   │       ├── payouts/      # 6. Commission Rules & Vendor Payouts (Wallet balances, IMPS trigger)
│   │       ├── banners/      # 7. Banner & Content CMS (Hero carousels, target routes)
│   │       ├── coupons/      # 8. Promotions & Discount Vouchers (Coupon generator, push alerts)
│   │       ├── disputes/     # 9. Support & Dispute Resolution Portal (Ticket queue, refund controls)
│   │       └── analytics/    # 10. Analytics & Business Intelligence (Export CSV, Print summary)
│
└── mobile-app/               # Flutter 3.35.1 (Dart 3.9) Dual App Ecosystem
    ├── lib/
    │   ├── config/           # AppTheme (Royal Crimson #9B1B30 & Wedding Gold #D4AF37)
    │   ├── models/           # UserModel, CategoryModel, VendorModel, BookingModel, ChatModel
    │   ├── services/         # ApiService (REST sync & instant offline interactive mock engine)
    │   └── screens/
    │       ├── common/       # RoleSelectorScreen, AuthScreen (Phone OTP)
    │       ├── customer/     # 15 Customer Screens & Flows (Onboarding, Home, Search, Detail, Checkout, Success, Tracker, Chat)
    │       └── vendor/       # 7 Vendor Modules (KYC Onboarding, Dashboard, Order Dispatch, Calendar Blocking, Catalog, Earnings, Chat)
```

---

## 🚀 How to Run the Applications

### 1. Start the Spring Boot Backend (Port 8080)
Open a terminal in `backend/` and run:
```powershell
cd "d:\sadi setu project\backend"
.\mvnw.cmd spring-boot:run
```
* **Swagger OpenAPI Docs**: `http://localhost:8080/swagger-ui/index.html`
* **H2 Database Console**: `http://localhost:8080/h2-console` (JDBC URL: `jdbc:h2:mem:shadisetu_db`, user: `sa`, blank password)
* **MySQL Configuration**: To connect to your local MySQL, set `spring.profiles.active=mysql` in `application.yml`.
* **Default Super Admin**: Email `admin@shadisetu.com`, Password `admin123`, Phone `9999999999`

---

### 2. Start the Angular 21 Admin Dashboard (Port 4200)
Open a terminal in `admin-dashboard/` and run:
```powershell
cd "d:\sadi setu project\admin-dashboard"
npm start
```
* Open your browser at: **`http://localhost:4200`**
* All 10 modules are fully interactive and pre-loaded with live state signals.

---

### 3. Start the Flutter Mobile Application
Open a terminal in `mobile-app/` and run:
```powershell
cd "d:\sadi setu project\mobile-app"
flutter run
```
*(Supports Android emulator, iOS simulator, Windows desktop, or Chrome web preview `flutter run -d chrome`).*

---

## 🎯 Key Features Implemented

1. **Dual-App Ecosystem Switcher**:
   - Seamlessly launch and switch between the **Customer Booking App** and the **Vendor Merchant App** from the startup screen.
2. **Escrow Payment Security**:
   - Customer deposits are securely designated as `ESCROW_HELD`. Funds are only credited to the vendor wallet once the ceremony is marked `COMPLETED`.
3. **Availability Calendar & Date Blocking**:
   - Vendors can tap any calendar date to block it, immediately preventing double-bookings.
4. **Interactive 60-Second Incoming Order Alert**:
   - Real-time modal with countdown timer alerting merchants to instant incoming wedding bookings.
5. **Super Admin Web Portal (10 Screens)**:
   - Includes real-time revenue charts, document review modal, category editor, commission settings, automated payouts, promotional banners, promo coupons, dispute refund mediation, and CSV export.
