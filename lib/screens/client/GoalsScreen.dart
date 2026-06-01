import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/goals/goals_cubit.dart';
import '../../../services/progress_log_service.dart';
import '../../../utils/store_styles.dart';
import '../../../widgets/GoalCard.dart';
import '../../../widgets/GoalShimmer.dart';
import 'AddGoalScreen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GoalsCubit(ProgressLogService())..fetchGoals(),
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
            'My Fitness Goals',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            BlocBuilder<GoalsCubit, GoalsState>(
              builder: (context, state) {
                if (state is GoalsSuccess) {
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.sort, color: StoreColors.primary),
                    color: const Color(0xFF222222),
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onSelected: (value) => context.read<GoalsCubit>().changeSort(value),
                    itemBuilder: (context) => [
                      _buildSortItem('Deadline', Icons.timer_outlined, state.sortBy == 'Deadline'),
                      _buildSortItem('Progress', Icons.trending_up, state.sortBy == 'Progress'),
                      _buildSortItem('Newest', Icons.calendar_today_outlined, state.sortBy == 'Newest'),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: StoreColors.primary),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddGoalScreen()),
                );
                if (result == true && context.mounted) {
                  context.read<GoalsCubit>().fetchGoals();
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: BlocBuilder<GoalsCubit, GoalsState>(
                builder: (context, state) {
                  if (state is GoalsLoading) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: 4,
                      itemBuilder: (context, index) => const GoalShimmer(),
                    );
                  }

                  if (state is GoalsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(state.message, style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => context.read<GoalsCubit>().fetchGoals(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: StoreColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Retry', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is GoalsSuccess) {
                    final goals = state.filteredGoals;
                    
                    if (goals.isEmpty) {
                      return _buildEmptyState(context, state.filter);
                    }

                    return RefreshIndicator(
                      onRefresh: () => context.read<GoalsCubit>().fetchGoals(),
                      color: StoreColors.primary,
                      backgroundColor: const Color(0xFF222222),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: goals.length,
                        itemBuilder: (context, index) {
                          final goal = goals[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: GoalCard(
                              goal: goal,
                              onDelete: () => _confirmDelete(context, goal.id),
                              onUpdate: () => context.read<GoalsCubit>().fetchGoals(),
                            ),
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

  PopupMenuItem<String> _buildSortItem(String value, IconData icon, bool isSelected) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: isSelected ? StoreColors.primary : Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              color: isSelected ? StoreColors.primary : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Active', 'Completed', 'Expired'];
    return BlocBuilder<GoalsCubit, GoalsState>(
      builder: (context, state) {
        if (state is! GoalsSuccess) return const SizedBox.shrink();
        
        return Container(
          height: 60,
          margin: const EdgeInsets.only(top: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = state.filter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => context.read<GoalsCubit>().changeFilter(filter),
                  backgroundColor: const Color(0xFF1E1E1E),
                  selectedColor: StoreColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: StoreColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? StoreColors.primary : Colors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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

  Widget _buildEmptyState(BuildContext context, String currentFilter) {
    String title = "No goals set yet";
    String subtitle = "Setting goals is the first step to success!";
    
    if (currentFilter != 'All') {
      title = "No $currentFilter goals";
      subtitle = "Try changing your filter to see more goals.";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.track_changes, color: Colors.white.withValues(alpha: 0.1), size: 100),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          if (currentFilter == 'All') ...[
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddGoalScreen()),
                );
                if (result == true && context.mounted) {
                  context.read<GoalsCubit>().fetchGoals();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: StoreColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Create Your First Goal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String goalId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Delete Goal", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to delete this goal?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              context.read<GoalsCubit>().deleteGoal(goalId);
              Navigator.pop(dialogContext);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
