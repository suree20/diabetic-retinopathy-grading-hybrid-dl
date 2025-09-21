import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class DetailedFindingsCardWidget extends StatelessWidget {
  final String riskLevel;
  final String explanation;

  const DetailedFindingsCardWidget({
    Key? key,
    required this.riskLevel,
    required this.explanation,
  }) : super(key: key);

  Color _getRiskColor() {
    return AppTheme.getRiskColor(riskLevel, isLight: true);
  }

  String _getRecommendation() {
    switch (riskLevel.toLowerCase()) {
      case 'mild':
      case 'low':
        return '• Monitor every 6-12 months\n• Maintain blood sugar control\n• Follow diabetes management plan\n• Regular eye check-ups';
      case 'moderate':
      case 'medium':
        return '• Consult ophthalmologist within 2-3 months\n• Consider treatment options\n• Monitor blood sugar closely\n• Potential follow-up imaging';
      case 'severe':
      case 'high':
        return '• URGENT: See ophthalmologist immediately\n• Treatment likely required\n• Possible laser therapy or injections\n• Prevent further vision loss';
      default:
        return '• Consult healthcare professional\n• Follow medical guidance\n• Regular monitoring recommended';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: _getRiskColor(),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Detailed Findings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Explanation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.outlineLight,
                  width: 1,
                ),
              ),
              child: Text(
                explanation,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: AppTheme.onSurfaceLight,
                    ),
              ),
            ),

            const SizedBox(height: 20),

            // Recommendations
            Text(
              'Recommendations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getRiskColor(),
                  ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getRiskColor().withAlpha(13),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getRiskColor().withAlpha(51),
                  width: 1,
                ),
              ),
              child: Text(
                _getRecommendation(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: AppTheme.onSurfaceLight,
                    ),
              ),
            ),

            if (riskLevel.toLowerCase() == 'severe' ||
                riskLevel.toLowerCase() == 'high') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorLight.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.errorLight.withAlpha(77),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: AppTheme.errorLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Urgent medical attention recommended',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.errorLight,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
