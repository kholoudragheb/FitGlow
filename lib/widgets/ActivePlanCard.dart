import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/plan_model.dart';
import '../utils/store_styles.dart';

class ActivePlanCard extends StatelessWidget {
  final PlanModel plan;
  final VoidCallback onTap;

  const ActivePlanCard({
    super.key,
    required this.plan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress (mock for now, or based on dates if available)
    double progress = 0.35; // Default mock progress

    final Color typeColor = plan.type == 'workout' 
        ? Colors.blueAccent 
        : plan.type == 'nutrition' 
            ? Colors.greenAccent 
            : Colors.orangeAccent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF1E1E1E), const Color(0xFF121212)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: StoreColors.primary.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    plan.type.toUpperCase(),
                    style: TextStyle(
                      color: typeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              plan.title,
              style: AppConstants.headlineMedium.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              plan.description,
              style: AppConstants.bodyMedium.copyWith(color: Colors.grey, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Overall Progress",
                            style: AppConstants.bodyMedium.copyWith(fontSize: 12),
                          ),
                          Text(
                            "${(progress * 100).toInt()}%",
                            style: TextStyle(
                              color: StoreColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          color: StoreColors.primary,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                _buildInfoBit("Duration", "${plan.durationWeeks}W"),
                const SizedBox(width: 16),
                _buildInfoBit("Difficulty", plan.difficulty.substring(0, 3).toUpperCase()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBit(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}
