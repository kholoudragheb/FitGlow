import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/schedule/my_sessions_cubit.dart';
import '../../../models/session_model.dart';
import '../../../services/schedule_service.dart';
import 'SessionDetailsScreen.dart';

class CoachSessionsScreen extends StatelessWidget {
  const CoachSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MySessionsCubit(ScheduleService())..fetchMySessions(),
      child: const _CoachSessionsView(),
    );
  }
}

class _CoachSessionsView extends StatelessWidget {
  const _CoachSessionsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Sessions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<MySessionsCubit, MySessionsState>(
        builder: (context, state) {
          if (state is MySessionsLoading) {
            return _buildLoadingState();
          } else if (state is MySessionsError) {
            return _buildErrorState(context, state.message);
          } else if (state is MySessionsSuccess) {
            return _buildSuccessState(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        _buildFiltersShimmer(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: 5,
            itemBuilder: (context, index) => _buildCardShimmer(),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersShimmer() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 4,
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: const Color(0xFF2C2C2C),
          highlightColor: const Color(0xFF3C3C3C),
          child: Container(
            width: 80,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2C2C2C),
      highlightColor: const Color(0xFF3C3C3C),
      child: Container(
        height: 140,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppConstants.errorColor, size: 64),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<MySessionsCubit>().fetchMySessions(),
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
            child: const Text('Retry', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, MySessionsSuccess state) {
    return Column(
      children: [
        _buildFilters(context, state.currentFilter),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<MySessionsCubit>().fetchMySessions(),
            color: AppConstants.primaryColor,
            child: state.filteredSessions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: state.filteredSessions.length,
                    itemBuilder: (context, index) => _buildSessionCard(context, state.filteredSessions[index]),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, String currentFilter) {
    final filters = ['All', 'Upcoming', 'Completed', 'Canceled'];
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == currentFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) context.read<MySessionsCubit>().setFilter(filter);
              },
              backgroundColor: const Color(0xFF1E1E1E),
              selectedColor: AppConstants.primaryColor,
              showCheckmark: false,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, color: Colors.white24, size: 80),
          SizedBox(height: 16),
          Text('No sessions found', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, SessionModel session) {
    DateTime date = DateTime.tryParse(session.scheduledDate) ?? DateTime.now();
    String formattedDate = DateFormat('MMM dd, yyyy').format(date);

    Color statusColor;
    switch (session.status.toLowerCase()) {
      case 'confirmed': statusColor = Colors.green; break;
      case 'pending': statusColor = Colors.orange; break;
      case 'completed': statusColor = Colors.blue; break;
      case 'canceled':
      case 'cancelled': statusColor = Colors.red; break;
      default: statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SessionDetailsScreen(sessionId: session.id)),
        );
        // Refresh after coming back
        if (context.mounted) {
          context.read<MySessionsCubit>().fetchMySessions();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, color: AppConstants.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      session.clientName ?? 'Unknown Client',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    session.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.white10),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white54, size: 14),
                        const SizedBox(width: 6),
                        Text(formattedDate, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.white54, size: 14),
                        const SizedBox(width: 6),
                        Text('${session.startTime} - ${session.endTime}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    session.sessionType.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
