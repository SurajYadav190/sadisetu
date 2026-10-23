import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/wedding_models.dart';
import '../../services/api_service.dart';
import 'booking_checkout_screen.dart';

class VendorDetailScreen extends StatefulWidget {
  final VendorModel vendor;
  const VendorDetailScreen({super.key, required this.vendor});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  late List<ServiceVarietyOption> _availableVarieties;
  final Set<String> _selectedVarietyIds = {};

  @override
  void initState() {
    super.initState();
    _availableVarieties = ApiService.instance.getVarietiesForCategory(widget.vendor.categoryName);

    // Pre-select popular variety (like Drone Camera for Camera & Photography)
    final isCamera = widget.vendor.categoryName.toLowerCase().contains('camera') ||
        widget.vendor.categoryName.toLowerCase().contains('photo');
    if (isCamera && _availableVarieties.isNotEmpty) {
      _selectedVarietyIds.add(_availableVarieties.first.id); // 'drone_4k'
    }
  }

  double get _addedVarietiesPrice {
    double sum = 0.0;
    for (final v in _availableVarieties) {
      if (_selectedVarietyIds.contains(v.id)) {
        sum += v.price;
      }
    }
    return sum;
  }

  int get _addedVarietiesHours {
    int hours = 0;
    for (final v in _availableVarieties) {
      if (_selectedVarietyIds.contains(v.id)) {
        hours += v.durationHours;
      }
    }
    return hours;
  }

  void _navigateToCheckout(ServicePackageModel pkg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingCheckoutScreen(
          vendor: widget.vendor,
          package: pkg,
          initialSelectedVarietyIds: _selectedVarietyIds.toList(),
        ),
      ),
    );
  }

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
              backgroundColor: Colors.white.withValues(alpha: 0.85),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.slateDark),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.vendor.coverImageUrl ?? 'https://images.unsplash.com/photo-1519741497674-611481863552',
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
                              '${widget.vendor.rating} (${widget.vendor.reviewCount} reviews)',
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
                    widget.vendor.businessName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.slateMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.vendor.address}, ${widget.vendor.city}',
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
                    widget.vendor.bio,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Available Varieties Showcase Section (Interactive Selection)
                  _buildVarietiesShowcase(),

                  const SizedBox(height: 28),

                  // Service Packages Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Available Service Packages',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                      ),
                      if (_selectedVarietyIds.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGold,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+${_selectedVarietyIds.length} Varieties chosen',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF78350F)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...widget.vendor.packages.map((pkg) => _buildPackageCard(pkg)),

                  const SizedBox(height: 24),

                  // Escrow Guarantee Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGold,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.weddingGold.withValues(alpha: 0.4)),
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

  Widget _buildPackageCard(ServicePackageModel pkg) {
    final basePrice = pkg.discountedPrice ?? pkg.price;
    final totalEstimated = basePrice + _addedVarietiesPrice;
    final totalHours = pkg.durationHours + _addedVarietiesHours;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                    '₹${basePrice.toInt()}',
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

          const SizedBox(height: 12),

          // Dynamic estimation tag when varieties are chosen
          if (_selectedVarietyIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.weddingGold.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded, size: 15, color: Color(0xFF78350F)),
                      const SizedBox(width: 6),
                      Text(
                        'With ${_selectedVarietyIds.length} Varieties:',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF78350F)),
                      ),
                    ],
                  ),
                  Text(
                    '₹${totalEstimated.toInt()} • $totalHours hrs',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryCrimson),
                  ),
                ],
              ),
            ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: Text(_selectedVarietyIds.isEmpty ? 'Book Package' : 'Book with Selected Varieties (₹${totalEstimated.toInt()})'),
              onPressed: () => _navigateToCheckout(pkg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVarietiesShowcase() {
    if (_availableVarieties.isEmpty) return const SizedBox.shrink();

    final isCamera = widget.vendor.categoryName.toLowerCase().contains('camera') ||
        widget.vendor.categoryName.toLowerCase().contains('photo');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(isCamera ? Icons.videocam_rounded : Icons.extension_rounded, color: AppTheme.primaryCrimson, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isCamera ? 'Camera Varieties & Equipment Add-ons' : 'Available Service Varieties',
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isCamera
                ? 'Tap any variety (e.g. 4K Drone Camera) to select. Price and service hours adjust automatically!'
                : 'Select options and equipment to customize your booking.',
            style: const TextStyle(fontSize: 12, color: AppTheme.slateMuted),
          ),
          const SizedBox(height: 12),

          // Real-time Selected Summary Banner inside the showcase
          if (_selectedVarietyIds.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${_selectedVarietyIds.length} Varieties Active',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF065F46)),
                      ),
                    ],
                  ),
                  Text(
                    '+₹${_addedVarietiesPrice.toInt()} Added  |  +$_addedVarietiesHours hrs',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF065F46)),
                  ),
                ],
              ),
            ),
          ],

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _availableVarieties.map((v) {
                final isSelected = _selectedVarietyIds.contains(v.id);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedVarietyIds.remove(v.id);
                      } else {
                        _selectedVarietyIds.add(v.id);
                      }
                    });
                  },
                  child: Container(
                    width: 220,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFFBEB) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryCrimson : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryCrimson.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (v.badge.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightGold,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  v.badge,
                                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF78350F)),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                              color: isSelected ? AppTheme.primaryCrimson : const Color(0xFF94A3B8),
                              size: 19,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          v.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? AppTheme.primaryCrimson : AppTheme.slateDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          v.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '+₹${v.price.toInt()}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '+${v.durationHours} hrs',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
