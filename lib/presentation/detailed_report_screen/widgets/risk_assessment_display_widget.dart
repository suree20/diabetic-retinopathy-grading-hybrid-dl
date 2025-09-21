import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class RiskAssessmentDisplayWidget extends StatelessWidget {
  final String riskLevel;
  final double confidenceScore;
  final DateTime uploadDate;

  const RiskAssessmentDisplayWidget({
    Key? key,
    required this.riskLevel,
    required this.confidenceScore,
    required this.uploadDate,
  }) : super(key: key);

  Color _getRiskColor() {
    return AppTheme.getRiskColor(riskLevel, isLight: true);
  }

  IconData _getRiskIcon() {
    switch (riskLevel.toLowerCase()) {
      case 'mild':
      case 'low':
        return Icons.check_circle;
      case 'moderate':
      case 'medium':
        return Icons.warning;
      case 'severe':
      case 'high':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _formatDate() {
    return '${uploadDate.day}/${uploadDate.month}/${uploadDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              _getRiskColor().withAlpha(13),
              _getRiskColor().withAlpha(5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Risk Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getRiskColor().withAlpha(26),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: _getRiskColor().withAlpha(77),
                  width: 2,
                ),
              ),
              child: Icon(
                _getRiskIcon(),
                color: _getRiskColor(),
                size: 40,
              ),
            ),

            const SizedBox(height: 16),

            // Risk Level
            Text(
              riskLevel.toUpperCase(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: _getRiskColor(),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),

            const SizedBox(height: 8),

            // Upload Date
            Text(
              'Analyzed on $_formatDate()',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariantLight,
                  ),
            ),

            const SizedBox(height: 16),

            // Confidence Score
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Confidence Score: ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.onSurfaceLight,
                      ),
                ),
                Text(
                  '${(confidenceScore * 100).toStringAsFixed(1)}%',
                  style: AppTheme.getDataTextStyle(
                    isLight: true,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress bar for confidence
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.outlineLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: confidenceScore,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getRiskColor(),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Confidence explanation
            Text(
              'AI accuracy metrics based on analysis patterns',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceVariantLight.withAlpha(179),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
