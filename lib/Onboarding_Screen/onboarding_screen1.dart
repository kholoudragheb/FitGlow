import 'package:fit_app/screens/RoleScreen.dart';

import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      image: 'lib/assets/images/onboarding/onboarding_robot.jpg',
      title: 'AI-Powered Coach',
      description:
          'Personalized workouts, nutrition advice, and progress tracking powered by intelligent technology.',
      buttonText: 'Next',
    ),
    OnboardingData(
      image: 'lib/assets/images/onboarding/onboarding_equipment.jpg',
      title: 'Expert Human Coaches',
      description:
          'Connect with certified personal trainers for one-on-one sessions, customized guidance, and the motivation you need to reach your goals.',
      buttonText: 'Next',
    ),
    OnboardingData(
      image: 'lib/assets/images/onboarding/onboarding_supplements.png',
      title: 'Gear and Supplements\nin One Place',
      description:
          'Shop carefully selected products that power your workouts and support your fitness journey.',
      buttonText: 'Get Started',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return OnboardingPage(
                data: _pages[index],
                onNextPressed: _nextPage,
                currentPage: _currentPage,
                totalPages: _pages.length,
              );
            },
          ),
          // Skip button
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RoleScreen()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Skip',
                      style: TextStyle(
                        color: const Color(0xFFCDFF00),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: const Color(0xFFCDFF00),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final String title;
  final String description;
  final String buttonText;

  OnboardingData({
    required this.image,
    required this.title,
    required this.description,
    required this.buttonText,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final VoidCallback onNextPressed;
  final int currentPage;
  final int totalPages;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.onNextPressed,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Background Image - Full Screen
        Positioned.fill(
          child: Image.asset(
            data.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF1A1A1A),
                child: Center(
                  child: Icon(
                    Icons.fitness_center,
                    size: 100,
                    color: Colors.grey[800],
                  ),
                ),
              );
            },
          ),
        ),
        // Dark Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.95),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(),
                // Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width < 360 ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: size.width < 360 ? 14 : 15,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Bottom Row with Indicators and Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page Indicators
                    Row(
                      children: List.generate(
                        totalPages,
                        (index) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: currentPage == index ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: currentPage == index
                                ? const Color(0xFFCDFF00)
                                : Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    // Next/Get Started Button
                    ElevatedButton(
                      onPressed: onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCDFF00),
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width < 360 ? 32 : 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        data.buttonText,
                        style: TextStyle(
                          fontSize: size.width < 360 ? 15 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
