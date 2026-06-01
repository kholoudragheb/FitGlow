import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fit_app/screens/SignUpScreen.dart';
import 'package:fit_app/models/auth_models.dart';
import 'package:fit_app/services/auth_api_service.dart';
import 'package:fit_app/utils/token_storage.dart';

class LoginScreen extends StatefulWidget {
  final String? role;
  const LoginScreen({super.key, this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  final AuthApiService _authService = AuthApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Stack(
                children: [
                  // Background Image
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('lib/assets/images/auth/auth_background.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              const Color(0xFF1A1A1A),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 35),
                        // FG Logo - Letters stacked vertically
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'F',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFCDFF00),
                                  height: 0.8,
                                  letterSpacing: 0,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(8, -10),
                                child: Text(
                                  'G',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFCDFF00),
                                    height: 0.8,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        // Login Title
                        const Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Welcome Back
                        const Center(
                          child: Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Email Label
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Email TextField
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _emailController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Password Label
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Password TextField
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),
                              suffixIcon: IconButton(
                                icon: FaIcon(
                                  _isPasswordVisible
                                      ? FontAwesomeIcons.eye
                                      : FontAwesomeIcons.eyeSlash,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  size: 16,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Remember Me & Forgot Password Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Remember Me Checkbox
                            Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    fillColor:
                                        WidgetStateProperty.resolveWith<
                                          Color
                                        >((Set<WidgetState> states) {
                                          if (states.contains(
                                            WidgetState.selected,
                                          )) {
                                            return const Color(0xFFCDFF00);
                                          }
                                          return Colors.transparent;
                                        }),
                                    checkColor: Colors.black,
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Remember Me',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            // Forgot Password
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/forgot-password',
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFCDFF00),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    final email = _emailController.text.trim();
                                    final password = _passwordController.text.trim();

                                    if (email.isEmpty || password.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please enter both email and password.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      _isLoading = true;
                                    });

                                    final request = LoginRequest(
                                      email: email,
                                      password: password,
                                    );

                                    final response = await _authService.login(request);

                                    if (!mounted) return;

                                    setState(() {
                                      _isLoading = false;
                                    });

                                    if (response.isSuccess) {
                                      // Save Token Strategy
                                      if (response.accessToken != null) {
                                        await TokenStorage.saveTokensAndUser(
                                          accessToken: response.accessToken!,
                                          refreshToken: response.refreshToken ?? '',
                                          role: response.user?.role ?? widget.role ?? 'Client',
                                          email: response.user?.email ?? '',
                                          firstName: response.user?.firstName ?? '',
                                          lastName: response.user?.lastName ?? '',
                                          userId: response.user?.id ?? '',
                                        );
                                      }

                                      if (!mounted) return;

                                      // Handle Navigation Check based on API result
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Login successful! Welcome.'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      
                                      final userRole = response.user?.role ?? widget.role;

                                      // Go directly to Home — no onboarding detour on login
                                      final String nextRoute =
                                          (userRole == 'Coach') ? '/coach-home' : '/home';

                                      Navigator.pushReplacementNamed(context, nextRoute);

                                    } else if (response.isEmailUnverified) {
                                      // Email not verified — redirect to OTP verification screen
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please verify your email first. Check your inbox for the OTP code.'),
                                          backgroundColor: Colors.orange,
                                          duration: Duration(seconds: 4),
                                        ),
                                      );
                                      if (!mounted) return;
                                      Navigator.pushNamed(
                                        context,
                                        '/otp-verification',
                                        arguments: {
                                          'email': email,
                                          'mode': 'registration',
                                        },
                                      );
                                    } else {
                                      // Handle detailed and generic Error states
                                      final errorMsg = response.statusCode == 401
                                          ? 'Invalid email or password. Please check your credentials.'
                                          : (response.message ?? 'Login failed. Please try again.');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(errorMsg),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCDFF00),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const Spacer(),
                        // Or login with Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white.withValues(alpha: 0.2),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'Or login with',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white.withValues(alpha: 0.2),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Social Login Buttons
                        // Facebook Button
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const FaIcon(
                              FontAwesomeIcons.facebookF,
                              color: Colors.blueAccent,
                              size: 16,
                            ),
                            label: const Text(
                              'Continue with Facebook',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Google Button
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const FaIcon(
                              FontAwesomeIcons.google,

                              size: 16,
                            ),
                            label: const Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Apple Button
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const FaIcon(
                              FontAwesomeIcons.apple,
                              color: Colors.grey,
                              size: 18,
                            ),
                            label: const Text(
                              'Continue with Apple',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Sign Up Link
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SignUpScreen(role: widget.role)),
                                  );
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFCDFF00),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
