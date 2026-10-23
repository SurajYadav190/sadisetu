import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../common/auth_screen.dart';
import 'vendor_calendar_screen.dart';
import 'vendor_catalog_screen.dart';
import 'vendor_dashboard_screen.dart';
import 'vendor_earnings_screen.dart';
import 'vendor_orders_screen.dart';

class VendorMainNav extends StatefulWidget {
  const VendorMainNav({super.key});

  @override
  State<VendorMainNav> createState() => _VendorMainNavState();
}

class _VendorMainNavState extends State<VendorMainNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const VendorDashboardScreen(),
    const VendorOrdersScreen(),
    const VendorCalendarScreen(),
    const VendorCatalogScreen(),
    const VendorEarningsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if (!ApiService.instance.isVendorLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen(role: 'VENDOR')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ApiService.instance.isVendorLoggedIn) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFB45309)),
        ),
      );
    }
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
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment_rounded),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_calendar_outlined),
              activeIcon: Icon(Icons.edit_calendar_rounded),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2_rounded),
              label: 'Catalog',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Earnings',
            ),
          ],
        ),
      ),
    );
  }
}
