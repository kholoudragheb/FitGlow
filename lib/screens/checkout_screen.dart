import 'package:fit_app/core/constants.dart';
import 'package:fit_app/providers/subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/subscription_service.dart';
import '../services/user_service.dart';
import '../services/promo_code_service.dart';
import '../logic/cubits/promo/promo_code_cubit.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> coachData;
  final Map<String, dynamic> selectedPlan;

  const CheckoutScreen({
    super.key,
    required this.coachData,
    required this.selectedPlan,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentMethod = 0; // 0 = Visa, 1 = PayPal, 2 = Apple Pay
  
  bool _isLoading = false;
  final SubscriptionService _subService = SubscriptionService();
  final UserService _userService = UserService();
  final TextEditingController _promoController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _processSubscription() async {
    if (_isLoading) return;

    // Basic validation
    if (_cardNumberController.text.isEmpty || 
        _cardHolderController.text.isEmpty || 
        _expiryController.text.isEmpty || 
        _cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all card details"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String planId = widget.selectedPlan['priceId'] ?? widget.selectedPlan['id'] ?? widget.selectedPlan['name']?.toString().toLowerCase().replaceAll(' ', '_') ?? 'pro';
    final String coachId = widget.coachData['_id'] ?? widget.coachData['id'] ?? 'unknown_coach';

    try {
      await _subService.checkout(planId: planId, coachId: coachId);
      await _subService.confirmSubscription(planId: planId, coachId: coachId);
      
      // Optimistically update the global subscription state, then verify
      if (mounted) {
        final subProvider = context.read<SubscriptionProvider>();
        subProvider.markActive();
        subProvider.refresh(); // fire-and-forget to sync with backend
      }

      try {
        await _userService.getProfile();
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Subscription activated 🎉"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PromoCodeCubit(PromoCodeService()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFF181818),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: SvgPicture.asset(
                  AppConstants.iconBack,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                "Checkout",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Color(0xFFF0F0F0),
                ),
              ),
              centerTitle: true,
            ),
            body: BlocBuilder<PromoCodeCubit, PromoCodeState>(
              builder: (context, promoState) {
                final basePrice = (widget.selectedPlan['rawPrice'] as num?)?.toDouble() ?? 500.0;
                final tax = 10.0;
                double discount = 0.0;
                String finalPriceLabel = "${(basePrice + tax).toInt()} EGP";

                if (promoState is PromoCodeValid) {
                  discount = basePrice - promoState.promo.finalPrice;
                  finalPriceLabel = "${(promoState.promo.finalPrice + tax).toInt()} EGP";
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 24,
                    bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subscription Summary Header
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF5C5C5C), width: 1),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(35),
                              child: Image.asset(
                                widget.coachData['image'] ?? 'lib/assets/images/checkout/8e55570584acfecd5cee3ad6b4469bfe0b4cca31.png',
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.person, color: Colors.white54),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Subscription with",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Color(0xFF5C5C5C),
                                    ),
                                  ),
                                  Text(
                                    widget.coachData['name'] ?? "Alex Johnson",
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Color(0xFFF0F0F0),
                                    ),
                                  ),
                                  Text(
                                    widget.selectedPlan['price'] ?? "${basePrice.toInt()} EGP",
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppConstants.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Choose Payment method
                      const Text(
                        "Choose Payment method",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Color(0xFFF0F0F0),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Payment Methods Row
                      Row(
                        children: [
                          _buildPaymentMethodButton(0, "Visa"),
                          const SizedBox(width: 16),
                          _buildPaymentMethodButton(1, "Pay Pal"),
                          const SizedBox(width: 16),
                          _buildPaymentMethodButton(2, " Pay"),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Mock Card Image
                      Center(
                        child: Image.asset(
                          'lib/assets/images/checkout/46bd94c33071c4e27c3ad1f4aa139f47f48961e7.png',
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Form Fields
                      _buildInputField("Card Number", "1234 1234 1234 1234", controller: _cardNumberController, keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildInputField("Card Holder Name", "Enter card holder name", controller: _cardHolderController, keyboardType: TextInputType.name),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildInputField("Expiry Date", "MM / YY", controller: _expiryController, keyboardType: TextInputType.datetime)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildInputField("CVV", "123", controller: _cvvController, keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Discount Code
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: TextFormField(
                                    controller: _promoController,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Color(0xFFF0F0F0),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Enter discount code",
                                      hintStyle: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Color(0xFF5C5C5C),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                      filled: true,
                                      fillColor: const Color(0xFF181818),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: promoState is PromoCodeValid 
                                              ? Colors.green.withValues(alpha: 0.5) 
                                              : (promoState is PromoCodeInvalid ? Colors.red.withValues(alpha: 0.5) : const Color(0xFF5C5C5C)),
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: promoState is PromoCodeValid ? Colors.green : AppConstants.primaryColor,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: promoState is PromoCodeLoading 
                                    ? null 
                                    : () => context.read<PromoCodeCubit>().validateCode(_promoController.text),
                                child: Container(
                                  height: 44,
                                  width: 85,
                                  decoration: BoxDecoration(
                                    color: promoState is PromoCodeValid ? Colors.green : AppConstants.primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      if (promoState is PromoCodeValid)
                                        BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 8)
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: promoState is PromoCodeLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                                        )
                                      : Text(
                                          promoState is PromoCodeValid ? "Applied" : "Apply",
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color(0xFF0C0C0C),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          if (promoState is PromoCodeValid || promoState is PromoCodeInvalid || promoState is PromoCodeError)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 4),
                              child: Text(
                                promoState is PromoCodeValid 
                                    ? "Promo code applied successfully!" 
                                    : (promoState is PromoCodeInvalid ? promoState.message : (promoState as PromoCodeError).message),
                                style: TextStyle(
                                  color: promoState is PromoCodeValid ? Colors.green : Colors.redAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Totals
                      _buildTotalRow("Subtotal:", "${basePrice.toInt()} EGP", isBold: false),
                      const SizedBox(height: 8),
                      if (discount > 0) ...[
                        _buildTotalRow("Discount:", "-\${discount.toInt()} EGP", isBold: false, valueColor: Colors.greenAccent),
                        const SizedBox(height: 8),
                      ],
                      _buildTotalRow("Tax:", "10 EGP", isBold: false),
                      const SizedBox(height: 8),
                      _buildTotalRow("Total", finalPriceLabel, isBold: true),
                      const SizedBox(height: 32),

                      // Bottom CTA
                      GestureDetector(
                        onTap: _processSubscription,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: _isLoading ? AppConstants.surfaceColor : AppConstants.primaryColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if (!_isLoading)
                                BoxShadow(color: AppConstants.primaryColor.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))
                            ],
                          ),
                          alignment: Alignment.center,
                          child: _isLoading 
                          ? const SizedBox(
                              width: 24, 
                              height: 24, 
                              child: CircularProgressIndicator(color: AppConstants.primaryColor, strokeWidth: 2),
                            )
                          : Text(
                              "Subscribe - $finalPriceLabel",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _isLoading ? Colors.white54 : const Color(0xFF0C0C0C),
                              ),
                            ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
      ),
    );
  }

  Widget _buildPaymentMethodButton(int index, String label) {
    final isSelected = _selectedPaymentMethod == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : const Color(0xFF5C5C5C),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppConstants.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 0),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 16,
            color: const Color(0xFFF0F0F0),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, {required TextEditingController controller, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Color(0xFFF0F0F0),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFFF0F0F0),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF545454),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              filled: true,
              fillColor: const Color(0xFF181818),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF6D6D6D), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppConstants.primaryColor, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value, {required bool isBold, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
            fontSize: 14,
            color: isBold ? const Color(0xFFF0F0F0) : const Color(0xFF5C5C5C),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
            color: valueColor ?? const Color(0xFFF0F0F0),
          ),
        ),
      ],
    );
  }
}
