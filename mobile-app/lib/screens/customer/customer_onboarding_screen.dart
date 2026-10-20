import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../common/auth_screen.dart';
import 'customer_main_nav.dart';

class CustomerOnboardingScreen extends StatefulWidget {
  const CustomerOnboardingScreen({super.key});

  @override
  State<CustomerOnboardingScreen> createState() => _CustomerOnboardingScreenState();
}

class _CustomerOnboardingScreenState extends State<CustomerOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Discover Top Wedding Vendors',
      'subtitle': 'Verified Candid Photographers, Luxury Vintage Cars, Concert DJs, Mandap Decorators & Baaja in one tap.',
      'icon': 'camera',
    },
    {
      'title': 'Instant Slot Booking & Escrow',
      'subtitle': 'Real-time vendor calendar slot availability. Payments stay safely protected in escrow until your event is fulfilled.',
      'icon': 'shield',
    },
    {
      'title': 'Live Event Tracking & Direct Chat',
      'subtitle': 'Track vendor arrival timelines on wedding day and chat directly with your service coordinators.',
      'icon': 'chat',
    },
  ];

  void _proceedToApp() {
    if (ApiService.instance.isCustomerLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CustomerMainNav()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen(role: 'CUSTOMER')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _proceedToApp,
            child: const Text('SKIP', style: TextStyle(color: AppTheme.slateMuted, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppTheme.lightGold,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.weddingGold.withValues(alpha: 0.3), width: 3),
                          ),
                          child: Icon(
                            index == 0
                                ? Icons.auto_awesome_rounded
                                : index == 1
                                    ? Icons.security_rounded
                                    : Icons.event_available_rounded,
                            size: 68,
                            color: AppTheme.primaryCrimson,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          slide['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.slateDark,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          slide['subtitle']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: AppTheme.slateMuted,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppTheme.primaryCrimson : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Get Started / Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _proceedToApp();
                    }
                  },
                  child: Text(_currentPage == _slides.length - 1 ? 'Get Started (Login)' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
