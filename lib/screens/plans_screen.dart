import 'package:fit_app/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'checkout_screen.dart'; // We will implement this next

class PlansScreen extends StatefulWidget {
  final Map<String, dynamic> coachData;

  const PlansScreen({super.key, required this.coachData});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  int _selectedPlanIndex = 0; // 0 for 1 month, 1 for 2 months, 2 for 3 months

  final List<Map<String, dynamic>> _plans = [
    {
      'name': '1 Month Plan',
      'priceId': 'monthly',
      'price': '500 EGP',
      'rawPrice': 500.0,
      'duration': '/1 Month',
      'isRecommended': false,
      'features': [
        'real feedback',
        'Master body control & form',
        'Correct your moves step by step',
        'Grow stronger with weekly guidance',
      ],
    },
    {
      'name': '2 Months Plan',
      'priceId': 'bi-monthly',
      'price': '950 EGP',
      'rawPrice': 950.0,
      'duration': '/2 Months',
      'isRecommended': false,
      'features': [
        'real feedback',
        'Master body control & form',
        'Correct your moves step by step',
        'Grow stronger with weekly guidance',
      ],
    },
    {
      'name': '3 Months Plan',
      'priceId': 'quarterly',
      'price': '1350 EGP',
      'rawPrice': 1350.0,
      'duration': '/3 Months',
      'isRecommended': true,
      'features': [
        'real feedback',
        'Master body control & form',
        'Correct your moves step by step',
        'Grow stronger with weekly guidance',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
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
          "Plans",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFFF0F0F0),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              const Center(
                child: Text(
                  "Choose Your plan",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Color(0xFFF0F0F0),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(_plans.length, (index) {
                return _buildPlanCard(index);
              }),
              const SizedBox(height: 100), // Space for bottom button
            ],
          ),

          // Bottom CTA Button
          Positioned(
            bottom: 32, // Safe area distance
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(
                      coachData: widget.coachData,
                      selectedPlan: _plans[_selectedPlanIndex],
                    ),
                  ),
                );
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Continue to payment",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF0C0C0C),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(int index) {
    final isSelected = _selectedPlanIndex == index;
    final plan = _plans[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent, // Figma shows it's transparent or same as background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : const Color(0xFF5C5C5C),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppConstants.primaryColor.withValues(alpha: 0.25), // Adjusted opacity from reference .5 to .25 for softness/matching the visual more closely overall
                    blurRadius: 12,
                    offset: const Offset(0, 0),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan['price'],
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: isSelected ? AppConstants.primaryColor : const Color(0xFFD0FD3E), // Always green in Figma actually, let's keep it green
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 4),
                      child: Text(
                        plan['duration'],
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFFF0F0F0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...List.generate(plan['features'].length, (fIndex) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check,
                          color: AppConstants.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            plan['features'][fIndex],
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Color(0xFFF0F0F0),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            if (plan['isRecommended'])
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    "Recommended",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
