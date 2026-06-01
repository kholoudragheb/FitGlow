import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fit_app/screens/login_screen.dart';
import 'package:fit_app/models/auth_models.dart';
import 'package:fit_app/services/auth_api_service.dart';
import 'package:fit_app/utils/token_storage.dart';

class SignUpScreen extends StatefulWidget {
  final String? role;
  const SignUpScreen({super.key, this.role});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  String? _selectedRole;
  final AuthApiService _authApiService = AuthApiService();

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.role ?? 'Client';
    if (!['Client', 'Coach'].contains(_selectedRole)) {
      _selectedRole = 'Client';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
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
                        height: 160,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'lib/assets/images/auth/auth_background.jpg',
                            ),
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
                          const SizedBox(height: 20),
                          // FG Logo - Letters stacked vertically
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'F',
                                  style: TextStyle(
                                    fontSize: 32,
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
                                      fontSize: 32,
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
                          const SizedBox(height: 14),
                          // Create Account Title
                          const Center(
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Subtitle
                          const Center(
                            child: Text(
                              'Create a new account to get started',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Role Selector Label
                          const Text(
                            'Role',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Role Selector Dropdown
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedRole,
                                isExpanded: true,
                                dropdownColor: const Color(0xFF1A1A1A),
                                icon: FaIcon(
                                  FontAwesomeIcons.chevronDown,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  size: 14,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Client',
                                    child: Text('Client'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Coach',
                                    child: Text('Coach'),
                                  ),
                                ],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    if (newValue != null) {
                                      _selectedRole = newValue;
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // First Name Label
                          const Text(
                            'First Name',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // First Name TextField
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
                              controller: _firstNameController,
                              focusNode: _firstNameFocusNode,
                              enabled: !_isLoading,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your first name',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                              ),
                              keyboardType: TextInputType.name,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Last Name Label
                          const Text(
                            'Last Name',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Last Name TextField
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
                              controller: _lastNameController,
                              focusNode: _lastNameFocusNode,
                              enabled: !_isLoading,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your last name',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                              ),
                              keyboardType: TextInputType.name,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Email Label
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 12,
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
                              focusNode: _emailFocusNode,
                              enabled: !_isLoading,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Password Label
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 12,
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
                              focusNode: _passwordFocusNode,
                              enabled: !_isLoading,
                              obscureText: !_isPasswordVisible,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                                suffixIcon: IconButton(
                                  icon: FaIcon(
                                    _isPasswordVisible
                                        ? FontAwesomeIcons.eye
                                        : FontAwesomeIcons.eyeSlash,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    size: 14,
                                  ),
                                  onPressed: () {
                                    print(
                                      "Button clicked: Toggle Password Visibility",
                                    );
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Confirm Password Label
                          const Text(
                            'Confirm Password',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Confirm Password TextField
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
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocusNode,
                              enabled: !_isLoading,
                              obscureText: !_isConfirmPasswordVisible,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                                suffixIcon: IconButton(
                                  icon: FaIcon(
                                    _isConfirmPasswordVisible
                                        ? FontAwesomeIcons.eye
                                        : FontAwesomeIcons.eyeSlash,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    size: 14,
                                  ),
                                  onPressed: () {
                                    print(
                                      "Button clicked: Toggle Confirm Password Visibility",
                                    );
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Terms and Conditions Checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToTerms = value ?? false;
                                    });
                                  },
                                  fillColor:
                                      WidgetStateProperty.resolveWith<Color>((
                                        Set<WidgetState> states,
                                      ) {
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
                              Expanded(
                                child: Wrap(
                                  children: [
                                    Text(
                                      'I agree to the terms of ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        // Navigate to service terms
                                      },
                                      child: const Text(
                                        'service',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFCDFF00),
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xFFCDFF00),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      ' and ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        // Navigate to privacy policy
                                      },
                                      child: const Text(
                                        'privacy policy',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFCDFF00),
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xFFCDFF00),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      print("Button clicked: Sign Up");
                                      // Basic validation
                                      if (_firstNameController.text
                                              .trim()
                                              .isEmpty ||
                                          _lastNameController.text
                                              .trim()
                                              .isEmpty ||
                                          _emailController.text
                                              .trim()
                                              .isEmpty ||
                                          _passwordController.text
                                              .trim()
                                              .isEmpty ||
                                          _confirmPasswordController.text
                                              .trim()
                                              .isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please fill all fields.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (_passwordController.text !=
                                          _confirmPasswordController.text) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Passwords do not match.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (!_agreeToTerms) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please agree to the terms and privacy policy.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      setState(() {
                                        _isLoading = true;
                                      });

                                      final request = RegisterRequest(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text
                                            .trim(),
                                        firstName: _firstNameController.text
                                            .trim(),
                                        lastName: _lastNameController.text
                                            .trim(),
                                        role: _selectedRole ?? 'Customer',
                                      );

                                      final response = await _authApiService
                                          .register(request);

                                      if (!context.mounted) return;
                                      
                                      setState(() {
                                        _isLoading = false;
                                      });

                                      if (response.isSuccess) {
                                        // Auto-login to fetch tokens
                                        final loginRequest = LoginRequest(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text.trim(),
                                        );
                                        
                                        final loginResponse = await _authApiService.login(loginRequest);

                                        if (loginResponse.isSuccess && loginResponse.accessToken != null) {
                                          await TokenStorage.saveTokensAndUser(
                                            accessToken: loginResponse.accessToken!,
                                            refreshToken: loginResponse.refreshToken ?? '',
                                            role: loginResponse.user?.role ?? _selectedRole ?? 'Client',
                                            email: loginResponse.user?.email ?? '',
                                            firstName: loginResponse.user?.firstName ?? '',
                                            lastName: loginResponse.user?.lastName ?? '',
                                            userId: loginResponse.user?.id ?? '',
                                          );
                                          
                                          print("Token saved:");
                                          print(loginResponse.accessToken);
                                          print("Auth state:");
                                          print("isLoggedIn: true");
                                        } else {
                                          print("Auth state:");
                                          print("isLoggedIn: false (Auto-login failed)");
                                        }

                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Registration successful!',
                                            ),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 4),
                                          ),
                                        );

                                        // Bypass OTP verification and route based on role
                                        if (_selectedRole == 'Coach') {
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/coach-info',
                                            (route) => false,
                                          );
                                        } else {
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/build-your-profile',
                                            (route) => false,
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              response.message ??
                                                  'Registration failed.',
                                            ),
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
                                      'Sign Up',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Or sign up with Divider
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
                                  horizontal: 10,
                                ),
                                child: Text(
                                  'Or sign up with',
                                  style: TextStyle(
                                    fontSize: 11,
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
                          const SizedBox(height: 16),
                          // Social Login Buttons
                          // Facebook Button
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const FaIcon(
                                FontAwesomeIcons.facebookF,
                                color: Colors.blueAccent,
                                size: 14,
                              ),
                              label: const Text(
                                'Continue with Facebook',
                                style: TextStyle(
                                  fontSize: 12,
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
                            height: 40,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                print("Button clicked: Continue with Google");
                              },
                              icon: const FaIcon(
                                FontAwesomeIcons.google,

                                size: 14,
                              ),
                              label: const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 12,
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
                            height: 40,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                print("Button clicked: Continue with Apple");
                              },
                              icon: const FaIcon(
                                FontAwesomeIcons.apple,
                                color: Colors.grey,
                                size: 16,
                              ),
                              label: const Text(
                                'Continue with Apple',
                                style: TextStyle(
                                  fontSize: 12,
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
                          const SizedBox(height: 18),
                          // Login Link
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    print("Button clicked: Login from SignUp");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LoginScreen(role: widget.role),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 11,
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
      ),
    );
  }
}
