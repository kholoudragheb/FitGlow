import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../utils/store_styles.dart';
import 'package:intl/intl.dart';
import 'UpdateProgressBottomSheet.dart';

class GoalCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onUpdate;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onDelete,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressPercentage / 100;
    final bool isCompleted = goal.isCompleted;
    final bool isExpired = goal.isExpired;
    final daysLeft = goal.deadline.difference(DateTime.now()).inDays;

    Color statusColor = StoreColors.primary;
    String statusText = "Active";
    
    if (isCompleted) {
      statusColor = Colors.amber;
      statusText = "Completed";
    } else if (isExpired) {
      statusColor = Colors.redAccent;
      statusText = "Expired";
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCompleted 
                ? Colors.amber.withValues(alpha: 0.3) 
                : Colors.white.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
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
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    statusText.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final result = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => UpdateProgressBottomSheet(goal: goal),
                    );
                    if (result == true && onUpdate != null) {
                      onUpdate!();
                    }
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16, color: StoreColors.primary),
                  label: const Text(
                    "Update",
                    style: TextStyle(color: StoreColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: StoreColors.primary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGoalMetric(
                  "Current", 
                  "${goal.currentValue.toStringAsFixed(goal.currentValue % 1 == 0 ? 0 : 1)} ${goal.unit}",
                  Colors.grey,
                ),
                _buildGoalMetric(
                  "Target", 
                  "${goal.targetValue.toStringAsFixed(goal.targetValue % 1 == 0 ? 0 : 1)} ${goal.unit}",
                  StoreColors.primary,
                ),
                _buildGoalMetric(
                  "Deadline", 
                  daysLeft > 0 ? "$daysLeft days left" : DateFormat('MMM dd').format(goal.deadline),
                  daysLeft <= 3 && !isCompleted && !isExpired ? Colors.orangeAccent : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isCompleted ? "Goal Achieved! 🎉" : isExpired ? "Time's up" : "Progress",
                      style: TextStyle(
                        color: isCompleted ? Colors.amber : isExpired ? Colors.redAccent : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${goal.progressPercentage.toInt()}%",
                      style: TextStyle(
                        color: isCompleted ? Colors.amber : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress > 1.0 ? 1.0 : progress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        color: isCompleted ? Colors.amber : statusColor,
                        minHeight: 8,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalMetric(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}
