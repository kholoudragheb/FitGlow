import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/create_plan/create_plan_cubit.dart';
import '../../../models/plan_model.dart';
import '../../../services/plan_service.dart';

class CreatePlanScreen extends StatefulWidget {
  final String clientId;
  final String? initialType;

  const CreatePlanScreen({
    super.key,
    required this.clientId,
    this.initialType,
  });

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  
  String _selectedType = 'workout';
  String _selectedDifficulty = 'beginner';
  int _durationWeeks = 4;
  int _daysPerWeek = 3;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _notesController = TextEditingController();
    if (widget.initialType != null) {
      _selectedType = widget.initialType!.toLowerCase();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final request = PlanCreateRequest(
        clientId: widget.clientId,
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
        durationWeeks: _durationWeeks,
        daysPerWeek: _daysPerWeek,
        difficulty: _selectedDifficulty,
        notes: _notesController.text,
      );
      context.read<CreatePlanCubit>().createPlan(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreatePlanCubit(PlanService()),
      child: BlocConsumer<CreatePlanCubit, CreatePlanState>(
        listener: (context, state) {
          if (state is CreatePlanSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Plan created successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is CreatePlanError) {
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
          final isLoading = state is CreatePlanLoading;

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
                'Create New Plan',
                style: AppConstants.headlineMedium.copyWith(fontSize: 18),
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
                    _buildSectionTitle('Plan Basics'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _titleController,
                      label: 'Plan Title',
                      hint: 'e.g. 4-Week Fat Loss',
                      validator: (v) => v!.isEmpty ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Plan Type',
                      value: _selectedType,
                      items: ['workout', 'nutrition', 'custom'],
                      onChanged: (v) => setState(() => _selectedType = v!),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Configuration'),
                    const SizedBox(height: 16),
                    _buildDifficultySelector(),
                    const SizedBox(height: 24),
                    _buildCounterRow(
                      label: 'Duration (Weeks)',
                      value: _durationWeeks,
                      onChanged: (v) => setState(() => _durationWeeks = v),
                      min: 1,
                      max: 52,
                    ),
                    const SizedBox(height: 16),
                    _buildCounterRow(
                      label: 'Days Per Week',
                      value: _daysPerWeek,
                      onChanged: (v) => setState(() => _daysPerWeek = v),
                      min: 1,
                      max: 7,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Content & Notes'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'What is this plan about?',
                      maxLines: 4,
                      validator: (v) => v!.isEmpty ? 'Please enter a description' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _notesController,
                      label: 'Internal Notes',
                      hint: 'Private notes for you (optional)',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 40),
                    _buildSubmitButton(context, isLoading),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: AppConstants.bodyMedium.copyWith(
        color: AppConstants.primaryColor,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        fontSize: 12,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppConstants.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
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
              borderSide: const BorderSide(color: AppConstants.primaryColor),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppConstants.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppConstants.surfaceColor,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppConstants.primaryColor),
              items: items.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type[0].toUpperCase() + type.substring(1),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Difficulty Level', style: AppConstants.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          children: ['beginner', 'intermediate', 'advanced'].map((diff) {
            final isSelected = _selectedDifficulty == diff;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDifficulty = diff),
                child: Container(
                  margin: EdgeInsets.only(right: diff == 'advanced' ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppConstants.primaryColor : AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppConstants.primaryColor : Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    diff[0].toUpperCase() + diff.substring(1),
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCounterRow({
    required String label,
    required int value,
    required void Function(int) onChanged,
    required int min,
    required int max,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppConstants.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
        Container(
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove, size: 18),
                color: AppConstants.primaryColor,
                disabledColor: Colors.grey,
              ),
              Text(
                value.toString(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add, size: 18),
                color: AppConstants.primaryColor,
                disabledColor: Colors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
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
                'Create Plan',
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
