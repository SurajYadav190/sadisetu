import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/wedding_models.dart';
import 'customer_chat_screen.dart';

class LiveEventTrackerScreen extends StatelessWidget {
  final BookingModel booking;
  const LiveEventTrackerScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Live Event Service Tracker'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Event Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking.bookingNumber,
                      style: const TextStyle(color: AppTheme.weddingGold, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(radius: 3, backgroundColor: AppTheme.successGreen),
                          SizedBox(width: 4),
                          Text('LIVE TRACKING', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  booking.vendorName,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Venue: ${booking.venueAddress}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '⏱️ ${booking.totalDurationHours} Hours Total Coverage',
                        style: const TextStyle(color: AppTheme.weddingGold, fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '₹${booking.totalAmount.toInt()} in Escrow',
                        style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                if (booking.selectedVarieties.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 8),
                  const Text(
                    'Confirmed Equipment & Varieties:',
                    style: TextStyle(color: AppTheme.weddingGold, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: booking.selectedVarieties
                        .map((v) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                v.contains('Drone') ? '🛸 $v' : '✓ $v',
                                style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Stepper Timeline
          const Text(
            'Ceremony Dispatch Stepper',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 16),

          _buildStep(
            title: '1. Booking Accepted & Slot Reserved',
            subtitle: 'Vendor confirmed equipment & team assignment',
            time: '10:30 AM',
            isDone: true,
            isCurrent: false,
          ),
          _buildStep(
            title: '2. Team Dispatched & En Route',
            subtitle: 'Service convoy departed from hub towards venue',
            time: '12:15 PM',
            isDone: true,
            isCurrent: false,
          ),
          _buildStep(
            title: '3. Arrived at Wedding Venue',
            subtitle: 'Crew arrived at venue and setting up gears / drones',
            time: '01:00 PM',
            isDone: true,
            isCurrent: true,
          ),
          _buildStep(
            title: '4. Event Work In-Progress',
            subtitle: 'Ceremony photography / luxury doli ride ongoing',
            time: 'Pending',
            isDone: false,
            isCurrent: false,
          ),
          _buildStep(
            title: '5. Ceremony Completed & Escrow Release',
            subtitle: 'Deliverables verified and vendor payout processed',
            time: 'Scheduled',
            isDone: false,
            isCurrent: false,
            isLast: true,
          ),

          const SizedBox(height: 24),

          // Direct Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calling Vendor Team Coordinator: +91 9811122233')),
                    );
                  },
                  icon: const Icon(Icons.phone_rounded),
                  label: const Text('Call Vendor'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CustomerChatScreen()),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_rounded),
                  label: const Text('Chat with Team'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String title,
    required String subtitle,
    required String time,
    required bool isDone,
    required bool isCurrent,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDone
                    ? AppTheme.successGreen
                    : isCurrent
                        ? AppTheme.primaryCrimson
                        : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check_rounded : Icons.radio_button_checked_rounded,
                size: 16,
                color: isDone || isCurrent ? Colors.white : AppTheme.slateMuted,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isDone ? AppTheme.successGreen : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isCurrent ? AppTheme.primaryCrimson : AppTheme.slateDark,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 11, color: AppTheme.slateMuted, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppTheme.slateMuted),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
