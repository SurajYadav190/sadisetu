import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/common/role_selector_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShaadiSetuApp());
}

class ShaadiSetuApp extends StatelessWidget {
  const ShaadiSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shaadi Setu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const RoleSelectorScreen(),
    );
  }
}
