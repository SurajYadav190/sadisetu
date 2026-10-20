import 'package:flutter_test/flutter_test.dart';
import 'package:shadi_setu_app/main.dart';
import 'package:shadi_setu_app/services/api_service.dart';

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

  testWidgets('Authentication gating logic - default state requires login', (WidgetTester tester) async {
    expect(ApiService.instance.isCustomerLoggedIn, isFalse);
    expect(ApiService.instance.isVendorLoggedIn, isFalse);

    // Simulate customer login
    await ApiService.instance.loginOrVerify('9876543210', '123456', 'CUSTOMER');
    expect(ApiService.instance.isCustomerLoggedIn, isTrue);
    expect(ApiService.instance.isVendorLoggedIn, isFalse);
    expect(ApiService.instance.currentUser?.fullName, equals('Rahul Sharma'));

    // Logout
    ApiService.instance.logout();
    expect(ApiService.instance.isCustomerLoggedIn, isFalse);

    // Simulate vendor login
    await ApiService.instance.loginOrVerify('9811122233', '123456', 'VENDOR');
    expect(ApiService.instance.isVendorLoggedIn, isTrue);
    expect(ApiService.instance.isCustomerLoggedIn, isFalse);
    expect(ApiService.instance.currentUser?.role, equals('ROLE_VENDOR'));
  });
}
