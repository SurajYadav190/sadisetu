import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/wedding_models.dart';
import 'customer_main_nav.dart';
import 'live_event_tracker_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  final BookingModel booking;
  const BookingSuccessScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 50),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Wedding Booking Confirmed!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Booking ID: ${booking.bookingNumber}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryCrimson),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Payment is safely held in Shaadi Setu Escrow. Vendor dispatch notification has been sent.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppTheme.slateMuted, height: 1.4),
                  ),
                  const SizedBox(height: 24),

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
                        _buildRow('Vendor Service', booking.vendorName),
                        const Divider(height: 16),
                        _buildRow('Category', booking.categoryName),
                        const Divider(height: 16),
                        _buildRow('Event Date', booking.bookingDate),
                        const Divider(height: 16),
                        _buildRow('Total Service Time', '${booking.totalDurationHours} Hours Coverage'),
                        const Divider(height: 16),
                        _buildRow('Time Shift', booking.timeSlot),
                        if (booking.selectedVarieties.isNotEmpty) ...[
                          const Divider(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Selected Varieties', style: TextStyle(fontSize: 13, color: AppTheme.slateMuted)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: booking.selectedVarieties
                                      .map((v) => Padding(
                                            padding: const EdgeInsets.only(bottom: 3.0),
                                            child: Text(
                                              '✓ $v',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryCrimson),
                                              textAlign: TextAlign.right,
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 16),
                        _buildRow('Total Escrow Held', '₹${booking.totalAmount.toInt()}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LiveEventTrackerScreen(booking: booking),
                          ),
                        );
                      },
                      child: const Text('Track Event Status Live'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const CustomerMainNav()),
                          (route) => false,
                        );
                      },
                      child: const Text('Back to Home Dashboard'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.slateMuted)),
        Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.slateDark)),
      ],
    );
  }
}
