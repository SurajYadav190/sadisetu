import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'vendor_main_nav.dart';

class VendorOnboardingScreen extends StatefulWidget {
  const VendorOnboardingScreen({super.key});

  @override
  State<VendorOnboardingScreen> createState() => _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState extends State<VendorOnboardingScreen> {
  final _businessNameController = TextEditingController(text: 'Royal Rajputana Events & Dhol');
  final _addressController = TextEditingController(text: 'Tonk Road, Jaipur, Rajasthan');
  final _accountController = TextEditingController(text: '918237461928');
  final _ifscController = TextEditingController(text: 'HDFC0001234');

  String _selectedCategory = 'Camera & Photography';
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Merchant Partner Registration'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Join Shaadi Setu Vendor Network',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
            ),
            const SizedBox(height: 6),
            const Text(
              'Onboard your photography studio, luxury car fleet, sound systems, mandap decor or brass band.',
              style: TextStyle(fontSize: 13.5, color: AppTheme.slateMuted),
            ),
            const SizedBox(height: 24),

            // Category Selection
            const Text('Wedding Service Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                  items: [
                    'Camera & Photography',
                    'Luxury Cars',
                    'DJ & Sound Systems',
                    'Decorators & Mandap',
                    'Baaja & Brass Band',
                    'Royal Catering'
                  ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Business Name
            const Text('Registered Business / Brand Name', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _businessNameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 18),

            // Address
            const Text('Operational Office / Workshop Address', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 18),

            // KYC Upload Section
            const Text('KYC Document (GST Certificate / Trade License)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_rounded, color: AppTheme.primaryCrimson, size: 36),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GST_Registration_Certificate.pdf', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Text('Verified size: 1.8 MB (Ready for Admin review)', style: TextStyle(fontSize: 11, color: AppTheme.successGreen)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Bank Account Details for Payouts
            const Text('Bank Account for Direct Payouts', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _accountController,
                    decoration: InputDecoration(
                      hintText: 'Account Number',
                      filled: true,
                      fillColor: AppTheme.surfaceBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _ifscController,
                    decoration: InputDecoration(
                      hintText: 'IFSC Code',
                      filled: true,
                      fillColor: AppTheme.surfaceBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting
                    ? null
                    : () {
                        setState(() => _submitting = true);
                        Future.delayed(const Duration(milliseconds: 600), () {
                          if (!mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const VendorMainNav()),
                            (route) => false,
                          );
                        });
                      },
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit KYC & Open Merchant Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
