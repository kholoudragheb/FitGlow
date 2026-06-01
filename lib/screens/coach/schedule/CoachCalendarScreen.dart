import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/schedule/coach_calendar_cubit.dart';
import '../../../models/coach_calendar_model.dart';
import '../../../models/session_model.dart';
import '../../../models/time_slot_model.dart';
import '../../../services/schedule_service.dart';
import 'SessionDetailsScreen.dart';

class CoachCalendarScreen extends StatelessWidget {
  const CoachCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CoachCalendarCubit(ScheduleService())
        ..fetchCalendar(DateTime.now().month, DateTime.now().year),
      child: const _CoachCalendarView(),
    );
  }
}

class _CoachCalendarView extends StatefulWidget {
  const _CoachCalendarView();

  @override
  State<_CoachCalendarView> createState() => _CoachCalendarViewState();
}

class _CoachCalendarViewState extends State<_CoachCalendarView> {
  late DateTime _selectedMonth;
  DateTime _selectedDate = DateTime.now();
  String _activeFilter = 'All';

  final List<String> _filters = ['All', 'Confirmed', 'Pending', 'Completed', 'Canceled'];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  void _onMonthChanged(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
      _selectedDate = _selectedMonth; // Reset selected date to 1st of new month
    });
    context.read<CoachCalendarCubit>().fetchCalendar(_selectedMonth.month, _selectedMonth.year);
  }

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
          'Coach Calendar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildMonthPicker(),
          _buildFilters(),
          Expanded(
            child: BlocBuilder<CoachCalendarCubit, CoachCalendarState>(
              builder: (context, state) {
                if (state is CoachCalendarLoading) {
                  return _buildLoadingState();
                } else if (state is CoachCalendarError) {
                  return _buildErrorState(state.message);
                } else if (state is CoachCalendarSuccess) {
                  return _buildCalendarContent(state.calendarData);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppConstants.primaryColor),
            onPressed: () => _onMonthChanged(-1),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppConstants.primaryColor),
            onPressed: () => _onMonthChanged(1),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isActive = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: InkWell(
              onTap: () => setState(() => _activeFilter = filter),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? AppConstants.primaryColor : const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppConstants.primaryColor : Colors.white10,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isActive ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E1E1E),
      highlightColor: const Color(0xFF2C2C2C),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) => Container(
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppConstants.errorColor, size: 64),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<CoachCalendarCubit>().fetchCalendar(_selectedMonth.month, _selectedMonth.year),
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
              child: const Text('Retry', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarContent(CoachCalendarModel data) {
    return RefreshIndicator(
      onRefresh: () => context.read<CoachCalendarCubit>().fetchCalendar(_selectedMonth.month, _selectedMonth.year),
      color: AppConstants.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCalendarGrid(data),
            const SizedBox(height: 24),
            _buildDayDetails(data),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(CoachCalendarModel data) {
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday; // 1 = Monday, 7 = Sunday
    
    // Adjust for Monday start (weekday is 1-7)
    final paddingDays = firstDayOfMonth - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildWeekdayHeader(),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth + paddingDays,
            itemBuilder: (context, index) {
              if (index < paddingDays) return const SizedBox.shrink();
              
              final day = index - paddingDays + 1;
              final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
              final isSelected = _selectedDate.day == day && _selectedDate.month == _selectedMonth.month;
              final isToday = DateTime.now().day == day && DateTime.now().month == _selectedMonth.month && DateTime.now().year == _selectedMonth.year;

              // Check for sessions/slots on this day
              final dateStr = DateFormat('yyyy-MM-dd').format(date);
              final hasSessions = data.sessions.any((s) => s.scheduledDate.startsWith(dateStr));
              final hasSlots = data.availableSlots.any((s) => s.date?.startsWith(dateStr) ?? false);

              return InkWell(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppConstants.primaryColor : (isToday ? AppConstants.primaryColor.withValues(alpha: 0.1) : Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                    border: isToday ? Border.all(color: AppConstants.primaryColor.withValues(alpha: 0.5)) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      if (hasSessions || hasSlots)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasSessions)
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.black : Colors.blueAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (hasSessions && hasSlots) const SizedBox(width: 2),
                            if (hasSlots)
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.black : Colors.greenAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) => Text(
        day,
        style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
      )).toList(),
    );
  }

  Widget _buildDayDetails(CoachCalendarModel data) {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    // Filter sessions by date AND active status filter
    final daySessions = data.sessions.where((s) {
      final matchesDate = s.scheduledDate.startsWith(dateStr);
      if (!matchesDate) return false;
      if (_activeFilter == 'All') return true;
      return s.status.toLowerCase() == _activeFilter.toLowerCase();
    }).toList();

    // Filter slots by date
    final daySlots = data.availableSlots.where((s) => s.date?.startsWith(dateStr) ?? false).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEEE, MMM dd').format(_selectedDate),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${daySessions.length} sessions',
              style: const TextStyle(color: AppConstants.primaryColor, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (daySessions.isEmpty && daySlots.isEmpty)
          _buildEmptyState()
        else ...[
          if (daySessions.isNotEmpty) ...[
            const Text('Sessions', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...daySessions.map((s) => _buildSessionCard(s)),
          ],
          if (daySlots.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Available Slots', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...daySlots.map((s) => _buildSlotCard(s)),
          ],
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy, color: Colors.white.withValues(alpha: 0.1), size: 48),
          const SizedBox(height: 16),
          const Text(
            'No sessions scheduled',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(SessionModel session) {
    Color statusColor;
    switch (session.status.toLowerCase()) {
      case 'confirmed': statusColor = Colors.green; break;
      case 'pending': statusColor = Colors.orange; break;
      case 'completed': statusColor = Colors.blue; break;
      case 'canceled': statusColor = Colors.red; break;
      default: statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SessionDetailsScreen(sessionId: session.id)),
      ).then((_) => context.read<CoachCalendarCubit>().fetchCalendar(_selectedMonth.month, _selectedMonth.year)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                session.sessionType.toLowerCase() == 'online' ? Icons.videocam : Icons.person,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.clientName ?? 'Client',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${session.startTime} - ${session.endTime}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
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
      ),
    );
  }

  Widget _buildSlotCard(TimeSlotModel slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.white54, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '${slot.startTime} - ${slot.endTime}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          const Text(
            'AVAILABLE',
            style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
