import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/verify_otp_model.dart';
import '../services/otp_service.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String? initialEmail;

  const VerifyOtpScreen({super.key, this.initialEmail});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  
  bool _isLoading = false;
  final OtpService _otpService = OtpService();

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _emailFocusNode.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _handleVerifyOtp() async {
    print("Button clicked: Verify OTP");
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (email.isEmpty || otp.isEmpty) {
      _showError('Please enter both email and OTP.');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email address.');
      return;
    }

    if (otp.length != 6 || int.tryParse(otp) == null) {
      _showError('OTP must be a 6-digit number.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final request = VerifyOtpRequest(email: email, otp: otp);
    final response = await _otpService.verifyOtp(request);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'OTP verified successfully.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Navigate to Reset Password Screen or Complete Registration
      // Navigator.pushReplacementNamed(context, '/reset-password', arguments: {'email': email, 'otp': otp});
      
    } else {
      _showError(response.message ?? 'Invalid OTP. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Verify OTP', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              const Icon(
                Icons.security_outlined,
                size: 80,
                color: Color(0xFFCDFF00),
              ),
              const SizedBox(height: 24),
              const Text(
                'Enter OTP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please enter the 6-digit code sent to your email.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 40),
              
              // Email Field
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
                  readOnly: false,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 16),

              // OTP Field
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
                  controller: _otpController,
                  focusNode: _otpFocusNode,
                  enabled: !_isLoading,
                  readOnly: false,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 24, 
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '......',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      letterSpacing: 8,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Verify Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCDFF00),
                    foregroundColor: Colors.black,
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
                          'Verify',
                          style: TextStyle(
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
      ),
      ),
    );
  }
}
