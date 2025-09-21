import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget for displaying medical recommendations and next steps
class RecommendationsCard extends StatelessWidget {
  final String riskLevel;
  final List<String> recommendations;
  final String timeline;

  const RecommendationsCard({
    super.key,
    required this.riskLevel,
    required this.recommendations,
    required this.timeline,
  });

  List<String> _getDefaultRecommendations() {
    switch (riskLevel.toLowerCase()) {
      case 'mild':
        return [
          'Continue regular eye examinations every 12 months',
          'Maintain good blood sugar control',
          'Monitor blood pressure regularly',
          'Follow a healthy diet and exercise routine',
          'Take prescribed medications as directed',
        ];
      case 'moderate':
        return [
          'Schedule ophthalmologist consultation within 3-6 months',
          'Increase eye examination frequency to every 6 months',
          'Optimize diabetes management with your physician',
          'Consider additional retinal imaging studies',
          'Monitor for vision changes and report immediately',
        ];
      case 'severe':
        return [
          'Seek immediate ophthalmologist consultation',
          'Consider urgent retinal specialist referral',
          'Discuss treatment options (laser therapy, injections)',
          'Intensive diabetes management required',
          'Weekly monitoring until condition stabilizes',
        ];
      default:
        return [
          'Follow up with your healthcare provider',
          'Continue regular monitoring',
          'Maintain healthy lifestyle habits',
        ];
    }
  }

  String _getDefaultTimeline() {
    switch (riskLevel.toLowerCase()) {
      case 'mild':
        return 'Next examination in 12 months';
      case 'moderate':
        return 'Ophthalmologist consultation within 3-6 months';
      case 'severe':
        return 'Immediate medical attention required';
      default:
        return 'Follow standard care guidelines';
    }
  }

  Color _getRecommendationColor(ColorScheme colorScheme) {
    switch (riskLevel.toLowerCase()) {
      case 'mild':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'moderate':
        return const Color(0xFFD97706);
      case 'severe':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return colorScheme.primary;
    }
  }

  IconData _getUrgencyIcon() {
    switch (riskLevel.toLowerCase()) {
      case 'mild':
        return Icons.schedule_outlined;
      case 'moderate':
        return Icons.event_outlined;
      case 'severe':
        return Icons.priority_high_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recommendationColor = _getRecommendationColor(colorScheme);
    final effectiveRecommendations = recommendations.isNotEmpty
        ? recommendations
        : _getDefaultRecommendations();
    final effectiveTimeline =
        timeline.isNotEmpty ? timeline : _getDefaultTimeline();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: recommendationColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: recommendationColor.withValues(alpha: 0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: recommendationColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'medical_services',
                    color: recommendationColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medical Recommendations',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Next steps based on your results',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Timeline urgency
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: recommendationColor.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: _getUrgencyIcon().codePoint.toString(),
                  color: recommendationColor,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    effectiveTimeline,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: recommendationColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Recommendations list
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Actions:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                ...effectiveRecommendations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final recommendation = entry.value;

                  return Container(
                    margin: EdgeInsets.only(bottom: 2.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 0.5.h),
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: recommendationColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: recommendationColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            recommendation,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // Important note
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'These recommendations are based on AI analysis. Always consult with your healthcare provider for personalized medical advice and treatment decisions.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
