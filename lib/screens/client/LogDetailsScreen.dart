import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/progress_log/log_details_cubit.dart';
import '../../../services/progress_log_service.dart';
import '../../../utils/store_styles.dart';

class LogDetailsScreen extends StatelessWidget {
  final String logId;

  const LogDetailsScreen({super.key, required this.logId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LogDetailsCubit(ProgressLogService())..fetchLogDetails(logId),
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Log Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<LogDetailsCubit, LogDetailsState>(
          builder: (context, state) {
            if (state is LogDetailsLoading) {
              return const Center(child: CircularProgressIndicator(color: StoreColors.primary));
            }

            if (state is LogDetailsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(state.message, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<LogDetailsCubit>().fetchLogDetails(logId),
                      style: ElevatedButton.styleFrom(backgroundColor: StoreColors.primary),
                      child: const Text('Retry', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }

            if (state is LogDetailsSuccess) {
              final log = state.log;
              final Color typeColor = _getTypeColor(log.type);
              final IconData typeIcon = _getTypeIcon(log.type);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            typeColor.withValues(alpha: 0.2),
                            typeColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: typeColor.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Icon(typeIcon, color: typeColor, size: 64),
                          const SizedBox(height: 24),
                          Text(
                            log.type.toUpperCase(),
                            style: TextStyle(
                              color: typeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (log.duration != null && log.duration! > 0)
                            Text(
                              "${log.duration} Minutes",
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                            )
                          else if (log.value != null)
                            Text(
                              "${log.value}",
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                            )
                          else
                            const Text(
                              "Activity Log",
                              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Metadata Section
                    const Text(
                      "GENERAL INFO",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(Icons.calendar_today, "Date", DateFormat('EEEE, MMM dd, yyyy').format(log.createdAt)),
                    const SizedBox(height: 12),
                    _buildInfoCard(Icons.access_time, "Time", DateFormat('hh:mm a').format(log.createdAt)),
                    const SizedBox(height: 12),
                    _buildInfoCard(Icons.check_circle_outline, "Status", log.status.toUpperCase(), 
                        valueColor: log.status.toLowerCase() == 'completed' ? Colors.greenAccent : Colors.orangeAccent),
                    
                    const SizedBox(height: 32),
                    
                    // Notes Section
                    if (log.notes != null && log.notes!.isNotEmpty) ...[
                      const Text(
                        "NOTES",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Text(
                          log.notes!,
                          style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 40),
                    
                    // Last Updated
                    Center(
                      child: Text(
                        "Last updated: ${DateFormat('MMM dd, HH:mm').format(log.updatedAt)}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: StoreColors.primary, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'workout': return Colors.blueAccent;
      case 'nutrition': return Colors.greenAccent;
      case 'check-in': return Colors.purpleAccent;
      default: return StoreColors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'workout': return Icons.fitness_center;
      case 'nutrition': return Icons.restaurant;
      case 'check-in': return Icons.assignment_turned_in;
      default: return Icons.history;
    }
  }
}
