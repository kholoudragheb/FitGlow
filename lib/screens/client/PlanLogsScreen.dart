import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/progress_log/plan_logs_cubit.dart';
import '../../../models/plan_model.dart';
import '../../../services/progress_log_service.dart';
import '../../../utils/store_styles.dart';
import '../../../widgets/PlanLogTimelineTile.dart';
import 'package:shimmer/shimmer.dart';

class PlanLogsScreen extends StatelessWidget {
  final PlanModel plan;

  const PlanLogsScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlanLogsCubit(ProgressLogService())..fetchLogs(plan.id),
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Activity History',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                plan.title,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: BlocBuilder<PlanLogsCubit, PlanLogsState>(
                builder: (context, state) {
                  if (state is PlanLogsLoading) {
                    return _buildShimmerLoading();
                  }

                  if (state is PlanLogsError) {
                    return _buildErrorState(context, state.message);
                  }

                  if (state is PlanLogsSuccess) {
                    final logs = state.filteredLogs;
                    
                    if (logs.isEmpty) {
                      return _buildEmptyState(state.currentFilter);
                    }

                    return RefreshIndicator(
                      onRefresh: () => context.read<PlanLogsCubit>().fetchLogs(plan.id),
                      color: StoreColors.primary,
                      backgroundColor: const Color(0xFF222222),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          return PlanLogTimelineTile(
                            log: logs[index],
                            isFirst: index == 0,
                            isLast: index == logs.length - 1,
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Workout', 'Nutrition', 'Check-in', 'Completed'];
    return BlocBuilder<PlanLogsCubit, PlanLogsState>(
      builder: (context, state) {
        if (state is! PlanLogsSuccess) return const SizedBox.shrink();

        return Container(
          height: 50,
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = state.currentFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => context.read<PlanLogsCubit>().changeFilter(filter),
                  backgroundColor: const Color(0xFF1E1E1E),
                  selectedColor: StoreColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: StoreColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? StoreColors.primary : Colors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? StoreColors.primary : Colors.white.withValues(alpha: 0.05),
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

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E1E1E),
      highlightColor: const Color(0xFF2C2C2C),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 20, right: 16),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
              Expanded(
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, color: Colors.white.withValues(alpha: 0.1), size: 100),
          const SizedBox(height: 24),
          Text(
            filter == 'All' ? "No activity yet" : "No $filter logs found",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Start your training to see logs here.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<PlanLogsCubit>().fetchLogs(plan.id),
            style: ElevatedButton.styleFrom(backgroundColor: StoreColors.primary),
            child: const Text('Retry', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
