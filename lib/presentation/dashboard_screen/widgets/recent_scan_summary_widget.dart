import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Recent scan summary widget displaying last analysis information
/// Shows color-coded risk indicators for medical context
class RecentScanSummaryWidget extends StatelessWidget {
  /// Date of the last scan analysis
  final DateTime? lastScanDate;

  /// Risk level from last analysis (Mild, Moderate, Severe)
  final String? riskLevel;

  /// Confidence score percentage
  final double? confidenceScore;

  /// Callback when user taps to view full history
  final VoidCallback onViewHistory;

  const RecentScanSummaryWidget({
    super.key,
    this.lastScanDate,
    this.riskLevel,
    this.confidenceScore,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (lastScanDate == null || riskLevel == null) {
      return _buildEmptyState(context, theme, colorScheme);
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 1.h),
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
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'history',
                color: colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Recent Scan Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              TextButton(
                onPressed: onViewHistory,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context,
                  theme,
                  colorScheme,
                  'Last Scan',
                  _formatDate(lastScanDate!),
                  'calendar_today',
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildRiskIndicator(context, theme, colorScheme),
              ),
            ],
          ),
          if (confidenceScore != null) ...[
            SizedBox(height: 2.h),
            _buildConfidenceScore(context, theme, colorScheme),
          ],
        ],
      ),
    );
  }

  /// Builds empty state when no scan history exists
  Widget _buildEmptyState(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'visibility_off',
            color: colorScheme.onSurfaceVariant,
            size: 8.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Recent Scans',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Upload your first eye scan to get started with diabetic retinopathy monitoring',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Builds individual information item
  Widget _buildInfoItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    String value,
    String iconName,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: colorScheme.onSurfaceVariant,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  /// Builds risk level indicator with color coding
  Widget _buildRiskIndicator(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final riskColor = _getRiskColor(riskLevel!, colorScheme);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: riskColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: riskColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Risk Level',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            riskLevel!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: riskColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  /// Builds confidence score progress indicator
  Widget _buildConfidenceScore(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final score = confidenceScore! / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confidence Score',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${confidenceScore!.toStringAsFixed(1)}%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        LinearProgressIndicator(
          value: score,
          backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            score >= 0.8
                ? colorScheme.tertiary
                : score >= 0.6
                    ? Colors.orange
                    : colorScheme.error,
          ),
          minHeight: 1.h,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  /// Returns appropriate color for risk level
  Color _getRiskColor(String risk, ColorScheme colorScheme) {
    switch (risk.toLowerCase()) {
      case 'mild':
        return colorScheme.tertiary; // Green for mild risk
      case 'moderate':
        return Colors.orange; // Orange for moderate risk
      case 'severe':
        return colorScheme.error; // Red for severe risk
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  /// Formats date in MM/DD/YYYY format
  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
}
