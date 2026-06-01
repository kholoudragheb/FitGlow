import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../logic/cubits/workout/workouts_cubit.dart';
import '../../../models/workout_model.dart';
import 'WorkoutDetailScreen.dart';

class WorkoutsLibraryScreen extends StatefulWidget {
  const WorkoutsLibraryScreen({super.key});

  @override
  State<WorkoutsLibraryScreen> createState() => _WorkoutsLibraryScreenState();
}

class _WorkoutsLibraryScreenState extends State<WorkoutsLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedDifficulty;
  String? _selectedTag;
  Timer? _debounce;

  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _tags = ['Cardio', 'Strength', 'Yoga', 'HIIT', 'Flexibility', 'Kickboxing', 'Core', 'Abs', 'Full Body'];

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
  }

  void _fetchWorkouts() {
    context.read<WorkoutsCubit>().fetchWorkouts(
      difficulty: _selectedDifficulty,
      tags: _selectedTag,
      search: _searchController.text,
    );
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          "Workout Library",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _fetchWorkouts(),
              color: const Color(0xFFD0FD3E),
              backgroundColor: const Color(0xFF1E1E1E),
              child: BlocBuilder<WorkoutsCubit, WorkoutsState>(
                builder: (context, state) {
                  if (state is WorkoutsLoading) {
                    return _buildShimmerLoading();
                  } else if (state is WorkoutsError) {
                    return _buildErrorState(state.message);
                  } else if (state is WorkoutsSuccess) {
                    if (state.workouts.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildWorkoutsList(state.workouts);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search workouts...",
            hintStyle: TextStyle(color: Colors.white38),
            prefixIcon: Icon(Icons.search, color: Colors.white38),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip("All", _selectedDifficulty == null, () {
                setState(() => _selectedDifficulty = null);
                _fetchWorkouts();
              }),
              ..._difficulties.map((d) => _buildFilterChip(
                d.toUpperCase(),
                _selectedDifficulty == d,
                () {
                  setState(() => _selectedDifficulty = d);
                  _fetchWorkouts();
                },
              )),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildTagChip("Any Tag", _selectedTag == null, () {
                setState(() => _selectedTag = null);
                _fetchWorkouts();
              }),
              ..._tags.map((t) => _buildTagChip(
                t,
                _selectedTag == t,
                () {
                  setState(() => _selectedTag = t);
                  _fetchWorkouts();
                },
              )),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: const Color(0xFF1E1E1E),
        selectedColor: const Color(0xFFD0FD3E),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        checkmarkColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildTagChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD0FD3E).withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFFD0FD3E) : Colors.white24,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFD0FD3E) : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutsList(List<WorkoutModel> workouts) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workouts.length,
      itemBuilder: (context, index) => _buildWorkoutCard(workouts[index]),
    );
  }

  Widget _buildWorkoutCard(WorkoutModel workout) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailScreen(workoutId: workout.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // Image
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: workout.image.isNotEmpty 
                          ? NetworkImage(workout.image) 
                          : const AssetImage('lib/assets/images/home/workout_placeholder.png') as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Difficulty Badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD0FD3E).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        workout.difficulty.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFD0FD3E),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoItem(Icons.timer_outlined, workout.duration),
                        const SizedBox(width: 20),
                        _buildInfoItem(Icons.local_fire_department_outlined, "${workout.caloriesBurned} kcal"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: workout.tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "#$tag",
                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD0FD3E), size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Shimmer.fromColors(
          baseColor: Colors.white.withValues(alpha: 0.05),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 64, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text(
            "No workouts found",
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedDifficulty = null;
                _selectedTag = null;
                _searchController.clear();
              });
              _fetchWorkouts();
            },
            child: const Text("Clear Filters", style: TextStyle(color: Color(0xFFD0FD3E))),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchWorkouts,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD0FD3E)),
            child: const Text("Retry", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
