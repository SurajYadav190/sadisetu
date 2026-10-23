import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../customer/customer_main_nav.dart';
import '../vendor/vendor_main_nav.dart';
import 'auth_screen.dart';

class RoleSelectorScreen extends StatefulWidget {
  const RoleSelectorScreen({super.key});

  @override
  State<RoleSelectorScreen> createState() => _RoleSelectorScreenState();
}

class _RoleSelectorScreenState extends State<RoleSelectorScreen> {
  void _openCustomerFlow() {
    if (ApiService.instance.isCustomerLoggedIn) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Customer Session Active', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.slateDark)),
              const SizedBox(height: 6),
              Text(
                'Logged in as ${ApiService.instance.currentUser?.fullName ?? 'Rahul Sharma'} (+91 ${ApiService.instance.currentUser?.phone ?? '9876543210'})',
                style: const TextStyle(fontSize: 13, color: AppTheme.slateMuted),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('Continue to Customer Home Page'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CustomerMainNav()),
                    ).then((_) => setState(() {}));
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.login_rounded, size: 16, color: AppTheme.primaryCrimson),
                  label: const Text('Login Again / Switch Customer', style: TextStyle(color: AppTheme.primaryCrimson, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.primaryCrimson)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ApiService.instance.logout();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthScreen(role: 'CUSTOMER')),
                    ).then((_) => setState(() {}));
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen(role: 'CUSTOMER')),
      ).then((_) => setState(() {}));
    }
  }

  void _openVendorFlow() {
    if (ApiService.instance.isVendorLoggedIn) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Vendor Session Active', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.slateDark)),
              const SizedBox(height: 6),
              Text(
                'Logged in as ${ApiService.instance.currentUser?.fullName ?? 'Vendor'} (+91 ${ApiService.instance.currentUser?.phone ?? '9811122233'})',
                style: const TextStyle(fontSize: 13, color: AppTheme.slateMuted),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB45309)),
                  label: const Text('Continue to Vendor Hub'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VendorMainNav()),
                    ).then((_) => setState(() {}));
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.login_rounded, size: 16, color: Color(0xFFB45309)),
                  label: const Text('Login Again / Switch Vendor', style: TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFB45309))),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ApiService.instance.logout();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthScreen(role: 'VENDOR')),
                    ).then((_) => setState(() {}));
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen(role: 'VENDOR')),
      ).then((_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerLoggedIn = ApiService.instance.isCustomerLoggedIn;
    final vendorLoggedIn = ApiService.instance.isVendorLoggedIn;
    final currentUser = ApiService.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  // App Brand Logo
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.weddingGold, AppTheme.primaryCrimson],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryCrimson.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'श',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Shaadi Setu',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.slateDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Complete Wedding & Event Services Marketplace',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.slateMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Customer Portal Card
                  _buildRoleCard(
                    context,
                    title: 'Customer Experience',
                    subtitle: customerLoggedIn
                        ? 'Logged in as ${currentUser?.fullName ?? 'Rahul Sharma'}. Tap to open options or Login Again.'
                        : 'Sign in with phone number first to access verified vendors, packages & bookings.',
                    badge: customerLoggedIn ? 'Logged In ✓' : 'Login Required',
                    actionLabel: customerLoggedIn ? 'Options' : 'Login First',
                    icon: Icons.favorite_rounded,
                    color: AppTheme.primaryCrimson,
                    onTap: _openCustomerFlow,
                    onLoginAgain: () {
                      ApiService.instance.logout();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthScreen(role: 'CUSTOMER')),
                      ).then((_) => setState(() {}));
                    },
                    onLogout: customerLoggedIn
                        ? () {
                            setState(() {
                              ApiService.instance.logout();
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Vendor Portal Card
                  _buildRoleCard(
                    context,
                    title: 'Vendor Partner Ecosystem',
                    subtitle: vendorLoggedIn
                        ? 'Logged in as ${currentUser?.fullName ?? 'Vendor'}. Tap to open options or Login Again.'
                        : 'Sign in with merchant phone number first to manage bookings, catalog & calendar.',
                    badge: vendorLoggedIn ? 'Verified Partner ✓' : 'Login Required',
                    actionLabel: vendorLoggedIn ? 'Options' : 'Login First',
                    icon: Icons.storefront_rounded,
                    color: const Color(0xFFB45309),
                    onTap: _openVendorFlow,
                    onLoginAgain: () {
                      ApiService.instance.logout();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthScreen(role: 'VENDOR')),
                      ).then((_) => setState(() {}));
                    },
                    onLogout: vendorLoggedIn
                        ? () {
                            setState(() {
                              ApiService.instance.logout();
                            });
                          }
                        : null,
                  ),

                  const SizedBox(height: 36),

                  // Direct Quick Login Again Buttons
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.login_rounded, size: 16),
                        label: const Text('Customer Login Again'),
                        onPressed: () {
                          ApiService.instance.logout();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthScreen(role: 'CUSTOMER'),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.store_rounded, size: 16),
                        label: const Text('Vendor Login Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB45309),
                        ),
                        onPressed: () {
                          ApiService.instance.logout();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthScreen(role: 'VENDOR'),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
    required String actionLabel,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    VoidCallback? onLoginAgain,
    VoidCallback? onLogout,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.slateDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.slateMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFCBD5E1)),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onLoginAgain != null) ...[
                  TextButton.icon(
                    onPressed: onLoginAgain,
                    icon: Icon(Icons.login_rounded, size: 14, color: color),
                    label: Text('Login Again', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (onLogout != null) ...[
                  TextButton.icon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout_rounded, size: 14, color: Colors.red),
                    label: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w700)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
