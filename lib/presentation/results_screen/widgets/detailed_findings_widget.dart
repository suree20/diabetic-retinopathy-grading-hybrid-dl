import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget for displaying detailed medical findings in expandable cards
class DetailedFindingsWidget extends StatefulWidget {
  final Map<String, dynamic> findings;

  const DetailedFindingsWidget({
    super.key,
    required this.findings,
  });

  @override
  State<DetailedFindingsWidget> createState() => _DetailedFindingsWidgetState();
}

class _DetailedFindingsWidgetState extends State<DetailedFindingsWidget> {
  final Set<String> _expandedCards = {};

  void _toggleCard(String cardKey) {
    setState(() {
      if (_expandedCards.contains(cardKey)) {
        _expandedCards.remove(cardKey);
      } else {
        _expandedCards.add(cardKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            child: Text(
              'Detailed Findings',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          SizedBox(height: 1.h),

          // Findings cards
          _buildFindingCard(
            context,
            'retinal_abnormalities',
            'Retinal Abnormalities',
            Icons.visibility_outlined,
            widget.findings['retinalAbnormalities'] as Map<String, dynamic>? ??
                {},
            colorScheme,
            theme,
          ),

          SizedBox(height: 2.h),

          _buildFindingCard(
            context,
            'blood_vessel_changes',
            'Blood Vessel Changes',
            Icons.device_hub_outlined,
            widget.findings['bloodVesselChanges'] as Map<String, dynamic>? ??
                {},
            colorScheme,
            theme,
          ),

          SizedBox(height: 2.h),

          _buildFindingCard(
            context,
            'hemorrhage_detection',
            'Hemorrhage Detection',
            Icons.water_drop_outlined,
            widget.findings['hemorrhageDetection'] as Map<String, dynamic>? ??
                {},
            colorScheme,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildFindingCard(
    BuildContext context,
    String cardKey,
    String title,
    IconData icon,
    Map<String, dynamic> data,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final isExpanded = _expandedCards.contains(cardKey);

    return Container(
      width: double.infinity,
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
        children: [
          // Card header
          InkWell(
            onTap: () => _toggleCard(cardKey),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: icon.codePoint.toString(),
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: isExpanded ? 'expand_less' : 'expand_more',
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (isExpanded) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medical terminology section
                  _buildDetailSection(
                    'Medical Findings',
                    data['medicalTerms'] as String? ??
                        'No significant abnormalities detected in this category.',
                    theme,
                    colorScheme,
                    isHighlight: true,
                  ),

                  SizedBox(height: 2.h),

                  // Patient-friendly explanation
                  _buildDetailSection(
                    'What This Means',
                    data['patientExplanation'] as String? ??
                        'This indicates normal findings in this area of examination.',
                    theme,
                    colorScheme,
                  ),

                  if (data['severity'] != null) ...[
                    SizedBox(height: 2.h),
                    _buildSeverityIndicator(
                      data['severity'] as String,
                      theme,
                      colorScheme,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    String content,
    ThemeData theme,
    ColorScheme colorScheme, {
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isHighlight ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isHighlight
                ? colorScheme.primary.withValues(alpha: 0.05)
                : colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: isHighlight
                ? Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  )
                : null,
          ),
          child: Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeverityIndicator(
    String severity,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    Color severityColor;
    IconData severityIcon;

    switch (severity.toLowerCase()) {
      case 'mild':
        severityColor = AppTheme.lightTheme.colorScheme.tertiary;
        severityIcon = Icons.check_circle_outline;
        break;
      case 'moderate':
        severityColor = const Color(0xFFD97706);
        severityIcon = Icons.warning_amber_outlined;
        break;
      case 'severe':
        severityColor = AppTheme.lightTheme.colorScheme.error;
        severityIcon = Icons.error_outline;
        break;
      default:
        severityColor = colorScheme.primary;
        severityIcon = Icons.info_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.w),
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: severityIcon.codePoint.toString(),
            color: severityColor,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            'Severity: ${severity.toUpperCase()}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: severityColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
