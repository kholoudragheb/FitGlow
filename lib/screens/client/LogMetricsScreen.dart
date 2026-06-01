import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/progress_log/metric_log_cubit.dart';
import '../../../services/progress_log_service.dart';
import '../../../utils/store_styles.dart';

class LogMetricsScreen extends StatefulWidget {
  const LogMetricsScreen({super.key});

  @override
  State<LogMetricsScreen> createState() => _LogMetricsScreenState();
}

class _LogMetricsScreenState extends State<LogMetricsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _waistController = TextEditingController();
  final _chestController = TextEditingController();
  final _hipsController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _waistController.dispose();
    _chestController.dispose();
    _hipsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: StoreColors.primary,
              onPrimary: Colors.black,
              surface: AppConstants.surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final body = {
        'weight': double.tryParse(_weightController.text),
        if (_bodyFatController.text.isNotEmpty) 'bodyFat': double.tryParse(_bodyFatController.text),
        if (_waistController.text.isNotEmpty) 'waist': double.tryParse(_waistController.text),
        if (_chestController.text.isNotEmpty) 'chest': double.tryParse(_chestController.text),
        if (_hipsController.text.isNotEmpty) 'hips': double.tryParse(_hipsController.text),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      };
      context.read<MetricLogCubit>().logMetrics(body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MetricLogCubit(ProgressLogService()),
      child: BlocConsumer<MetricLogCubit, MetricLogState>(
        listener: (context, state) {
          if (state is MetricLogSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Metrics saved successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is MetricLogError) {
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
          final isLoading = state is MetricLogLoading;

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
                'Body Metrics',
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
                    _buildSectionHeader("PRIMARY METRICS"),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _weightController,
                      label: 'Weight (Kg)',
                      hint: '0.0',
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _bodyFatController,
                      label: 'Body Fat (%)',
                      hint: 'Optional',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),
                    
                    _buildSectionHeader("MEASUREMENTS (OPTIONAL)"),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _waistController,
                            label: 'Waist (cm)',
                            hint: '0.0',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _chestController,
                            label: 'Chest (cm)',
                            hint: '0.0',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _hipsController,
                      label: 'Hips (cm)',
                      hint: '0.0',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),

                    _buildSectionHeader("LOGGING DATE"),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectDate(context),
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
                              DateFormat('MMMM dd, yyyy').format(_selectedDate),
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
                'Save Metrics',
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
