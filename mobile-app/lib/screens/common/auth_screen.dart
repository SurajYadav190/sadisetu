import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../customer/customer_main_nav.dart';
import '../vendor/vendor_main_nav.dart';

class AuthScreen extends StatefulWidget {
  final String role; // 'CUSTOMER' or 'VENDOR'
  const AuthScreen({super.key, required this.role});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late String _activeRole;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController(text: '123456');
  bool _otpSent = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _activeRole = widget.role;
    _setDemoNumber();
  }

  void _setDemoNumber() {
    if (_activeRole == 'VENDOR') {
      _phoneController.text = '9811122233';
    } else {
      _phoneController.text = '9876543210';
    }
  }

  void _handleSendOtp() {
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }
    setState(() {
      _otpSent = true;
    });
  }

  void _handleVerify() async {
    setState(() => _loading = true);
    await ApiService.instance.loginOrVerify(
      _phoneController.text.trim(),
      _otpController.text.trim(),
      _activeRole,
    );
    setState(() => _loading = false);

    if (!mounted) return;
    if (_activeRole == 'VENDOR') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const VendorMainNav()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CustomerMainNav()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVendor = _activeRole == 'VENDOR';
    final roleColor = isVendor ? const Color(0xFFB45309) : AppTheme.primaryCrimson;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isVendor ? 'Vendor Partner Sign In' : 'Customer Sign In'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role indicator & switcher
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _activeRole = 'CUSTOMER';
                                _setDemoNumber();
                                _otpSent = false;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isVendor ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: !isVendor
                                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '👤 Customer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: !isVendor ? AppTheme.primaryCrimson : AppTheme.slateMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _activeRole = 'VENDOR';
                                _setDemoNumber();
                                _otpSent = false;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isVendor ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isVendor
                                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                    : null,
                              ),
                              child: const Center(
                                child: Text(
                                  '🏬 Vendor Partner',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Header title
                  Text(
                    _otpSent ? 'Enter Verification Code' : (isVendor ? 'Vendor Partner Portal' : 'Welcome to Shaadi Setu'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.slateDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _otpSent
                        ? 'Code sent to +91 ${_phoneController.text}. (Default test code is 123456)'
                        : (isVendor
                            ? 'Sign in to access your vendor dashboard, accept incoming bookings, manage calendar and view earnings.'
                            : 'Sign in to access verified wedding vendors, packages, chat and instant booking.'),
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.slateMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  if (!_otpSent) ...[
                    const Text(
                      'Mobile Number',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '🇮🇳 +91 ',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter 10-digit number',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Demo Fill Chip
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.flash_on_rounded, size: 14),
                          label: Text(
                            isVendor ? 'Fill Demo Vendor (Vikramaditya)' : 'Fill Demo Customer (Rahul)',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                          onPressed: _setDemoNumber,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: roleColor),
                        onPressed: _handleSendOtp,
                        child: const Text('Get OTP'),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Verification Code',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 8),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceBg,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: roleColor),
                        onPressed: _loading ? null : _handleVerify,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text('Verify & Enter ${isVendor ? 'Vendor Hub' : 'Customer App'}'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => _otpSent = false),
                        child: const Text('Change Phone Number'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
