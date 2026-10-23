import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/wedding_models.dart';
import 'live_event_tracker_screen.dart';
import 'customer_chat_screen.dart';
import 'service_listing_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  void _showPaymentDetails(BuildContext context, BookingModel b) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool processing = false;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
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
                            'Escrow Payment Details',
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
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: AppTheme.successGreen, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.paymentStatus == 'ESCROW_HELD' ? '100% Escrow Active & Protected' : 'Payment Status: ${b.paymentStatus}',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF065F46)),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Payment is held in a secure trust account. Vendor receives payout only after event is successfully executed.',
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF047857), height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentRow('Booking Reference', b.bookingNumber),
                  const Divider(height: 14),
                  _buildPaymentRow('Service Vendor', b.vendorName),
                  const Divider(height: 14),
                  _buildPaymentRow('Total Amount', '₹${b.totalAmount.toInt()}'),
                  const Divider(height: 14),
                  _buildPaymentRow('Escrow Held Amount', '₹${b.totalAmount.toInt()}'),
                  const Divider(height: 14),
                  _buildPaymentRow('Transaction ID', b.paymentTransactionId ?? 'TXN-${b.bookingNumber.replaceAll('SS-', '')}9218'),
                  const Divider(height: 14),
                  _buildPaymentRow('Payment Method', 'UPI / Safe Escrow (Verified)'),
                  const SizedBox(height: 22),

                  if (b.paymentStatus != 'ESCROW_HELD')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: processing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.lock_outline_rounded, size: 18),
                        label: Text(processing ? 'Processing Payment...' : 'Make Escrow Payment (₹${b.totalAmount.toInt()})'),
                        onPressed: processing
                            ? null
                            : () async {
                                setSheetState(() => processing = true);
                                await Future.delayed(const Duration(milliseconds: 1200));
                                setState(() {
                                  b.paymentStatus = 'ESCROW_HELD';
                                });
                                setSheetState(() => processing = false);
                                if (!context.mounted) return;
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Payment completed and safely deposited into Escrow!')),
                                );
                              },
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.receipt_long_rounded, size: 18),
                        label: const Text('Download Escrow Invoice PDF'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Escrow Tax Invoice downloaded to device!')),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    },
  );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppTheme.slateMuted)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.slateDark)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ApiService.instance.customerBookings;
    final activeBookings = bookings.where((b) => b.status == 'PENDING' || b.status == 'ACCEPTED' || b.status == 'IN_PROGRESS').toList();
    final completedBookings = bookings.where((b) => b.status == 'COMPLETED').toList();
    final cancelledBookings = bookings.where((b) => b.status == 'CANCELLED').toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text(
            'My Event Bookings',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.slateDark),
          ),
          bottom: TabBar(
            labelColor: AppTheme.primaryCrimson,
            unselectedLabelColor: AppTheme.slateMuted,
            indicatorColor: AppTheme.primaryCrimson,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Active'),
                    if (activeBookings.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCrimson.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${activeBookings.length}',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppTheme.primaryCrimson),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Completed'),
                    if (completedBookings.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${completedBookings.length}',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppTheme.successGreen),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Cancelled'),
                    if (cancelledBookings.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${cancelledBookings.length}',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppTheme.slateMuted),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: TabBarView(
              children: [
                _buildResponsiveList(context, activeBookings, 'No active or upcoming bookings found.', showExploreAction: true),
                _buildResponsiveList(context, completedBookings, 'No completed wedding bookings yet.'),
                _buildResponsiveList(context, cancelledBookings, 'No cancelled bookings.'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveList(
    BuildContext context,
    List<BookingModel> list,
    String emptyMessage, {
    bool showExploreAction = false,
  }) {
    if (list.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.lightGold.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_note_rounded, size: 36, color: Color(0xFFB45309)),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Book vetted photographers, drone pilots, luxury cars, or DJs with 100% Escrow Protection.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppTheme.slateMuted, height: 1.4),
              ),
              if (showExploreAction) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Browse Wedding Vendors'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ServiceListingScreen()),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 680;

        if (isWideScreen) {
          // 2-column grid layout for wide screens / desktop / tablets
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 310,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) => _buildBookingCard(context, list[index]),
          );
        }

        // Standard responsive list for mobile screens
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: list.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildBookingCard(context, list[index]),
          ),
        );
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel b) {
    Color statusBg;
    Color statusTextColor;
    if (b.status == 'ACCEPTED' || b.status == 'COMPLETED') {
      statusBg = const Color(0xFFECFDF5);
      statusTextColor = AppTheme.successGreen;
    } else if (b.status == 'CANCELLED') {
      statusBg = const Color(0xFFFEE2E2);
      statusTextColor = Colors.red.shade700;
    } else {
      statusBg = const Color(0xFFFFFBEB);
      statusTextColor = const Color(0xFFB45309);
    }

    return Container(
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LiveEventTrackerScreen(booking: b)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header: Booking Number & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.confirmation_number_outlined, size: 16, color: AppTheme.primaryCrimson),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              b.bookingNumber,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryCrimson, fontSize: 13.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        b.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Vendor Name & Category
                Text(
                  b.vendorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                ),
                const SizedBox(height: 6),

                // Event Date & Time Shift (Safely flexible to prevent overflow)
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.slateMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${b.bookingDate}  •  ${b.timeSlot}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Venue Address (Safely flexible)
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.slateMuted),
                    const SizedBox(width: 6),
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

                // Selected Varieties & Add-ons Wrap
                if (b.selectedVarieties.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: [
                      ...b.selectedVarieties.map((v) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGold,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: AppTheme.weddingGold.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              v.toLowerCase().contains('drone') ? '🛸 $v' : '✓ $v',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF78350F),
                              ),
                            ),
                          )),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '⏱️ ${b.totalDurationHours}h coverage',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                        ),
                      ),
                    ],
                  ),
                ],

                // Fixed height separator - replaces Spacer() to eliminate unbounded height null crash
                const SizedBox(height: 12),
                const Divider(height: 18),

                // Responsive Bottom Action Bar with Payment & Chat Actions
                LayoutBuilder(
                  builder: (context, cardConstraints) {
                    final isVeryNarrow = cardConstraints.maxWidth < 280;

                    final amountWidget = InkWell(
                      onTap: () => _showPaymentDetails(context, b),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.shield_rounded, size: 12, color: AppTheme.successGreen),
                                const SizedBox(width: 3),
                                Text(
                                  b.paymentStatus == 'ESCROW_HELD' ? 'Escrow Held' : 'Pay Escrow',
                                  style: const TextStyle(fontSize: 10.5, color: AppTheme.slateMuted, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Text(
                              '₹${b.totalAmount.toInt()}',
                              style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900, color: AppTheme.slateDark),
                            ),
                          ],
                        ),
                      ),
                    );

                    final buttonsWidget = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Payment details pill
                        InkWell(
                          onTap: () => _showPaymentDetails(context, b),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.payment_rounded, size: 14, color: AppTheme.successGreen),
                                SizedBox(width: 4),
                                Text(
                                  'Payment',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF065F46)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryCrimson, size: 20),
                          tooltip: 'Chat with Vendor',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerChatScreen(
                                  vendorName: b.vendorName,
                                  booking: b,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LiveEventTrackerScreen(booking: b)),
                            );
                          },
                          icon: const Icon(Icons.gps_fixed_rounded, size: 13),
                          label: const Text('Tracker'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    );

                    if (isVeryNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          amountWidget,
                          const SizedBox(height: 8),
                          buttonsWidget,
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        amountWidget,
                        buttonsWidget,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
