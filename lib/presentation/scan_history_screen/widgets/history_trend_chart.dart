import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Medical trend visualization widget showing risk level progression over time
class HistoryTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> scanHistory;

  const HistoryTrendChart({
    super.key,
    required this.scanHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (scanHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'trending_up',
                color: colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Risk Trend Analysis',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              _buildTrendIndicator(context),
            ],
          ),
          SizedBox(height: 3.h),

          // Chart
          SizedBox(
            height: 25.h,
            child: _buildLineChart(context),
          ),
          SizedBox(height: 2.h),

          // Legend
          _buildLegend(context),
        ],
      ),
    );
  }

  /// Builds the line chart for risk trend visualization
  Widget _buildLineChart(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final chartData = _prepareChartData();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outline.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                  final date = chartData[value.toInt()]['date'] as String;
                  final parts = date.split('/');
                  return Text(
                    '${parts[0]}/${parts[1]}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 1:
                    return Text('Mild',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant));
                  case 2:
                    return Text('Moderate',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant));
                  case 3:
                    return Text('Severe',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant));
                  default:
                    return const Text('');
                }
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        minX: 0,
        maxX: (chartData.length - 1).toDouble(),
        minY: 0.5,
        maxY: 3.5,
        lineBarsData: [
          LineChartBarData(
            spots: chartData.asMap().entries.map((entry) {
              return FlSpot(
                  entry.key.toDouble(), entry.value['riskValue'] as double);
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.8),
                colorScheme.primary,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final riskValue = spot.y.toInt();
                Color dotColor;
                switch (riskValue) {
                  case 1:
                    dotColor = const Color(0xFF059669);
                    break;
                  case 2:
                    dotColor = const Color(0xFFD97706);
                    break;
                  case 3:
                    dotColor = const Color(0xFFDC2626);
                    break;
                  default:
                    dotColor = colorScheme.primary;
                }
                return FlDotCirclePainter(
                  radius: 4,
                  color: dotColor,
                  strokeWidth: 2,
                  strokeColor: colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.1),
                  colorScheme.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < chartData.length) {
                  final data = chartData[index];
                  final riskLevel = data['riskLevel'] as String;
                  final confidence = data['confidence'] as double;
                  return LineTooltipItem(
                    '$riskLevel\n${confidence.toStringAsFixed(1)}%',
                    theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w500,
                        ) ??
                        const TextStyle(),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  /// Builds trend indicator showing overall progression
  Widget _buildTrendIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final trend = _calculateTrend();
    final isImproving = trend < 0;
    final isStable = trend.abs() < 0.1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: isStable
            ? colorScheme.surfaceContainerHighest
            : isImproving
                ? const Color(0xFF059669).withValues(alpha: 0.1)
                : const Color(0xFFDC2626).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: isStable
                ? 'trending_flat'
                : isImproving
                    ? 'trending_down'
                    : 'trending_up',
            color: isStable
                ? colorScheme.onSurfaceVariant
                : isImproving
                    ? const Color(0xFF059669)
                    : const Color(0xFFDC2626),
            size: 16,
          ),
          SizedBox(width: 1.w),
          Text(
            isStable
                ? 'Stable'
                : isImproving
                    ? 'Improving'
                    : 'Worsening',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isStable
                  ? colorScheme.onSurfaceVariant
                  : isImproving
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds legend for risk levels
  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(context, 'Mild', const Color(0xFF059669)),
        _buildLegendItem(context, 'Moderate', const Color(0xFFD97706)),
        _buildLegendItem(context, 'Severe', const Color(0xFFDC2626)),
      ],
    );
  }

  /// Builds individual legend item
  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Prepares chart data from scan history
  List<Map<String, dynamic>> _prepareChartData() {
    final sortedHistory = List<Map<String, dynamic>>.from(scanHistory);
    sortedHistory.sort((a, b) {
      final dateA =
          DateTime.tryParse(a['scanDate'] as String? ?? '') ?? DateTime.now();
      final dateB =
          DateTime.tryParse(b['scanDate'] as String? ?? '') ?? DateTime.now();
      return dateA.compareTo(dateB);
    });

    return sortedHistory.take(10).map((scan) {
      final riskLevel = (scan['riskLevel'] as String? ?? 'mild').toLowerCase();
      double riskValue;
      switch (riskLevel) {
        case 'mild':
        case 'low':
          riskValue = 1.0;
          break;
        case 'moderate':
        case 'medium':
          riskValue = 2.0;
          break;
        case 'severe':
        case 'high':
          riskValue = 3.0;
          break;
        default:
          riskValue = 1.0;
      }

      return {
        'date': scan['scanDate'] as String? ?? '01/01/2024',
        'riskLevel': riskLevel,
        'riskValue': riskValue,
        'confidence': (scan['confidence'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();
  }

  /// Calculates overall trend direction
  double _calculateTrend() {
    if (scanHistory.length < 2) return 0.0;

    final chartData = _prepareChartData();
    if (chartData.length < 2) return 0.0;

    final firstValue = chartData.first['riskValue'] as double;
    final lastValue = chartData.last['riskValue'] as double;

    return lastValue - firstValue;
  }
}
