import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fit_app/utils/store_styles.dart';
import 'package:fit_app/services/user_service.dart';
import 'package:fit_app/models/saved_items_model.dart';

class SavedItemsScreen extends StatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  SavedItemsModel? _savedItems;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchSavedItems();
  }

  Future<void> _fetchSavedItems() async {
    try {
      final items = await _userService.getSavedItems();
      if (mounted) {
        setState(() {
          _savedItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('401')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Please log in again.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading saved items: $e')),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoreColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Header
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: SvgPicture.asset(
                        'lib/assets/images/profile/ic_back_arrow_square.svg',
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Saved',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: StoreColors.textWhite,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tab Bar
            _buildTabBar(),
            
            const SizedBox(height: 24),

            // Tab Content
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: StoreColors.primary))
                : TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildWorkoutList(),
                      _buildNutritionList(),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      child: Row(
        children: [
           // Workout Tab (Left)
           Expanded(
             child: GestureDetector(
               onTap: () {
                 setState(() {
                   _tabController.index = 0;
                 });
               },
               child: Container(
                 decoration: BoxDecoration(
                   color: Colors.transparent, 
                   borderRadius: const BorderRadius.only(
                     topLeft: Radius.circular(8),
                     bottomLeft: Radius.circular(8),
                   ),
                   border: Border.all(
                     color: _tabController.index == 0 ? StoreColors.primary : StoreColors.border, 
                     width: _tabController.index == 0 ? 2 : 1
                   ),
                 ),
                 alignment: Alignment.center,
                 child: Text(
                   'Workout',
                   style: TextStyle(
                     fontFamily: 'Poppins',
                     fontWeight: FontWeight.w600,
                     fontSize: 16,
                     color: StoreColors.textWhite,
                   ),
                 ),
               ),
             ),
           ),
           // Nutrition Tab (Right)
           Expanded(
             child: GestureDetector(
               onTap: () {
                  setState(() {
                   _tabController.index = 1;
                 });
               },
               child: Container(
                 decoration: BoxDecoration(
                   color: Colors.transparent,
                   borderRadius: const BorderRadius.only(
                     topRight: Radius.circular(8),
                     bottomRight: Radius.circular(8),
                   ),
                   border: Border.all(
                     color: _tabController.index == 1 ? StoreColors.primary : StoreColors.border, 
                     width: _tabController.index == 1 ? 2 : 1
                   ),
                 ),
                 alignment: Alignment.center,
                 child: Text(
                   'Nutrition',
                   style: TextStyle(
                     fontFamily: 'Poppins',
                     fontWeight: FontWeight.w600,
                     fontSize: 16,
                     color: StoreColors.textWhite,
                   ),
                 ),
               ),
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildWorkoutList() {
    if (_savedItems == null || _savedItems!.savedWorkouts.isEmpty) {
      return const Center(
        child: Text(
          'No saved workouts yet',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: StoreColors.textWhite,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _savedItems!.savedWorkouts.length,
      itemBuilder: (context, index) {
        final item = _savedItems!.savedWorkouts[index];
        return _buildWorkoutCard(
          imagePath: 'lib/assets/images/profile/saved_workout_1.png', // Or item['image'] if exists
          title: item['title'] ?? 'Workout',
          level: item['level'] ?? 'Beginner',
          duration: item['duration'] ?? '15 min',
        );
      },
    );
  }

  Widget _buildNutritionList() {
    if (_savedItems == null || _savedItems!.savedMeals.isEmpty) {
      return const Center(
        child: Text(
          'No saved meals yet',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: StoreColors.textWhite,
            fontSize: 16,
          ),
        ),
      );
    }

     return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _savedItems!.savedMeals.map((item) {
            return _buildNutritionCard(
              imagePath: 'lib/assets/images/profile/saved_nutrition_1.png', // Or item['image']
              title: item['title'] ?? 'Meal',
              calories: item['calories'] ?? '300 Kcal',
              duration: item['duration'] ?? '15 min',
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _buildWorkoutCard({
    required String imagePath,
    required String title,
    required String level,
    required String duration,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: 94,
              height: 79,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: StoreColors.textWhite,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: StoreColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      level,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: StoreColors.textLightGrey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SvgPicture.asset(
                      'lib/assets/images/profile/ic_timer_small.svg',
                      width: 12,
                      height: 12,
                      colorFilter: const ColorFilter.mode(StoreColors.textLightGrey, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: StoreColors.textLightGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard({
    required String imagePath,
    required String title,
    required String calories,
    required String duration,
  }) {
    return Container(
      width: 164, 
      decoration: BoxDecoration(
        color: StoreColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                   decoration: BoxDecoration(
                     color: Colors.white.withValues(alpha: 0.2),
                     shape: BoxShape.circle,
                   ),
                  child: SvgPicture.asset(
                     'lib/assets/images/profile/ic_saved.svg', 
                     width: 16,
                     height: 16,
                     colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: StoreColors.textWhite,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SvgPicture.asset(
                      'lib/assets/images/profile/ic_timer_small.svg',
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(StoreColors.textGrey, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: StoreColors.textGrey,
                      ),
                    ),
                    const SizedBox(width: 12),
                     SvgPicture.asset(
                       'lib/assets/icons/nutrition/icon_fire_small.svg',
                       width: 14,
                       height: 14,
                       colorFilter: const ColorFilter.mode(StoreColors.textGrey, BlendMode.srcIn),
                     ), 
                     const SizedBox(width: 4),
                    Text(
                      calories,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: StoreColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
