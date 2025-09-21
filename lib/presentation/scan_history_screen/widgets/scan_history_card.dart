import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Individual scan history card widget displaying scan information
/// with swipe actions and risk level indicators
class ScanHistoryCard extends StatelessWidget {
  final Map<String, dynamic> scanData;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;

  const ScanHistoryCard({
    super.key,
    required this.scanData,
    required this.onTap,
    required this.onShare,
    required this.onDelete,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String riskLevel =
        (scanData['riskLevel'] as String? ?? 'Unknown').toLowerCase();
    final double confidence =
        (scanData['confidence'] as num?)?.toDouble() ?? 0.0;
    final String scanDate = scanData['scanDate'] as String? ?? 'Unknown Date';
    final String fileName = scanData['fileName'] as String? ?? 'Unknown File';
    final String? imageUrl = scanData['imageUrl'] as String?;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Dismissible(
        key: Key(scanData['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString()),
        background: _buildSwipeBackground(context, isLeftSwipe: false),
        secondaryBackground: _buildSwipeBackground(context, isLeftSwipe: true),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Right swipe - show share and delete options
            _showActionBottomSheet(context);
          } else {
            // Left swipe - view details
            onViewDetails();
          }
          return false; // Don't actually dismiss
        },
        child: GestureDetector(
          onTap: onTap,
          onLongPress: () => _showContextMenu(context),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: _getRiskColor(riskLevel, theme),
                  width: 4,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Row(
                children: [
                  // Thumbnail preview
                  _buildThumbnail(context, imageUrl),
                  SizedBox(width: 3.w),

                  // Scan information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // File name
                        Text(
                          fileName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),

                        // Scan date
                        Text(
                          scanDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 1.h),

                        // Risk level and confidence
                        Row(
                          children: [
                            _buildRiskBadge(context, riskLevel),
                            SizedBox(width: 2.w),
                            _buildConfidenceScore(context, confidence),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action indicator
                  CustomIconWidget(
                    iconName: 'chevron_right',
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds thumbnail preview for the scan
  Widget _buildThumbnail(BuildContext context, String? imageUrl) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 15.w,
      height: 15.w,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: CustomImageWidget(
                imageUrl: imageUrl,
                width: 15.w,
                height: 15.w,
                fit: BoxFit.cover,
              ),
            )
          : Center(
              child: CustomIconWidget(
                iconName: 'visibility',
                color: colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
    );
  }

  /// Builds risk level badge with appropriate color
  Widget _buildRiskBadge(BuildContext context, String riskLevel) {
    final theme = Theme.of(context);
    final riskColor = _getRiskColor(riskLevel, theme);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: riskColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        riskLevel.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: riskColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Builds confidence score display
  Widget _buildConfidenceScore(BuildContext context, double confidence) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        CustomIconWidget(
          iconName: 'analytics',
          color: colorScheme.primary,
          size: 16,
        ),
        SizedBox(width: 1.w),
        Text(
          '${confidence.toStringAsFixed(1)}%',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Builds swipe action background
  Widget _buildSwipeBackground(BuildContext context,
      {required bool isLeftSwipe}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeftSwipe
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeftSwipe ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: isLeftSwipe
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'visibility',
                      color: colorScheme.onPrimary,
                      size: 24,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'View Details',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'share',
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Share',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    SizedBox(width: 4.w),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'delete',
                          color: colorScheme.error,
                          size: 24,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Delete',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Shows action bottom sheet for share and delete options
  void _showActionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),

            // Share option
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Share Scan'),
              subtitle: const Text('Share scan results with others'),
              onTap: () {
                Navigator.pop(context);
                onShare();
              },
            ),

            // Delete option
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              title: const Text('Delete Scan'),
              subtitle: const Text('Remove this scan from history'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  /// Shows context menu for long press
  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),

            // View details
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                onViewDetails();
              },
            ),

            // Share
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                onShare();
              },
            ),

            // Delete
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  /// Shows delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Scan'),
        content: const Text(
            'Are you sure you want to delete this scan? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Gets risk level color based on risk assessment
  Color _getRiskColor(String riskLevel, ThemeData theme) {
    switch (riskLevel.toLowerCase()) {
      case 'mild':
      case 'low':
        return theme.brightness == Brightness.light
            ? const Color(0xFF059669)
            : const Color(0xFF10B981);
      case 'moderate':
      case 'medium':
        return theme.brightness == Brightness.light
            ? const Color(0xFFD97706)
            : const Color(0xFFF59E0B);
      case 'severe':
      case 'high':
        return theme.brightness == Brightness.light
            ? const Color(0xFFDC2626)
            : const Color(0xFFEF4444);
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }
}
