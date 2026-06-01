import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../logic/cubits/workout/workout_detail_cubit.dart';
import '../../../models/workout_model.dart';
import '../../../services/workout_service.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final String workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkoutDetailCubit(WorkoutService(), workoutId)..fetchWorkoutDetails(),
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: BlocBuilder<WorkoutDetailCubit, WorkoutDetailState>(
          builder: (context, state) {
            if (state is WorkoutDetailLoading) {
              return _buildShimmerLoading();
            } else if (state is WorkoutDetailError) {
              return _buildErrorState(state.message, context);
            } else if (state is WorkoutDetailSuccess) {
              return _buildContent(context, state.workout);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WorkoutModel workout) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, workout),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(workout),
                const SizedBox(height: 24),
                _buildStatsRow(workout),
                const SizedBox(height: 24),
                const Text(
                  "Description",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  workout.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Exercises",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${workout.exercises.length} items",
                      style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildExerciseCard(workout.exercises[index]),
              childCount: workout.exercises.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding for FAB
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WorkoutModel workout) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: const Color(0xFF1E1E1E),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            workout.image.isNotEmpty
                ? Image.network(workout.image, fit: BoxFit.cover)
                : Container(color: Colors.grey[900]),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF111111).withValues(alpha: 0.8),
                    const Color(0xFF111111),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
            child: const Icon(Icons.share_outlined, size: 20, color: Colors.white),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderInfo(WorkoutModel workout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD0FD3E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD0FD3E).withValues(alpha: 0.5)),
              ),
              child: Text(
                workout.difficulty.toUpperCase(),
                style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            ...workout.tags.take(2).map((tag) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text("#$tag", style: const TextStyle(color: Colors.white38, fontSize: 12)),
            )),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          workout.title,
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatsRow(WorkoutModel workout) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(Icons.timer_outlined, workout.duration, "Time"),
        _buildStatItem(Icons.local_fire_department_outlined, "${workout.caloriesBurned}", "Calories"),
        _buildStatItem(Icons.fitness_center_outlined, "${workout.exercises.length}", "Exercises"),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFD0FD3E), size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              image: exercise.image != null
                  ? DecorationImage(image: NetworkImage(exercise.image!), fit: BoxFit.cover)
                  : null,
            ),
            child: exercise.image == null ? const Icon(Icons.fitness_center, color: Colors.white24) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "${exercise.sets} Sets | ${exercise.reps} Reps",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.info_outline, color: Color(0xFFD0FD3E), size: 20),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.1),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 350, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 30, width: 200, color: Colors.white),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(3, (_) => Container(height: 60, width: 80, color: Colors.white)),
                  ),
                  const SizedBox(height: 32),
                  Container(height: 100, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 32),
                  ...List.generate(4, (_) => Container(height: 80, margin: const EdgeInsets.only(bottom: 16), color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<WorkoutDetailCubit>().fetchWorkoutDetails(),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD0FD3E)),
              child: const Text("Retry", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
