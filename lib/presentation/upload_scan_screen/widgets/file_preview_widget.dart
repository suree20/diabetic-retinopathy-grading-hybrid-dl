import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for displaying file preview with zoom capability and context menu
class FilePreviewWidget extends StatefulWidget {
  final String? filePath;
  final Uint8List? fileBytes;
  final String fileName;
  final String fileExtension;
  final VoidCallback? onRemove;
  final VoidCallback? onViewFullSize;

  const FilePreviewWidget({
    super.key,
    this.filePath,
    this.fileBytes,
    required this.fileName,
    required this.fileExtension,
    this.onRemove,
    this.onViewFullSize,
  });

  @override
  State<FilePreviewWidget> createState() => _FilePreviewWidgetState();
}

class _FilePreviewWidgetState extends State<FilePreviewWidget> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 85.w,
      height: 35.h,
      margin: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPreviewHeader(theme, colorScheme),
          Expanded(
            child: _buildPreviewContent(theme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: _getFileIcon(),
            color: colorScheme.primary,
            size: 5.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fileName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.fileExtension.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
            onSelected: (value) {
              switch (value) {
                case 'remove':
                  widget.onRemove?.call();
                  break;
                case 'fullsize':
                  widget.onViewFullSize?.call();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'fullsize',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'zoom_in',
                      color: colorScheme.onSurface,
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Text('View Full Size'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'delete_outline',
                      color: colorScheme.error,
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Remove File',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent(ThemeData theme, ColorScheme colorScheme) {
    if (_isImageFile()) {
      return _buildImagePreview(theme, colorScheme);
    } else if (widget.fileExtension.toLowerCase() == 'pdf') {
      return _buildPdfPreview(theme, colorScheme);
    } else {
      return _buildGenericFilePreview(theme, colorScheme);
    }
  }

  Widget _buildImagePreview(ThemeData theme, ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 3.0,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: kIsWeb && widget.fileBytes != null
              ? Image.memory(
                  widget.fileBytes!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildErrorWidget(colorScheme),
                )
              : widget.filePath != null
                  ? Image.file(
                      File(widget.filePath!),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildErrorWidget(colorScheme),
                    )
                  : _buildErrorWidget(colorScheme),
        ),
      ),
    );
  }

  Widget _buildPdfPreview(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: 'picture_as_pdf',
              color: colorScheme.error,
              size: 10.w,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'PDF Document',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Preview not available',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericFilePreview(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: 'description',
              color: colorScheme.primary,
              size: 10.w,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'File Selected',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Ready for analysis',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'error_outline',
            color: colorScheme.error,
            size: 10.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'Preview not available',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  String _getFileIcon() {
    switch (widget.fileExtension.toLowerCase()) {
      case 'pdf':
        return 'picture_as_pdf';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'image';
      default:
        return 'description';
    }
  }

  bool _isImageFile() {
    final ext = widget.fileExtension.toLowerCase();
    return ext == 'jpg' || ext == 'jpeg' || ext == 'png';
  }
}
