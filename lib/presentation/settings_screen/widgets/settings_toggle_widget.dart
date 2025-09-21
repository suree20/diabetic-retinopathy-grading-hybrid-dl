import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

/// Settings Toggle Widget for boolean preferences
/// Implements medical UI patterns with accessibility support
class SettingsToggleWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isEnabled;

  const SettingsToggleWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled
            ? () {
                HapticFeedback.selectionClick();
                onChanged?.call(!value);
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 3.h,
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: value
                      ? colorScheme.primary.withAlpha(26)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: value
                        ? colorScheme.primary.withAlpha(77)
                        : colorScheme.outline.withAlpha(51),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 5.w,
                  color: value
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),

              SizedBox(width: 4.w),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isEnabled
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isEnabled
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurfaceVariant.withAlpha(153),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Toggle Switch
              Switch(
                value: value,
                onChanged: isEnabled ? onChanged : null,
                activeThumbColor: colorScheme.primary,
                inactiveThumbColor: colorScheme.onSurfaceVariant,
                inactiveTrackColor: colorScheme.outline.withAlpha(77),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
