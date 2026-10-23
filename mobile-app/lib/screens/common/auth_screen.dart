import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../customer/customer_main_nav.dart';
import '../vendor/vendor_main_nav.dart';

class AuthScreen extends StatefulWidget {
  final String role; // 'CUSTOMER' or 'VENDOR'
  final bool isRegister;

  const AuthScreen({
    super.key,
    required this.role,
    this.isRegister = false,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late String _activeRole;
  late bool _isRegister;

  // Sign In / OTP controllers
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _smsDelivered = false;
  bool _otpSent = false;
  bool _loading = false;

  // Customer Register controllers
  final _custNameController = TextEditingController();
  final _custPhoneController = TextEditingController();
  final _custEmailController = TextEditingController();
  String _custCity = 'Delhi NCR';

  // Vendor Register controllers
  final _vendorBusinessController = TextEditingController();
  final _vendorOwnerController = TextEditingController();
  final _vendorPhoneController = TextEditingController();
  final _vendorAddressController = TextEditingController();
  final _vendorPriceController = TextEditingController(text: '35000');
  final _vendorBioController = TextEditingController();
  String _vendorCategory = 'Camera & Photography';
  String _vendorCity = 'Delhi NCR';

  final List<String> _cities = ['Delhi NCR', 'Jaipur', 'Lucknow', 'Mumbai', 'Chandigarh', 'Bangalore'];

  final List<String> _categories = [
    'Camera & Photography',
    'Luxury Cars',
    'DJ & Sound Systems',
    'Decorators & Mandap',
    'Baaja & Brass Band',
    'Royal Catering'
  ];

  @override
  void initState() {
    super.initState();
    _activeRole = widget.role;
    _isRegister = widget.isRegister;
  }

  void _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    setState(() => _loading = true);
    final res = await ApiService.instance.sendOtp(phone, role: _activeRole);

    if (!mounted) return;
    setState(() => _loading = false);

    if (res['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('⚠️ ${res['message'] ?? 'Failed to send OTP.'}'),
          action: SnackBarAction(
            label: 'Register Now',
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                _isRegister = true;
                if (_activeRole == 'VENDOR') {
                  _vendorPhoneController.text = phone;
                } else {
                  _custPhoneController.text = phone;
                }
              });
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() {
      _otpSent = true;
      _smsDelivered = res['smsDelivered'] == true;
      _otpController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F172A),
        content: Text('📲 Verification code sent via SMS to +91 $phone'),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          content: Text('⚠️ Please enter the complete 6-digit OTP received on your mobile.'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final res = await ApiService.instance.loginOrVerify(
      _phoneController.text.trim(),
      otp,
      _activeRole,
    );
    setState(() => _loading = false);

    if (!mounted) return;

    if (res['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('❌ ${res['message'] ?? 'Invalid OTP! Only the code received on your mobile number is valid.'}'),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

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

  void _handleCustomerRegister() async {
    final name = _custNameController.text.trim();
    final phone = _custPhoneController.text.trim();
    final email = _custEmailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your full name')));
      return;
    }
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid 10-digit mobile number')));
      return;
    }

    setState(() => _loading = true);
    final res = await ApiService.instance.registerCustomer(
      fullName: name,
      phone: phone,
      city: _custCity,
      email: email.isNotEmpty ? email : null,
    );
    setState(() => _loading = false);

    if (!mounted) return;

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.successGreen,
          content: Text('🎉 ${res['message'] ?? 'Customer account registered!'}'),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CustomerMainNav()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('⚠️ ${res['message'] ?? 'Registration failed'}'),
        ),
      );
    }
  }

  void _handleVendorRegister() async {
    final bName = _vendorBusinessController.text.trim();
    final oName = _vendorOwnerController.text.trim();
    final phone = _vendorPhoneController.text.trim();
    final address = _vendorAddressController.text.trim();
    final price = double.tryParse(_vendorPriceController.text.trim()) ?? 25000.0;
    final bio = _vendorBioController.text.trim();

    if (bName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter business / brand name')));
      return;
    }
    if (oName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter owner / contact person name')));
      return;
    }
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid 10-digit phone number')));
      return;
    }
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter business address or studio location')));
      return;
    }

    setState(() => _loading = true);
    final res = await ApiService.instance.registerVendor(
      businessName: bName,
      ownerName: oName,
      phone: phone,
      categoryName: _vendorCategory,
      city: _vendorCity,
      address: address,
      startingPrice: price,
      bio: bio.isNotEmpty ? bio : null,
    );
    setState(() => _loading = false);

