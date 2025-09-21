import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget for action buttons in thumb-reachable zone
class ActionButtonsWidget extends StatelessWidget {
  final String riskLevel;
  final VoidCallback onSaveToHistory;
  final VoidCallback onShareReport;
  final VoidCallback? onScheduleAppointment;

  const ActionButtonsWidget({
    super.key,
    required this.riskLevel,
    required this.onSaveToHistory,
    required this.onShareReport,
    this.onScheduleAppointment,
  });

  bool get _shouldShowScheduleButton => riskLevel.toLowerCase() == 'severe';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Primary action button
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onSaveToHistory();
                },
                icon: CustomIconWidget(
                  iconName: 'save',
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  'Save to History',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: colorScheme.shadow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Secondary actions row
            Row(
              children: [
                // Share report button
                Expanded(
                  child: SizedBox(
                    height: 6.h,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onShareReport();
                      },
                      icon: CustomIconWidget(
                        iconName: 'share',
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      label: Text(
                        'Share Report',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

                if (_shouldShowScheduleButton) ...[
                  SizedBox(width: 3.w),

                  // Schedule appointment button (for severe cases)
                  Expanded(
                    child: SizedBox(
                      height: 6.h,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          if (onScheduleAppointment != null) {
                            onScheduleAppointment!();
                          } else {
                            _showScheduleDialog(context);
                          }
                        },
                        icon: CustomIconWidget(
                          iconName: 'calendar_today',
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          'Schedule',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.error,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: colorScheme.shadow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            SizedBox(height: 2.h),

            // Additional actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Copy results button
                TextButton.icon(
                  onPressed: () => _copyResults(context),
                  icon: CustomIconWidget(
                    iconName: 'content_copy',
                    color: colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  label: Text(
                    'Copy Results',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

                // View history button
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/scan-history-screen');
                  },
                  icon: CustomIconWidget(
                    iconName: 'history',
                    color: colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  label: Text(
                    'View History',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyResults(BuildContext context) {
    final resultsText = '''
Diabetic Retinopathy Analysis Results

Risk Level: ${riskLevel.toUpperCase()}
Analysis Date: ${DateTime.now().toString().split(' ')[0]}

This analysis was performed using AI-powered diagnostic tools. Please consult with your healthcare provider for professional medical advice.
''';

    Clipboard.setData(ClipboardData(text: resultsText));

    Fluttertoast.showToast(
      msg: "Results copied to clipboard",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  void _showScheduleDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'priority_high',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 3.w),
            Text(
              'Urgent Consultation',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your results indicate severe diabetic retinopathy that requires immediate medical attention.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                height: 1.5,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Please contact:',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              '• Your ophthalmologist immediately\n• Emergency medical services if experiencing vision loss\n• Your primary care physician for urgent referral',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Understood',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would open the phone dialer
              Fluttertoast.showToast(
                msg: "Contact your healthcare provider immediately",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
                textColor: Colors.white,
                fontSize: 14,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Call Now',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
