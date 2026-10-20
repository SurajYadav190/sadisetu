import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/wedding_models.dart';

class VendorCatalogScreen extends StatefulWidget {
  const VendorCatalogScreen({super.key});

  @override
  State<VendorCatalogScreen> createState() => _VendorCatalogScreenState();
}

class _VendorCatalogScreenState extends State<VendorCatalogScreen> {
  final ApiService _api = ApiService.instance;

  void _showAddPackageModal() {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add New Service Package', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Package Title (e.g. Pre-Wedding Drone Reel)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Package Price (INR)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Features & Deliverables'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty && priceController.text.isNotEmpty) {
                      setState(() {
                        _api.vendors[0].packages.add(
                          ServicePackageModel(
                            id: DateTime.now().millisecondsSinceEpoch,
                            title: titleController.text,
                            description: descController.text,
                            price: double.tryParse(priceController.text) ?? 25000,
                            discountedPrice: null,
                            features: ['Raw files delivered', 'HD editing', 'Live on-site crew'],
                            durationHours: 8,
                          ),
                        );
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Package added to your live catalog!')),
                      );
                    }
                  },
                  child: const Text('Save Package'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final packages = _api.vendors.first.packages;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Service Catalog & Pricing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryCrimson),
            onPressed: _showAddPackageModal,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Live Service Packages', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark)),
              TextButton.icon(
                onPressed: _showAddPackageModal,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Tier'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...packages.map((pkg) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
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
                        Text(
                          '₹${(pkg.discountedPrice ?? pkg.price).toInt()}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryCrimson),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pkg.description,
                      style: const TextStyle(fontSize: 13, color: AppTheme.slateMuted),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: pkg.features
                          .map((f) => Chip(
                                label: Text(f, style: const TextStyle(fontSize: 11)),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: AppTheme.surfaceBg,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
