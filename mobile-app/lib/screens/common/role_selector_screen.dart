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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CustomerMainNav()),
      ).then((_) => setState(() {}));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen(role: 'CUSTOMER')),
      ).then((_) => setState(() {}));
    }
  }

  void _openVendorFlow() {
    if (ApiService.instance.isVendorLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VendorMainNav()),
      ).then((_) => setState(() {}));
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
                        ? 'Logged in as ${currentUser?.fullName ?? 'Rahul'}. Tap to enter Customer Home Page.'
                        : 'Sign in with phone number first to access verified vendors, packages & bookings.',
                    badge: customerLoggedIn ? 'Logged In ✓' : 'Login Required',
                    actionLabel: customerLoggedIn ? 'Open Home Page' : 'Login First',
                    icon: Icons.favorite_rounded,
                    color: AppTheme.primaryCrimson,
                    onTap: _openCustomerFlow,
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
                        ? 'Logged in as ${currentUser?.fullName ?? 'Vendor'}. Tap to enter Vendor Hub.'
                        : 'Sign in with merchant phone number first to manage bookings, catalog & calendar.',
                    badge: vendorLoggedIn ? 'Verified Partner ✓' : 'Login Required',
                    actionLabel: vendorLoggedIn ? 'Open Vendor Hub' : 'Login First',
                    icon: Icons.storefront_rounded,
                    color: const Color(0xFFB45309),
                    onTap: _openVendorFlow,
                    onLogout: vendorLoggedIn
                        ? () {
                            setState(() {
                              ApiService.instance.logout();
                            });
                          }
                        : null,
                  ),

                  const SizedBox(height: 36),

                  // Direct Quick Sign In Buttons
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.login_rounded, size: 16),
                        label: const Text('Customer Login'),
                        onPressed: () {
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
                        label: const Text('Vendor Login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB45309),
                        ),
                        onPressed: () {
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
            if (onLogout != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
              ),
            ],
          ],
        ),
      ),
    );
  }
}
