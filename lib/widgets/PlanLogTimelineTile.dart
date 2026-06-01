import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/progress_log_model.dart';
import '../utils/store_styles.dart';
import '../screens/client/LogDetailsScreen.dart';

class PlanLogTimelineTile extends StatelessWidget {
  final ProgressLogModel log;
  final bool isFirst;
  final bool isLast;

  const PlanLogTimelineTile({
    super.key,
    required this.log,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color typeColor = _getTypeColor(log.type);
    final IconData typeIcon = _getTypeIcon(log.type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 20,
                  color: isFirst ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: typeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: typeColor.withValues(alpha: 0.4), blurRadius: 8),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
          
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LogDetailsScreen(logId: log.id),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(typeIcon, color: typeColor, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                log.type.toUpperCase(),
                                style: TextStyle(
                                  color: typeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            DateFormat('HH:mm').format(log.createdAt),
                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (log.duration != null && log.duration! > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            "${log.duration} minutes session",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                      if (log.notes != null && log.notes!.isNotEmpty)
                        Text(
                          log.notes!,
                          style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatusBadge(log.status),
                          const Spacer(),
                          const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(log.createdAt),
                            style: TextStyle(color: Colors.grey[600], fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isCompleted = status.toLowerCase() == 'completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: isCompleted ? Colors.greenAccent : Colors.orangeAccent,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'workout': return Colors.blueAccent;
      case 'nutrition': return Colors.greenAccent;
      case 'check-in': return Colors.purpleAccent;
      default: return StoreColors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'workout': return Icons.fitness_center;
      case 'nutrition': return Icons.restaurant;
      case 'check-in': return Icons.assignment_turned_in;
      default: return Icons.history;
    }
  }
}
