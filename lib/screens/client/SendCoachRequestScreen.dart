import 'package:flutter/material.dart';
import 'package:fit_app/services/coach_service.dart';

class SendCoachRequestScreen extends StatefulWidget {
  final String coachId;
  final String coachName;

  const SendCoachRequestScreen({
    super.key,
    required this.coachId,
    required this.coachName,
  });

  @override
  State<SendCoachRequestScreen> createState() => _SendCoachRequestScreenState();
}

class _SendCoachRequestScreenState extends State<SendCoachRequestScreen> {
  final CoachService _coachService = CoachService();
  final TextEditingController _messageController = TextEditingController();
  
  String _selectedTrainingType = 'online';
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message to the coach.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _coachService.sendCoachRequest(
        coachId: widget.coachId,
        message: message,
        trainingType: _selectedTrainingType,
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, true); // Pop back with success = true
    } catch (e) {
      final errorStr = e.toString().replaceAll('Exception: ', '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorStr.contains('Already requested') ? 'You already sent a request to this coach.' : errorStr),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Request Coach',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send request to ${widget.coachName}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            
            // Training Type Dropdown
            const Text(
              'Preferred Training Type',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F272D),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTrainingType,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1F272D),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
                  items: const [
                    DropdownMenuItem(value: 'online', child: Text('Online Training')),
                    DropdownMenuItem(value: 'offline', child: Text('In-person (Offline)')),
                    DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTrainingType = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Message Field
            const Text(
              'Message to Coach',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F272D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'I want to train with you!',
                  hintStyle: TextStyle(color: Color(0xFFA09D9D)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Send Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD0FD3E),
                  disabledBackgroundColor: const Color(0xFFD0FD3E).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Text(
                      'Send Request',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF0C0C0C),
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD0FD3E)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFFD0FD3E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
