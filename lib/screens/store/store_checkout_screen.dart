import 'package:flutter/material.dart';
import 'package:fit_app/utils/store_styles.dart';

class StoreCheckoutScreen extends StatefulWidget {
  const StoreCheckoutScreen({super.key});

  @override
  State<StoreCheckoutScreen> createState() => _StoreCheckoutScreenState();
}

class _StoreCheckoutScreenState extends State<StoreCheckoutScreen> {
  int _currentStep = 0; // 0: Address, 1: Payment, 2: Complete

  // Address form controllers (matching Figma fields exactly)
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _stateCtrl = TextEditingController(text: 'Cairo');
  final _addressCtrl = TextEditingController();

  // Payment
  int _selectedPayment = 0; // 0: Visa, 1: PayPal, 2: Mobile Wallet, 3: Cash

  // Card details
  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _stateCtrl.dispose();
    _addressCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoreColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_currentStep < 3) ...[
              const SizedBox(height: 8),
              _buildStepIndicator(),
            ],
            Expanded(
              child: _buildStepContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_currentStep == 3) {
                // From completed, go back to store
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else if (_currentStep > 0) {
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: StoreColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: StoreColors.border),
              ),
              child: const Center(
                child: Icon(Icons.arrow_back_ios_new, color: StoreColors.textWhite, size: 16),
              ),
            ),
          ),
          Expanded(
            child: Text(
              _currentStep == 3 ? '' : 'Checkout',
              style: StoreTextStyles.title,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Address', 'Payment', 'Completed'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          final isLast = index == steps.length - 1;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive ? StoreColors.primary : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive ? StoreColors.primary : StoreColors.border,
                        ),
                      ),
                      child: Center(
                        child: isActive && index < _currentStep
                            ? const Icon(Icons.check, size: 14, color: StoreColors.textBlack)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? StoreColors.textBlack : StoreColors.textGrey,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isActive ? StoreColors.primary : StoreColors.textGrey,
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      color: index < _currentStep ? StoreColors.primary : StoreColors.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildAddressStep();
      case 1:
        return _buildPaymentStep();
      case 2:
        return _buildCardStep();
      case 3:
        return _buildCompletedStep();
      default:
        return const SizedBox();
    }
  }

  // ─── STEP 1: ADDRESS ─────────────────────────

  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Billing details',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: StoreColors.textWhite,
            ),
          ),
          const SizedBox(height: 16),
          _buildField('First name', _firstNameCtrl, hint: 'Enter your first name'),
          const SizedBox(height: 16),
          _buildField('Last name', _lastNameCtrl, hint: 'Enter your last name'),
          const SizedBox(height: 16),
          _buildField('Phone number', _phoneCtrl, hint: 'Enter your phone number'),
          const SizedBox(height: 16),
          _buildStateField(),
          const SizedBox(height: 16),
          _buildField('Address', _addressCtrl, hint: 'Enter your address'),
          const SizedBox(height: 24),
          // Divider
          const Divider(color: StoreColors.border, height: 1),
          const SizedBox(height: 24),
          // Order summary
          _buildOrderSummary(),
          const SizedBox(height: 24),
          // Next button
          _buildNextButton('Next', () => setState(() => _currentStep = 1)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'State',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: StoreColors.textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: StoreColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF6D6D6D)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Cairo',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF545454),
                  ),
                ),
              ),
              Transform.rotate(
                angle: 3.14159, // 180 degrees - rotated up-arrow = down arrow
                child: const Icon(
                  Icons.arrow_drop_up,
                  color: StoreColors.textGrey,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: StoreColors.textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: StoreColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF6D6D6D)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: StoreColors.textWhite,
            ),
            decoration: InputDecoration(
              hintText: hint ?? 'Enter $label',
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF545454),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      children: [
        _summaryRow('Subtotal', '150 EGP'),
        const SizedBox(height: 8),
        _summaryRow('Shipping', '80 EGP'),
        const SizedBox(height: 16),
        _summaryRow('Total', '230 EGP', isTotal: true),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: StoreColors.textWhite,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: StoreColors.textWhite,
          ),
        ),
      ],
    );
  }

  // ─── STEP 2: PAYMENT METHOD ──────────────────

  Widget _buildPaymentStep() {
    final methods = [
      'Visa / Mastercard',
      'PayPal',
      'Mobile Wallet ',
      'Cash on delivery ',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose your payment method',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: StoreColors.textWhite,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(methods.length, (index) {
            final isSelected = _selectedPayment == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedPayment = index),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    // Radio circle matching Figma mdi:checkbox-blank-circle-outline
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? StoreColors.primary : StoreColors.textWhite,
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: StoreColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      methods[index],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: StoreColors.textWhite,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 40),
          _buildNextButton('Next', () => setState(() => _currentStep = 2)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── STEP 3: CARD DETAILS ────────────────────

  Widget _buildCardStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Paymob card image from Figma (imgImage16)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'lib/assets/images/store/paymob_card.png',
                width: 278,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildCardVisual(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildField('Card Number ', _cardNumberCtrl, hint: '1234 1234 1234 1234'),
          const SizedBox(height: 16),
          _buildField('Card Holder Name', _cardNameCtrl, hint: 'Enter card holder name'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildField('Expiry Date', _expiryCtrl, hint: 'MM / YY')),
              const SizedBox(width: 16),
              Expanded(child: _buildField('CVV', _cvvCtrl, hint: '123')),
            ],
          ),
          const SizedBox(height: 24),
          _buildNextButton('Pay 500 EGP', () => setState(() => _currentStep = 3)),
        ],
      ),
    );
  }

  Widget _buildCardVisual() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2D4A3E), Color(0xFF1A2F28)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chip + Paymob
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const Text(
                'paymob',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: StoreColors.primary,
                ),
              ),
            ],
          ),
          // Card number dots
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CARD NUMBER',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: StoreColors.primary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(4, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      children: List.generate(4, (_) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: StoreColors.primary,
                          shape: BoxShape.circle,
                        ),
                      )),
                    ),
                  );
                }),
              ),
            ],
          ),
          // Card name + Valid thru
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARD NAME',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: StoreColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  const Text(
                    'Enter Name',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: StoreColors.textWhite,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VALID THRU',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: StoreColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  const Text(
                    'MM/YY',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: StoreColors.textWhite,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── STEP 4: COMPLETED ───────────────────────

  Widget _buildCompletedStep() {
    return Column(
      children: [
        const Spacer(),
        // Successmark — 100×100 matching Figma
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: StoreColors.primary,
          ),
          child: const Center(
            child: Icon(Icons.check, color: StoreColors.textBlack, size: 56),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Payment process completed',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: StoreColors.textWhite,
          ),
        ),
        const Spacer(),
        // Continue shopping button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Container(
              width: 343,
              height: 48,
              decoration: BoxDecoration(
                color: StoreColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Continue shopping', style: StoreTextStyles.button),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ─── SHARED ──────────────────────────────────

  Widget _buildNextButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 343,
        height: 48,
        decoration: BoxDecoration(
          color: StoreColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label, style: StoreTextStyles.button),
        ),
      ),
    );
  }
}
