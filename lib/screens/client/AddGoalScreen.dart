import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/goals/goals_cubit.dart';
import '../../../services/progress_log_service.dart';
import '../../../utils/store_styles.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _targetValueController = TextEditingController();
  
  String _selectedUnit = 'kg';
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  late CreateGoalCubit _createGoalCubit;

  final List<String> _units = ['kg', 'lbs', '%', 'reps', 'km', 'miles'];

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTitleChanged);
    _createGoalCubit = CreateGoalCubit(ProgressLogService());
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _currentValueController.dispose();
    _targetValueController.dispose();
    _createGoalCubit.close();
    super.dispose();
  }

  void _onTitleChanged() {
    final title = _titleController.text.toLowerCase();
    String? detectedUnit;

    if (title.contains('weight') || title.contains('lose') || title.contains('gain')) {
      detectedUnit = 'kg';
    } else if (title.contains('run') || title.contains('walk') || title.contains('distance')) {
      detectedUnit = 'km';
    } else if (title.contains('fat') || title.contains('body') || title.contains('%')) {
      detectedUnit = '%';
    } else if (title.contains('reps') || title.contains('pushup') || title.contains('squat')) {
      detectedUnit = 'reps';
    }

    if (detectedUnit != null && detectedUnit != _selectedUnit) {
      setState(() {
        _selectedUnit = detectedUnit!;
      });
    }
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: StoreColors.primary,
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final body = {
        'title': _titleController.text,
        'targetValue': double.tryParse(_targetValueController.text),
        'currentValue': double.tryParse(_currentValueController.text) ?? 0.0,
        'unit': _selectedUnit,
        'deadline': DateFormat('yyyy-MM-dd').format(_deadline),
      };
      _createGoalCubit.createGoal(body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _createGoalCubit,
      child: BlocConsumer<CreateGoalCubit, CreateGoalState>(
        listener: (context, state) {
          if (state is CreateGoalSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Goal created successfully! 🎯'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is CreateGoalError) {
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
          final isLoading = state is CreateGoalLoading;

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
                'Create New Goal',
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
                    _buildSectionHeader("GOAL DETAILS"),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _titleController,
                      label: 'Goal Title',
                      hint: 'e.g., Lose 5kg of body weight',
                      validator: (v) => v!.isEmpty ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _currentValueController,
                            label: 'Current Value',
                            hint: '0.0',
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _targetValueController,
                            label: 'Target Value',
                            hint: '0.0',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v!.isEmpty) return 'Required';
                              if (double.tryParse(v) == 0) return 'Must be > 0';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildUnitSelector(),
                    const SizedBox(height: 32),
                    
                    _buildSectionHeader("DEADLINE"),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectDeadline(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppConstants.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMMM dd, yyyy').format(_deadline),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                            const Icon(Icons.calendar_today, color: StoreColors.primary, size: 20),
                          ],
                        ),
                      ),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: StoreColors.primary,
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
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

  Widget _buildUnitSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unit',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedUnit,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E1E1E),
              icon: const Icon(Icons.keyboard_arrow_down, color: StoreColors.primary),
              items: _units.map((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedUnit = newValue;
                  });
                }
              },
            ),
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
                'Create Goal',
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
