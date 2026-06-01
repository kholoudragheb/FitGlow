import 'package:fit_app/core/constants.dart';
import 'package:fit_app/screens/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/subscription_plan_model.dart';
import '../services/subscription_service.dart';

class SubscriptionScreen extends StatefulWidget {
  final Map<String, dynamic>? coachData;

  const SubscriptionScreen({super.key, this.coachData});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _subscriptionService = SubscriptionService();
  int? selectedPlanIndex;
  
  bool _isLoading = true;
  String? _errorMessage;
  List<SubscriptionPlan> _plans = [];

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final plans = await _subscriptionService.getPlans();
      if (mounted) {
        setState(() {
          _plans = plans;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text("Plans", style: AppConstants.headlineMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppConstants.iconBack,
            colorFilter: const ColorFilter.mode(AppConstants.textPrimary, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: AppConstants.defaultPadding,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.orangeAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              "Failed to load plans",
              style: AppConstants.headlineMedium.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppConstants.bodyMedium.copyWith(color: const Color(0xFF72777A)),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _fetchPlans,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(200, 50),
              ),
              child: const Text(
                "Retry",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      );
    }

    if (_plans.isEmpty) {
      return Center(
        child: Text(
          "No subscription plans are currently available.",
          style: AppConstants.bodyMedium.copyWith(color: AppConstants.textSecondary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "Choose Your plan",
            style: AppConstants.headlineMedium.copyWith(fontSize: 20),
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.separated(
            itemCount: _plans.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildPlanCard(index, _plans[index]);
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedPlanIndex != null
                ? () {
                    final selectedPlan = _plans[selectedPlanIndex!];
                    // Create formatted Map for legacy CheckoutScreen structure
                    final mappedPlan = {
                      "price": "${selectedPlan.price.toInt()} EGP",
                      "rawPrice": selectedPlan.price,
                      "duration": "/${selectedPlan.interval}",
                      "features": selectedPlan.features,
                      "isRecommended": selectedPlan.isRecommended,
                      "name": selectedPlan.name,
                      "priceId": selectedPlan.priceId,
                    };
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                          coachData: widget.coachData ?? {'name': 'Coach'},
                          selectedPlan: mappedPlan,
                        ),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              disabledBackgroundColor: AppConstants.surfaceColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              "Continue",
              style: AppConstants.buttonText.copyWith(
                color: selectedPlanIndex != null ? Colors.black : AppConstants.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(int index, SubscriptionPlan plan) {
    final isSelected = selectedPlanIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlanIndex = index;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppConstants.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              border: Border.all(
                color: isSelected ? AppConstants.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: AppConstants.bodyMedium.copyWith(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "${plan.price.toInt()} EGP",
                      style: AppConstants.headlineLarge.copyWith(
                        color: AppConstants.textPrimary,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text("/\${plan.interval}", style: AppConstants.bodyMedium),
                  ],
                ),
                const SizedBox(height: 16),
                ...plan.features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppConstants.iconDoubleCheck,
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(AppConstants.primaryColor, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: AppConstants.bodyMedium.copyWith(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (plan.isRecommended)
            Positioned(
              top: 0,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  "Recommended",
                  style: AppConstants.bodyMedium.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
