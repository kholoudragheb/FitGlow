import 'package:fit_app/core/constants.dart';
import 'package:fit_app/screens/coach_details_screen.dart';
import 'package:fit_app/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/coach_model.dart';
import '../services/coach_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/cubits/chat/start_conversation_cubit.dart';
import '../widgets/StartConversationModal.dart';
import '../utils/image_utils.dart';

class CoachesListScreen extends StatefulWidget {
  const CoachesListScreen({super.key});

  @override
  State<CoachesListScreen> createState() => _CoachesListScreenState();
}

class _CoachesListScreenState extends State<CoachesListScreen> {
  final CoachService _coachService = CoachService();
  List<Coach> coaches = [];
  bool isLoading = true;
  String? errorMessage;

  final List<String> specialtyOptions = ["All", "Fitness", "Nutrition", "Yoga", "Pilates", "Crossfit"];
  String selectedSpecialty = "All";
  double minRating = 0.0;
  bool verifiedOnly = false;

  bool showFilters = false;

  @override
  void initState() {
    super.initState();
    _fetchCoaches();
  }

  Future<void> _fetchCoaches() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final fetchedCoaches = await _coachService.getCoaches(
        specialty: selectedSpecialty == 'All' ? null : selectedSpecialty,
        minRating: minRating > 0 ? minRating : null,
        verifiedOnly: verifiedOnly ? true : null,
      );
      setState(() {
        coaches = fetchedCoaches;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load coaches";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: SizedBox(
               width: 32,
               height: 32,
               child: SvgPicture.asset(
                 AppConstants.iconBack,
                 colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
               ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          "Coaches",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFFF0F0F0),
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: Icon(
              showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: AppConstants.primaryColor,
            ),
            onPressed: () {
              setState(() {
                showFilters = !showFilters;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Search Bar
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF5C5C5C)),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AppConstants.iconSearch,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(Color(0xFFF0F0F0), BlendMode.srcIn)
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Find your coach...",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFFF0F0F0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Filter UI
            if (showFilters) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF5C5C5C)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Specialty Dropdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Specialty",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFFF0F0F0),
                            fontSize: 14,
                          ),
                        ),
                        DropdownButton<String>(
                          value: selectedSpecialty,
                          dropdownColor: const Color(0xFF222222),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: AppConstants.primaryColor,
                            fontSize: 14,
                          ),
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down, color: AppConstants.primaryColor),
                          items: specialtyOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedSpecialty = newValue;
                              });
                              _fetchCoaches();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Min Rating Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Min Rating: ${minRating.toStringAsFixed(1)}",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFFF0F0F0),
                            fontSize: 14,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: minRating,
                            min: 0.0,
                            max: 5.0,
                            divisions: 10,
                            activeColor: AppConstants.primaryColor,
                            thumbColor: AppConstants.primaryColor,
                            inactiveColor: const Color(0xFF5C5C5C),
                            onChanged: (value) {
                              setState(() {
                                minRating = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _fetchCoaches();
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    // Verified Only Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Verified Only",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFFF0F0F0),
                            fontSize: 14,
                          ),
                        ),
                        Switch(
                          value: verifiedOnly,
                          activeThumbColor: AppConstants.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              verifiedOnly = value;
                            });
                            _fetchCoaches();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),

            // Coaches List
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppConstants.primaryColor),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFFF0F0F0),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchCoaches,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    if (coaches.isEmpty) {
      return const Center(
        child: Text(
          "No coaches found.",
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF5C5C5C),
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: coaches.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildCoachCard(coaches[index]);
      },
    );
  }

  Widget _buildCoachCard(Coach coach) {
    // Map Coach model to existing structure expected by CoachDetailsScreen
    final mappedCoachData = {
      'name': '${coach.firstName} ${coach.lastName}'.trim(),
      'title': coach.specialties.isNotEmpty ? coach.specialties.first : 'Coach',
      'rating': coach.averageRating.toStringAsFixed(1),
      'price': '0 EGP', // Fallback as not in API
      'image': 'lib/assets/images/coaches/coach_1.jpg', // Fallback for testing, replace with coach.profileImageUrl if added later
      'experienceYears': coach.experienceYears.toString(),
      'bio': coach.bio,
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoachDetailsScreen(coachId: coach.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF5C5C5C)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF333333),
                image: ImageUtils.coachDecorationImage(
                  url: coach.avatarUrl,
                  coachId: coach.id,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          mappedCoachData['name']!, 
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFFF0F0F0),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (coach.isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Icon(Icons.verified, color: Colors.blue, size: 16),
                        ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 204, 0, 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              mappedCoachData['rating']!, 
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xFFCECECE)
                              )
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                context.read<StartConversationCubit>().reset();
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => StartConversationModal(
                                    recipientId: coach.userId.isNotEmpty ? coach.userId : coach.id,
                                    recipientName: mappedCoachData['name']!,
                                  ),
                                );
                              },
                              child: const Icon(Icons.chat_bubble_outline, color: AppConstants.primaryColor, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mappedCoachData['title']!, 
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: AppConstants.primaryColor
                    )
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${coach.experienceYears} Years Experience', 
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF5C5C5C)
                    )
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: coach.specialties.take(3).map((spec) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        spec,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: Color(0xFFAEAEAE),
                        ),
                      ),
                    )).toList(),
                  ),
                  if (coach.bio.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      coach.bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFFCECECE),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
