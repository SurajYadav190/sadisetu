import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import 'customer_home_screen.dart';
import 'my_bookings_screen.dart';
import 'customer_chat_screen.dart';
import '../common/role_selector_screen.dart';

class CustomerMainNav extends StatefulWidget {
  const CustomerMainNav({super.key});

  @override
  State<CustomerMainNav> createState() => _CustomerMainNavState();
}

class _CustomerMainNavState extends State<CustomerMainNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CustomerHomeScreen(),
    const MyBookingsScreen(),
    const CustomerChatScreen(),
    const CustomerAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryCrimson,
          unselectedItemColor: AppTheme.slateMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore_rounded),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: 'My Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerAccountScreen extends StatelessWidget {
  const CustomerAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ApiService.instance.currentUser;
    final initials = user != null && user.fullName.isNotEmpty
        ? user.fullName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase()
        : 'RS';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppTheme.lightGold,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryCrimson,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? 'Rahul Sharma',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                  ),
                  Text(
                    '+91 ${user?.phone ?? '9876543210'} • Verified Customer',
                    style: const TextStyle(fontSize: 13, color: AppTheme.slateMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.swap_horiz_rounded, color: AppTheme.weddingGold),
            title: const Text('Switch to Vendor Partner App', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Access merchant order dispatch & earnings'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RoleSelectorScreen()),
              );
            },
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.location_on_outlined),
            title: Text('Saved Event Addresses'),
            subtitle: Text('Farmhouses, banquet halls & venue locations'),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ),
          const ListTile(
            leading: Icon(Icons.support_agent_rounded),
            title: Text('24x7 Wedding Concierge & Help'),
            subtitle: Text('Instant dispute mediation & live ticket help'),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ),
          const ListTile(
            leading: Icon(Icons.policy_outlined),
            title: Text('Escrow Payment Protection Terms'),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Logout from Account', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
            subtitle: const Text('Requires re-login to access wedding data'),
            onTap: () {
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
    );
  }
}
