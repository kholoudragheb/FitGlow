import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/progress_log/progress_log_cubit.dart';
import '../../../services/progress_log_service.dart';
import '../../../utils/store_styles.dart';

class CreateProgressLogScreen extends StatefulWidget {
  final String? initialType;

  const CreateProgressLogScreen({
    super.key,
    this.initialType,
  });

  @override
  State<CreateProgressLogScreen> createState() => _CreateProgressLogScreenState();
}

class _CreateProgressLogScreenState extends State<CreateProgressLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _durationController = TextEditingController();
  final _weightController = TextEditingController();
  
  late String _selectedType;
  final List<String> _types = ['workout', 'meal', 'weight', 'cardio', 'progress'];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? 'workout';
  }

  @override
  void dispose() {
    _notesController.dispose();
    _durationController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final body = {
        'type': _selectedType,
        'notes': _notesController.text,
        if (_selectedType == 'workout' || _selectedType == 'cardio') 
          'duration': int.tryParse(_durationController.text),
        if (_selectedType == 'weight')
          'value': double.tryParse(_weightController.text),
      };
      context.read<ProgressLogCubit>().createLog(body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProgressLogCubit(ProgressLogService()),
      child: BlocConsumer<ProgressLogCubit, ProgressLogState>(
        listener: (context, state) {
          if (state is ProgressLogSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Activity logged successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ProgressLogError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ProgressLogLoading;

          return Scaffold(
            backgroundColor: AppConstants.backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Log Activity',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(),
                    const SizedBox(height: 32),
                    if (_selectedType == 'weight') ...[
                      _buildTextField(
                        controller: _weightController,
                        label: 'Current Weight (Kg)',
                        hint: 'e.g. 75.5',
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Please enter weight' : null,
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (_selectedType == 'workout' || _selectedType == 'cardio') ...[
                      _buildTextField(
                        controller: _durationController,
                        label: 'Duration (Minutes)',
                        hint: 'e.g. 45',
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Please enter duration' : null,
                      ),
                      const SizedBox(height: 24),
                    ],
                    _buildTextField(
                      controller: _notesController,
                      label: 'Notes',
                      hint: 'How did it go?',
                      maxLines: 4,
                      validator: (v) => v!.isEmpty ? 'Please enter some notes' : null,
                    ),
                    const SizedBox(height: 48),
                    _buildSubmitButton(isLoading),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT ACTIVITY TYPE',
          style: TextStyle(
            color: StoreColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _types.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? StoreColors.primary : AppConstants.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? StoreColors.primary : Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconForType(type),
                      size: 16,
                      color: isSelected ? Colors.black : Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type[0].toUpperCase() + type.substring(1),
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'workout': return Icons.fitness_center;
      case 'meal': return Icons.restaurant;
      case 'weight': return Icons.monitor_weight;
      case 'cardio': return Icons.directions_run;
      default: return Icons.assignment;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            filled: true,
            fillColor: AppConstants.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: StoreColors.primary),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: StoreColors.primary,
          disabledBackgroundColor: Colors.grey.shade800,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
              )
            : const Text(
                'Save Activity',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
