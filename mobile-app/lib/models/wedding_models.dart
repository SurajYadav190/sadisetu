class UserModel {
  final int id;
  final String fullName;
  final String phone;
  final String? email;
  final String role; // ROLE_CUSTOMER, ROLE_VENDOR, ROLE_ADMIN

  UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? 'Guest User',
      phone: json['phone'] ?? '',
      email: json['email'],
      role: json['role'] ?? 'ROLE_CUSTOMER',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phone': phone,
    'email': email,
    'role': role,
  };
}

class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String icon;
  final String description;
  final double startingPrice;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.description,
    required this.startingPrice,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      icon: json['icon'] ?? 'star',
      description: json['description'] ?? '',
      startingPrice: (json['startingPrice'] ?? 0).toDouble(),
    );
  }
}

class ServicePackageModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final double? discountedPrice;
  final List<String> features;
  final int durationHours;

  ServicePackageModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.discountedPrice,
    required this.features,
    required this.durationHours,
  });

  factory ServicePackageModel.fromJson(Map<String, dynamic> json) {
    return ServicePackageModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountedPrice: json['discountedPrice'] != null ? (json['discountedPrice']).toDouble() : null,
      features: (json['features'] as List?)?.map((e) => e.toString()).toList() ?? [],
      durationHours: json['durationHours'] ?? 8,
    );
  }
}

class VendorModel {
  final int id;
  final String businessName;
  final String categoryName;
  final String bio;
  final String city;
  final String address;
  final double rating;
  final int reviewCount;
  final double startingPrice;
  final bool isOnline;
  final String kycStatus;
  final String? coverImageUrl;
  final List<ServicePackageModel> packages;

  VendorModel({
    required this.id,
    required this.businessName,
    required this.categoryName,
    required this.bio,
    required this.city,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.startingPrice,
    required this.isOnline,
    required this.kycStatus,
    this.coverImageUrl,
    required this.packages,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] ?? 0,
      businessName: json['businessName'] ?? '',
      categoryName: json['category'] != null ? (json['category']['name'] ?? '') : 'Wedding Service',
      bio: json['bio'] ?? '',
      city: json['city'] ?? 'Delhi NCR',
      address: json['address'] ?? '',
      rating: (json['rating'] ?? 4.8).toDouble(),
      reviewCount: json['reviewCount'] ?? 10,
      startingPrice: (json['startingPrice'] ?? 15000).toDouble(),
      isOnline: json['isOnline'] ?? true,
      kycStatus: json['kycStatus'] ?? 'VERIFIED',
      coverImageUrl: json['coverImageUrl'],
      packages: [],
    );
  }
}

class ServiceVarietyOption {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationHours; // added time in hours
  final String categorySlug;
  final String badge;
  final String icon;

  const ServiceVarietyOption({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationHours,
    required this.categorySlug,
    this.badge = '',
    this.icon = 'camera',
  });

  factory ServiceVarietyOption.fromJson(Map<String, dynamic> json) {
    return ServiceVarietyOption(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      durationHours: json['durationHours'] ?? 0,
      categorySlug: json['categorySlug'] ?? '',
      badge: json['badge'] ?? '',
      icon: json['icon'] ?? 'camera',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'durationHours': durationHours,
    'categorySlug': categorySlug,
    'badge': badge,
    'icon': icon,
  };
}

class BookingModel {
  final int id;
  final String bookingNumber;
  final String customerName;
  final String vendorName;
  final String categoryName;
  final String bookingDate;
  final String timeSlot;
  final String venueAddress;
  String status; // PENDING, ACCEPTED, IN_PROGRESS, COMPLETED, CANCELLED
  final double totalAmount;
  String paymentStatus; // ESCROW_HELD, RELEASED, REFUNDED
  String? paymentTransactionId;
  final List<String> selectedVarieties;
  final int totalDurationHours;

  BookingModel({
    required this.id,
    required this.bookingNumber,
    required this.customerName,
    required this.vendorName,
    required this.categoryName,
    required this.bookingDate,
    required this.timeSlot,
    required this.venueAddress,
    required this.status,
    required this.totalAmount,
    required this.paymentStatus,
    this.paymentTransactionId,
    this.selectedVarieties = const [],
    this.totalDurationHours = 8,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    List<String> varieties = [];
    if (json['selectedVarieties'] is List) {
      varieties = (json['selectedVarieties'] as List).map((e) => e.toString()).toList();
    } else if (json['selectedVarieties'] is String && (json['selectedVarieties'] as String).isNotEmpty) {
      varieties = (json['selectedVarieties'] as String)
          .split(';')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return BookingModel(
      id: json['id'] ?? 0,
      bookingNumber: json['bookingNumber'] ?? '',
      customerName: json['customer']?['fullName'] ?? (json['customerName'] ?? 'Client'),
      vendorName: json['vendor']?['businessName'] ?? (json['vendorName'] ?? 'Vendor'),
      categoryName: json['vendor']?['category']?['name'] ?? (json['categoryName'] ?? 'Wedding'),
      bookingDate: json['bookingDate'] ?? '',
      timeSlot: json['timeSlot'] ?? 'Full Day',
      venueAddress: json['venueAddress'] ?? '',
      status: json['status'] ?? 'PENDING',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'ESCROW_HELD',
      paymentTransactionId: json['paymentTransactionId'],
      selectedVarieties: varieties,
      totalDurationHours: json['durationHours'] ?? (json['totalDurationHours'] ?? 8),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookingNumber': bookingNumber,
    'customerName': customerName,
    'vendorName': vendorName,
    'categoryName': categoryName,
    'bookingDate': bookingDate,
    'timeSlot': timeSlot,
    'venueAddress': venueAddress,
    'status': status,
    'totalAmount': totalAmount,
    'paymentStatus': paymentStatus,
    'paymentTransactionId': paymentTransactionId,
    'selectedVarieties': selectedVarieties,
    'totalDurationHours': totalDurationHours,
  };
}

class ChatMessageModel {
  final int id;
  final int senderId;
  final String senderName;
  final String messageText;
  final String timestamp;
  final bool isMe;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.messageText,
    required this.timestamp,
    required this.isMe,
  });
}
