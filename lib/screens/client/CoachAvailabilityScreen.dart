import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/schedule/coach_availability_cubit.dart';
import '../../../models/time_slot_model.dart';
import '../../../services/schedule_service.dart';
import 'BookSessionScreen.dart';

class CoachAvailabilityScreen extends StatelessWidget {
  final Map<String, dynamic> coachData;

  const CoachAvailabilityScreen({super.key, required this.coachData});

  @override
  Widget build(BuildContext context) {
    final coachId = coachData['_id']?.toString() ?? coachData['id']?.toString() ?? '';
    
    return BlocProvider(
      create: (context) => CoachAvailabilityCubit(ScheduleService())..fetchAvailability(coachId),
      child: _CoachAvailabilityView(coachData: coachData),
    );
  }
}

class _CoachAvailabilityView extends StatefulWidget {
  final Map<String, dynamic> coachData;

  const _CoachAvailabilityView({required this.coachData});

  @override
  State<_CoachAvailabilityView> createState() => _CoachAvailabilityViewState();
}

class _CoachAvailabilityViewState extends State<_CoachAvailabilityView> {
  TimeSlotModel? _selectedSlot;

  @override
  Widget build(BuildContext context) {
    final coachName = widget.coachData['name'] ?? 'Coach';
    
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$coachName\'s Availability',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<CoachAvailabilityCubit, CoachAvailabilityState>(
        listener: (context, state) {
          if (state is CoachAvailabilitySuccess) {
            // Reset selected slot if the date changes
            setState(() {
              _selectedSlot = null;
            });
          }
        },
        builder: (context, state) {
          if (state is CoachAvailabilityLoading) {
            return _buildLoadingState();
          } else if (state is CoachAvailabilityError) {
            return _buildErrorState(state.message);
          } else if (state is CoachAvailabilitySuccess) {
            return _buildSuccessState(state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        // Calendar shimmer
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 7,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: const Color(0xFF2C2C2C),
                highlightColor: const Color(0xFF3C3C3C),
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        // Slots shimmer
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: const Color(0xFF2C2C2C),
                highlightColor: const Color(0xFF3C3C3C),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
              onPressed: () {
                final coachId = widget.coachData['_id']?.toString() ?? widget.coachData['id']?.toString() ?? '';
                context.read<CoachAvailabilityCubit>().fetchAvailability(coachId);
              },
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

  Widget _buildSuccessState(CoachAvailabilitySuccess state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateSelector(state.selectedDate),
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 32, bottom: 16),
          child: Text(
            "Available Slots",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: state.slotsForSelectedDate.isEmpty
              ? _buildEmptyState()
              : _buildSlotsGrid(state.slotsForSelectedDate),
        ),
        _buildBottomAction(state.selectedDate),
      ],
    );
  }

  Widget _buildDateSelector(DateTime selectedDate) {
    final now = DateTime.now();
    final List<DateTime> dates = List.generate(14, (i) => now.add(Duration(days: i)));

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          final dayName = DateFormat('EEE').format(date).toUpperCase();
          final dayNumber = DateFormat('dd').format(date);

          return GestureDetector(
            onTap: () => context.read<CoachAvailabilityCubit>().selectDate(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppConstants.primaryColor : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppConstants.primaryColor : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      color: isSelected ? Colors.black54 : Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNumber,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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
          Icon(Icons.event_busy, color: Colors.white54, size: 64),
          SizedBox(height: 16),
          Text(
            'No available slots on this date',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsGrid(List<TimeSlotModel> slots) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = _selectedSlot?.id == slot.id;
        final isAvailable = slot.isAvailable;

        return GestureDetector(
          onTap: isAvailable
              ? () {
                  setState(() {
                    _selectedSlot = slot;
                  });
                }
              : null,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppConstants.primaryColor
                  : (isAvailable ? const Color(0xFF1E1E1E) : const Color(0xFF2C2C2C)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppConstants.primaryColor
                    : (isAvailable ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.1)),
                width: 1,
              ),
            ),
            child: Text(
              slot.startTime,
              style: TextStyle(
                color: isSelected
                    ? Colors.black
                    : (isAvailable ? Colors.white : Colors.white30),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
                decoration: isAvailable ? TextDecoration.none : TextDecoration.lineThrough,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomAction(DateTime selectedDate) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _selectedSlot != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookSessionScreen(
                      slot: _selectedSlot!,
                      coachData: widget.coachData,
                    ),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          disabledBackgroundColor: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 56),
        ),
        child: Text(
          _selectedSlot != null ? "Continue to Booking" : "Select a Time Slot",
          style: TextStyle(
            color: _selectedSlot != null ? Colors.black : Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