    if (!mounted) return;

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.successGreen,
          content: Text('🎉 ${res['message'] ?? 'Vendor partner registered successfully!'}'),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const VendorMainNav()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('⚠️ ${res['message'] ?? 'Vendor registration failed'}'),
        ),
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
        title: Text(_isRegister
            ? (isVendor ? 'Vendor Partner Registration' : 'Customer Account Registration')
            : (isVendor ? 'Vendor Partner Sign In' : 'Customer Sign In')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Role selector tabs (Customer vs Vendor)
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
                                _otpSent = false;
                                _phoneController.clear();
                                _otpController.clear();
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isVendor ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: !isVendor
                                    ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
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
                                _otpSent = false;
                                _phoneController.clear();
                                _otpController.clear();
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isVendor ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isVendor
                                    ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
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

                  const SizedBox(height: 12),

                  // 2. Mode selector (Sign In vs Register)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isRegister = false),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !_isRegister ? roleColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Sign In (OTP)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: !_isRegister ? Colors.white : AppTheme.slateDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isRegister = true),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _isRegister ? roleColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Register Account',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: _isRegister ? Colors.white : AppTheme.slateDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Header title
                  Text(
                    _isRegister
                        ? (isVendor ? 'Register Vendor Partner' : 'Create Customer Account')
                        : (_otpSent ? 'Enter Verification Code' : (isVendor ? 'Vendor Partner Portal' : 'Welcome to Shaadi Setu')),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.slateDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isRegister
                        ? (isVendor
                            ? 'Register your camera studio, luxury cars, DJ or decor business to get booked by couples.'
                            : 'Sign up to explore verified wedding vendors, customize packages and book with safe escrow.')
                        : (_otpSent
                            ? 'Code sent to +91 ${_phoneController.text}.'
                            : (isVendor
                                ? 'Sign in with your mobile number to view orders, update calendar and check earnings.'
                                : 'Sign in to access verified wedding vendors, packages, chat and instant booking.')),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.slateMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ================= SIGN IN VIEW =================
                  if (!_isRegister) ...[
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
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter 10-digit number',
                                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                  suffixIcon: _phoneController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, size: 18),
                                          onPressed: () => setState(() => _phoneController.clear()),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: roleColor),
                          onPressed: _loading ? null : _handleSendOtp,
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Get OTP'),
                        ),
                      ),
                    ] else ...[
                      // OTP Verification Card
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.mark_chat_read_rounded, color: Color(0xFF16A34A), size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _smsDelivered ? 'SMS Delivered to your mobile' : 'OTP Code Dispatched',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF166534)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Enter the 6-digit verification code sent to +91 ${_phoneController.text}.',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF15803D)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 8),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppTheme.surfaceBg,
                          hintText: '• • • • • •',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: roleColor),
                          onPressed: _loading ? null : _handleVerify,
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(isVendor ? 'Enter Vendor Hub' : 'Enter Customer Experience'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: () => setState(() => _otpSent = false),
                          child: const Text('Change Number'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => _isRegister = true),
                        child: Text(
                          isVendor ? 'New Vendor? Register Your Business Here' : 'New Customer? Create An Account Here',
                          style: TextStyle(color: roleColor, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ]

                  // ================= CUSTOMER REGISTRATION =================
                  else if (!isVendor) ...[
                    const Text('Full Name *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _custNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceBg,
                        hintText: 'e.g. Amit Sharma',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text('Mobile Number (10 Digits) *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _custPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceBg,
                        prefixText: '+91 ',
                        hintText: '9876543210',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text('City / Location *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _custCity,
                          isExpanded: true,
                          onChanged: (val) {
                            if (val != null) setState(() => _custCity = val);
                          },
                          items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text('Email Address (Optional)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _custEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceBg,
                        hintText: 'e.g. amit@example.com',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryCrimson),
                        onPressed: _loading ? null : _handleCustomerRegister,
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Register Customer Account'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => _isRegister = false),
                        child: const Text('Already have an account? Sign In with OTP', style: TextStyle(color: AppTheme.primaryCrimson, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]

                  // ================= VENDOR REGISTRATION =================
                  else ...[
                    const Text('Business / Brand Name *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _vendorBusinessController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceBg,
                        hintText: 'e.g. Royal Lens & Drone Cinematics',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text('Owner / Contact Person Name *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _vendorOwnerController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceBg,
                        hintText: 'e.g. Vikramaditya Rathore',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text('Mobile Number (10 Digits) *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _vendorPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceBg,
                        prefixText: '+91 ',
                        hintText: '9811122233',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text('Service Category *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _vendorCategory,
                          isExpanded: true,
                          onChanged: (val) {
                            if (val != null) setState(() => _vendorCategory = val);
                          },
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Operating City *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _vendorCity,
                                    isExpanded: true,
                                    onChanged: (val) {
                                      if (val != null) setState(() => _vendorCity = val);
                                    },
                                    items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Starting Price (₹) *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _vendorPriceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppTheme.surfaceBg,
                                  prefixText: '₹ ',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    const Text('Office / Studio / Workshop Address *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _vendorAddressController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceBg,
                        hintText: 'e.g. 42 Connaught Place, Central Delhi',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text('Business Bio / Equipment Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _vendorBioController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceBg,
                        hintText: 'e.g. 4K Drone photography, candid portraits, jimmy jib crane & teasers.',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB45309)),
                        onPressed: _loading ? null : _handleVendorRegister,
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Register Vendor Partner Business'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => _isRegister = false),
                        child: const Text('Already have a vendor account? Sign In', style: TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.w700)),
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
