import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fit_app/screens/ai_chat_screen.dart';
// Removed old screen imports
// Removed old screen imports
// Removed old store_screen.dart import to avoid conflict
import 'package:fit_app/screens/profile/profile_main_screen.dart';
import 'package:fit_app/screens/coaches_list_screen.dart';
import 'package:fit_app/screens/notification_screen.dart';
import 'package:fit_app/screens/message_list_screen.dart';
import 'package:fit_app/screens/workout/WorkoutsLibraryScreen.dart';
import 'package:fit_app/screens/nutrition/NutritionLibraryScreen.dart';
import 'package:fit_app/screens/store/StoreScreen.dart';
import '../core/constants.dart';
import '../utils/store_styles.dart';
import 'package:fit_app/services/user_service.dart';
import 'package:fit_app/models/user_model.dart';
import 'package:fit_app/screens/coach_details_screen.dart';
import 'package:fit_app/logic/cubits/progress_log/progress_stats_cubit.dart';
import 'package:fit_app/screens/client/LogMetricsScreen.dart';
import 'package:fit_app/services/progress_log_service.dart';
import 'package:fit_app/models/my_coach_model.dart';
import 'package:fit_app/models/coach_model.dart';
import 'package:fit_app/services/coach_service.dart';
import 'package:fit_app/screens/client/MyCoachScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/cubits/active_plan/active_plan_cubit.dart';
import '../widgets/ActivePlanCard.dart';
import '../services/plan_service.dart';
import 'coach/plans/PlanDetailsScreen.dart';
import 'client/CreateProgressLogScreen.dart';
import 'client/MyProgressLogsScreen.dart';
import 'client/GoalsScreen.dart';
import '../widgets/StatsDashboard.dart';
import '../logic/cubits/chat/unread_count_cubit.dart';
import '../utils/image_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0;

  final List<Widget> _screens = [
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ActivePlanCubit(PlanService())..fetchActivePlan()),
        BlocProvider(create: (context) => ProgressStatsCubit(ProgressLogService())..fetchStats()),
      ],
      child: const HomeTab(),
    ),
    const WorkoutsLibraryScreen(),
    const NutritionLibraryScreen(),
    const StoreScreen(),
    const ClientProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF111111,
      ), // Very dark grey/black background
      body: IndexedStack(index: _bottomNavIndex, children: _screens),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF1A1A1A),
          selectedItemColor: StoreColors.primary,
          unselectedItemColor: const Color(0xFF9E9E9E),
          currentIndex: _bottomNavIndex,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          onTap: (index) {
            print("Button clicked: Bottom Nav Index $index");
            setState(() {
              _bottomNavIndex = index;
            });
          },
          items: [
            _buildNavItem(
              AppConstants.navHome,
              AppConstants.navHomeFilled,
              'Home',
              0,
            ),
            _buildNavItem(
              AppConstants.navWorkout,
              AppConstants.navWorkoutFilled,
              'Workout',
              1,
            ),
            _buildNavItem(
              AppConstants.navNutrition,
              AppConstants.navNutritionFilled,
              'Nutrition',
              2,
            ),
            _buildNavItem(
              AppConstants.navStore,
              AppConstants.navStoreFilled,
              'Store',
              3,
            ),
            _buildNavItem(
              AppConstants.navProfile,
              AppConstants.navProfileFilled,
              'Profile',
              4,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    String icon,
    String activeIcon,
    String label,
    int index,
  ) {
    final bool isSelected = _bottomNavIndex == index;
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: BlocBuilder<UnreadCountCubit, UnreadCountState>(
          builder: (context, state) {
            final int count = state is UnreadCountSuccess ? state.count : 0;
            // Assuming index 1 or 2 is chat? No, wait, looking at nav items...
            // It seems Chat is not in the bottom nav yet? Let's check items.
            return Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  icon,
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    isSelected ? StoreColors.primary : const Color(0xFF9E9E9E),
                    BlendMode.srcIn,
                  ),
                ),
                if (label == 'Chat' && count > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: _buildBadge(count),
                  ),
              ],
            );
          },
        ),
      ),
      label: label,
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: StoreColors.red,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  UserModel? _userProfile;
  MyCoachModel? _myCoach;
  List<Coach> _coaches = [];
  bool _isLoading = true;
  bool _isCoachLoading = true;
  bool _isCoachesLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchMyCoach();
    _fetchCoaches();
    // No need to fetch active plan here if using BlocProvider outside, 
    // but I'll add it to the build or provider.
  }

  Future<void> _fetchCoaches() async {
    try {
      final coachService = CoachService();
      final coaches = await coachService.getCoaches();
      if (mounted) {
        setState(() {
          _coaches = coaches;
          _isCoachesLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching coaches: $e');
      if (mounted) {
        setState(() {
          _isCoachesLoading = false;
        });
      }
    }
  }

  Future<void> _fetchMyCoach() async {
    try {
      final coachService = CoachService();
      final coach = await coachService.getMyCoach();
      if (mounted) {
        setState(() {
          _myCoach = coach;
          _isCoachLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching my coach: $e');
      if (mounted) {
        setState(() {
          _isCoachLoading = false;
        });
      }
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final userService = UserService();
      final profile = await userService.getProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  final List<CarouselItem> _sliderData = [
    CarouselItem(
      title: 'Train Smarter, Not Harder.',
      description:
          'An AI-powered training plan tailored specifically to your body and goals, evolving with you every day.',
      buttonText: 'Start Your AI Plan',
      image: 'lib/assets/images/home/ai_robot_home.png',
      imageWidth: 120, // Reduced to fit beautifully
      imageBottom: 10, // Sticks to bottom of card
      imageRight: 0,
    ),
    CarouselItem(
      title: 'Real Experts. Real Accountability.',
      description:
          'Connect with elite trainers to perfect your form, stay motivated, and push past your limits.',
      buttonText: 'Find Your Coach',
      image: 'lib/assets/images/home/coach_banner.png',
      imageWidth: 110,
      imageBottom: 0,
      imageRight: 0,
    ),
    CarouselItem(
      title: 'Our Store Completes Your Journey.',
      description:
          'Everything you need to successfully complete your workout. Top-quality supplements and equipment.',
      buttonText: 'Shop Now',
      image: 'lib/assets/images/home/store_banner.png',
      imageWidth: 130,
      imageBottom: 10,
      imageRight: -10,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          'lib/assets/images/profile/user_avatar.png',
                        ),
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLoading
                              ? "Welcome..."
                              : "Welcome, ${_userProfile?.firstName ?? 'User'}",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Are you ready for a workout today?",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      print("Button clicked: Chat Icon");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MessageListScreen(),
                        ),
                      );
                    },
                    child: BlocBuilder<UnreadCountCubit, UnreadCountState>(
                      builder: (context, state) {
                        final count = state is UnreadCountSuccess ? state.count : 0;
                        return _buildHeaderIconBtn(
                          AppConstants.iconChat,
                          hasNotification: count > 0,
                          unreadCount: count,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      print("Button clicked: Notification Icon");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                    child: _buildHeaderIconBtn(
                      AppConstants.iconNotification,
                      hasNotification: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Carousel Slider Banner
            // We give it extra height to allow the image to overflow the card bounds vertically
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _sliderData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildSliderCard(_sliderData[index]),
                  );
                },
              ),
            ),

            const SizedBox(height: 4),

            // Exact Page Indicators (Pills below the banner)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _sliderData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? StoreColors.primary
                        : Colors.grey[700], // Grey dots for inactive
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Active Plan Section
            _buildActivePlanSection(),

            const SizedBox(height: 32),

            // Insights/Stats Section
            _buildStatsSection(),

            const SizedBox(height: 32),

            // Quick Log Activities
            _buildQuickLogSection(),

            const SizedBox(height: 32),

            // My Coach Section
            _buildMyCoachSection(),

            const SizedBox(height: 32),

            // Coaches Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Coaches",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("Button clicked: View All Coaches");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CoachesListScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "View all",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey[500],
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Coaches Horizontal List matching Figma layout
            if (_isCoachesLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(child: CircularProgressIndicator(color: StoreColors.primary)),
              )
            else if (_coaches.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "No coaches available.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _coaches.map((coach) => _buildCoachCard(coach)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderCard(CarouselItem data) {
    return GestureDetector(
      onTap: () {
        print("Card clicked: Carousel - ${data.buttonText}");
        if (data.buttonText == 'Start Your AI Plan') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AIChatScreen()),
          );
        } else if (data.buttonText == 'Find Your Coach') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CoachesListScreen()),
          );
        } else if (data.buttonText == 'Shop Now') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StoreScreen()),
          );
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The green card background
          Container(
            height: double.infinity,
            width: double.infinity,
            margin: const EdgeInsets.only(top: 24, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4E602A),
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                top: 20,
                bottom: 20,
                right: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.description,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Button positioned accurately at the bottom right
          Positioned(
            bottom: 24,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                print("Button clicked: Carousel - ${data.buttonText}");
                if (data.buttonText == 'Start Your AI Plan') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AIChatScreen(),
                    ),
                  );
                } else if (data.buttonText == 'Find Your Coach') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CoachesListScreen(),
                    ),
                  );
                } else if (data.buttonText == 'Shop Now') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StoreScreen(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: StoreColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                elevation: 0,
                minimumSize: const Size(0, 30),
              ),
              child: Text(
                data.buttonText,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ),

          // Image positioned absolutely to overflow the card (top right)
          // PLACED ABOVE THE BUTTON to prevent overlap (foa al zorar msh 3aleh)
          Positioned(
            right: data.imageRight,
            bottom:
                64, // Button is at bottom 24 + height ~30 = top 54. So bottom 64 clears the button entirely!
            width: data.imageWidth,
            child: IgnorePointer(
              // Add IgnorePointer so the button underneath is clickable
              child: Image.asset(
                data.image,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachCard(Coach coach) {
    final String name = "${coach.firstName} ${coach.lastName}".trim();
    final String specialty = coach.specialties.isNotEmpty ? coach.specialties.first : "Coach";
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoachDetailsScreen(
              coachId: coach.id,
            ),
          ),
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Darker gray exactly like Figma
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF2C2C2C), width: 1.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: ImageUtils.coachDecorationImage(
                    url: coach.avatarUrl,
                    coachId: coach.id,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB800),
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      "4.5",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              specialty,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey[500],
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  "Starting from ",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Text(
                  "0 EGP", // Fallback for price
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: StoreColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIconBtn(String iconPath, {bool hasNotification = false, int unreadCount = 0}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SvgPicture.asset(
          iconPath,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          width: 24,
          height: 24,
        ),
        if (hasNotification)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: StoreColors.red,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF111111),
                  width: 1.5,
                ),
              ),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: unreadCount > 0 
                ? Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                : null,
            ),
          ),
      ],
    );
  }

  Widget _buildActivePlanSection() {
    return BlocBuilder<ActivePlanCubit, ActivePlanState>(
      builder: (context, state) {
        if (state is ActivePlanLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Active Plan",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(child: CircularProgressIndicator(color: StoreColors.primary)),
                ),
              ],
            ),
          );
        }

        if (state is ActivePlanSuccess && state.plan != null) {
          final plan = state.plan!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Active Plan",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ActivePlanCard(
                  plan: plan,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlanDetailsScreen(planId: plan.id),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }

        // Error or No Plan state
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Active Plan",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.assignment_outlined, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "No active plan assigned",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Your coach will assign one soon.",
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyCoachSection() {
    if (_isCoachLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(child: CircularProgressIndicator(color: StoreColors.primary)),
        ),
      );
    }

    if (_myCoach == null) {
      return const SizedBox.shrink(); // Hide if no coach
    }

    final coach = _myCoach!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Coach",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyCoachScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: StoreColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: ImageUtils.coachDecorationImage(
                        url: coach.imageUrl,
                        coachId: coach.id,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coach.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          coach.specialties.isNotEmpty ? coach.specialties.first : 'Elite Coach',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: StoreColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLogSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Quick Log",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyProgressLogsScreen()),
                ),
                child: const Text(
                  "History",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: StoreColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildLogChip("Workout", Icons.fitness_center, 'workout'),
                const SizedBox(width: 12),
                _buildLogChip("Meal", Icons.restaurant, 'meal'),
                const SizedBox(width: 12),
                _buildLogChip("Metrics", Icons.monitor_weight, 'metrics'),
                const SizedBox(width: 12),
                _buildLogChip("Goal", Icons.track_changes, 'goal'),
                const SizedBox(width: 12),
                _buildLogChip("Cardio", Icons.directions_run, 'cardio'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return BlocBuilder<ProgressStatsCubit, ProgressStatsState>(
      builder: (context, state) {
        if (state is ProgressStatsLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppConstants.surfaceColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(child: CircularProgressIndicator(color: StoreColors.primary)),
            ),
          );
        }

        if (state is ProgressStatsSuccess) {
          return StatsDashboard(stats: state.stats);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLogChip(String label, IconData icon, String type) {
    return GestureDetector(
      onTap: () {
        if (type == 'metrics') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LogMetricsScreen()),
          );
        } else if (type == 'goal') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GoalsScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateProgressLogScreen(initialType: type)),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: StoreColors.primary, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class CarouselItem {
  final String title;
  final String description;
  final String buttonText;
  final String image;
  final double imageWidth;
  final double imageBottom;
  final double imageRight;

  CarouselItem({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.image,
    required this.imageWidth,
    required this.imageBottom,
    required this.imageRight,
  });
}
