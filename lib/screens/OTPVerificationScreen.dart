import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fit_app/services/otp_service.dart';
import 'package:fit_app/services/auth_service.dart';
import 'package:fit_app/models/verify_otp_model.dart';
import 'package:fit_app/models/forgot_password_model.dart';
import 'package:fit_app/models/send_otp_model.dart';
import 'package:fit_app/models/onboarding_data.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  final AuthService _authService = AuthService();
  final OtpService _otpService = OtpService();

  String? _email;
  String? _role;   // Passed from SignUpScreen for registration mode

  /// 'registration' = email verification after sign-up.
  /// 'forgot-password' = password reset OTP (default).
  String _mode = 'forgot-password';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _email = args['email'] as String?;
      _mode  = (args['mode']  as String?) ?? 'forgot-password';
      _role  = (args['role']  as String?) ?? 'Customer';
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
    } else {
      if (index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleVerifyNext() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      _showSnackBar('Please enter the 6-digit OTP.', Colors.red);
      return;
    }
    if (_email == null || _email!.isEmpty) {
      _showSnackBar('Email not found. Please start again.', Colors.red);
      return;
    }

    if (_mode == 'registration') {
      // ─── Registration Email Verification ──────────────────────────────────
      setState(() => _isVerifying = true);
      print('[OTPScreen] Verifying registration OTP. Email: $_email, OTP: $otp');

      final response = await _otpService.verifyOtp(
        VerifyOtpRequest(email: _email!, otp: otp),
      );

      print('[OTPScreen] VerifyOtp result: ${response.isSuccess} | ${response.message}');

      if (!mounted) return;
      setState(() => _isVerifying = false);

      if (response.isSuccess) {
        _showSnackBar('Email verified! Setting up your profile...', Colors.green);
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;

        // Navigate to the correct onboarding screen based on role.
        // Use pushNamedAndRemoveUntil so the user cannot go back to OTP/login.
        final isCoach = _role == 'Coach';
        if (isCoach) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/coach-info',
            (route) => false,
          );
        } else {
          // Client — start 7-step onboarding with a fresh OnboardingData object
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/build-your-profile',
            (route) => false,
            arguments: {'onboardingData': OnboardingData()},
          );
        }
      } else {
        _showSnackBar(response.message ?? 'Invalid OTP. Please try again.', Colors.red);
      }
    } else {
      // ─── Forgot-password flow: go to create-new-password ─────────────────
      Navigator.pushNamed(
        context,
        '/create-new-password',
        arguments: {'email': _email, 'otp': otp},
      );
    }
  }

  Future<void> _handleResend() async {
    if (_email == null || _email!.isEmpty) {
      _showSnackBar('Email not found. Please start again.', Colors.red);
      return;
    }

    setState(() => _isResending = true);

    if (_mode == 'registration') {
      final response = await _otpService.sendOtp(SendOtpRequest(email: _email!));
      if (!mounted) return;
      setState(() => _isResending = false);
      _showSnackBar(
        response.isSuccess
            ? 'Verification code resent. Check your inbox.'
            : (response.message ?? 'Failed to resend code.'),
        response.isSuccess ? Colors.green : Colors.red,
      );
    } else {
      final response = await _authService.forgotPassword(ForgotPasswordRequest(email: _email!));
      if (!mounted) return;
      setState(() => _isResending = false);
      _showSnackBar(
        response.isSuccess
            ? (response.message ?? 'Code resent successfully.')
            : (response.message ?? 'Failed to resend code.'),
        response.isSuccess ? Colors.green : Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRegistration = _mode == 'registration';
    final subtitle = isRegistration
        ? 'We sent a verification code to your email. Enter it below to activate your account.'
        : 'Enter the verification code we just sent on your email address.';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                isRegistration ? 'Email Verification' : 'OTP Verification',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
              ),
              if (_email != null) ...[
                const SizedBox(height: 8),
                Text(
                  _email!,
                  style: const TextStyle(
                    color: Color(0xFFCDFF00),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 40),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) => _onDigitEntered(index, value),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: const Color(0xFF1C1C1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCBFB5E), width: 1.5),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Resend Code
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Didn't receive the code? ", style: TextStyle(color: Colors.grey)),
                    _isResending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(color: Color(0xFFCDFF00), strokeWidth: 2),
                          )
                        : GestureDetector(
                            onTap: _isResending ? null : _handleResend,
                            child: const Text(
                              'Resend',
                              style: TextStyle(color: Color(0xFFCDFF00), fontWeight: FontWeight.bold),
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _handleVerifyNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCDFF00),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                        )
                      : Text(
                          isRegistration ? 'Verify Email' : 'Verify',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
