import 'package:fit_app/core/constants.dart';
import 'package:fit_app/screens/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MentorProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? coachData;

  const MentorProfileScreen({super.key, this.coachData});

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen> {
  // ... (existing variable declaration)
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Default data if none provided (for testing or fallback)
    final data = widget.coachData ?? {
      "name": "Alex Johnson",
      "title": "Senior Fitness Trainer",
      "rating": "4.6",
      "price": "500 EGP",
    };

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header Image
              SliverAppBar(
                expandedHeight: 400.0,
                floating: false,
                pinned: true,
                backgroundColor: AppConstants.backgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'lib/assets/images/coach_alex.jpg', // Alex Johnson photo from Figma
                        fit: BoxFit.cover,
                      ),
                      // Gradient Overlay for text readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppConstants.backgroundColor.withValues(alpha: 0.8),
                              AppConstants.backgroundColor,
                            ],
                            stops: const [0.6, 0.9, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset(AppConstants.iconBack, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: AppConstants.defaultPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Title
                      Text(
                        data['name'] ?? "Coach Name",
                        style: AppConstants.headlineLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['title'] ?? "Fitness Trainer",
                        style: AppConstants.bodyMedium.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatCard("Experience", "8 Years"), // Keep static for now or add to data
                          _buildStatCard("Clients", "35+"),
                          _buildStatCard("Reviews", "${data['rating']} (120)"),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Bio Section
                      Row(
                        children: [
                          Text("About ${data['name'].split(" ")[0]}", style: AppConstants.headlineMedium),
                          const SizedBox(width: 20),
                          Text("Reviews", style: AppConstants.headlineMedium.copyWith(color: Colors.grey, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AnimatedCrossFade(
                        firstChild: Text(
                          "Lorem ipsum dolor sit amet consectetur. Hac aliquam metus morbi nisi fringilla vitae adipiscing faucibus in.",
                          style: AppConstants.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondChild: Text(
                          "Lorem ipsum dolor sit amet consectetur. Hac aliquam metus morbi nisi fringilla vitae adipiscing faucibus in. This is a placeholder for the full bio text from the design.",
                          style: AppConstants.bodyMedium,
                        ),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Text(
                          isExpanded ? "Read Less" : "Read More",
                          style: AppConstants.bodyMedium.copyWith(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Text("Certificates", style: AppConstants.headlineMedium),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 140,
                            height: 100,
                             decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(child: Icon(Icons.workspace_premium, color: Colors.white24, size: 40)),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 140,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                            ),
                             child: const Center(child: Icon(Icons.workspace_premium, color: Colors.white24, size: 40)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubscriptionScreen(coachData: data),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultRadius,
                    ),
                  ),
                ),
                child: Text("Book a Session", style: AppConstants.buttonText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppConstants.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppConstants.bodyMedium.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}
