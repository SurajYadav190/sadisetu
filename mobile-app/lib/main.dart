 import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'services/api_service.dart';
import 'screens/common/role_selector_screen.dart';
import 'screens/customer/customer_main_nav.dart';
import 'screens/vendor/vendor_main_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restore persisted session & bookings so users do not get logged out on app close
  await ApiService.instance.initSession();
  runApp(const ShaadiSetuApp());
}

class ShaadiSetuApp extends StatelessWidget {
  const ShaadiSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget initialScreen;
    final user = ApiService.instance.currentUser;

    if (user != null) {
      if (user.role == 'ROLE_VENDOR') {
        initialScreen = const VendorMainNav();
      } else {
        initialScreen = const CustomerMainNav();
      }
    } else {
      initialScreen = const RoleSelectorScreen();
    }

    return MaterialApp(
      title: 'Shaadi Setu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: initialScreen,
    );
  }
}
