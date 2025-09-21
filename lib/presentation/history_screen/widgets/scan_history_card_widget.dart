import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ScanHistoryCardWidget extends StatelessWidget {
  final Map<String, dynamic> scanData;
  final VoidCallback onTap;

  const ScanHistoryCardWidget({
    Key? key,
    required this.scanData,
    required this.onTap,
  }) : super(key: key);

  Color _getRiskColor(String riskLevel) {
    return AppTheme.getRiskColor(riskLevel, isLight: true);
  }

  IconData _getRiskIcon(String riskLevel) {
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

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final riskLevel = scanData['riskLevel'] ?? 'Unknown';
    final confidence = scanData['confidence'] ?? 0.0;
    final uploadDate = scanData['uploadDate'] as Timestamp?;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: _getRiskColor(riskLevel),
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              // Risk Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getRiskColor(riskLevel).withAlpha(26),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _getRiskIcon(riskLevel),
                  color: _getRiskColor(riskLevel),
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Risk Level (Title)
                    Text(
                      riskLevel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getRiskColor(riskLevel),
                          ),
                    ),

                    const SizedBox(height: 4),

                    // Upload Date (Subtitle)
                    Text(
                      _formatDate(uploadDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.onSurfaceVariantLight,
                          ),
                    ),

                    const SizedBox(height: 4),

                    // Confidence Score
                    Row(
                      children: [
                        Text(
                          'Confidence: ',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.onSurfaceVariantLight,
                                  ),
                        ),
                        Text(
                          '${confidence.toStringAsFixed(1)}%',
                          style: AppTheme.getDataTextStyle(
                            isLight: true,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.onSurfaceVariantLight,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
