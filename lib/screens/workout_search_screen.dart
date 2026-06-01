import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants.dart';
import 'workout_filter_screen.dart';

class WorkoutSearchScreen extends StatefulWidget {
  const WorkoutSearchScreen({super.key});

  @override
  State<WorkoutSearchScreen> createState() => _WorkoutSearchScreenState();
}

class _WorkoutSearchScreenState extends State<WorkoutSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock search history
  final List<String> _searchHistory = ['Full Body', 'Cardio', 'Chest'];

  // Top searches
  final List<String> _topSearches = ['Yoga', 'Upper Body', 'Stretching'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _deleteHistoryItem(String item) {
    setState(() {
      _searchHistory.remove(item);
    });
  }

  void _deleteAllHistory() {
    setState(() {
      _searchHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Header with back button and title
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppConstants.iconBack,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balance the back button
                  ],
                ),

                const SizedBox(height: 24),

                // Search Bar with Filter
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppConstants.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppConstants.iconSearch,
                              colorFilter: const ColorFilter.mode(
                                AppConstants.textSecondary,
                                BlendMode.srcIn,
                              ),
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Search workout...',
                                  hintStyle: TextStyle(
                                    color: AppConstants.textSecondary,
                                  ),
                                  border: InputBorder.none,
                                ),
                                autofocus: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WorkoutFilterScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: AppConstants.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(
                            AppConstants.iconFilter,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // History Section
                if (_searchHistory.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: _deleteAllHistory,
                        child: Text(
                          'Delete all',
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_searchHistory.length, (index) {
                    final item = _searchHistory[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: AppConstants.textSecondary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _deleteHistoryItem(item),
                            child: Icon(
                              Icons.close,
                              color: AppConstants.textSecondary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],

                // Top Search Section
                const Text(
                  'Top Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(_topSearches.length, (index) {
                  final item = _topSearches[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: AppConstants.primaryColor,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
