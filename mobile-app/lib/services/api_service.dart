import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wedding_models.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  String baseUrl = 'http://10.0.2.2:8080/api'; // Android emulator localhost
  String? authToken;
  UserModel? currentUser;

  void setBaseUrl(String url) {
    baseUrl = url;
  }

  // Pre-loaded realistic initial data
  List<CategoryModel> categories = [
    CategoryModel(id: 1, name: 'Camera & Photography', slug: 'camera-photography', icon: 'camera', description: 'Candid photographers, cinematic 4K drone films and luxury photo albums.', startingPrice: 25000),
    CategoryModel(id: 2, name: 'Luxury Cars', slug: 'luxury-cars', icon: 'car', description: 'Vintage Rolls Royce, Audi, Mercedes, BMW for groom Baraat and Doli.', startingPrice: 15000),
    CategoryModel(id: 3, name: 'DJ & Sound Systems', slug: 'dj-sound-systems', icon: 'music', description: 'JBL Line Arrays, moving heads, cold pyros, LED walls, Bollywood DJs.', startingPrice: 30000),
    CategoryModel(id: 4, name: 'Decorators & Mandap', slug: 'decorators-mandap', icon: 'flower', description: 'Royal floral mandap, grand entry gates, fairytale lighting.', startingPrice: 50000),
    CategoryModel(id: 5, name: 'Baaja & Brass Band', slug: 'baaja-brass-band', icon: 'bell', description: 'Traditional royal brass band, Punjabi dhol, illuminated umbrellas.', startingPrice: 18000),
    CategoryModel(id: 6, name: 'Royal Catering', slug: 'royal-catering', icon: 'coffee', description: 'Multi-cuisine live counters, dessert lounges, authentic royal feast.', startingPrice: 650),
  ];

  List<VendorModel> vendors = [
    VendorModel(
      id: 1,
      businessName: 'LensCraft Cinematic Weddings',
      categoryName: 'Camera & Photography',
      bio: 'Award-winning wedding photography collective capturing timeless emotions with 4K cinematography & drone.',
      city: 'Delhi NCR',
      address: '42 Connaught Place, New Delhi',
      rating: 4.9,
      reviewCount: 48,
      startingPrice: 85000,
      isOnline: true,
      kycStatus: 'VERIFIED',
      coverImageUrl: 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=800',
      packages: [
        ServicePackageModel(
          id: 1,
          title: 'Royal Cinematic 2-Day Package',
          description: '2 Candid Photographers + 2 Cinematographers + 4K Drone Coverage + 1 Teaser + 1 Full Length Film + 2 Premium Coffee Table Albums.',
          price: 95000,
          discountedPrice: 85000,
          features: ['2 Traditional + 2 Candid Shooters', '4K Drone Aerial Coverage', 'Teaser + 45-min Film', '2 Luxury Matt Photobooks'],
          durationHours: 16,
        ),
        ServicePackageModel(
          id: 2,
          title: 'Single Day Candid Classic',
          description: '1 Candid Photographer + 1 Traditional Videographer for Wedding & Reception ceremony.',
          price: 45000,
          discountedPrice: 39999,
          features: ['All raw 1500+ photos delivered', '100 edited portraits', 'HD cinematic highlights'],
          durationHours: 8,
        ),
      ],
    ),
    VendorModel(
      id: 2,
      businessName: 'Rajputana Luxury & Vintage Cars',
      categoryName: 'Luxury Cars',
      bio: 'Chauffeured luxury cars for Baraat entries, vintage convertibles, Audi A6, Jaguar XF, and Mercedes E-Class.',
      city: 'Jaipur',
      address: 'Tonk Road, Jaipur',
      rating: 4.8,
      reviewCount: 32,
      startingPrice: 19999,
      isOnline: true,
      kycStatus: 'VERIFIED',
      coverImageUrl: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800',
      packages: [
        ServicePackageModel(
          id: 3,
          title: 'Audi A6 / BMW 5 Series Doli Ride',
          description: 'White luxury sedan with fresh floral decoration, uniform driver, fuel included for 80 km.',
          price: 22000,
          discountedPrice: 19999,
          features: ['White Audi / BMW', 'Fresh Orchid & Rose Floral Decor', 'Uniformed Chauffeur', '80km / 8 Hours inclusive'],
          durationHours: 8,
        ),
      ],
    ),
    VendorModel(
      id: 3,
      businessName: 'DJ Aryan & Bass Mafia Productions',
      categoryName: 'DJ & Sound Systems',
      bio: 'High-octane sound setups, JBL VRX Line Arrays, CO2 Jets, Cold Pyros, and LED Trusses for Sangeet & Reception.',
      city: 'Lucknow',
      address: 'Gomti Nagar, Lucknow',
      rating: 4.7,
      reviewCount: 29,
      startingPrice: 40000,
      isOnline: true,
      kycStatus: 'VERIFIED',
      coverImageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
      packages: [
        ServicePackageModel(
          id: 4,
          title: 'Mega Sangeet Bash DJ Setup',
          description: 'Dual JBL Line Arrays + 4 Subwoofers + Sharpys Moving Heads + Cold Pyro Sparkulars + Live DJ.',
          price: 45000,
          discountedPrice: 40000,
          features: ['JBL Line Array + 4 Bass', 'Sharpy Beam Lights & Smoke Machine', '4 Cold Pyro Firework Jets', 'Bollywood / Punjabi Hit DJ'],
          durationHours: 6,
        ),
      ],
    ),
  ];

  List<BookingModel> customerBookings = [
    BookingModel(
      id: 1,
      bookingNumber: 'SS-2026001',
      customerName: 'Rahul Sharma',
      vendorName: 'LensCraft Cinematic Weddings',
      categoryName: 'Camera & Photography',
      bookingDate: '2026-11-04',
      timeSlot: '10:00 AM - 11:00 PM',
      venueAddress: 'The Grand Palace Resort, GT Karnal Road, Delhi',
      status: 'ACCEPTED',
      totalAmount: 85000,
      paymentStatus: 'ESCROW_HELD',
    ),
    BookingModel(
      id: 2,
      bookingNumber: 'SS-2026002',
      customerName: 'Rahul Sharma',
      vendorName: 'Rajputana Luxury & Vintage Cars',
      categoryName: 'Luxury Cars',
      bookingDate: '2026-11-10',
      timeSlot: '4:00 PM - 12:00 AM',
      venueAddress: 'Rambagh Palace Lawn, Jaipur',
      status: 'PENDING',
      totalAmount: 19999,
      paymentStatus: 'ESCROW_HELD',
    ),
  ];

  List<ChatMessageModel> chatMessages = [
    ChatMessageModel(id: 1, senderId: 4, senderName: 'LensCraft Studios', messageText: 'Namaste Rahul ji! We have confirmed your wedding date for Nov 4th. Would you like a drone trial before the sangeet?', timestamp: '10:30 AM', isMe: false),
    ChatMessageModel(id: 2, senderId: 2, senderName: 'Rahul Sharma', messageText: 'Yes please! We would love 4K aerial shots of the grand entrance and the Varmala stage.', timestamp: '10:34 AM', isMe: true),
    ChatMessageModel(id: 3, senderId: 4, senderName: 'LensCraft Studios', messageText: 'Noted! Our senior cinematographer will coordinate the drone setup at 4 PM.', timestamp: '10:36 AM', isMe: false),
  ];

  // Auth & OTP
  Future<bool> loginOrVerify(String phone, String otp, String role) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/otp-verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp, 'role': role}),
      ).timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        authToken = data['token'];
        currentUser = UserModel(
          id: data['id'] ?? 1,
          fullName: data['fullName'] ?? 'User $phone',
          phone: phone,
          role: role == 'VENDOR' ? 'ROLE_VENDOR' : 'ROLE_CUSTOMER',
        );
        return true;
      }
    } catch (_) {}

    // Fallback simulation
    currentUser = UserModel(
      id: role == 'VENDOR' ? 4 : 2,
      fullName: role == 'VENDOR' ? 'Vikramaditya Studios' : 'Rahul Sharma',
      phone: phone,
      role: role == 'VENDOR' ? 'ROLE_VENDOR' : 'ROLE_CUSTOMER',
    );
    return true;
  }

  void logout() {
    currentUser = null;
    authToken = null;
  }

  bool get isCustomerLoggedIn => currentUser != null && currentUser!.role == 'ROLE_CUSTOMER';
  bool get isVendorLoggedIn => currentUser != null && currentUser!.role == 'ROLE_VENDOR';

  // Create Booking
  Future<BookingModel> createBooking({
    required int vendorId,
    required int packageId,
    required String bookingDate,
    required String timeSlot,
    required String address,
    required double totalAmount,
  }) async {
    final newBooking = BookingModel(
      id: customerBookings.length + 1,
      bookingNumber: 'SS-${DateTime.now().millisecondsSinceEpoch % 1000000}',
      customerName: currentUser?.fullName ?? 'Rahul Sharma',
      vendorName: vendors.firstWhere((v) => v.id == vendorId, orElse: () => vendors.first).businessName,
      categoryName: vendors.firstWhere((v) => v.id == vendorId, orElse: () => vendors.first).categoryName,
      bookingDate: bookingDate,
      timeSlot: timeSlot,
      venueAddress: address,
      status: 'PENDING',
      totalAmount: totalAmount,
      paymentStatus: 'ESCROW_HELD',
    );
    customerBookings.insert(0, newBooking);
    return newBooking;
  }

  // Send message
  void sendChatMessage(String text) {
    chatMessages.add(
      ChatMessageModel(
        id: chatMessages.length + 1,
        senderId: currentUser?.id ?? 2,
        senderName: currentUser?.fullName ?? 'Rahul Sharma',
        messageText: text,
        timestamp: 'Just now',
        isMe: true,
      ),
    );
  }
}
