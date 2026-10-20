import 'package:flutter/material.dart';
import '../../config/theme.dart';

class VendorCalendarScreen extends StatefulWidget {
  const VendorCalendarScreen({super.key});

  @override
  State<VendorCalendarScreen> createState() => _VendorCalendarScreenState();
}

class _VendorCalendarScreenState extends State<VendorCalendarScreen> {
  final Set<int> _blockedDays = {4, 10, 18, 25};

  void _toggleDate(int day) {
    setState(() {
      if (_blockedDays.contains(day)) {
        _blockedDays.remove(day);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Date Nov $day unblocked and open for bookings')),
        );
      } else {
        _blockedDays.add(day);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Date Nov $day blocked to prevent double booking')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Availability & Date Blocking'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightGold,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.weddingGold.withOpacity(0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.event_busy_rounded, color: Color(0xFFB45309), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap any wedding auspicious date to block or unblock. Blocked dates won\'t be bookable by customers.',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF78350F), height: 1.4, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Month Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'November 2026 (Wedding Season)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
              ),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: () {}),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekdays
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => Text(d, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.slateMuted)))
                .toList(),
          ),
          const SizedBox(height: 12),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isBlocked = _blockedDays.contains(day);

              return GestureDetector(
                onTap: () => _toggleDate(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: isBlocked ? const Color(0xFFFEF2F2) : AppTheme.surfaceBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isBlocked ? Colors.red.shade300 : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: isBlocked ? Colors.red : AppTheme.slateDark,
                            ),
                          ),
                          if (isBlocked)
                            const Text(
                              'BLOCKED',
                              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.red),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(const Color(0xFFFEF2F2), Colors.red, 'Blocked / Reserved'),
              const SizedBox(width: 20),
              _buildLegend(AppTheme.surfaceBg, const Color(0xFFE2E8F0), 'Available for Client Booking'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color bg, Color border, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.slateMuted)),
      ],
    );
  }
}
