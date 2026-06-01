import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/plan_model.dart';
import '../../../services/plan_service.dart';
import 'UpdatePlanScreen.dart';
import '../../client/PlanLogsScreen.dart';

class PlanDetailsScreen extends StatefulWidget {
  final String planId;

  const PlanDetailsScreen({
    super.key,
    required this.planId,
  });

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  final PlanService _planService = PlanService();
  bool _isLoading = true;
  PlanModel? _plan;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPlan();
  }

  Future<void> _fetchPlan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final plan = await _planService.getPlanById(widget.planId);
      if (mounted) {
        setState(() {
          _plan = plan;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
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
        actions: [
          if (_plan != null)
            TextButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdatePlanScreen(plan: _plan!),
                  ),
                );
                if (result == true) {
                  _fetchPlan();
                }
              },
              child: const Text(
                "Edit",
                style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
        ],
        title: Text(
          "Plan Details",
          style: AppConstants.headlineMedium.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_plan == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildInfoGrid(),
          const SizedBox(height: 32),
          _buildSection("Description", _plan!.description),
          if (_plan!.notes != null && _plan!.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSection("Internal Notes", _plan!.notes!),
          ],
          const SizedBox(height: 32),
          _buildActivityButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActivityButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlanLogsScreen(plan: _plan!),
            ),
          );
        },
        icon: const Icon(Icons.history, color: AppConstants.primaryColor),
        label: const Text(
          "View Activity History",
          style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppConstants.primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppConstants.primaryColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            _plan!.type.toUpperCase(),
            style: const TextStyle(
              color: AppConstants.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _plan!.status.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid() {
    return Column(
      children: [
        Text(
          _plan!.title,
          style: AppConstants.headlineMedium.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildInfoCard("Duration", "${_plan!.durationWeeks} Weeks", Icons.calendar_today)),
            const SizedBox(width: 12),
            Expanded(child: _buildInfoCard("Frequency", "${_plan!.daysPerWeek} Days/Wk", Icons.repeat)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildInfoCard("Difficulty", _plan!.difficulty.toUpperCase(), Icons.speed)),
            const SizedBox(width: 12),
            Expanded(child: _buildInfoCard("Created", _formatDate(_plan!.createdAt), Icons.history)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppConstants.primaryColor, size: 20),
          const SizedBox(height: 12),
          Text(label, style: AppConstants.bodyMedium.copyWith(fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: AppConstants.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppConstants.bodyMedium.copyWith(
            color: AppConstants.primaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            content,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchPlan,
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
              child: const Text('Retry', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
