import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import 'service_listing_screen.dart';
import 'vendor_detail_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final ApiService _api = ApiService.instance;
  String _selectedCity = 'Delhi NCR';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.location_on_rounded, color: AppTheme.primaryCrimson, size: 20),
            const SizedBox(width: 6),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCity,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.slateDark, fontSize: 15),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCity = val);
                },
                items: ['Delhi NCR', 'Jaipur', 'Lucknow', 'Mumbai', 'Chandigarh']
                    .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                    .toList(),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new alerts. Your bookings are on schedule!')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ServiceListingScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search_rounded, color: AppTheme.slateMuted),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Search Photographers, Luxury Cars, DJs...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppTheme.slateMuted, fontSize: 13.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Promotional Hero Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 140),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9B1B30), Color(0xFFC42D48)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryCrimson.withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: AppTheme.weddingGold,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'WEDDING SEASON 2026',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.slateDark),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Save 15% on Top Vendors',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Use coupon: SHADI2026 at checkout',
                              style: TextStyle(fontSize: 11.5, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.card_giftcard_rounded, size: 48, color: AppTheme.weddingGold),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Category Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Wedding Categories',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ServiceListingScreen()),
                        );
                      },
                      child: const Text('View All', style: TextStyle(color: AppTheme.primaryCrimson, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Responsive Category Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 3;
                    if (constraints.maxWidth > 650) {
                      crossAxisCount = 6;
                    } else if (constraints.maxWidth > 440) {
                      crossAxisCount = 4;
                    }

                    double childAspectRatio = constraints.maxWidth < 360 ? 0.80 : 0.88;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _api.categories.length,
                      itemBuilder: (context, index) {
                        final cat = _api.categories[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceListingScreen(categoryFilter: cat.name),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.lightGold,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    cat.icon == 'camera'
                                        ? Icons.camera_alt_rounded
                                        : cat.icon == 'car'
                                            ? Icons.directions_car_rounded
                                            : cat.icon == 'music'
                                                ? Icons.headphones_rounded
                                                : cat.icon == 'flower'
                                                    ? Icons.yard_rounded
                                                    : cat.icon == 'bell'
                                                        ? Icons.notifications_active_rounded
                                                        : Icons.restaurant_rounded,
                                    color: AppTheme.primaryCrimson,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cat.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.slateDark,
                                    height: 1.15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Top-Rated Verified Vendors Near You
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Top-Rated Vendors',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ServiceListingScreen()),
                        );
                      },
                      child: const Text('See All', style: TextStyle(color: AppTheme.primaryCrimson, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _api.vendors.length,
                  itemBuilder: (context, index) {
                    final vendor = _api.vendors[index];
                    return Container(
                      width: 240,
                      margin: const EdgeInsets.only(right: 14),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VendorDetailScreen(vendor: vendor),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.network(
                                  vendor.coverImageUrl ?? 'https://images.unsplash.com/photo-1519741497674-611481863552',
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.lightGold,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFB45309)),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${vendor.rating}',
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          vendor.city,
                                          style: const TextStyle(fontSize: 11, color: AppTheme.slateMuted),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      vendor.businessName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'From ₹${vendor.startingPrice.toInt()}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryCrimson),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
