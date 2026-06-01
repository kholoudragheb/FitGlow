import 'package:flutter/material.dart';
import 'package:fit_app/Onboarding_Screen/onboarding_screen1.dart';
import 'package:fit_app/utils/token_storage.dart';
import 'package:fit_app/services/coach_service.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _breathController;
  late AnimationController _outroController;

  late Animation<double> _glowOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  late Animation<double> _breathScale;
  late Animation<double> _glowRadius;

  late Animation<double> _outroScale;
  late Animation<double> _outroOpacity;

  @override
  void initState() {
    super.initState();

    // 1. Intro Controller (Smooth wakeup from Native Splash)
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 2. Breath Controller (Continuous subtle floating/glowing)
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 3. Outro Controller (Cinematic dive-in fade out)
    _outroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Intro Animations (Logo is already at 1.0x scale and 1.0 opacity matching Native Splash perfectly)
    _glowOpacity = Tween<double>(begin: 0.0, end: 0.45).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.0, 0.8, curve: Curves.easeInOut)),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.3, 1.0, curve: Curves.easeIn)),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)),
    );

    // Breath Animations
    _breathScale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    _glowRadius = Tween<double>(begin: 110.0, end: 145.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    // Outro Animations
    _outroScale = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _outroController, curve: Curves.easeInCubic),
    );
    _outroOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _outroController, curve: Curves.easeOut),
    );

    _startChoreography();
  }

  Future<void> _startChoreography() async {
    // Play Intro (Wakeup animation)
    await _introController.forward();

    // Start Breathing loop
    _breathController.repeat(reverse: true);

    // Concurrently hold & check API tokens
    final apiCheckFuture = _checkNavigation();
    final timerFuture = Future.delayed(const Duration(milliseconds: 1600));

    // Wait for both timer and API check
    final results = await Future.wait([apiCheckFuture, timerFuture]);
    final VoidCallback navigateAction = results[0] as VoidCallback;

    if (!mounted) return;

    // Stop breathing, play outro
    _breathController.stop();
    await _outroController.forward();

    if (!mounted) return;
    navigateAction();
  }

  Future<VoidCallback> _checkNavigation() async {
    final token = await TokenStorage.getAccessToken();
    final role = await TokenStorage.getUserRole();

    if (token != null && token.isNotEmpty) {
      if (role == 'Coach') {
        try {
          await CoachService().getMyCoachProfile();
          return () => Navigator.of(context).pushReplacementNamed('/coach-home');
        } catch (e) {
          if (e.toString().contains('Profile not found')) {
            return () => Navigator.of(context).pushReplacementNamed('/coach-info');
          } else {
            return () => Navigator.of(context).pushReplacementNamed('/coach-home');
          }
        }
      } else {
        return () => Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      return () => Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    _breathController.dispose();
    _outroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0C),
      body: AnimatedBuilder(
        animation: Listenable.merge([_introController, _breathController, _outroController]),
        builder: (context, child) {
          // Initial scale is 1.0 (matching native splash), modified by breath and outro
          final currentScale = _breathScale.value * _outroScale.value;
          final currentOpacity = _outroOpacity.value;

          return Opacity(
            opacity: currentOpacity,
            child: Stack(
              children: [
                // Background animated radial glow
                Center(
                  child: Container(
                    width: _glowRadius.value * 2.5,
                    height: _glowRadius.value * 2.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFD0FD3E).withValues(alpha: _glowOpacity.value),
                          const Color(0xFFD0FD3E).withValues(alpha: _glowOpacity.value * 0.5),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Main Content (Logo + Tagline)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo (starts exactly where Native Splash left off)
                      Transform.scale(
                        scale: currentScale,
                        child: Image.asset(
                          'assets/splash_logo.png',
                          width: 170,
                          height: 170,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Premium Tagline
                      Opacity(
                        opacity: _textOpacity.value,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Column(
                            children: [
                              Text(
                                'FIT GLOW',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 6.0,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'ELEVATE YOUR POTENTIAL',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 4.0,
                                  color: const Color(0xFFD0FD3E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
