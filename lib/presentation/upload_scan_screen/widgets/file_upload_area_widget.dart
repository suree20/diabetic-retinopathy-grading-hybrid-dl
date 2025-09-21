import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for the main file upload area with dashed border and medical scan icon
class FileUploadAreaWidget extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasFile;
  final String? fileName;
  final String? fileSize;

  const FileUploadAreaWidget({
    super.key,
    required this.onTap,
    this.hasFile = false,
    this.fileName,
    this.fileSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85.w,
        height: hasFile ? 25.h : 30.h,
        decoration: BoxDecoration(
          color: hasFile
              ? colorScheme.primary.withValues(alpha: 0.05)
              : colorScheme.surface,
          border: Border.all(
            color: hasFile
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.5),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: hasFile
            ? _buildFileSelectedContent(theme, colorScheme)
            : _buildUploadPrompt(theme, colorScheme),
      ),
    );
  }

  Widget _buildUploadPrompt(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 15.w,
          height: 15.w,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: 'medical_services',
            color: colorScheme.primary,
            size: 8.w,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          'Upload Eye Scan',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Tap to select PDF, JPG, or PNG files',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Maximum file size: 10MB',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFileSelectedContent(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'description',
                  color: colorScheme.primary,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName ?? 'Selected File',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (fileSize != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        fileSize!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              CustomIconWidget(
                iconName: 'check_circle',
                color: colorScheme.tertiary,
                size: 6.w,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Tap to change file',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
