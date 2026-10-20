import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import 'vendor_chat_screen.dart';
import '../common/role_selector_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  bool _isOnline = true;

  void _showIncomingRequestModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.timer_rounded, size: 14, color: AppTheme.primaryCrimson),
                          SizedBox(width: 4),
                          Text(
                            '54s Remaining',
                            style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryCrimson, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Text('⚡ Instant Dispatch', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.slateMuted)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Incoming Wedding Booking Alert!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Client: Priya Singhania\nPackage: Royal Cinematic 2-Day Package\nDate: 22 Nov 2026 (Full Day)\nVenue: Taj Palace, Chanakyapuri, New Delhi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Escrow Deposit: ₹85,000',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primaryCrimson),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ Booking Accepted! Equipment assigned.')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successGreen,
                        ),
                        child: const Text('Accept (₹85k)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendorName = ApiService.instance.currentUser?.fullName ?? 'LensCraft Cinematic Weddings';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Merchant Partner Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Switch Mode',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RoleSelectorScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            tooltip: 'Logout',
            onPressed: () {
              ApiService.instance.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const RoleSelectorScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Storefront Status & Online Toggle Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.slateDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendorName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 4,
                            backgroundColor: _isOnline ? AppTheme.successGreen : Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isOnline ? 'Accepting Instant Bookings' : 'Storefront Offline',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isOnline ? AppTheme.successGreen : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isOnline,
                  activeColor: AppTheme.weddingGold,
                  onChanged: (val) {
                    setState(() => _isOnline = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Test Incoming Request Trigger
          InkWell(
            onTap: _showIncomingRequestModal,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightGold,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.weddingGold),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: Color(0xFFB45309)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Test Incoming 60-Second Booking Alert Modal',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF78350F)),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFB45309)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Metrics Overview
          const Text(
            'Operational Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Net Wallet Balance',
                  value: '₹45,000',
                  subtitle: 'Available to withdraw',
                  color: AppTheme.successGreen,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricTile(
                  title: 'Escrow Underway',
                  value: '₹1,04,999',
                  subtitle: '2 events in progress',
                  color: AppTheme.weddingGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Upcoming Bookings',
                  value: '3 Events',
                  subtitle: 'Next: Nov 4th (Delhi)',
                  color: AppTheme.primaryCrimson,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricTile(
                  title: 'Merchant Rating',
                  value: '4.9 ★',
                  subtitle: '48 verified client reviews',
                  color: const Color(0xFFB45309),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Quick Action Hub
          const Text(
            'Quick Operations',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 12),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            tileColor: AppTheme.surfaceBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryCrimson),
            title: const Text('Client Inquiry Messages', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            subtitle: const Text('3 new coordination messages'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VendorChatScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11.5, color: AppTheme.slateMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppTheme.slateMuted)),
        ],
      ),
    );
  }
}
