import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Empty state widget displayed when user has no scan history
class EmptyHistoryState extends StatelessWidget {
  final VoidCallback onUploadScan;

  const EmptyHistoryState({
    super.key,
    required this.onUploadScan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Medical illustration
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'visibility',
                  color: colorScheme.primary,
                  size: 60,
                ),
              ),
            ),
            SizedBox(height: 4.h),

            // Title
            Text(
              'No Scan History',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),

            // Description
            Text(
              'Start monitoring your eye health by uploading your first diabetic retinopathy scan. Early detection is key to preventing vision complications.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),

            // Upload scan button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onUploadScan,
                icon: CustomIconWidget(
                  iconName: 'upload_file',
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
                label: const Text('Upload Your First Scan'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),

            // Learn more button
            TextButton.icon(
              onPressed: () => _showInfoDialog(context),
              icon: CustomIconWidget(
                iconName: 'info_outline',
                color: colorScheme.primary,
                size: 18,
              ),
              label: const Text('Learn About Diabetic Retinopathy'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows information dialog about diabetic retinopathy
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'medical_services',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            const Text('About Diabetic Retinopathy'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What is Diabetic Retinopathy?',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 1.h),
              const Text(
                'Diabetic retinopathy is a diabetes complication that affects eyes. It\'s caused by damage to the blood vessels of the light-sensitive tissue at the back of the eye (retina).',
              ),
              SizedBox(height: 2.h),
              Text(
                'Why Regular Screening Matters:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 1.h),
              const Text(
                '• Early detection prevents vision loss\n'
                '• Treatment is most effective when started early\n'
                '• Regular monitoring helps track progression\n'
                '• AI-powered analysis provides quick results',
              ),
              SizedBox(height: 2.h),
              Text(
                'Risk Levels:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 1.h),
              _buildRiskInfo(context, 'Mild',
                  'Early stage with minimal symptoms', const Color(0xFF059669)),
              _buildRiskInfo(
                  context,
                  'Moderate',
                  'Progressing damage requiring monitoring',
                  const Color(0xFFD97706)),
              _buildRiskInfo(
                  context,
                  'Severe',
                  'Advanced stage needing immediate care',
                  const Color(0xFFDC2626)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Builds risk level information item
  Widget _buildRiskInfo(
      BuildContext context, String level, String description, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3.w,
            height: 3.w,
            margin: EdgeInsets.only(top: 0.5.h),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
