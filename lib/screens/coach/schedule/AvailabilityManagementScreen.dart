import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/schedule/create_time_slot_cubit.dart';
import '../../../services/schedule_service.dart';

class AvailabilityManagementScreen extends StatelessWidget {
  const AvailabilityManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateTimeSlotCubit(ScheduleService()),
      child: const _AvailabilityManagementView(),
    );
  }
}

class _AvailabilityManagementView extends StatefulWidget {
  const _AvailabilityManagementView();

  @override
  State<_AvailabilityManagementView> createState() => _AvailabilityManagementViewState();
}

class _AvailabilityManagementViewState extends State<_AvailabilityManagementView> {
  int _selectedDay = 1; // 1 = Monday
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  int _selectedDuration = 60;
  String _selectedSessionType = 'online';
  bool _isRecurring = true;

  final List<String> _daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final List<int> _durations = [30, 45, 60, 90, 120];

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppConstants.primaryColor,
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          // Auto-adjust end time based on duration if possible
          final newEndTotalMinutes = picked.hour * 60 + picked.minute + _selectedDuration;
          _endTime = TimeOfDay(hour: (newEndTotalMinutes ~/ 60) % 24, minute: newEndTotalMinutes % 60);
        } else {
          _endTime = picked;
          // Auto-adjust duration
          final startMinutes = _startTime.hour * 60 + _startTime.minute;
          final endMinutes = picked.hour * 60 + picked.minute;
          if (endMinutes > startMinutes) {
            final diff = endMinutes - startMinutes;
            if (_durations.contains(diff)) {
              _selectedDuration = diff;
            }
          }
        }
      });
    }
  }

  void _submitForm() {
    final startStr = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    final endStr = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';

    final body = {
      'dayOfWeek': _selectedDay,
      'startTime': startStr,
      'endTime': endStr,
      'duration': _selectedDuration,
      'sessionType': _selectedSessionType,
      'isRecurring': _isRecurring,
    };

    context.read<CreateTimeSlotCubit>().submitSlot(body);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateTimeSlotCubit, CreateTimeSlotState>(
      listener: (context, state) {
        if (state is CreateTimeSlotSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Time slot created successfully"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Optional: Clear form or pop
          // Navigator.pop(context, true); 
        } else if (state is CreateTimeSlotError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
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
            'Manage Availability',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Day of Week'),
              const SizedBox(height: 16),
              _buildDaySelector(),
              
              const SizedBox(height: 32),
              
              _buildSectionTitle('Time Window'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTimePickerCard("Start Time", _startTime, true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTimePickerCard("End Time", _endTime, false)),
                ],
              ),
              
              const SizedBox(height: 32),
              
              _buildSectionTitle('Session Details'),
              const SizedBox(height: 16),
              _buildDropdownCard(
                label: "Duration (Minutes)",
                value: _selectedDuration.toString(),
                items: _durations.map((d) => d.toString()).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedDuration = int.parse(val);
                      // Auto-adjust end time
                      final newEndTotalMinutes = _startTime.hour * 60 + _startTime.minute + _selectedDuration;
                      _endTime = TimeOfDay(hour: (newEndTotalMinutes ~/ 60) % 24, minute: newEndTotalMinutes % 60);
                    });
                  }
                },
              ),
              
              const SizedBox(height: 16),
              _buildDropdownCard(
                label: "Session Type",
                value: _selectedSessionType,
                items: ['online', 'in_person', 'hybrid'],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedSessionType = val);
                  }
                },
              ),
              
              const SizedBox(height: 32),
              
              _buildRecurringToggle(),
              
              const SizedBox(height: 48),
              
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDaySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_daysOfWeek.length, (index) {
          final isSelected = _selectedDay == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppConstants.primaryColor : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppConstants.primaryColor : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                _daysOfWeek[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimePickerCard(String label, TimeOfDay time, bool isStart) {
    return GestureDetector(
      onTap: () => _selectTime(context, isStart),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  time.format(context),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Icon(Icons.access_time, color: AppConstants.primaryColor, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownCard({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF2C2C2C),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppConstants.primaryColor),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item.toUpperCase()),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRecurringToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Recurring Slot",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                "Repeat every week",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Switch(
            value: _isRecurring,
            onChanged: (val) => setState(() => _isRecurring = val),
            activeThumbColor: AppConstants.primaryColor,
            activeTrackColor: AppConstants.primaryColor.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<CreateTimeSlotCubit, CreateTimeSlotState>(
      builder: (context, state) {
        final isLoading = state is CreateTimeSlotLoading;
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              disabledBackgroundColor: AppConstants.surfaceColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: AppConstants.primaryColor.withValues(alpha: 0.4),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                  )
                : const Text(
                    "Create Slot",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
