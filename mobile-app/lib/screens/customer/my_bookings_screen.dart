import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/wedding_models.dart';
import 'live_event_tracker_screen.dart';
import 'customer_chat_screen.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = ApiService.instance.customerBookings;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('My Event Bookings'),
          bottom: const TabBar(
            labelColor: AppTheme.primaryCrimson,
            unselectedLabelColor: AppTheme.slateMuted,
            indicatorColor: AppTheme.primaryCrimson,
            tabs: [
              Tab(text: 'Active / Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList(
              context,
              bookings.where((b) => b.status == 'PENDING' || b.status == 'ACCEPTED' || b.status == 'IN_PROGRESS').toList(),
            ),
            _buildBookingList(
              context,
              bookings.where((b) => b.status == 'COMPLETED').toList(),
            ),
            _buildBookingList(
              context,
              bookings.where((b) => b.status == 'CANCELLED').toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, List<BookingModel> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text('No bookings found in this section.', style: TextStyle(color: AppTheme.slateMuted)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final b = list[index];
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
                  Text(
                    b.bookingNumber,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryCrimson, fontSize: 14),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: b.status == 'ACCEPTED' || b.status == 'COMPLETED'
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      b.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: b.status == 'ACCEPTED' || b.status == 'COMPLETED' ? AppTheme.successGreen : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                b.vendorName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.slateMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${b.bookingDate} (${b.timeSlot})',
                    style: const TextStyle(fontSize: 12.5, color: AppTheme.slateMuted),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.slateMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      b.venueAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppTheme.slateMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Escrow Deposit', style: TextStyle(fontSize: 11, color: AppTheme.slateMuted)),
                      Text(
                        '₹${b.totalAmount.toInt()}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.slateDark),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryCrimson),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CustomerChatScreen()),
                          );
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LiveEventTrackerScreen(booking: b),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Live Tracker'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
