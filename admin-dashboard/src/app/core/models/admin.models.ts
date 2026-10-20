export interface User {
  id: number;
  fullName: string;
  phone: string;
  email?: string;
  role: 'ROLE_CUSTOMER' | 'ROLE_VENDOR' | 'ROLE_ADMIN';
  status: 'ACTIVE' | 'SUSPENDED';
  createdAt: string;
}

export interface Category {
  id: number;
  name: string;
  slug: string;
  icon: string;
  description: string;
  startingPrice: number;
  active: boolean;
  dynamicFieldsJson?: string;
}

export interface VendorProfile {
  id: number;
  user: User;
  category?: Category;
  businessName: string;
  bio?: string;
  city?: string;
  address?: string;
  kycStatus: 'PENDING' | 'VERIFIED' | 'REJECTED';
  businessLicenseUrl?: string;
  idProofUrl?: string;
  kycRejectionReason?: string;
  bankAccountNumber?: string;
  bankIfsc?: string;
  bankHolderName?: string;
  isOnline: boolean;
  rating: number;
  reviewCount: number;
  commissionRate: number;
  walletBalance: number;
}

export interface Booking {
  id: number;
  bookingNumber: string;
  customer: User;
  vendor: VendorProfile;
  servicePackage?: {
    id: number;
    title: string;
    price: number;
  };
  bookingDate: string;
  timeSlot: string;
  venueAddress: string;
  status: 'PENDING' | 'ACCEPTED' | 'REJECTED' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED';
  totalAmount: number;
  commissionAmount: number;
  payoutAmount: number;
  paymentStatus: 'ESCROW_HELD' | 'RELEASED' | 'REFUNDED';
  customerNotes?: string;
  createdAt: string;
}

export interface Banner {
  id: number;
  title: string;
  subtitle: string;
  imageUrl: string;
  targetRoute: string;
  active: boolean;
  expiryDate?: string;
  displayOrder: number;
}

export interface Coupon {
  id: number;
  code: string;
  discountPercent: number;
  maxDiscountAmount: number;
  minBookingAmount: number;
  validUntil: string;
  usageCount: number;
  active: boolean;
}

export interface SupportTicket {
  id: number;
  ticketNumber: string;
  user: User;
  booking?: Booking;
  subject: string;
  description: string;
  priority: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT';
  status: 'OPEN' | 'IN_REVIEW' | 'RESOLVED' | 'CLOSED';
  resolutionNotes?: string;
  createdAt: string;
}

export interface DashboardStats {
  totalUsers: number;
  totalCustomers: number;
  totalVendors: number;
  pendingKycCount: number;
  verifiedVendorsCount: number;
  totalBookings: number;
  pendingBookings: number;
  completedBookings: number;
  grossMerchandiseValue: number;
  platformCommissionEarned: number;
  openSupportTickets: number;
  monthlyRevenue: { month: string; revenue: number }[];
  categoryBreakdown: { category: string; count: number }[];
}
