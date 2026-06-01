import 'package:flutter/material.dart';
import 'package:fit_app/services/coach_service.dart';
import 'package:fit_app/models/client_details_model.dart';
import 'package:fit_app/screens/coach/plans/CreatePlanScreen.dart';
import 'package:fit_app/screens/coach/plans/ClientPlansScreen.dart';
import 'package:intl/intl.dart';

class ClientDetailsScreen extends StatefulWidget {
  final String clientId;

  const ClientDetailsScreen({super.key, required this.clientId});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  final CoachService _coachService = CoachService();
  ClientDetailsModel? _details;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final details = await _coachService.getClientDetails(widget.clientId);
      if (mounted) {
        setState(() {
          _details = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _showEditNotesDialog() {
    final TextEditingController notesController = TextEditingController(text: _details?.notes ?? '');
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1F272D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Coach Notes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: notesController,
            maxLines: 5,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter notes about client progress...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.black12,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isUpdating ? null : () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: _isUpdating ? null : () async {
                setDialogState(() => _isUpdating = true);
                await _updateNotes(notesController.text);
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD0FD3E),
                disabledBackgroundColor: Colors.grey,
              ),
              child: _isUpdating 
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('Save Notes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateNotes(String newNotes) async {
    setState(() => _isUpdating = true);
    try {
      final updated = await _coachService.updateClientDetails(
        clientId: widget.clientId,
        body: {'notes': newNotes},
      );
      if (mounted) {
        setState(() {
          _details = updated;
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client details updated successfully'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _removeClient() async {
    setState(() => _isUpdating = true);
    try {
      await _coachService.removeClient(widget.clientId);
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Client removed successfully'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate client was removed
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showRemoveConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F272D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Client?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This client will be deactivated from your list. You will still be able to see past records, but active coaching will stop.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeClient();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Client Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)))
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchDetails,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD0FD3E)),
              child: const Text('Retry', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final client = _details!.client;
    String initials = '';
    if (client.firstName.isNotEmpty) initials += client.firstName[0].toUpperCase();
    if (client.lastName.isNotEmpty) initials += client.lastName[0].toUpperCase();
    if (initials.isEmpty) initials = '?';

    final startDate = DateTime.tryParse(_details!.startDate);
    final formattedStartDate = startDate != null ? DateFormat('MMM dd, yyyy').format(startDate) : 'Not started';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Profile
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFD0FD3E).withValues(alpha: 0.2),
                  child: Text(
                    initials,
                    style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  client.fullName,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  client.email,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 16),
                _buildStatusBadge(_details!.isActive),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Details Card
          _buildInfoCard(
            title: 'Training Information',
            children: [
              _buildInfoRow(Icons.fitness_center, 'Training Type', _details!.trainingType.toUpperCase()),
              _buildInfoRow(Icons.calendar_today, 'Start Date', formattedStartDate),
              if (_details!.lastActivityAt != null)
                _buildInfoRow(Icons.history, 'Last Active', DateFormat('MMM dd, HH:mm').format(DateTime.parse(_details!.lastActivityAt!))),
            ],
          ),
          const SizedBox(height: 16),

          // Coach Notes Section
          _buildInfoCard(
            title: 'Coach Notes',
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Internal Notes', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  IconButton(
                    onPressed: _showEditNotesDialog,
                    icon: const Icon(Icons.edit, color: Color(0xFFD0FD3E), size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                (_details!.notes == null || _details!.notes!.isEmpty) 
                  ? 'No notes yet. Tap edit to add progress notes for this client.'
                  : _details!.notes!,
                style: TextStyle(
                  color: (_details!.notes == null || _details!.notes!.isEmpty) ? Colors.grey : Colors.white70,
                  fontSize: 14,
                  fontStyle: (_details!.notes == null || _details!.notes!.isEmpty) ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Section
          _buildInfoCard(
            title: 'Goal Progress',
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Overall Completion', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text('${_details!.progressPercentage.toInt()}%',
                      style: const TextStyle(color: Color(0xFFD0FD3E), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _details!.progressPercentage / 100,
                backgroundColor: Colors.white10,
                color: const Color(0xFFD0FD3E),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Health Conditions
          _buildInfoCard(
            title: 'Health Conditions',
            children: [
              if (client.healthConditions.isEmpty)
                const Text('No health conditions reported', style: TextStyle(color: Colors.grey, fontSize: 14))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: client.healthConditions.map((condition) => _buildChip(condition)).toList(),
                ),
            ],
          ),
          const SizedBox(height: 32),

          // Action Buttons
          const Text('Actions', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildActionButton(
            'Create Workout Plan', 
            Icons.edit_note, 
            _details!.isActive ? () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePlanScreen(
                    clientId: widget.clientId,
                    initialType: 'workout',
                  ),
                ),
              );
              if (result == true && mounted) {
                _fetchDetails(); // Refresh details if needed
              }
            } : null
          ),
          _buildActionButton(
            'Create Meal Plan', 
            Icons.restaurant_menu, 
            _details!.isActive ? () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePlanScreen(
                    clientId: widget.clientId,
                    initialType: 'nutrition',
                  ),
                ),
              );
              if (result == true && mounted) {
                _fetchDetails();
              }
            } : null
          ),
          _buildActionButton(
            'View All Plans', 
            Icons.list_alt, 
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClientPlansScreen(
                    clientId: widget.clientId,
                    clientName: _details!.client.fullName,
                  ),
                ),
              );
            }
          ),
          _buildActionButton(
            'Chat with Client', 
            Icons.chat_bubble_outline, 
            _details!.isActive ? () {} : null
          ),
          _buildActionButton(
            'Update Progress', 
            Icons.trending_up, 
            _details!.isActive ? () {} : null,
            isLast: true
          ),
          
          if (_details!.isActive) ...[
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isUpdating ? null : _showRemoveConfirmation,
                icon: const Icon(Icons.person_remove_outlined, size: 20),
                label: const Text('Remove Client from List'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? Colors.green.withValues(alpha: 0.5) : Colors.red.withValues(alpha: 0.5)),
      ),
      child: Text(
        isActive ? 'ACTIVE CLIENT' : 'INACTIVE',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.redAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F272D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback? onTap, {bool isLast = false}) {
    final bool isDisabled = onTap == null;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDisabled ? const Color(0xFF1F272D).withValues(alpha: 0.5) : const Color(0xFF1F272D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Icon(icon, color: isDisabled ? Colors.grey : const Color(0xFFD0FD3E), size: 24),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isDisabled ? Colors.grey : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: isDisabled ? Colors.grey.withValues(alpha: 0.3) : Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
