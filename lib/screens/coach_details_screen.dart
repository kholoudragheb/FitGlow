import 'package:fit_app/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/coach_details_model.dart';
import '../services/coach_service.dart';
import 'plans_screen.dart';
import '../features/rate_coach/presentation/screens/rate_coach_screen.dart';
import 'client/SendCoachRequestScreen.dart';
import 'client/CoachAvailabilityScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/cubits/chat/start_conversation_cubit.dart';
import '../widgets/StartConversationModal.dart';
import '../utils/image_utils.dart';

class CoachDetailsScreen extends StatefulWidget {
  final String coachId;

  const CoachDetailsScreen({super.key, required this.coachId});

  @override
  State<CoachDetailsScreen> createState() => _CoachDetailsScreenState();
}

class _CoachDetailsScreenState extends State<CoachDetailsScreen> {
  int _selectedTabIndex = 0;
  final CoachService _coachService = CoachService();
  CoachDetailsModel? coachData;
  bool isLoading = true;
  String? errorMessage;
  bool _requestPending = false;

  @override
  void initState() {
    super.initState();
    _fetchCoachDetails();
  }

  Future<void> _fetchCoachDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _coachService.getCoachById(widget.coachId);
      setState(() {
        coachData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().contains('not found') 
            ? 'Coach profile not found' 
            : 'Failed to load coach profile';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF181818),
        body: Center(
          child: CircularProgressIndicator(color: AppConstants.primaryColor),
        ),
      );
    }

    if (errorMessage != null || coachData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF181818),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? 'Coach profile not found',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFFF0F0F0),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchCoachDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final String coachName = (coachData!.firstName != null && coachData!.lastName != null)
        ? '${coachData!.firstName} ${coachData!.lastName}'
        : 'Coach';
    
    final String coachTitle = coachData!.specialties.isNotEmpty 
        ? coachData!.specialties.first 
        : 'Professional Coach';

    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: Stack(
        children: [
          // Background Image Section (top image)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 270, // Slightly taller to allow overlap
            child: ImageUtils.coachImage(
              url: coachData!.avatarUrl,
              coachId: coachData!.id,
              width: double.infinity,
              height: 270,
              fit: BoxFit.cover,
            ),
          ),

          // Back Button Overlay
          Positioned(
            top: 56,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.transparent, // Or a slightly tinted color if needed
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppConstants.iconBack,
                    width: 20, // size from figma or constants
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ),

          // Rate Coach Button Overlay
          Positioned(
            top: 56,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RateCoachScreen(coachId: widget.coachId, coachName: coachName),
                  ),
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rate, color: Color(0xFFD0FD3E), size: 20),
              ),
            ),
          ),

          // Message Coach Button Overlay
          Positioned(
            top: 56,
            right: 60,
            child: GestureDetector(
              onTap: () {
                context.read<StartConversationCubit>().reset();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => StartConversationModal(
                    recipientId: coachData?.userId.isNotEmpty == true ? coachData!.userId : widget.coachId,
                    recipientName: coachName,
                  ),
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
              ),
            ),
          ),

          // Main scrolling content
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(top: 200), // Overlaps the image
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   // Overlapping Info Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222222),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5C5C5C).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                coachName,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: Color(0xFFF0F0F0),
                                  height: 1.2,
                                ),
                              ),
                            ),
                            if (coachData!.isVerified)
                              const Icon(Icons.verified, color: Colors.blue, size: 20),
                            if (coachData!.isActive) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          coachTitle,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        if (coachData!.specialties.isNotEmpty) ...[
                           const SizedBox(height: 12),
                           Wrap(
                             spacing: 6,
                             runSpacing: 6,
                             children: coachData!.specialties.map((s) => Container(
                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                               decoration: BoxDecoration(
                                 color: const Color(0xFF333333),
                                 borderRadius: BorderRadius.circular(6),
                               ),
                               child: Text(
                                 s,
                                 style: const TextStyle(
                                   fontFamily: 'Poppins',
                                   fontSize: 12,
                                   color: Color(0xFFCECECE),
                                 ),
                               ),
                             )).toList(),
                           ),
                        ],
                        const SizedBox(height: 24),
                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem("lib/assets/icons/shared/bookmark.svg", "${coachData!.experienceYears} Yrs", "Experience", isIcon: true, iconData: Icons.workspace_premium_outlined), 
                            _buildVerticalDivider(),
                            _buildStatItem("", "${coachData!.totalReviews}", "Reviews", isIcon: true, iconData: Icons.people_outline), 
                            _buildVerticalDivider(),
                            _buildStatItem(AppConstants.iconStar, coachData!.averageRating.toStringAsFixed(1), "Rating", isIcon: true, iconData: Icons.star),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Tabs Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _selectedTabIndex = 0),
                          child: Container(
                            color: Colors.transparent, // expand gesture area
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              "About",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: _selectedTabIndex == 0 ? FontWeight.w500 : FontWeight.w400,
                                color: _selectedTabIndex == 0 ? AppConstants.primaryColor : const Color(0xFF5C5C5C),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _selectedTabIndex = 1),
                          child: Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              "Reviews",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: _selectedTabIndex == 1 ? FontWeight.w500 : FontWeight.w400,
                                color: _selectedTabIndex == 1 ? AppConstants.primaryColor : const Color(0xFF5C5C5C),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tab Indicator Line
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      children: [
                        Container(
                          height: 1,
                          color: const Color(0xFF5C5C5C).withValues(alpha: 0.5),
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final tabWidth = constraints.maxWidth / 2;
                            return AnimatedPositioned(
                              duration: const Duration(milliseconds: 200),
                              left: _selectedTabIndex == 0 ? 0 : tabWidth,
                              child: Container(
                                height: 1.5, // slightly thicker line
                                width: tabWidth,
                                color: AppConstants.primaryColor,
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tab Content
                  if (_selectedTabIndex == 0) _buildAboutTab()
                  else _buildReviewsTab(),

                  const SizedBox(height: 120), // Padding to avoid overlap with bottom button
                ],
              ),
            ),
          ),

          // Sticky Bottom CTA Buttons
          Positioned(
            bottom: 32, // Safe area distance
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _requestPending ? null : () async {
                      final bool? success = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SendCoachRequestScreen(
                            coachId: coachData?.userId.isNotEmpty == true ? coachData!.userId : widget.coachId,
                            coachName: coachName,
                          ),
                        ),
                      );
                      if (success == true && mounted) {
                        setState(() {
                          _requestPending = true;
                        });
                      }
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: _requestPending ? Colors.transparent : Colors.transparent,
                        border: Border.all(
                          color: _requestPending ? const Color(0xFF5C5C5C) : AppConstants.primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _requestPending ? "Request Pending" : "Request Coach",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _requestPending ? const Color(0xFF5C5C5C) : AppConstants.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlansScreen(coachData: {'name': coachName}),
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
                        "Subscribe Coach",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF0C0C0C),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 48,
      width: 1,
      color: const Color(0xFF5C5C5C).withValues(alpha: 0.4),
    );
  }

  Widget _buildStatItem(String pathOrIcon, String value, String label, {bool isIcon = false, IconData? iconData}) {
    return Column(
      children: [
        if (isIcon && iconData != null)
          Icon(iconData, size: 24, color: AppConstants.primaryColor)
        else
          SvgPicture.asset(pathOrIcon, width: 24, height: 24, colorFilter: const ColorFilter.mode(AppConstants.primaryColor, BlendMode.srcIn)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Color(0xFFF0F0F0),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Color(0xFF5C5C5C),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutTab() {
    final String coachName = (coachData!.firstName != null && coachData!.lastName != null)
        ? '${coachData!.firstName} ${coachData!.lastName}'
        : 'Coach';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About $coachName",
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFFF0F0F0),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            coachData!.bio.isNotEmpty ? coachData!.bio : "No biography available.",
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Color(0xFFAEAEAE),
            ),
          ),
          const SizedBox(height: 24),
          if (coachData!.certifications.isNotEmpty) ...[
            const Text(
              "Certificates",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFFF0F0F0),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: coachData!.certifications.map((cert) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF5C5C5C).withValues(alpha: 0.5),
                    width: 1,
                  ),
                  color: const Color(0xFF222222),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.workspace_premium, color: AppConstants.primaryColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      cert,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFFF0F0F0),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CoachAvailabilityScreen(
                    coachData: {
                      '_id': widget.coachId,
                      'name': coachName,
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.calendar_month, color: Colors.black),
            label: const Text('View Coach Availability'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateImage(String path) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF5C5C5C).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7), // Slightly less than container to fit inside border
        child: Image.asset(
          path,
          width: 146,
          height: 107,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 146,
            height: 107,
            color: Colors.grey[800],
            child: const Icon(Icons.image, color: Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        "Reviews will appear here.",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
