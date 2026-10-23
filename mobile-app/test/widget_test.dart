import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shadi_setu_app/main.dart';
import 'package:shadi_setu_app/services/api_service.dart';
import 'package:shadi_setu_app/screens/customer/customer_main_nav.dart';
import 'package:shadi_setu_app/screens/customer/booking_checkout_screen.dart';
import 'package:shadi_setu_app/screens/vendor/vendor_main_nav.dart';
import 'package:shadi_setu_app/models/wedding_models.dart';

void main() {
  setUp(() {
    ApiService.instance.logout();
  });

  testWidgets('App smoke test - verifies brand header on RoleSelectorScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const ShaadiSetuApp());
    expect(find.text('Shaadi Setu'), findsOneWidget);
    expect(find.text('Customer Experience'), findsOneWidget);
    expect(find.text('Vendor Partner Ecosystem'), findsOneWidget);
  });

  testWidgets('CustomerMainNav blocks direct access without login and redirects to login', (WidgetTester tester) async {
    expect(ApiService.instance.isCustomerLoggedIn, isFalse);

    await tester.pumpWidget(const MaterialApp(home: CustomerMainNav()));
    // Should show loading spinner while redirecting, not the home page contents
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('VendorMainNav blocks direct access without login and redirects to login', (WidgetTester tester) async {
    expect(ApiService.instance.isVendorLoggedIn, isFalse);

    await tester.pumpWidget(const MaterialApp(home: VendorMainNav()));
    // Should show loading spinner while redirecting, not the vendor hub
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Authentication gating logic - default state requires login', (WidgetTester tester) async {
    expect(ApiService.instance.isCustomerLoggedIn, isFalse);
    expect(ApiService.instance.isVendorLoggedIn, isFalse);

    // Test customer login state
    ApiService.instance.currentUser = UserModel(
      id: 2,
      fullName: 'Rahul Sharma',
      phone: '9876543210',
      role: 'ROLE_CUSTOMER',
    );
    expect(ApiService.instance.isCustomerLoggedIn, isTrue);
    expect(ApiService.instance.isVendorLoggedIn, isFalse);
    expect(ApiService.instance.currentUser?.fullName, equals('Rahul Sharma'));

    // Logout
    ApiService.instance.logout();
    expect(ApiService.instance.isCustomerLoggedIn, isFalse);

    // Test vendor login state
    ApiService.instance.currentUser = UserModel(
      id: 4,
      fullName: 'Vikramaditya Studios',
      phone: '9811122233',
      role: 'ROLE_VENDOR',
    );
    expect(ApiService.instance.isVendorLoggedIn, isTrue);
    expect(ApiService.instance.isCustomerLoggedIn, isFalse);
    expect(ApiService.instance.currentUser?.role, equals('ROLE_VENDOR'));
  });

  test('Camera varieties data provider includes Drone Camera with price and duration', () {
    final varieties = ApiService.instance.getVarietiesForCategory('Camera & Photography');
    expect(varieties, isNotEmpty);

    final droneOption = varieties.firstWhere((v) => v.id == 'drone_4k');
    expect(droneOption.name, contains('Drone Camera'));
    expect(droneOption.price, equals(10000.0));
    expect(droneOption.durationHours, equals(4));
  });

  testWidgets('BookingCheckoutScreen displays camera varieties, drone camera and updates price & duration', (WidgetTester tester) async {
    final cameraVendor = ApiService.instance.vendors.firstWhere((v) => v.categoryName.contains('Camera'));
    final package = cameraVendor.packages.first;

    await tester.pumpWidget(
      MaterialApp(
        home: BookingCheckoutScreen(
          vendor: cameraVendor,
          package: package,
          initialSelectedVarietyIds: const ['drone_4k'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check varieties section header
    expect(find.text('1. Camera Variety & Equipment Options'), findsOneWidget);

    // Verify 4K Drone Camera is displayed with price & time
    expect(find.text('4K Drone Camera Aerial Coverage'), findsOneWidget);
    expect(find.text('+ ₹10000 Added'), findsWidgets);
    expect(find.text('+ 4 Hours Coverage'), findsWidgets);

    // Verify dynamic total hours includes base (16) + drone (4) = 20 Hours in summary pill
    expect(find.text('20 Hours'), findsOneWidget);

    // Now tap to deselect drone
    await tester.tap(find.text('4K Drone Camera Aerial Coverage'));
    await tester.pumpAndSettle();

    // Total hours drops back to base 16 hours
    expect(find.text('16 Hours'), findsOneWidget);
    expect(find.text('+₹0'), findsOneWidget);
  });
}
