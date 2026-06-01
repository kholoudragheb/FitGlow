import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants.dart';
import '../../../logic/cubits/schedule/schedule_stats_cubit.dart';
import '../../../models/schedule_stats_model.dart';
import '../../../services/schedule_service.dart';

class ScheduleAnalyticsScreen extends StatelessWidget {
  const ScheduleAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScheduleStatsCubit(ScheduleService())..fetchStats(),
      child: const _ScheduleAnalyticsView(),
    );
  }
}

class _ScheduleAnalyticsView extends StatelessWidget {
  const _ScheduleAnalyticsView();

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
        title: const Text(
          'Schedule Analytics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ScheduleStatsCubit, ScheduleStatsState>(
        builder: (context, state) {
          if (state is ScheduleStatsLoading) {
            return _buildLoadingState();
          } else if (state is ScheduleStatsError) {
            return _buildErrorState(context, state.message);
          } else if (state is ScheduleStatsSuccess) {
            if (state.stats.totalSessions == 0) {
              return _buildEmptyState();
            }
            return _buildContent(context, state.stats);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF1E1E1E),
        highlightColor: const Color(0xFF2C2C2C),
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 200,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
            ),
            const SizedBox(height: 24),
            Container(
              height: 300,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppConstants.errorColor, size: 64),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<ScheduleStatsCubit>().fetchStats(),
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
              child: const Text('Retry', style: TextStyle(color: Colors.black)),
            ),
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
          Icon(Icons.analytics_outlined, color: Colors.white.withValues(alpha: 0.1), size: 80),
          const SizedBox(height: 16),
          const Text(
            'No schedule data available yet',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScheduleStatsModel stats) {
    return RefreshIndicator(
      onRefresh: () => context.read<ScheduleStatsCubit>().fetchStats(),
      color: AppConstants.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewGrid(stats),
            const SizedBox(height: 24),
            _buildWeeklyActivityChart(stats),
            const SizedBox(height: 24),
            _buildStatusBreakdownChart(stats),
            const SizedBox(height: 24),
            _buildPerformanceMetrics(stats),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewGrid(ScheduleStatsModel stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Sessions', stats.totalSessions.toString(), Icons.event, Colors.blue),
        _buildStatCard('Upcoming', stats.upcomingSessions.toString(), Icons.upcoming, Colors.orange),
        _buildStatCard('Completed', stats.completedSessions.toString(), Icons.check_circle, Colors.green),
        _buildStatCard('Canceled', stats.canceledSessions.toString(), Icons.cancel, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivityChart(ScheduleStatsModel stats) {
    final activity = stats.weeklyActivity;
    if (activity.isEmpty) return const SizedBox.shrink();

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final spots = days.map((day) => activity[day]?.toDouble() ?? 0.0).toList();
    final maxVal = spots.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Activity', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal + 1,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(days[value.toInt()], style: const TextStyle(color: Colors.white54, fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(spots.length, (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: spots[i],
                      color: AppConstants.primaryColor,
                      width: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdownChart(ScheduleStatsModel stats) {
    final breakdown = stats.sessionStatusBreakdown;
    if (breakdown.isEmpty) return const SizedBox.shrink();

    final data = breakdown.entries.map((e) {
      Color color;
      switch (e.key.toLowerCase()) {
        case 'confirmed': color = Colors.green; break;
        case 'pending': color = Colors.orange; break;
        case 'completed': color = Colors.blue; break;
        case 'canceled': color = Colors.red; break;
        default: color = Colors.grey;
      }
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${e.value}',
        color: color,
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status Breakdown', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: PieChart(
                  PieChartData(
                    sections: data,
                    sectionsSpace: 4,
                    centerSpaceRadius: 30,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: breakdown.entries.map((e) {
                    Color color;
                    switch (e.key.toLowerCase()) {
                      case 'confirmed': color = Colors.green; break;
                      case 'pending': color = Colors.orange; break;
                      case 'completed': color = Colors.blue; break;
                      case 'canceled': color = Colors.red; break;
                      default: color = Colors.grey;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(e.key.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          const Spacer(),
                          Text(e.value.toString(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(ScheduleStatsModel stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performance Overview', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildMetricRow('Completion Rate', '${(stats.completionRate * 100).toInt()}%', Colors.green),
          const SizedBox(height: 16),
          _buildMetricRow('Booking Rate', '${(stats.bookingRate * 100).toInt()}%', Colors.blue),
          const SizedBox(height: 16),
          _buildMetricRow('Total Clients', stats.totalClients.toString(), Colors.purple),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.trending_up, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
