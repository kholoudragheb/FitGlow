import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/progress_stats_model.dart';
import '../utils/store_styles.dart';

class StatsDashboard extends StatelessWidget {
  final ProgressStatsModel stats;

  const StatsDashboard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            "Insights",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildStatCard(
                "Workouts",
                stats.workoutsCompleted.toString(),
                Icons.fitness_center,
                StoreColors.primary,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                "Streak",
                "${stats.streakDays} Days",
                Icons.local_fire_department,
                Colors.orangeAccent,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                "Total Mins",
                stats.totalMinutes.toString(),
                Icons.timer,
                Colors.blueAccent,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                "Completion",
                "${(stats.completionRate * 100).toInt()}%",
                Icons.check_circle_outline,
                Colors.greenAccent,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildWeeklyChart(context),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Weekly Activity",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "Last 7 Days",
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final value = stats.weeklyActivity[index];
                return _buildBar(context, value, ["M", "T", "W", "T", "F", "S", "S"][index]);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context, double value, String day) {
    // Normalize height (assuming max activity level is 1.0 or based on max in list)
    double height = (value * 60) + 4; // Min 4px, Max 64px
    if (height > 64) height = 64;

    return Column(
      children: [
        Container(
          width: 24,
          height: height,
          decoration: BoxDecoration(
            color: value > 0.5 ? StoreColors.primary : StoreColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
