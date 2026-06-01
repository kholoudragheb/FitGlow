import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fit_app/utils/store_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fit_app/logic/cubits/progress_log/progress_log_cubit.dart';
import 'package:fit_app/logic/cubits/progress_log/progress_stats_cubit.dart';
import 'package:fit_app/logic/cubits/progress_log/metric_history_cubit.dart';
import 'package:fit_app/models/metric_log_model.dart';
import 'package:fit_app/screens/client/LogMetricsScreen.dart';
import 'package:fit_app/services/progress_log_service.dart';
import 'package:intl/intl.dart';

class ProgressChartScreen extends StatefulWidget {
  const ProgressChartScreen({super.key});

  @override
  State<ProgressChartScreen> createState() => _ProgressChartScreenState();
}

class _ProgressChartScreenState extends State<ProgressChartScreen> {
  final TextEditingController _weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MetricHistoryCubit(ProgressLogService())..fetchHistory(),
      child: Scaffold(
        backgroundColor: StoreColors.background,
        appBar: AppBar(
          backgroundColor: StoreColors.background,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: SvgPicture.asset(
                'lib/assets/images/profile/ic_back_arrow_square.svg',
                width: 32,
                height: 32,
              ),
            ),
          ),
          leadingWidth: 48,
          title: const Text(
            'Progress Chart',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: StoreColors.textWhite,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: BlocBuilder<MetricHistoryCubit, MetricHistoryState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () => context.read<MetricHistoryCubit>().fetchHistory(),
                color: StoreColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'Track your transformation',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFFD1CDCD),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Stats Summary
                      BlocProvider(
                        create: (context) => ProgressStatsCubit(ProgressLogService())..fetchStats(),
                        child: BlocBuilder<ProgressStatsCubit, ProgressStatsState>(
                          builder: (context, statsState) {
                            if (statsState is ProgressStatsSuccess) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildMiniStat('Streak', '${statsState.stats.streakDays}d'),
                                  _buildMiniStat('Workouts', '${statsState.stats.workoutsCompleted}'),
                                  _buildMiniStat('Minutes', '${statsState.stats.totalMinutes}m'),
                                  _buildMiniStat('Avg Dur', '${statsState.stats.averageDuration.toInt()}m'),
                                ],
                              );
                            }
                            return const SizedBox(height: 40);
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 32),

                      // Chart Area
                      if (state is MetricHistorySuccess)
                        _buildChartSection(state.metrics)
                      else if (state is MetricHistoryLoading)
                        const SizedBox(height: 220, child: Center(child: CircularProgressIndicator(color: StoreColors.primary)))
                      else
                        const SizedBox(height: 220, child: Center(child: Text("No metrics recorded yet", style: TextStyle(color: Colors.white24)))),

                      const SizedBox(height: 48),

                      // Weight Log Card
                      _buildWeightLogCard(context),

                      const SizedBox(height: 32),
                      
                      // Metrics History Timeline
                      const Text(
                        'History',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: StoreColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (state is MetricHistorySuccess)
                        _buildHistoryTimeline(state.metrics)
                      else if (state is MetricHistoryLoading)
                        const Center(child: CircularProgressIndicator(color: StoreColors.primary))
                      else
                        const Center(child: Text("Start logging to see your timeline", style: TextStyle(color: Colors.white24))),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(List<MetricLogModel> metrics) {
    if (metrics.isEmpty) return const SizedBox(height: 220, child: Center(child: Text("Start logging to see trends", style: TextStyle(color: Colors.white24))));
    
    // Sort oldest first for the chart
    final chartData = List<MetricLogModel>.from(metrics)..sort((a, b) => a.date.compareTo(b.date));
    final weights = chartData.map((m) => m.weight).toList();
    final latestMetric = chartData.last;

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 40,
            bottom: 30,
            child: CustomPaint(
              painter: _ProgressChartPainter(weights: weights),
            ),
          ),
          
          // Latest Weight Tooltip
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: StoreColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Current: ${latestMetric.weight} Kg',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Color(0xFF0C0C0C),
                  letterSpacing: 0.18,
                ),
              ),
            ),
          ),

          // X-Axis Labels (Date based)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                chartData.length > 5 ? 5 : chartData.length,
                (index) {
                  int targetIndex = (index * (chartData.length - 1) / (chartData.length > 5 ? 4 : (chartData.length > 1 ? chartData.length - 1 : 1))).round();
                  final m = chartData[targetIndex];
                  return _buildXAxisLabel(DateFormat('MMM dd').format(m.date));
                }
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightLogCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5C5C5C)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: StoreColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.monitor_weight_outlined,
                  color: Colors.black,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weight Log',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: StoreColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LogMetricsScreen()),
                      );
                      if (result == true && mounted) {
                        context.read<MetricHistoryCubit>().fetchHistory();
                      }
                    },
                    child: Text(
                      'log full metrics',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: StoreColors.primary.withValues(alpha: 0.8),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: StoreColors.background,
                    border: Border.all(color: const Color(0xFF6D6D6D)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: StoreColors.textWhite,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter current weight',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Color(0xFF545454),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Kg',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: StoreColors.textWhite,
                ),
              ),
              const SizedBox(width: 16),
              BlocProvider(
                create: (context) => ProgressLogCubit(ProgressLogService()),
                child: BlocConsumer<ProgressLogCubit, ProgressLogState>(
                  listener: (context, logState) {
                    if (logState is ProgressLogSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Weight logged successfully!'), backgroundColor: Colors.green),
                      );
                      _weightController.clear();
                    }
                  },
                  builder: (context, logState) {
                    final isLoading = logState is ProgressLogLoading;
                    return SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          if (_weightController.text.isNotEmpty) {
                            final historyCubit = context.read<MetricHistoryCubit>();
                            await context.read<ProgressLogCubit>().createLog({
                              'type': 'weight',
                              'value': double.tryParse(_weightController.text),
                              'notes': 'Logged from Progress Chart',
                            });
                            historyCubit.fetchHistory();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StoreColors.primary,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Text(
                              'Save',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF0C0C0C),
                              ),
                            ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTimeline(List<MetricLogModel> metrics) {
    if (metrics.isEmpty) return const Center(child: Text("No records found", style: TextStyle(color: Colors.white24)));
    
    return Column(
      children: List.generate(metrics.length, (index) {
        final metric = metrics[index];
        final prevMetric = index < metrics.length - 1 ? metrics[index + 1] : null;
        final weightDiff = prevMetric != null ? metric.weight - prevMetric.weight : 0.0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM dd, yyyy').format(metric.date),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${metric.weight} Kg',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const Spacer(),
              if (prevMetric != null)
                Row(
                  children: [
                    Icon(
                      weightDiff > 0 ? Icons.trending_up : Icons.trending_down,
                      color: weightDiff > 0 ? Colors.redAccent : Colors.greenAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${weightDiff.abs().toStringAsFixed(1)} Kg',
                      style: TextStyle(
                        color: weightDiff > 0 ? Colors.redAccent : Colors.greenAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              if (metric.bodyFat != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    children: [
                      const Text('BF %', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      Text('${metric.bodyFat}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildXAxisLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: StoreColors.textWhite,
        letterSpacing: 0.18,
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: StoreColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 10),
        ),
      ],
    );
  }
}

class _ProgressChartPainter extends CustomPainter {
  final List<double> weights;

  _ProgressChartPainter({this.weights = const []});

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.isEmpty) return;

    // 1. Draw the white line chart path
    final pathPaint = Paint()
      ..color = StoreColors.textWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();

    // Map weights to normalized points [0, 1]
    double minW = weights.reduce((a, b) => a < b ? a : b);
    double maxW = weights.reduce((a, b) => a > b ? a : b);
    
    // Add some padding to min/max
    minW -= 5;
    maxW += 5;
    if (minW < 0) minW = 0;
    if (maxW == minW) maxW += 10;

    final List<Offset> points = [];
    for (int i = 0; i < weights.length; i++) {
      double x = i / (weights.length > 1 ? weights.length - 1 : 1);
      double y = 1.0 - (weights[i] - minW) / (maxW - minW);
      points.add(Offset(x, y));
    }

    path.moveTo(points[0].dx * size.width, points[0].dy * size.height);

    // Draw bezier curves through points
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = Offset(points[i].dx * size.width, points[i].dy * size.height);
      final p2 = Offset(points[i + 1].dx * size.width, points[i + 1].dy * size.height);
      
      final controlPointX = p1.dx + (p2.dx - p1.dx) / 2;
      path.cubicTo(
        controlPointX, p1.dy, 
        controlPointX, p2.dy, 
        p2.dx, p2.dy
      );
    }

    canvas.drawPath(path, pathPaint);

    // 2. Highlight latest point
    final lastPoint = Offset(points.last.dx * size.width, points.last.dy * size.height);
    
    final highlightLinePaint = Paint()
      ..color = StoreColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(lastPoint.dx, lastPoint.dy + 8), 
      Offset(lastPoint.dx, size.height), 
      highlightLinePaint
    );

    final glowPaint = Paint()
      ..color = StoreColors.primary.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      
    canvas.drawCircle(lastPoint, 8, glowPaint);
    canvas.drawCircle(lastPoint, 6, Paint()..color = StoreColors.primary);
  }

  @override
  bool shouldRepaint(covariant _ProgressChartPainter oldDelegate) {
    return oldDelegate.weights != weights;
  }
}

class _TooltipArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = StoreColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0); // Top left
    path.lineTo(size.width, 0); // Top right
    path.lineTo(size.width / 2, size.height); // Bottom center
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
