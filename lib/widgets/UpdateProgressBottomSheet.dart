import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/goal_model.dart';
import '../logic/cubits/goals/goals_cubit.dart';
import '../services/progress_log_service.dart';
import '../utils/store_styles.dart';

class UpdateProgressBottomSheet extends StatefulWidget {
  final GoalModel goal;

  const UpdateProgressBottomSheet({super.key, required this.goal});

  @override
  State<UpdateProgressBottomSheet> createState() => _UpdateProgressBottomSheetState();
}

class _UpdateProgressBottomSheetState extends State<UpdateProgressBottomSheet> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.goal.currentValue.toStringAsFixed(widget.goal.currentValue % 1 == 0 ? 0 : 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _adjustValue(double delta) {
    double current = double.tryParse(_controller.text) ?? 0;
    setState(() {
      _controller.text = (current + delta).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UpdateGoalCubit(ProgressLogService()),
      child: BlocConsumer<UpdateGoalCubit, UpdateGoalState>(
        listener: (context, state) {
          if (state is UpdateGoalSuccess) {
            Navigator.pop(context, true);
          } else if (state is UpdateGoalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is UpdateGoalLoading;

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 32,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Update Progress",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.goal.title,
                            style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: StoreColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.goal.unit,
                          style: const TextStyle(color: StoreColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _buildAdjustButton(Icons.remove, () => _adjustValue(-1)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextFormField(
                            controller: _controller,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(vertical: 20),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (double.tryParse(v) == null) return 'Invalid number';
                              if (double.parse(v) < 0) return 'Cannot be negative';
                              return null;
                            },
                          ),
                        ),
                      ),
                      _buildAdjustButton(Icons.add, () => _adjustValue(1)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () {
                        if (_formKey.currentState!.validate()) {
                          context.read<UpdateGoalCubit>().updateProgress(
                            widget.goal.id,
                            double.parse(_controller.text),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StoreColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                          : const Text(
                              "Save Progress",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
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

  Widget _buildAdjustButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
