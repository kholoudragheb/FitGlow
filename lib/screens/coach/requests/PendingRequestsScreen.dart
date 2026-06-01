import 'package:flutter/material.dart';
import 'package:fit_app/services/coach_service.dart';
import 'package:fit_app/models/pending_request_model.dart';
import 'package:fit_app/screens/coach/clients/ClientDetailsScreen.dart';
import 'package:intl/intl.dart';

class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  final CoachService _coachService = CoachService();
  List<PendingRequestModel> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;

  final Set<String> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requests = await _coachService.getPendingRequests();
      if (mounted) {
        setState(() {
          _requests = requests;
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

  void _showRespondConfirmation(String requestId, String status, String clientName) {
    final bool isAccept = status == 'accepted';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F272D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isAccept ? 'Accept Request?' : 'Reject Request?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isAccept 
            ? 'Are you sure you want to accept $clientName as your client?'
            : 'Are you sure you want to reject this request from $clientName?',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _respondToRequest(requestId, status);
            },
            child: Text(
              isAccept ? 'Yes, Accept' : 'Yes, Reject',
              style: TextStyle(
                color: isAccept ? const Color(0xFFD0FD3E) : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _respondToRequest(String requestId, String status) async {
    setState(() {
      _processingIds.add(requestId);
    });

    try {
      await _coachService.respondToRequest(requestId: requestId, status: status);
      
      if (mounted) {
        setState(() {
          _processingIds.remove(requestId);
          _requests.removeWhere((r) => r.id == requestId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'accepted' ? 'Client request accepted' : 'Client request rejected'),
            backgroundColor: status == 'accepted' ? Colors.green : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _processingIds.remove(requestId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
          'Pending Requests',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRequests,
        color: const Color(0xFFD0FD3E),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD0FD3E)))
            : _errorMessage != null
                ? _buildErrorState()
                : _requests.isEmpty
                    ? _buildEmptyState()
                    : _buildRequestsList(),
      ),
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
              onPressed: _fetchRequests,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD0FD3E)),
              child: const Text('Retry', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_late_outlined, color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            const Text(
              'No pending requests',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'You don\'t have any new client requests at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: _fetchRequests,
              child: const Text('Refresh', style: TextStyle(color: Color(0xFFD0FD3E))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        final client = request.client;
        final DateTime? date = DateTime.tryParse(request.createdAt);
        final String formattedDate = date != null ? DateFormat('MMM dd, yyyy').format(date) : '';
        final bool isProcessing = _processingIds.contains(request.id);
        
        // Initials for avatar
        String initials = '';
        if (client.firstName.isNotEmpty) initials += client.firstName[0].toUpperCase();
        if (client.lastName.isNotEmpty) initials += client.lastName[0].toUpperCase();
        if (initials.isEmpty) initials = '?';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1F272D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFFD0FD3E).withValues(alpha: 0.2),
                    child: Text(
                      initials,
                      style: const TextStyle(color: Color(0xFFD0FD3E), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.fullName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          client.email,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge('PENDING'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Message:',
                style: TextStyle(color: Color(0xFFD0FD3E), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                request.message,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fitness_center, color: Colors.grey, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Training: ${request.trainingType.toUpperCase()}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isProcessing ? null : () => _showRespondConfirmation(request.id, 'rejected', client.fullName),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: isProcessing 
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent)))
                        : const Text('Reject', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : () => _showRespondConfirmation(request.id, 'accepted', client.fullName),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD0FD3E),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: isProcessing 
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
                        : const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: isProcessing ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientDetailsScreen(clientId: client.id),
                      ),
                    );
                  },
                  child: const Text('View Client Profile', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
