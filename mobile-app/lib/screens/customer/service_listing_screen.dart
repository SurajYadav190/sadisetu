import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import 'vendor_detail_screen.dart';

class ServiceListingScreen extends StatefulWidget {
  final String? categoryFilter;
  const ServiceListingScreen({super.key, this.categoryFilter});

  @override
  State<ServiceListingScreen> createState() => _ServiceListingScreenState();
}

class _ServiceListingScreenState extends State<ServiceListingScreen> {
  final ApiService _api = ApiService.instance;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _activeSort = 'Recommended';

  @override
  void initState() {
    super.initState();
    if (widget.categoryFilter != null) {
      _selectedCategory = widget.categoryFilter!;
    }
  }

  @override
  Widget build(BuildContext context) {
    var filtered = _api.vendors.where((v) {
      if (_selectedCategory != 'All' && v.categoryName != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !v.businessName.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.categoryFilter ?? 'Browse Vendors',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search vendors or packages...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppTheme.surfaceBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),

          // Filter Chips Horizontal Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                _buildFilterChip('All', _selectedCategory == 'All', () {
                  setState(() => _selectedCategory = 'All');
                }),
                ..._api.categories.map((c) => _buildFilterChip(
                      c.name,
                      _selectedCategory == c.name,
                      () => setState(() => _selectedCategory = c.name),
                    )),
              ],
            ),
          ),
          const Divider(height: 16),

          // Vendors Count & Sorting
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} verified vendors available',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slateMuted),
                ),
                Row(
                  children: [
                    const Icon(Icons.sort_rounded, size: 16, color: AppTheme.primaryCrimson),
                    const SizedBox(width: 4),
                    Text(
                      _activeSort,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryCrimson),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Vendor Cards List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final vendor = filtered[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VendorDetailScreen(vendor: vendor)),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Stack(
                            children: [
                              Image.network(
                                vendor.coverImageUrl ?? 'https://images.unsplash.com/photo-1519741497674-611481863552',
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.verified_rounded, size: 14, color: AppTheme.successGreen),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Verified KYC',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    vendor.categoryName,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryCrimson),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, size: 16, color: Color(0xFFB45309)),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${vendor.rating} (${vendor.reviewCount})',
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                vendor.businessName,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vendor.bio,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, color: AppTheme.slateMuted),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Starting from', style: TextStyle(fontSize: 11, color: AppTheme.slateMuted)),
                                      Text(
                                        '₹${vendor.startingPrice.toInt()}',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => VendorDetailScreen(vendor: vendor)),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                    child: const Text('View Packages'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryCrimson : AppTheme.surfaceBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryCrimson : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.slateDark,
          ),
        ),
      ),
    );
  }
}
