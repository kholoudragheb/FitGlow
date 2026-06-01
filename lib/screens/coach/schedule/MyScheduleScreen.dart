import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/schedule/my_time_slots_cubit.dart';
import '../../../logic/cubits/schedule/delete_time_slot_cubit.dart';
import '../../../models/time_slot_model.dart';
import '../../../services/schedule_service.dart';
import 'AvailabilityManagementScreen.dart';
import 'SessionDetailsScreen.dart';

class MyScheduleScreen extends StatelessWidget {
  const MyScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyTimeSlotsCubit(ScheduleService())..fetchMySlots(),
      child: const _MyScheduleView(),
    );
  }
}

class _MyScheduleView extends StatefulWidget {
  const _MyScheduleView();

  @override
  State<_MyScheduleView> createState() => _MyScheduleViewState();
}

class _MyScheduleViewState extends State<_MyScheduleView> {
  final Map<int, String> _dayNames = {
    0: 'Sunday',
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
  };

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
          'My Schedule',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppConstants.primaryColor),
            onPressed: () => _navigateToAddAvailability(context),
          ),
        ],
      ),
      body: BlocBuilder<MyTimeSlotsCubit, MyTimeSlotsState>(
        builder: (context, state) {
          if (state is MyTimeSlotsLoading) {
            return _buildShimmerLoading();
          } else if (state is MyTimeSlotsError) {
            return _buildErrorState(state.message);
          } else if (state is MyTimeSlotsSuccess) {
            if (state.slots.isEmpty) {
              return _buildEmptyState();
            }
            return _buildSlotsList(state.slots);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _navigateToAddAvailability(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AvailabilityManagementScreen()),
    );
    // Refresh when coming back
    if (context.mounted) {
      context.read<MyTimeSlotsCubit>().fetchMySlots();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined, color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          const Text(
            'No time slots created yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateToAddAvailability(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('+ Add Availability'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
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
              onPressed: () => context.read<MyTimeSlotsCubit>().fetchMySlots(),
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

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: const Color(0xFF2C2C2C),
          highlightColor: const Color(0xFF3C3C3C),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlotsList(List<TimeSlotModel> slots) {
    // Group slots by day
    final Map<int, List<TimeSlotModel>> groupedSlots = {};
    for (var slot in slots) {
      if (!groupedSlots.containsKey(slot.dayOfWeek)) {
        groupedSlots[slot.dayOfWeek] = [];
      }
      groupedSlots[slot.dayOfWeek]!.add(slot);
    }

    return RefreshIndicator(
      color: AppConstants.primaryColor,
      backgroundColor: const Color(0xFF1E1E1E),
      onRefresh: () => context.read<MyTimeSlotsCubit>().fetchMySlots(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedSlots.keys.length,
        itemBuilder: (context, index) {
          final day = groupedSlots.keys.elementAt(index);
          final daySlots = groupedSlots[day]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 16),
                child: Text(
                  _dayNames[day] ?? 'Unknown Day',
                  style: const TextStyle(
                    color: AppConstants.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...daySlots.map((slot) => _buildSlotCard(slot)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSlotCard(TimeSlotModel slot) {
    final bool isBooked = slot.isBooked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBooked ? Colors.redAccent.withValues(alpha: 0.3) : AppConstants.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: isBooked && slot.bookedSessionId != null 
          ? () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SessionDetailsScreen(sessionId: slot.bookedSessionId!),
              ),
            )
          : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "${slot.startTime} - ${slot.endTime}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBadge(
                      icon: Icons.videocam_outlined,
                      text: slot.sessionType.toUpperCase(),
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(width: 8),
                    _buildBadge(
                      icon: Icons.timelapse,
                      text: "${slot.duration}m",
                      color: Colors.orangeAccent,
                    ),
                    if (slot.isRecurring) ...[
                      const SizedBox(width: 8),
                      _buildBadge(
                        icon: Icons.repeat,
                        text: "Weekly",
                        color: Colors.purpleAccent,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isBooked ? Colors.redAccent.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isBooked ? "BOOKED" : "AVAILABLE",
                    style: TextStyle(
                      color: isBooked ? Colors.redAccent : Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white54),
            color: const Color(0xFF2C2C2C),
            onSelected: (value) {
              // Action logic goes here
              if (value == 'edit') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit slot tapped')));
              } else if (value == 'delete') {
                _showDeleteConfirmationDialog(context, slot);
              } else if (value == 'unavailable') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mark unavailable tapped')));
              } else if (value == 'view') {
                if (slot.bookedSessionId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SessionDetailsScreen(sessionId: slot.bookedSessionId!),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session ID not found for this booking')),
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit Slot', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'unavailable',
                child: Text('Mark Unavailable', style: TextStyle(color: Colors.white)),
              ),
              if (isBooked)
                const PopupMenuItem<String>(
                  value: 'view',
                  child: Text('View Booking Details', style: TextStyle(color: Colors.white)),
                ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete Slot', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildBadge({required IconData icon, required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext parentContext, TimeSlotModel slot) {
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return BlocProvider(
          create: (context) => DeleteTimeSlotCubit(ScheduleService()),
          child: BlocConsumer<DeleteTimeSlotCubit, DeleteTimeSlotState>(
            listener: (context, state) {
              if (state is DeleteTimeSlotSuccess) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('Time slot deleted successfully'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                parentContext.read<MyTimeSlotsCubit>().fetchMySlots();
              } else if (state is DeleteTimeSlotError) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is DeleteTimeSlotLoading;
              
              return AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Delete Time Slot?',
                      style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 18),
                    ),
                  ],
                ),
                content: const Text(
                  'Are you sure you want to remove this slot?',
                  style: TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
                ),
                actions: [
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : () => context.read<DeleteTimeSlotCubit>().deleteSlot(slot.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Delete'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
