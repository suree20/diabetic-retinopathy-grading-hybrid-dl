import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Medical security badge widget displaying trust indicators
/// for healthcare data protection and compliance
class MedicalSecurityBadgeWidget extends StatelessWidget {
  /// Whether to show the badge in compact mode
  final bool isCompact;

  const MedicalSecurityBadgeWidget({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 3.w : 4.w,
        vertical: isCompact ? 1.h : 1.5.h,
      ),
      decoration: BoxDecoration(
        color: colorScheme.tertiary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.tertiary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: isCompact
          ? _buildCompactBadge(theme, colorScheme)
          : _buildFullBadge(theme, colorScheme),
    );
  }

  /// Builds compact version of the security badge
  Widget _buildCompactBadge(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: 'verified_user',
          color: colorScheme.tertiary,
          size: 4.w,
        ),
        SizedBox(width: 2.w),
        Text(
          'HIPAA Compliant',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.tertiary,
            fontWeight: FontWeight.w600,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  /// Builds full version of the security badge
  Widget _buildFullBadge(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'verified_user',
              color: colorScheme.tertiary,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Medical Grade Security',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.tertiary,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),

        SizedBox(height: 1.h),

        // Security features list
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSecurityFeature(
              theme,
              colorScheme,
              'lock',
              'SSL',
            ),
            SizedBox(width: 4.w),
            _buildSecurityFeature(
              theme,
              colorScheme,
              'shield',
              'HIPAA',
            ),
            SizedBox(width: 4.w),
            _buildSecurityFeature(
              theme,
              colorScheme,
              'privacy_tip',
              'Privacy',
            ),
          ],
        ),
      ],
    );
  }

  /// Builds individual security feature indicator
  Widget _buildSecurityFeature(
    ThemeData theme,
    ColorScheme colorScheme,
    String iconName,
    String label,
  ) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: colorScheme.tertiary,
          size: 3.5.w,
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.tertiary,
            fontWeight: FontWeight.w500,
            fontSize: 9.sp,
          ),
        ),
      ],
    );
  }
}
