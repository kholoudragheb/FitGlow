import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/schedule/session_details_cubit.dart';
import '../../../models/session_model.dart';
import '../../../services/schedule_service.dart';

class SessionDetailsScreen extends StatelessWidget {
  final String sessionId;

  const SessionDetailsScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SessionDetailsCubit(ScheduleService())..fetchSessionDetails(sessionId),
      child: const _SessionDetailsView(),
    );
  }
}

class _SessionDetailsView extends StatelessWidget {
  const _SessionDetailsView();

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
          'Session Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocListener<SessionDetailsCubit, SessionDetailsState>(
        listener: (context, state) {
          if (state is SessionDetailsSuccess && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is SessionDetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppConstants.errorColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<SessionDetailsCubit, SessionDetailsState>(
          builder: (context, state) {
            if (state is SessionDetailsLoading) {
              return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
            } else if (state is SessionDetailsError) {
              return _buildErrorState(context, state.message);
            } else if (state is SessionDetailsSuccess) {
              return _buildContent(context, state.session, false);
            } else if (state is SessionActionLoading) {
              return _buildContent(context, state.currentSession, true);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppConstants.errorColor, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<SessionDetailsCubit>().fetchSessionDetails(
                (context.findAncestorWidgetOfExactType<SessionDetailsScreen>()!).sessionId
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SessionModel session, bool isActionLoading) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => context.read<SessionDetailsCubit>().fetchSessionDetails(session.id),
          color: AppConstants.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(session),
                const SizedBox(height: 24),
                _buildInfoSection(
                  title: 'Client Information',
                  child: _buildClientCard(session),
                ),
                const SizedBox(height: 24),
                _buildInfoSection(
                  title: 'Session Schedule',
                  child: _buildScheduleCard(session),
                ),
                const SizedBox(height: 24),
                _buildInfoSection(
                  title: 'Session Type',
                  child: _buildTypeCard(session),
                ),
                if (session.sessionType.toLowerCase() == 'online') ...[
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    title: 'Meeting Link',
                    child: _buildMeetingLinkCard(context, session),
                  ),
                ],
                if (session.notes != null && session.notes!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    title: 'Notes',
                    child: _buildNotesCard(session),
                  ),
                ],
                if (session.status.toLowerCase() == 'canceled' || session.status.toLowerCase() == 'cancelled') ...[
                  if (session.cancelReason != null && session.cancelReason!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildInfoSection(
                      title: 'Cancellation Reason',
                      child: _buildCancelReasonCard(session),
                    ),
                  ],
                ],
                const SizedBox(height: 32),
                _buildActions(context, session),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        if (isActionLoading)
          Container(
            color: Colors.black45,
            child: const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor)),
          ),
      ],
    );
  }

  Widget _buildStatusHeader(SessionModel session) {
    Color statusColor;
    switch (session.status.toLowerCase()) {
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      case 'canceled':
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.title ?? 'No Title',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Session ID: ${session.id.substring(session.id.length > 8 ? session.id.length - 8 : 0)}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.5)),
          ),
          child: Text(
            session.status.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppConstants.primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildClientCard(SessionModel session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppConstants.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.clientName ?? 'Unknown Client',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (session.clientEmail != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    session.clientEmail!,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {}, // TODO: Implement chat navigation
            icon: const Icon(Icons.chat_bubble_outline, color: AppConstants.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(SessionModel session) {
    DateTime date = DateTime.tryParse(session.scheduledDate) ?? DateTime.now();
    String formattedDate = DateFormat('EEEE, MMMM dd, yyyy').format(date);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.calendar_today, 'Date', formattedDate),
          const Divider(color: Colors.white10, height: 24),
          _buildInfoRow(Icons.access_time, 'Time', '${session.startTime} - ${session.endTime}'),
        ],
      ),
    );
  }

  Widget _buildTypeCard(SessionModel session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            session.sessionType.toLowerCase() == 'online' ? Icons.videocam : Icons.location_on,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 16),
          Text(
            session.sessionType.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(SessionModel session) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        session.notes!,
        style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
      ),
    );
  }

  Widget _buildCancelReasonCard(SessionModel session) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.errorColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.errorColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        session.cancelReason!,
        style: const TextStyle(color: AppConstants.errorColor, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildMeetingLinkCard(BuildContext context, SessionModel session) {
    final hasLink = session.meetingLink != null && session.meetingLink!.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasLink ? AppConstants.primaryColor.withValues(alpha: 0.3) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.link,
            color: hasLink ? AppConstants.primaryColor : Colors.white24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              hasLink ? session.meetingLink! : 'No meeting link added yet',
              style: TextStyle(
                color: hasLink ? Colors.white : Colors.white24,
                fontSize: 14,
                decoration: hasLink ? TextDecoration.underline : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasLink)
            IconButton(
              onPressed: () {
                // TODO: Launch URL
              },
              icon: const Icon(Icons.open_in_new, color: AppConstants.primaryColor, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, SessionModel session) {
    final status = session.status.toLowerCase();
    
    if (status == 'canceled' || status == 'cancelled') {
      return const Center(
        child: Text(
          'This session was canceled.',
          style: TextStyle(color: AppConstants.errorColor, fontWeight: FontWeight.bold),
        ),
      );
    }

    if (status == 'completed') {
      return const Center(
        child: Text(
          'This session is completed.',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Column(
      children: [
        if (status == 'pending')
          _buildActionButton(
            context,
            'Confirm Session',
            Colors.green,
            () => context.read<SessionDetailsCubit>().updateStatus(session.id, 'confirmed'),
          ),
        if (status == 'confirmed') ...[
          _buildActionButton(
            context,
            'Mark as Completed',
            AppConstants.primaryColor,
            () => context.read<SessionDetailsCubit>().updateStatus(session.id, 'completed'),
            textColor: Colors.black,
          ),
          const SizedBox(height: 12),
        ],
        if (status != 'completed') ...[
          if (session.sessionType.toLowerCase() == 'online') ...[
            _buildActionButton(
              context,
              session.meetingLink == null || session.meetingLink!.isEmpty 
                  ? 'Add Meeting Link' 
                  : 'Edit Meeting Link',
              const Color(0xFF2C2C2C),
              () => _showMeetingLinkDialog(context, session),
            ),
            const SizedBox(height: 12),
          ],
          _buildActionButton(
            context,
            'Add / Edit Notes',
            const Color(0xFF2C2C2C),
            () => _showNotesDialog(context, session),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context,
            'Cancel Session',
            AppConstants.errorColor.withValues(alpha: 0.1),
            () => _showCancelConfirmation(context, session),
            textColor: AppConstants.errorColor,
            outline: true,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onPressed, {
    Color textColor = Colors.white,
    bool outline = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: outline
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
    );
  }

  void _showMeetingLinkDialog(BuildContext context, SessionModel session) {
    final TextEditingController controller = TextEditingController(text: session.meetingLink);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Meeting Link', style: TextStyle(color: Colors.white)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'https://zoom.us/j/...',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.link, color: Colors.white54),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a link';
              final uri = Uri.tryParse(value);
              if (uri == null || !uri.hasAbsolutePath) return 'Please enter a valid URL';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<SessionDetailsCubit>().updateMeetingLink(session.id, controller.text.trim());
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showNotesDialog(BuildContext context, SessionModel session) {
    final TextEditingController controller = TextEditingController(text: session.notes);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Session Notes', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter notes about the session...',
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SessionDetailsCubit>().addNotes(session.id, controller.text);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, SessionModel session) {
    final TextEditingController reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppConstants.errorColor, size: 28),
            const SizedBox(width: 12),
            const Text('Cancel Session?', style: TextStyle(color: Colors.white, fontSize: 20)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please provide a reason for canceling this session.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g., Cannot make it today',
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Reason is required';
                  if (value.trim().length < 3) return 'Reason must be at least 3 characters';
                  return null;
                },
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep Session', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<SessionDetailsCubit>().cancelSession(
                  session.id, 
                  reasonController.text.trim()
                );
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Confirm Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
