import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/wedding_models.dart';
import 'vendor_chat_screen.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  final ApiService _api = ApiService.instance;

  void _updateStatus(BookingModel booking, String newStatus) {
    setState(() {
      booking.status = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order ${booking.bookingNumber} marked as $newStatus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _api.customerBookings;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Order Dispatch & Active Jobs'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 18),
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
                    Text(
                      b.bookingNumber,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryCrimson),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: b.status == 'COMPLETED' ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        b.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: b.status == 'COMPLETED' ? AppTheme.successGreen : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Client: ${b.customerName}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                ),
                const SizedBox(height: 4),
                Text(
                  '📅 Date: ${b.bookingDate} (${b.timeSlot})',
                  style: const TextStyle(fontSize: 13, color: AppTheme.slateMuted),
                ),
                Text(
                  '📍 Venue: ${b.venueAddress}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.slateMuted),
                ),
                if (b.selectedVarieties.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      ...b.selectedVarieties.map((v) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGold,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              v.contains('Drone') ? '🛸 $v' : '✓ $v',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF78350F),
                              ),
                            ),
                          )),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '⏱️ ${b.totalDurationHours}h coverage',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Net Payout (Post 10% Comm.)', style: TextStyle(fontSize: 11, color: AppTheme.slateMuted)),
                        Text(
                          '₹${(b.totalAmount * 0.9).toInt()}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.successGreen),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryCrimson),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const VendorChatScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Status Update Buttons
                if (b.status == 'PENDING') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateStatus(b, 'REJECTED'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateStatus(b, 'ACCEPTED'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
                          child: const Text('Accept Order'),
                        ),
                      ),
                    ],
                  ),
                ] else if (b.status == 'ACCEPTED') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(b, 'IN_PROGRESS'),
                      icon: const Icon(Icons.location_on_rounded, size: 16),
                      label: const Text('Mark Arrived at Venue'),
                    ),
                  ),
                ] else if (b.status == 'IN_PROGRESS') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(b, 'COMPLETED'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
                      icon: const Icon(Icons.check_circle_rounded, size: 16),
                      label: const Text('Mark Ceremony Completed (Claim Payout)'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
