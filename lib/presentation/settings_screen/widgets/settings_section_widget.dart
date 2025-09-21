import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Settings Section Widget for grouping related settings
/// Implements medical app design patterns with clear visual hierarchy
class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const SettingsSectionWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withAlpha(51),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            color: colorScheme.outline.withAlpha(51),
          ),

          // Settings Items
          ...children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;

            return Column(
              children: [
                child,
                // Add divider between items (except last one)
                if (index < children.length - 1)
                  Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    color: colorScheme.outline.withAlpha(26),
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
