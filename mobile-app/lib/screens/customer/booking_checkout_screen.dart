import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/wedding_models.dart';
import '../../services/api_service.dart';
import 'booking_success_screen.dart';

class BookingCheckoutScreen extends StatefulWidget {
  final VendorModel vendor;
  final ServicePackageModel package;

  const BookingCheckoutScreen({
    super.key,
    required this.vendor,
    required this.package,
  });

  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 14));
  String _selectedSlot = 'Morning (10:00 AM - 4:00 PM)';
  final _addressController = TextEditingController(text: 'The Grand Palace Resort, GT Karnal Road, Delhi');
  final _couponController = TextEditingController(text: 'SHADI2026');

  bool _couponApplied = true;
  double _discountAmount = 5000.0;
  bool _loading = false;

  final List<String> _slots = [
    'Morning (10:00 AM - 4:00 PM)',
    'Evening & Sangeet (5:00 PM - 12:00 AM)',
    'Full Day & Night (24 Hours)',
  ];

  @override
  Widget build(BuildContext context) {
    final basePrice = widget.package.discountedPrice ?? widget.package.price;
    final finalPrice = basePrice - (_couponApplied ? _discountAmount : 0.0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Event Date & Checkout'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Selected Package Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.vendor.businessName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryCrimson),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.package.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${basePrice.toInt()}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.slateDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 1. Interactive Date Picker
          const Text(
            '1. Select Wedding / Event Date',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().add(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryCrimson, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.lightGold,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryCrimson),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Chosen Date (Real-time slot available)', style: TextStyle(fontSize: 11, color: Color(0xFF78350F))),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text('Change', style: TextStyle(color: AppTheme.primaryCrimson, fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Time Slot Picker
          const Text(
            '2. Select Event Shift / Time Slot',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 10),
          ..._slots.map((s) => RadioListTile<String>(
                value: s,
                groupValue: _selectedSlot,
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primaryCrimson,
                title: Text(s, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSlot = val);
                },
              )),
          const SizedBox(height: 16),

          // 3. Venue Address
          const Text(
            '3. Wedding Venue Address',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.surfaceBg,
              hintText: 'Enter complete venue / hall / farmhouse address...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          // 4. Promo Coupon
          const Text(
            '4. Apply Promo Voucher',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surfaceBg,
                    hintText: 'Enter coupon code',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _couponApplied = true;
                    _discountAmount = 5000.0;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Promo Code SHADI2026 applied! ₹5,000 saved.')),
                  );
                },
                child: const Text('Apply'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Cost Breakdown Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Summary (Held in Safe Escrow)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Base Package Price', style: TextStyle(color: AppTheme.slateMuted)),
                    Text('₹${basePrice.toInt()}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                if (_couponApplied) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Seasonal Discount (SHADI2026)', style: TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.w600)),
                      Text('-₹${_discountAmount.toInt()}', style: const TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Escrow Trust Protection & GST', style: TextStyle(color: AppTheme.slateMuted)),
                    Text('₹0 (Included)', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Payable Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    Text(
                      '₹${finalPrice.toInt()}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primaryCrimson),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Confirm and Pay Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      final booking = await ApiService.instance.createBooking(
                        vendorId: widget.vendor.id,
                        packageId: widget.package.id,
                        bookingDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
                        timeSlot: _selectedSlot,
                        address: _addressController.text,
                        totalAmount: finalPrice,
                      );
                      setState(() => _loading = false);

                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingSuccessScreen(booking: booking),
                        ),
                      );
                    },
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm & Deposit in Escrow'),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
