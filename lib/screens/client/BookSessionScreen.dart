import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/schedule/book_session_cubit.dart';
import '../../../models/time_slot_model.dart';
import '../../../services/schedule_service.dart';
import 'MySessionsScreen.dart';

class BookSessionScreen extends StatelessWidget {
  final TimeSlotModel slot;
  final Map<String, dynamic> coachData;

  const BookSessionScreen({
    super.key,
    required this.slot,
    required this.coachData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookSessionCubit(ScheduleService()),
      child: _BookSessionView(slot: slot, coachData: coachData),
    );
  }
}

class _BookSessionView extends StatefulWidget {
  final TimeSlotModel slot;
  final Map<String, dynamic> coachData;

  const _BookSessionView({
    required this.slot,
    required this.coachData,
  });

  @override
  State<_BookSessionView> createState() => _BookSessionViewState();
}

class _BookSessionViewState extends State<_BookSessionView> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onConfirmBooking(BuildContext context) {
    final coachId = widget.coachData['_id']?.toString() ?? widget.coachData['id']?.toString() ?? '';
    // Format the date if we have a real Date format, otherwise assume slot.date is YYYY-MM-DD
    String scheduledDate = widget.slot.date ?? '';
    if (scheduledDate.isEmpty) {
       // fallback, though it shouldn't happen based on the availability UI
       final now = DateTime.now();
       scheduledDate = DateFormat('yyyy-MM-dd').format(now); 
    }

    context.read<BookSessionCubit>().book(
      coachId: coachId,
      scheduledDate: scheduledDate,
      startTime: widget.slot.startTime,
      endTime: widget.slot.endTime,
      sessionType: widget.slot.sessionType,
      title: _titleController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coachName = widget.coachData['name'] ?? 'Coach';
    final dateDisplay = widget.slot.date != null 
        ? DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(widget.slot.date!))
        : 'Selected Date';

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
          'Confirm Booking',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: BlocListener<BookSessionCubit, BookSessionState>(
        listener: (context, state) {
          if (state is BookSessionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session booked successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Navigate to MySessionsScreen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MySessionsScreen(),
              ),
            );
          } else if (state is BookSessionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppConstants.primaryColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline, color: AppConstants.primaryColor, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          coachName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Color(0xFF2C2C2C)),
                    ),
                    _buildSummaryRow(Icons.calendar_today, 'Date', dateDisplay),
                    const SizedBox(height: 12),
                    _buildSummaryRow(Icons.access_time, 'Time', "\${widget.slot.startTime} - \${widget.slot.endTime}"),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      Icons.videocam_outlined,
                      'Type',
                      widget.slot.sessionType.toUpperCase(),
                      valueColor: Colors.blueAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Optional Details
              const Text(
                'Session Title (Optional)',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g., Weekly Check-in, Form Review',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppConstants.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Confirm Button
              BlocBuilder<BookSessionCubit, BookSessionState>(
                builder: (context, state) {
                  final isLoading = state is BookSessionLoading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : () => _onConfirmBooking(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      disabledBackgroundColor: const Color(0xFF2C2C2C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: const Size(double.infinity, 56),
                      elevation: isLoading ? 0 : 4,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : const Text(
                            "Confirm Booking",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, {Color valueColor = Colors.white}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
