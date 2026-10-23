import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wedding_models.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  String baseUrl = 'https://sadisetu.onrender.com/api';
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

  // Seeded Verified Vendors with dynamic packages & varieties
  List<VendorModel> vendors = [
    VendorModel(
      id: 1,
      businessName: 'LensCraft Royal Wedding & Drone Cinematography',
      categoryName: 'Camera & Photography',
      bio: 'Award-winning celebrity wedding photography studio with DGCA-certified drone pilots, Sony Alpha full-frame cinema cameras, and Bollywood edit suites.',
      city: 'Delhi NCR',
      address: 'Suite 402, Ring Road Plaza, South Extension Part II, New Delhi',
      rating: 4.9,
      reviewCount: 38,
      startingPrice: 35000.0,
      isOnline: true,
      kycStatus: 'VERIFIED',
      coverImageUrl: 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=800',
      packages: [
        ServicePackageModel(
          id: 101,
          title: 'Royal 4K Cinematic & Drone Film Package',
          description: 'Comprehensive wedding coverage: 2 Candid Photographers + 2 Cinematographers with licensed 4K Drone, 3-min highlight teaser, and 45-min documentary film.',
          price: 45000.0,
          discountedPrice: 40000.0,
          features: [
            'Licensed 4K Drone Aerial Coverage (DGCA Pilot)',
            '2 Candid Photographers + 2 Cinematographers',
            'Full Raw 1800+ Photos in Cloud Gallery',
            '3-min Bollywood Teaser + 45-min Cinematic Film',
            'Same-day 10 Edited Photos for Instagram/WhatsApp'
          ],
          durationHours: 10,
        ),
        ServicePackageModel(
          id: 102,
          title: 'Classic Candid & Ritual Coverage',
          description: 'Perfect for intimate weddings: 1 Candid Specialist + 1 Traditional Videographer covering Haldi, Varmala, and Pheras.',
          price: 28000.0,
          discountedPrice: 25000.0,
          features: [
            '1 Candid Photographer + 1 Traditional Videographer',
            '150 High-Res Master Retouched Portraits',
            'Full Ceremony HD Video Recording',
            'Handcrafted Premium Leatherette Album (40 Pages)'
          ],
          durationHours: 8,
        ),
        ServicePackageModel(
          id: 103,
          title: 'Pre-Wedding Cinematic Reel & Drone Shoot',
          description: 'Full 1-day outdoor couple photoshoot at heritage palace or resort with drone aerials and 3 teaser reels.',
          price: 20000.0,
          discountedPrice: 18000.0,
          features: [
            '1 Candid Photographer + 1 Drone Cinematographer',
            '50 Retouched Couple Portraits',
            '3 High-Energy Reels (9:16 vertical 4K)',
            '2 Outfit Changes at Location'
          ],
          durationHours: 6,
        ),
      ],
    ),
    VendorModel(
      id: 2,
      businessName: 'Royal Heritage Vintage Cars & Chauffeurs',
      categoryName: 'Luxury Cars',
      bio: 'Curated royal fleet of vintage Rolls Royce, open-top convertibles, Mercedes S-Class, and Audi A6 with uniformed chauffeurs for royal groom entries.',
      city: 'Delhi NCR',
      address: 'Plot 12, Aerocity Hospitality District, New Delhi',
      rating: 4.8,
      reviewCount: 29,
      startingPrice: 20000.0,
      isOnline: true,
      kycStatus: 'VERIFIED',
      coverImageUrl: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800',
      packages: [
        ServicePackageModel(
          id: 201,
          title: 'Vintage Rolls Royce Royale & White Horse Entry',
          description: 'Classic open-cab vintage royal car decorated with fresh orchid garlands, suited chauffeur, and convoy coordinator.',
          price: 28000.0,
          discountedPrice: 25000.0,
          features: [
            'Decorated Vintage Royal Car for 6 Hours',
            'Uniformed Professional Chauffeur',
            'Fuel & Chauffeur Batta Included',
            'Security Convoy Pilot Coordination'
          ],
          durationHours: 6,
        ),
        ServicePackageModel(
          id: 202,
          title: 'Mercedes-Benz S-Class Luxury Doli Edition',
          description: 'Ultra-luxurious Mercedes S-Class sedan with panoramic sunroof, ambient lighting, and satin ribbon decor.',
          price: 22000.0,
          discountedPrice: 19000.0,
          features: [
            'Mercedes-Benz S-Class Sedan for 8 Hours',
            'Fresh Flower Bonnet Garland Decor',
            'Trained Chauffeur with White Gloves',
            'City-wide Travel with Zero Extra Km charge up to 80km'
          ],
          durationHours: 8,
        ),
      ],
    ),
    VendorModel(
      id: 3,
      businessName: 'BassDrop Concert Sound, Pyro & LED Productions',
      categoryName: 'DJ & Sound Systems',
      bio: 'Concert-grade sound systems, moving head beams, stage P3 LED walls, cold sparkular pyro fountains, and celebrity Bollywood DJs.',
      city: 'Delhi NCR',
      address: 'Sector 29, City Centre, Gurugram, Haryana',
      rating: 4.9,
      reviewCount: 44,
      startingPrice: 35000.0,
      isOnline: true,
      kycStatus: 'VERIFIED',
      coverImageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
      packages: [
        ServicePackageModel(
          id: 301,
          title: 'Concert JBL Line-Array Sound & 3D Truss Stage',
          description: '12-box JBL VTX line array setup with dual 18-inch subwoofers, 8 Sharpy moving heads, dual CO2 jets, and Bollywood DJ.',
          price: 45000.0,
          discountedPrice: 38000.0,
          features: [
            'Concert JBL Line-Array Sound + 4 Heavy Bass Subs',
            '8 Sharpy Moving Heads & 12 LED Par Cans',
            'Bollywood & Punjabi Club DJ + Live Emcee',
            '4 Cold Pyro Sparkular Jets for Entry'
          ],
          durationHours: 7,
        ),
        ServicePackageModel(
          id: 302,
          title: 'Sangeet & Cocktail Night DJ Setup',
          description: 'High-energy sound setup tailored for banquet halls and farmhouse sangeet parties with laser beams and smoke fogger.',
          price: 28000.0,
          discountedPrice: 24000.0,
          features: [
            'High-Wattage Sound System with Subwoofers',
            'Multi-beam Laser Lighting & Low-fog Dry Ice Machine',
            'Live Audio Engineer & Sound Tech on-site'
          ],
          durationHours: 5,
        ),
      ],
    ),
  ];

  // Seeded Customer Bookings demonstrating varieties (e.g. Drone Camera) & dynamic time/price calculation
  List<BookingModel> customerBookings = [
    BookingModel(
      id: 1,
      bookingNumber: 'SS-849201',
      customerName: 'Rahul Sharma',
      vendorName: 'LensCraft Royal Wedding & Drone Cinematography',
      categoryName: 'Camera & Photography',
      bookingDate: '2026-11-15',
      timeSlot: 'Evening & Sangeet (5:00 PM - 1:00 AM) (14 hrs total)',
      venueAddress: 'The Grand Palace Resort, GT Karnal Road, Delhi NCR',
      status: 'ACCEPTED',
      totalAmount: 50000.0,
      paymentStatus: 'ESCROW_HELD',
      selectedVarieties: [
        '4K Drone Camera Aerial Coverage (+4 hrs)',
        '360° Rotating Video Spinner Booth (+4 hrs)',
      ],
      totalDurationHours: 14,
    ),
  ];

  List<ServiceVarietyOption> getVarietiesForCategory(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('camera') || lower.contains('photo')) {
      return [
        const ServiceVarietyOption(
          id: 'drone_4k',
          name: '4K Drone Camera Aerial Coverage',
          description: 'DJI Mavic 3 Pro Cine with licensed DGCA pilot for cinematic aerial shots of grand Baraat entry, Varmala & venue.',
          price: 10000.0,
          durationHours: 4,
          categorySlug: 'camera-photography',
          badge: '🔥 Most Popular',
          icon: 'drone',
        ),
        const ServiceVarietyOption(
          id: 'candid_portrait',
          name: 'Candid & Portrait Photographer',
          description: 'Dedicated candid specialist with Sony A7IV / 85mm prime lens capturing raw laughter, tears & ritual emotions.',
          price: 12000.0,
          durationHours: 6,
          categorySlug: 'camera-photography',
          badge: '⭐ Recommended',
          icon: 'candid',
        ),
        const ServiceVarietyOption(
          id: 'cinematic_teaser',
          name: 'Cinematic 4K Highlight Teaser & Film',
          description: 'Bollywood-style 3-minute teaser trailer + 45-minute 4K documentary wedding film with color grading.',
          price: 14000.0,
          durationHours: 8,
          categorySlug: 'camera-photography',
          badge: 'Bollywood Cut',
          icon: 'film',
        ),
        const ServiceVarietyOption(
          id: 'jimmy_jib_crane',
          name: 'Jimmy Jib / Hydraulic Crane Camera',
          description: '30-foot hydraulic crane for sweeping overhead stage, garland ceremony and grand crowd panoramic views.',
          price: 15000.0,
          durationHours: 6,
          categorySlug: 'camera-photography',
          badge: 'Grand Setup',
          icon: 'crane',
        ),
        const ServiceVarietyOption(
          id: 'spinner_360',
          name: '360° Rotating Video Spinner Booth',
          description: 'Rotating slow-motion 360 platform with ring light, custom overlay & instant WhatsApp / QR sharing for guests.',
          price: 9000.0,
          durationHours: 4,
          categorySlug: 'camera-photography',
          badge: 'Guest Favorite',
          icon: 'rotate',
        ),
        const ServiceVarietyOption(
          id: 'led_live_broadcast',
          name: 'Live LED Wall Wireless Broadcast',
          description: 'Zero-latency wireless HDMI streaming of live rituals and stage ceremony directly onto venue LED screens.',
          price: 11000.0,
          durationHours: 5,
          categorySlug: 'camera-photography',
          badge: 'Live Screen',
          icon: 'tv',
        ),
        const ServiceVarietyOption(
          id: 'pre_wedding_shoot',
          name: 'Pre-Wedding Destination Shoot Setup',
          description: 'Full 1-day outdoor couple photoshoot with drone, 50 edited portraits and teaser reel.',
          price: 16000.0,
          durationHours: 6,
          categorySlug: 'camera-photography',
          badge: 'Pre-Event',
          icon: 'heart',
        ),
        const ServiceVarietyOption(
          id: 'instant_photo_print',
          name: 'Instant Magnetic Photo Printing Kiosk',
          description: 'Unlimited instant 4x6 high-gloss magnetic photo souvenir prints on the spot for guests to take home.',
          price: 6000.0,
          durationHours: 4,
          categorySlug: 'camera-photography',
          badge: 'Souvenir Gift',
          icon: 'print',
        ),
      ];
    } else if (lower.contains('car')) {
      return [
        const ServiceVarietyOption(
          id: 'floral_bonnet',
          name: 'Fresh Orchid & Exotic Rose Bonnet Decor',
          description: 'Luxury fresh flower garland across bonnet, doors & rear bumper with ribbon accents.',
          price: 3500.0,
          durationHours: 2,
          categorySlug: 'luxury-cars',
          badge: 'Fresh Decor',
          icon: 'flower',
        ),
        const ServiceVarietyOption(
          id: 'vintage_convertible',
          name: 'Vintage Open-Top Convertible Upgrade',
          description: 'Upgrade groom entry to an open-top vintage classic for royal photo opportunities.',
          price: 12000.0,
          durationHours: 4,
          categorySlug: 'luxury-cars',
          badge: 'Royal Upgrade',
          icon: 'car',
        ),
        const ServiceVarietyOption(
          id: 'security_pilot',
          name: 'Uniformed Security Chauffeur & Pilot Escort',
          description: 'Trained security chauffeur with convoy coordination for safe Baraat transit.',
          price: 5000.0,
          durationHours: 4,
          categorySlug: 'luxury-cars',
          badge: 'VIP Escort',
          icon: 'shield',
        ),
      ];
    } else if (lower.contains('dj') || lower.contains('sound')) {
      return [
        const ServiceVarietyOption(
          id: 'cold_pyro',
          name: 'Cold Pyro Firework Jets & CO2 Cannons',
          description: 'Safe indoor non-hazardous sparkular fountains (4 jets) + dual CO2 blast guns for entry & drop.',
          price: 8000.0,
          durationHours: 3,
          categorySlug: 'dj-sound-systems',
          badge: 'Grand Entry',
          icon: 'spark',
        ),
        const ServiceVarietyOption(
          id: 'stage_led_wall',
          name: 'P3 Ultra-HD Indoor Stage LED Wall (16x10 ft)',
          description: 'High-brightness video backdrop displaying couple visuals, music sync animations and DJ visuals.',
          price: 15000.0,
          durationHours: 5,
          categorySlug: 'dj-sound-systems',
          badge: 'Concert Look',
          icon: 'tv',
        ),
        const ServiceVarietyOption(
          id: 'punjabi_dhol_duo',
          name: 'Live Punjabi Dhol Duo Performance',
          description: 'Two live traditional Punjabi dhol players playing in sync with DJ EDM and Bhangra beats.',
          price: 7000.0,
          durationHours: 3,
          categorySlug: 'dj-sound-systems',
          badge: 'High Energy',
          icon: 'drum',
        ),
      ];
    } else {
      return [
        const ServiceVarietyOption(
          id: 'vip_express_setup',
          name: 'VIP Priority Setup & Extra Crew',
          description: 'Dedicated advance setup team arriving 3 hours earlier for flawless execution.',
          price: 5000.0,
          durationHours: 3,
          categorySlug: 'general',
          badge: 'Priority',
          icon: 'star',
        ),
        const ServiceVarietyOption(
          id: 'extended_ceremony_hours',
          name: 'Extended Ceremony Late Night Shift (+4 Hrs)',
          description: 'Keep the team on-site till 4:00 AM for pheras and late-night vidai ceremonies.',
          price: 8000.0,
          durationHours: 4,
          categorySlug: 'general',
          badge: 'Night Shift',
          icon: 'clock',
        ),
      ];
    }
  }

  List<ChatMessageModel> chatMessages = [
    ChatMessageModel(id: 1, senderId: 4, senderName: 'LensCraft Studios', messageText: 'Namaste Rahul ji! We have confirmed your wedding date for Nov 4th. Would you like a drone trial before the sangeet?', timestamp: '10:30 AM', isMe: false),
    ChatMessageModel(id: 2, senderId: 2, senderName: 'Rahul Sharma', messageText: 'Yes please! We would love 4K aerial shots of the grand entrance and the Varmala stage.', timestamp: '10:34 AM', isMe: true),
    ChatMessageModel(id: 3, senderId: 4, senderName: 'LensCraft Studios', messageText: 'Noted! Our senior cinematographer will coordinate the drone setup at 4 PM.', timestamp: '10:36 AM', isMe: false),
  ];

  static final List<String> _candidateHosts = [
    'https://sadisetu.onrender.com/api',
    'http://localhost:8080/api',
    'http://127.0.0.1:8080/api',
    'http://192.168.1.6:8080/api',
    'http://192.168.1.20:8080/api',
    'http://10.0.2.2:8080/api',
  ];

  // Send Live SMS OTP
  Future<Map<String, dynamic>> sendOtp(String phone, {String? role}) async {
    List<String> hostsToTry = [baseUrl, ..._candidateHosts.where((h) => h != baseUrl)];

    for (final host in hostsToTry) {
      try {
        final res = await http.post(
          Uri.parse('$host/auth/send-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone': phone, 'role': role}),
        ).timeout(const Duration(milliseconds: 4000));

        final body = jsonDecode(res.body);
        baseUrl = host; // lock on responding host!
        if (res.statusCode == 200) {
          final data = body['data'] as Map<String, dynamic>? ?? {};
          return {
            'success': true,
            'message': body['message'] ?? 'OTP dispatched to your mobile number',
            'smsDelivered': data['smsDelivered'] == true || data['smsDelivered'] == 'true',
          };
        } else {
          return {
            'success': false,
            'message': body['message'] ?? 'Failed to send OTP. Server error ${res.statusCode}',
            'smsDelivered': false,
          };
        }
      } catch (_) {
        // try next candidate host
      }
    }

    return {
      'success': false,
      'message': 'Backend server unreachable. Please make sure backend is running.',
      'smsDelivered': false,
    };
  }

  // Auth & OTP - Strictly validates against backend
  Future<Map<String, dynamic>> loginOrVerify(String phone, String otp, String role) async {
    List<String> hostsToTry = [baseUrl, ..._candidateHosts.where((h) => h != baseUrl)];

    for (final host in hostsToTry) {
      try {
        final res = await http.post(
          Uri.parse('$host/auth/otp-verify'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone': phone, 'otp': otp.trim(), 'role': role}),
        ).timeout(const Duration(seconds: 8));

        final body = jsonDecode(res.body);
        baseUrl = host;
        if (res.statusCode == 200) {
          final data = body['data'];
          authToken = data['token'];
          currentUser = UserModel(
            id: data['id'] ?? (role == 'VENDOR' ? 4 : 2),
            fullName: data['fullName'] ?? (role == 'VENDOR' ? 'Vendor +91 $phone' : 'Customer +91 $phone'),
            phone: phone,
            role: role == 'VENDOR' ? 'ROLE_VENDOR' : 'ROLE_CUSTOMER',
          );
          await saveSession();
          return {'success': true, 'message': body['message'] ?? 'OTP verified successfully'};
        } else {
          return {
            'success': false,
            'message': body['message'] ?? 'Invalid OTP or account mismatch',
          };
        }
      } catch (_) {}
    }

    return {
      'success': false,
      'message': 'Backend server unreachable. Please ensure backend is running.',
    };
  }

  // Persistent Session Management
  Future<void> initSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('saved_user');
      final tokenStr = prefs.getString('saved_token');
      final bookingsStr = prefs.getString('saved_bookings');

      if (userStr != null && userStr.isNotEmpty) {
        currentUser = UserModel.fromJson(jsonDecode(userStr));
      }
      if (tokenStr != null && tokenStr.isNotEmpty) {
        authToken = tokenStr;
      }
      if (bookingsStr != null && bookingsStr.isNotEmpty) {
        final List list = jsonDecode(bookingsStr);
        final restored = list.map((item) => BookingModel.fromJson(item)).toList();
        if (restored.isNotEmpty) {
          customerBookings = restored;
        }
      }
    } catch (_) {}
  }

  Future<void> saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (currentUser != null) {
        await prefs.setString('saved_user', jsonEncode(currentUser!.toJson()));
      }
      if (authToken != null) {
        await prefs.setString('saved_token', authToken!);
      }
    } catch (_) {}
  }

  Future<void> saveBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = customerBookings.map((b) => b.toJson()).toList();
      await prefs.setString('saved_bookings', jsonEncode(list));
    } catch (_) {}
  }

  Future<void> logout() async {
    currentUser = null;
    authToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_user');
      await prefs.remove('saved_token');
    } catch (_) {}
  }

  bool get isCustomerLoggedIn => currentUser != null && currentUser!.role == 'ROLE_CUSTOMER';
  bool get isVendorLoggedIn => currentUser != null && currentUser!.role == 'ROLE_VENDOR';

  // Register Customer
  Future<Map<String, dynamic>> registerCustomer({
    required String fullName,
    required String phone,
    required String city,
    String? email,
    String? password,
  }) async {
    List<String> hostsToTry = [baseUrl, ..._candidateHosts.where((h) => h != baseUrl)];

    for (final host in hostsToTry) {
      try {
        final res = await http.post(
          Uri.parse('$host/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'fullName': fullName.trim(),
            'phone': phone.trim(),
            'email': email != null && email.trim().isNotEmpty ? email.trim() : '${phone.trim()}@shadisetu.user',
            'password': password ?? 'Customer@123',
            'role': 'ROLE_CUSTOMER',
            'city': city,
          }),
        ).timeout(const Duration(seconds: 4));

        final body = jsonDecode(res.body);
        baseUrl = host;
        if (res.statusCode == 200) {
          final data = body['data'];
          authToken = data['token'];
          currentUser = UserModel(
            id: data['id'] ?? (DateTime.now().millisecondsSinceEpoch % 10000),
            fullName: fullName.trim(),
            phone: phone.trim(),
            email: email,
            role: 'ROLE_CUSTOMER',
          );
          await saveSession();
          return {'success': true, 'message': 'Customer registered successfully!'};
        } else {
          return {'success': false, 'message': body['message'] ?? 'Customer registration failed.'};
        }
      } catch (_) {}
    }

    return {'success': false, 'message': 'Backend server unreachable. Please make sure backend is running.'};
  }

  // Register Vendor Partner
  Future<Map<String, dynamic>> registerVendor({
    required String businessName,
    required String ownerName,
    required String phone,
    required String categoryName,
    required String city,
    required String address,
    required double startingPrice,
    String? bio,
    String? password,
  }) async {
    final effectiveBio = bio != null && bio.trim().isNotEmpty
        ? bio.trim()
        : 'Specialist $categoryName providing verified service and full Shaadi Setu escrow guarantee.';

    final isCamera = categoryName.toLowerCase().contains('camera') || categoryName.toLowerCase().contains('photo');
    final List<ServicePackageModel> starterPackages = isCamera
        ? [
            ServicePackageModel(
              id: DateTime.now().millisecondsSinceEpoch % 100000,
              title: '$businessName Royal Cinematic & 4K Drone Package',
              description: '2 Candid Photographers + 2 Cinematographers + 4K Drone Coverage + 1 Teaser + Full Wedding Highlights.',
              price: startingPrice > 0 ? startingPrice : 45000.0,
              discountedPrice: (startingPrice > 5000 ? startingPrice - 5000 : startingPrice),
              features: ['4K Drone Aerial Coverage', '2 Candid + 2 Traditional Shooters', 'Teaser Reel + 45-min Film', 'All Raw 1500+ Photos Delivered'],
              durationHours: 12,
            ),
            ServicePackageModel(
              id: (DateTime.now().millisecondsSinceEpoch % 100000) + 1,
              title: '$businessName Single Day Candid Classic',
              description: '1 Candid Photographer + 1 Traditional Videographer for Wedding & Reception rituals.',
              price: (startingPrice > 10000 ? startingPrice * 0.6 : 25000.0).roundToDouble(),
              discountedPrice: null,
              features: ['Full ceremony video coverage', '100 edited portraits', 'HD cinematic highlights'],
              durationHours: 8,
            ),
          ]
        : [
            ServicePackageModel(
              id: DateTime.now().millisecondsSinceEpoch % 100000,
              title: '$businessName Signature Wedding Package',
              description: 'End-to-end premium service delivery with dedicated on-site coordinator and satisfaction guarantee.',
              price: startingPrice > 0 ? startingPrice : 25000.0,
              discountedPrice: (startingPrice > 3000 ? startingPrice - 3000 : startingPrice),
              features: ['Dedicated On-site Manager', 'VIP Guest Experience', 'Safe Escrow Protection'],
              durationHours: 8,
            ),
          ];

    final newVendor = VendorModel(
      id: vendors.length + 1,
      businessName: businessName.trim(),
      categoryName: categoryName,
      bio: effectiveBio,
      city: city,
      address: address.trim(),
      rating: 5.0,
      reviewCount: 1,
      startingPrice: startingPrice,
      isOnline: true,
      kycStatus: 'VERIFIED',
      coverImageUrl: isCamera
          ? 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=800'
          : 'https://images.unsplash.com/photo-1519741497674-611481863552?w=800',
      packages: starterPackages,
    );

    List<String> hostsToTry = [baseUrl, ..._candidateHosts.where((h) => h != baseUrl)];

    for (final host in hostsToTry) {
      try {
        final res = await http.post(
          Uri.parse('$host/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'fullName': ownerName.trim(),
            'businessName': businessName.trim(),
            'categoryName': categoryName,
            'phone': phone.trim(),
            'email': '${phone.trim()}@shadisetu.vendor',
            'password': password ?? 'Vendor@123',
            'role': 'ROLE_VENDOR',
            'city': city,
            'address': address.trim(),
            'bio': effectiveBio,
            'startingPrice': startingPrice,
          }),
        ).timeout(const Duration(seconds: 4));

        final body = jsonDecode(res.body);
        baseUrl = host;
        if (res.statusCode == 200) {
          final data = body['data'];
          authToken = data['token'];
          currentUser = UserModel(
            id: data['id'] ?? (DateTime.now().millisecondsSinceEpoch % 10000),
            fullName: businessName.trim(),
            phone: phone.trim(),
            role: 'ROLE_VENDOR',
          );
          vendors.insert(0, newVendor);
          await saveSession();
          return {'success': true, 'message': 'Vendor partner registered successfully!'};
        } else {
          return {'success': false, 'message': body['message'] ?? 'Vendor registration failed.'};
        }
      } catch (_) {}
    }

    return {'success': false, 'message': 'Backend server unreachable. Please make sure backend is running.'};
  }

  // Create Booking
  Future<BookingModel> createBooking({
    required int vendorId,
    required int packageId,
    required String bookingDate,
    required String timeSlot,
    required String address,
    required double totalAmount,
    List<String> selectedVarieties = const [],
    int totalDurationHours = 8,
    String? promoCode,
  }) async {
    // If backend is active and reachable, attempt remote sync
    if (authToken != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/customer/bookings'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode({
            'vendorId': vendorId,
            'packageId': packageId,
            'bookingDate': bookingDate,
            'timeSlot': timeSlot,
            'venueAddress': address,
            'promoCode': promoCode,
            'selectedVarieties': selectedVarieties.join('; '),
            'durationHours': totalDurationHours,
            'customTotalAmount': totalAmount,
          }),
        ).timeout(const Duration(seconds: 4));
      } catch (_) {
        // Fallback safely to offline-first state
      }
    }

    final vendorMatch = vendors.where((v) => v.id == vendorId).toList();
    final vName = vendorMatch.isNotEmpty ? vendorMatch.first.businessName : 'Wedding Vendor';
    final cName = vendorMatch.isNotEmpty ? vendorMatch.first.categoryName : 'Wedding Service';

    final newBooking = BookingModel(
      id: customerBookings.length + 1,
      bookingNumber: 'SS-${DateTime.now().millisecondsSinceEpoch % 1000000}',
      customerName: currentUser?.fullName ?? 'Rahul Sharma',
      vendorName: vName,
      categoryName: cName,
      bookingDate: bookingDate,
      timeSlot: timeSlot,
      venueAddress: address,
      status: 'PENDING',
      totalAmount: totalAmount,
      paymentStatus: 'ESCROW_HELD',
      selectedVarieties: selectedVarieties,
      totalDurationHours: totalDurationHours,
    );
    customerBookings.insert(0, newBooking);
    await saveBookings();
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
