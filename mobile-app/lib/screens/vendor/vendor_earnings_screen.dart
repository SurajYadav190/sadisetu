import 'package:flutter/material.dart';
import '../../config/theme.dart';

class VendorEarningsScreen extends StatelessWidget {
  const VendorEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Earnings & Payout Wallet'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Wallet Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9B1B30), Color(0xFFC42D48)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryCrimson.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('AVAILABLE BALANCE', style: TextStyle(color: AppTheme.weddingGold, fontWeight: FontWeight.w800, fontSize: 11)),
                    Icon(Icons.account_balance_wallet_rounded, color: AppTheme.weddingGold),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '₹45,000',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Auto-transferred to HDFC Bank ****1928 every Tuesday',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payout request of ₹45,000 initiated via IMPS! Ref: PO-9812')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryCrimson,
                  ),
                  child: const Text('Request Instant Withdrawal'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Payout Breakdown Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildRow('Lifetime Gross Revenue', '₹2,40,000'),
                const Divider(height: 16),
                _buildRow('Total Completed Bookings', '14 Weddings'),
                const Divider(height: 16),
                _buildRow('Platform Commission Deducted', '10.0% Standard'),
                const Divider(height: 16),
                _buildRow('Escrow Safety Status', 'Active & Protected'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Payout Transfers
          const Text(
            'Recent Bank Disbursals',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 12),

          _buildPayoutItem('TXN-HDFC-9081', 'Oct 14, 2026', '₹76,500', 'COMPLETED'),
          _buildPayoutItem('TXN-HDFC-8812', 'Oct 07, 2026', '₹45,000', 'COMPLETED'),
          _buildPayoutItem('TXN-HDFC-8201', 'Sep 30, 2026', '₹92,000', 'COMPLETED'),
        ],
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

  Widget _buildPayoutItem(String ref, String date, String amount, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFECFDF5),
                child: Icon(Icons.arrow_downward_rounded, color: AppTheme.successGreen, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ref, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.slateDark)),
                  Text(date, style: const TextStyle(fontSize: 12, color: AppTheme.slateMuted)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.successGreen)),
              Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.slateMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
