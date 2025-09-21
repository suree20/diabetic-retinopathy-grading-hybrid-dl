import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for the analyze scan button with loading state and haptic feedback
class AnalyzeButtonWidget extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AnalyzeButtonWidget({
    super.key,
    required this.isEnabled,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 85.w,
      height: 7.h,
      margin: EdgeInsets.symmetric(vertical: 2.h),
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? _handlePressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.3),
          foregroundColor:
              isEnabled ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          elevation: isEnabled ? 3.0 : 0.0,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        ),
        child: isLoading
            ? _buildLoadingContent(colorScheme)
            : _buildButtonContent(theme, colorScheme),
      ),
    );
  }

  Widget _buildButtonContent(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconWidget(
          iconName: 'analytics',
          color:
              isEnabled ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          size: 5.w,
        ),
        SizedBox(width: 3.w),
        Text(
          'Analyze Scan',
          style: theme.textTheme.titleMedium?.copyWith(
            color: isEnabled
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContent(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 5.w,
          height: 5.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          'Processing...',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
          ),
        ),
      ],
    );
  }

  void _handlePressed() {
    // Provide haptic feedback for medical app interactions
    HapticFeedback.mediumImpact();
    onPressed?.call();
  }
}
