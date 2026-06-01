import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/plan_model.dart';
import '../../../services/plan_service.dart';
import 'PlanDetailsScreen.dart';

class ClientPlansScreen extends StatefulWidget {
  final String clientId;
  final String clientName;

  const ClientPlansScreen({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<ClientPlansScreen> createState() => _ClientPlansScreenState();
}

class _ClientPlansScreenState extends State<ClientPlansScreen> {
  final PlanService _planService = PlanService();
  bool _isLoading = true;
  List<PlanModel> _plans = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final plans = await _planService.getClientPlans(widget.clientId);
      if (mounted) {
        setState(() {
          _plans = plans;
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
        title: Text(
          "${widget.clientName}'s Plans",
          style: AppConstants.headlineMedium.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPlans,
        color: AppConstants.primaryColor,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
            : _error != null
                ? _buildErrorState()
                : _plans.isEmpty
                    ? _buildEmptyState()
                    : _buildPlansList(),
      ),
    );
  }

  Widget _buildPlansList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _plans.length,
      itemBuilder: (context, index) {
        final plan = _plans[index];
        return _buildPlanCard(plan);
      },
    );
  }

  Widget _buildPlanCard(PlanModel plan) {
    final Color typeColor = plan.type == 'workout' 
        ? Colors.blueAccent 
        : plan.type == 'nutrition' 
            ? Colors.greenAccent 
            : Colors.orangeAccent;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlanDetailsScreen(planId: plan.id),
          ),
        );
        if (result == true) {
          _fetchPlans();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                plan.type == 'workout' 
                    ? Icons.fitness_center 
                    : plan.type == 'nutrition' 
                        ? Icons.restaurant 
                        : Icons.assignment,
                color: typeColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: AppConstants.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${plan.type.toUpperCase()} • ${plan.durationWeeks} Weeks",
                    style: AppConstants.bodyMedium.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          Text(
            "No plans found",
            style: AppConstants.bodyLarge.copyWith(color: Colors.white60),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Go Back", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
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
              onPressed: _fetchPlans,
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
              child: const Text('Retry', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
