import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/progress_log/my_progress_logs_cubit.dart';
import '../../../models/progress_log_model.dart';
import '../../../services/progress_log_service.dart';
import '../../../utils/store_styles.dart';
import 'CreateProgressLogScreen.dart';

class MyProgressLogsScreen extends StatelessWidget {
  const MyProgressLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyProgressLogsCubit(ProgressLogService())..fetchLogs(),
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Activity History',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: BlocBuilder<MyProgressLogsCubit, MyProgressLogsState>(
                builder: (context, state) {
                  if (state is MyProgressLogsLoading) {
                    return _buildLoadingState();
                  } else if (state is MyProgressLogsError) {
                    return _buildErrorState(context, state.message);
                  } else if (state is MyProgressLogsSuccess) {
                    final logs = state.filteredLogs;
                    if (logs.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return _buildLogsList(context, logs);
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateProgressLogScreen()),
            );
            if (result == true) {
              // Refresh is handled by pull to refresh or manually if needed
              // But here we can use context from BlocProvider if we had it
            }
          },
          backgroundColor: StoreColors.primary,
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Workout', 'Meal', 'Weight', 'Cardio'];
    return BlocBuilder<MyProgressLogsCubit, MyProgressLogsState>(
      builder: (context, state) {
        final currentFilter = (state is MyProgressLogsSuccess) ? state.currentFilter : 'All';
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = currentFilter == filter;
              return GestureDetector(
                onTap: () => context.read<MyProgressLogsCubit>().filterLogs(filter),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? StoreColors.primary : AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? StoreColors.primary : Colors.white.withValues(alpha: 0.05)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLogsList(BuildContext context, List<ProgressLogModel> logs) {
    return RefreshIndicator(
      onRefresh: () => context.read<MyProgressLogsCubit>().fetchLogs(),
      color: StoreColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return _buildLogCard(log);
        },
      ),
    );
  }

  Widget _buildLogCard(ProgressLogModel log) {
    final Color typeColor = _getColorForType(log.type);
    final String formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(log.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIconForType(log.type), color: typeColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log.type.toUpperCase(),
                      style: TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.white24, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (log.notes != null && log.notes!.isNotEmpty)
                  Text(
                    log.notes!,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (log.duration != null)
                      _buildMetric(Icons.access_time, "${log.duration} min"),
                    if (log.duration != null && log.value != null) const SizedBox(width: 16),
                    if (log.value != null)
                      _buildMetric(Icons.monitor_weight_outlined, "${log.value} Kg"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 14),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'workout': return Colors.blueAccent;
      case 'meal': return Colors.greenAccent;
      case 'weight': return Colors.purpleAccent;
      case 'cardio': return Colors.orangeAccent;
      default: return AppConstants.primaryColor;
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'workout': return Icons.fitness_center;
      case 'meal': return Icons.restaurant;
      case 'weight': return Icons.monitor_weight;
      case 'cardio': return Icons.directions_run;
      default: return Icons.assignment;
    }
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: StoreColors.primary));
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<MyProgressLogsCubit>().fetchLogs(),
              style: ElevatedButton.styleFrom(backgroundColor: StoreColors.primary),
              child: const Text('Retry', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          const Text("No activity history yet", style: TextStyle(color: Colors.white60, fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateProgressLogScreen()),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: StoreColors.primary),
            child: const Text("+ Add Your First Log", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
