import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/wedding_models.dart';
import '../../services/api_service.dart';
import 'booking_success_screen.dart';

class BookingCheckoutScreen extends StatefulWidget {
  final VendorModel vendor;
  final ServicePackageModel package;
  final List<String>? initialSelectedVarietyIds;

  const BookingCheckoutScreen({
    super.key,
    required this.vendor,
    required this.package,
    this.initialSelectedVarietyIds,
  });

  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 14));
  String _selectedSlot = 'Evening & Sangeet (5:00 PM - 12:00 AM)';
  final _addressController = TextEditingController(text: 'The Grand Palace Resort, GT Karnal Road, Delhi');
  final _couponController = TextEditingController(text: 'SHADI2026');

  bool _couponApplied = true;
  double _discountAmount = 5000.0;

  late List<ServiceVarietyOption> _availableVarieties;
  final Set<String> _selectedVarietyIds = {};

  final List<String> _slots = [
    'Morning (10:00 AM - 4:00 PM)',
    'Evening & Sangeet (5:00 PM - 12:00 AM)',
    'Full Day & Night (24 Hours)',
  ];

  @override
  void initState() {
    super.initState();
    _availableVarieties = ApiService.instance.getVarietiesForCategory(widget.vendor.categoryName);

    if (widget.initialSelectedVarietyIds != null && widget.initialSelectedVarietyIds!.isNotEmpty) {
      _selectedVarietyIds.addAll(widget.initialSelectedVarietyIds!);
    } else {
      // By default if Camera & Photography, pre-select Drone Camera as popular option
      final isCamera = widget.vendor.categoryName.toLowerCase().contains('camera') ||
          widget.vendor.categoryName.toLowerCase().contains('photo');
      if (isCamera && _availableVarieties.isNotEmpty) {
        _selectedVarietyIds.add(_availableVarieties.first.id); // 'drone_4k'
      }
    }
  }

  double get _varietiesPrice {
    double total = 0.0;
    for (final v in _availableVarieties) {
      if (_selectedVarietyIds.contains(v.id)) {
        total += v.price;
      }
    }
    return total;
  }

  int get _varietiesHours {
    int totalHours = 0;
    for (final v in _availableVarieties) {
      if (_selectedVarietyIds.contains(v.id)) {
        totalHours += v.durationHours;
      }
    }
    return totalHours;
  }

  int get _totalHours => widget.package.durationHours + _varietiesHours;

  List<ServiceVarietyOption> get _selectedVarietyList {
    return _availableVarieties.where((v) => _selectedVarietyIds.contains(v.id)).toList();
  }

  IconData _getVarietyIcon(String icon) {
    switch (icon) {
      case 'drone':
        return Icons.flight_takeoff_rounded;
      case 'candid':
      case 'camera':
        return Icons.camera_alt_rounded;
      case 'film':
      case 'video':
        return Icons.videocam_rounded;
      case 'crane':
        return Icons.precision_manufacturing_rounded;
      case 'booth':
      case 'rotate':
        return Icons.replay_circle_filled_rounded;
      case 'tv':
      case 'live':
        return Icons.tv_rounded;
      case 'heart':
        return Icons.favorite_rounded;
      case 'print':
        return Icons.print_rounded;
      case 'flower':
        return Icons.local_florist_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'spark':
        return Icons.auto_awesome_rounded;
      case 'drum':
        return Icons.surround_sound_rounded;
      default:
        return Icons.stars_rounded;
    }
  }

  void _openEscrowPaymentModal(BuildContext context, double finalPrice) {
    String selectedMethod = 'UPI';
    final upiIdController = TextEditingController(text: 'customer@okhdfcbank');
    bool isPaying = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shield_rounded, color: AppTheme.successGreen, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Safe Escrow Payment',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vendor: ${widget.vendor.businessName}',
                    style: const TextStyle(fontSize: 13, color: AppTheme.slateMuted, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  // Amount Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGold,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.weddingGold.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Escrow Deposit',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF78350F)),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '100% Protected & Refundable',
                              style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                            ),
                          ],
                        ),
                        Text(
                          '₹${finalPrice.toInt()}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primaryCrimson),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Select Payment Method',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                  ),
                  const SizedBox(height: 10),

                  // Method 1: UPI
                  _buildPaymentOption(
                    title: 'UPI Instant (GPay / PhonePe / Paytm / QR)',
                    subtitle: 'Zero fee • Instant escrow confirmation',
                    icon: Icons.account_balance_wallet_rounded,
                    isSelected: selectedMethod == 'UPI',
                    onTap: () => setModalState(() => selectedMethod = 'UPI'),
                  ),

                  if (selectedMethod == 'UPI') ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: ['GPay', 'PhonePe', 'Paytm', 'BHIM'].map((app) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  label: Text(app, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: upiIdController,
                            decoration: InputDecoration(
                              hintText: 'Enter UPI VPA (e.g. mobile@upi)',
                              filled: true,
                              fillColor: AppTheme.surfaceBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Method 2: Cards
                  _buildPaymentOption(
                    title: 'Credit / Debit Cards',
                    subtitle: 'Visa, MasterCard, RuPay, Maestro',
                    icon: Icons.credit_card_rounded,
                    isSelected: selectedMethod == 'CARD',
                    onTap: () => setModalState(() => selectedMethod = 'CARD'),
                  ),

                  // Method 3: Net Banking
                  _buildPaymentOption(
                    title: 'Net Banking',
                    subtitle: 'HDFC, ICICI, SBI, Axis, Kotak',
                    icon: Icons.account_balance_rounded,
                    isSelected: selectedMethod == 'NETBANKING',
                    onTap: () => setModalState(() => selectedMethod = 'NETBANKING'),
                  ),

                  const SizedBox(height: 24),

                  // Escrow Trust note
                  const Row(
                    children: [
                      Icon(Icons.lock_rounded, size: 14, color: AppTheme.successGreen),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '256-Bit SSL Encrypted. Payment is held in Escrow trust until ceremony sign-off.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF047857), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isPaying
                          ? null
                          : () async {
                              setModalState(() => isPaying = true);

                              final selectedVarietySummaries = _selectedVarietyList
                                  .map((v) => '${v.name} (+${v.durationHours} hrs)')
                                  .toList();

                              final txnId = 'TXN-${DateTime.now().millisecondsSinceEpoch % 10000000}';

                              // Simulate secure banking escrow authorization
                              await Future.delayed(const Duration(milliseconds: 1200));

                              final booking = await ApiService.instance.createBooking(
                                vendorId: widget.vendor.id,
                                packageId: widget.package.id,
                                bookingDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
                                timeSlot: '$_selectedSlot ($_totalHours hrs total)',
                                address: _addressController.text,
                                totalAmount: finalPrice,
                                selectedVarieties: selectedVarietySummaries,
                                totalDurationHours: _totalHours,
                                promoCode: _couponApplied ? 'SHADI2026' : null,
                              );
                              booking.paymentTransactionId = txnId;

                              setModalState(() => isPaying = false);

                              if (!ctx.mounted) return;
                              Navigator.pop(ctx); // Close sheet

                              if (!context.mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingSuccessScreen(booking: booking),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: isPaying
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                ),
                                SizedBox(width: 10),
                                Text('Processing Safe Escrow...'),
                              ],
                            )
                          : Text('Pay ₹${finalPrice.toInt()} & Hold in Escrow'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFFBEB) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryCrimson : const Color(0xFFE2E8F0),
          width: isSelected ? 1.6 : 1.0,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Icon(icon, color: isSelected ? AppTheme.primaryCrimson : AppTheme.slateDark),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.slateMuted)),
        trailing: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: isSelected ? AppTheme.primaryCrimson : const Color(0xFF94A3B8),
          size: 19,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final basePrice = widget.package.discountedPrice ?? widget.package.price;
    final subtotal = basePrice + _varietiesPrice;
    final finalPrice = (subtotal - (_couponApplied ? _discountAmount : 0.0)).clamp(0.0, double.infinity);

    final isCamera = widget.vendor.categoryName.toLowerCase().contains('camera') ||
        widget.vendor.categoryName.toLowerCase().contains('photo');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Event Date & Checkout'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
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
                      Row(
                        children: [
                          const Icon(Icons.verified_rounded, size: 14, color: AppTheme.primaryCrimson),
                          const SizedBox(width: 4),
                          Text(
                            widget.vendor.businessName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryCrimson),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.package.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: AppTheme.slateMuted),
                          const SizedBox(width: 4),
                          Text(
                            'Base Package Duration: ${widget.package.durationHours} Hours',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.slateMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Base Price', style: TextStyle(fontSize: 11, color: AppTheme.slateMuted)),
                    Text(
                      '₹${basePrice.toInt()}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.slateDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 1. Interactive Varieties & Options Selection (Highlighting Camera / Drone Varieties)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCamera ? '1. Camera Variety & Equipment Options' : '1. Service Variety & Equipment Add-ons',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.lightGold,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_selectedVarietyIds.length} Selected',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF78350F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isCamera
                ? 'Select camera varieties (Drone Camera, Candid Shooters, Jib Crane). Price and event hours add up dynamically.'
                : 'Choose custom service varieties. Price and ceremony hours adjust in real time.',
            style: const TextStyle(fontSize: 12, color: AppTheme.slateMuted),
          ),
          const SizedBox(height: 12),

          // Real-time Summary Badge Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDynamicPill(
                  icon: Icons.check_box_outlined,
                  label: 'Varieties',
                  value: '${_selectedVarietyIds.length} items',
                  color: AppTheme.primaryCrimson,
                ),
                Container(height: 24, width: 1, color: const Color(0xFFCBD5E1)),
                _buildDynamicPill(
                  icon: Icons.currency_rupee_rounded,
                  label: 'Added Price',
                  value: '+₹${_varietiesPrice.toInt()}',
                  color: const Color(0xFF047857),
                ),
                Container(height: 24, width: 1, color: const Color(0xFFCBD5E1)),
                _buildDynamicPill(
                  icon: Icons.access_time_rounded,
                  label: 'Total Time',
                  value: '$_totalHours Hours',
                  color: const Color(0xFFB45309),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Varieties List Cards
          ..._availableVarieties.map((variety) {
            final isSelected = _selectedVarietyIds.contains(variety.id);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                          color: AppTheme.primaryCrimson.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedVarietyIds.remove(variety.id);
                    } else {
                      _selectedVarietyIds.add(variety.id);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selection Checkbox
                      Container(
                        margin: const EdgeInsets.only(top: 2, right: 12),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryCrimson : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryCrimson : const Color(0xFF94A3B8),
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),

                      // Icon Avatar
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.lightGold : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getVarietyIcon(variety.icon),
                          color: isSelected ? AppTheme.primaryCrimson : AppTheme.slateDark,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Variety Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    variety.name,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? AppTheme.primaryCrimson : AppTheme.slateDark,
                                    ),
                                  ),
                                ),
                                if (variety.badge.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.lightGold,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      variety.badge,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF78350F)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              variety.description,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                            ),
                            const SizedBox(height: 8),

                            // Dynamic Badges: Price & Time
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '+ ₹${variety.price.toInt()} Added',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF047857),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.access_time_rounded, size: 13, color: AppTheme.slateMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        '+ ${variety.durationHours} Hours Coverage',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.slateDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // 2. Interactive Date Picker
          const Text(
            '2. Select Wedding / Event Date',
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

          // 3. Time Slot Picker with Calculated Total Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '3. Select Event Shift & Timing',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded, size: 14, color: AppTheme.primaryCrimson),
                    const SizedBox(width: 4),
                    Text(
                      'Total: $_totalHours Hours',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primaryCrimson),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (_varietiesHours > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Includes ${widget.package.durationHours}h base package + $_varietiesHours hours from selected varieties (like Drone Camera).',
                style: const TextStyle(fontSize: 12, color: Color(0xFF047857), fontWeight: FontWeight.w600),
              ),
            ),
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

          // 4. Venue Address
          const Text(
            '4. Wedding Venue Address',
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

          // 5. Promo Coupon
          const Text(
            '5. Apply Promo Voucher',
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

          // Dynamic Cost Breakdown Card
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
                const Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 18, color: AppTheme.primaryCrimson),
                    SizedBox(width: 6),
                    Text(
                      'Payment Summary (Held in Safe Escrow)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Base Package Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Base Package (${widget.package.durationHours} hrs)', style: const TextStyle(color: AppTheme.slateMuted)),
                    Text('₹${basePrice.toInt()}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),

                // Selected Varieties Itemized List
                if (_selectedVarietyList.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 12),
                  const Text(
                    'Selected Varieties & Add-ons:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                  ),
                  const SizedBox(height: 6),
                  ..._selectedVarietyList.map((v) => Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '• ${v.name} (+${v.durationHours}h)',
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              '+₹${v.price.toInt()}',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF047857)),
                            ),
                          ],
                        ),
                      )),
                ],

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Service Coverage', style: TextStyle(color: AppTheme.slateMuted)),
                    Text(
                      '$_totalHours Hours',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                    ),
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

          // Confirm and Pay Button (Opens Escrow Payment Gateway Modal)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.lock_outline_rounded, size: 18),
              label: Text('Proceed to Escrow Payment (₹${finalPrice.toInt()})'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              onPressed: () => _openEscrowPaymentModal(context, finalPrice),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildDynamicPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10.5, color: AppTheme.slateMuted)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }
}
