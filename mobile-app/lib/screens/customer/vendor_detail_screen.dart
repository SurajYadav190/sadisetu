import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/wedding_models.dart';
import 'booking_checkout_screen.dart';

class VendorDetailScreen extends StatelessWidget {
  final VendorModel vendor;
  const VendorDetailScreen({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.85),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.slateDark),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                vendor.coverImageUrl ?? 'https://images.unsplash.com/photo-1519741497674-611481863552',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verification & Rating Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: Color(0xFFB45309)),
                            const SizedBox(width: 4),
                            Text(
                              '${vendor.rating} (${vendor.reviewCount} reviews)',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFB45309)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_rounded, size: 16, color: AppTheme.successGreen),
                            SizedBox(width: 4),
                            Text(
                              'Verified KYC Merchant',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.successGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    vendor.businessName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.slateMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${vendor.address}, ${vendor.city}',
                        style: const TextStyle(fontSize: 13, color: AppTheme.slateMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 10),

                  // About Bio
                  const Text(
                    'About Service Provider',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vendor.bio,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Service Packages Section
                  const Text(
                    'Available Service Packages',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                  ),
                  const SizedBox(height: 12),

                  ...vendor.packages.map((pkg) => _buildPackageCard(context, pkg)),

                  const SizedBox(height: 24),
                  // Escrow Guarantee Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGold,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.weddingGold.withOpacity(0.4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_rounded, color: Color(0xFFB45309), size: 36),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shaadi Setu Escrow Guarantee',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.slateDark),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Your deposit is held securely. Vendor is paid only after event ceremony is completed to your satisfaction.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF78350F), height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, ServicePackageModel pkg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  pkg.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${(pkg.discountedPrice ?? pkg.price).toInt()}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryCrimson),
                  ),
                  if (pkg.discountedPrice != null)
                    Text(
                      '₹${pkg.price.toInt()}',
                      style: const TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                        color: AppTheme.slateMuted,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pkg.description,
            style: const TextStyle(fontSize: 13, color: AppTheme.slateMuted, height: 1.4),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          // Features List
          ...pkg.features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(f, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingCheckoutScreen(
                      vendor: vendor,
                      package: pkg,
                    ),
                  ),
                );
              },
              child: const Text('Book This Package'),
            ),
          ),
        ],
      ),
    );
  }
}
