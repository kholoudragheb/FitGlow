import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/schedule/my_sessions_cubit.dart';
import '../../../models/session_model.dart';
import '../../../services/schedule_service.dart';
// Note: In a real app, 'Book a Session' empty state would route to the Coach Discovery screen.
// We'll leave a simple Navigator.pop or placeholder for now.

class MySessionsScreen extends StatelessWidget {
  const MySessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MySessionsCubit(ScheduleService())..fetchMySessions(),
      child: const _MySessionsView(),
    );
  }
}

class _MySessionsView extends StatelessWidget {
  const _MySessionsView();

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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
        // Filters shimmer
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: const Color(0xFF2C2C2C),
                highlightColor: const Color(0xFF3C3C3C),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Cards shimmer
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: const Color(0xFF2C2C2C),
                highlightColor: const Color(0xFF3C3C3C),
                child: Container(
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<MySessionsCubit>().fetchMySessions(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, MySessionsSuccess state) {
    return Column(
      children: [
        _buildFilters(context, state.currentFilter),
        Expanded(
          child: RefreshIndicator(
            color: AppConstants.primaryColor,
            backgroundColor: const Color(0xFF2C2C2C),
            onRefresh: () => context.read<MySessionsCubit>().fetchMySessions(),
            child: state.filteredSessions.isEmpty
                ? _buildEmptyState(context, state.currentFilter)
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 32),
                    itemCount: state.filteredSessions.length,
                    itemBuilder: (context, index) {
                      return _buildSessionCard(state.filteredSessions[index]);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, String currentFilter) {
    final filters = ['All', 'Upcoming', 'Completed', 'Canceled'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == currentFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
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
                if (selected) {
                  context.read<MySessionsCubit>().setFilter(filter);
                }
              },
              backgroundColor: const Color(0xFF2C2C2C),
              selectedColor: AppConstants.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppConstants.primaryColor : Colors.transparent,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String filter) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(), // Allows pull-to-refresh
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Icon(Icons.event_note, color: Colors.white24, size: 80),
        const SizedBox(height: 24),
        Text(
          filter == 'All' ? 'No sessions booked yet' : 'No $filter sessions',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'When you book a session with a coach,\nit will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
        if (filter == 'All') ...[
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Return to previous screen (presumably dashboard or discovery)
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Find a Coach', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSessionCard(SessionModel session) {
    final String coachName = session.coachName ?? 'Coach';
    
    // Formatting date
    String displayDate = session.scheduledDate;
    try {
      final dt = DateTime.parse(session.scheduledDate);
      displayDate = DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {}

    // Status Styling
    Color statusColor;
    String statusText = session.status.toUpperCase();
    switch (session.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.blueAccent;
        break;
      case 'canceled':
      case 'cancelled':
        statusColor = Colors.redAccent;
        break;
      case 'scheduled':
      case 'confirmed':
        statusText = 'CONFIRMED';
        statusColor = Colors.greenAccent;
        break;
      case 'pending':
      default:
        statusColor = Colors.orangeAccent;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2C2C)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF2C2C2C),
                      child: Icon(Icons.person, color: Colors.white54, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        coachName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFF2C2C2C)),
          ),
          // Details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white54, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          displayDate,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.white54, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          "\${session.startTime} - \${session.endTime}",
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      session.sessionType.toLowerCase() == 'online' 
                          ? Icons.videocam 
                          : Icons.location_on, 
                      color: AppConstants.primaryColor, 
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      session.sessionType.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
