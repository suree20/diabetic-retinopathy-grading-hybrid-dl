import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ExportButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final int historyCount;

  const ExportButtonWidget({
    Key? key,
    required this.onPressed,
    required this.isLoading,
    required this.historyCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: historyCount > 0 && !isLoading ? onPressed : null,
      icon: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  historyCount > 0
                      ? Colors.white
                      : AppTheme.onSurfaceVariantLight,
                ),
              ),
            )
          : const Icon(Icons.download),
      label: Text(
        isLoading
            ? 'Exporting...'
            : historyCount > 0
                ? 'Export History ($historyCount scans)'
                : 'No History to Export',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: historyCount > 0
            ? AppTheme.primaryLight
            : AppTheme.onSurfaceVariantLight.withAlpha(26),
        foregroundColor:
            historyCount > 0 ? Colors.white : AppTheme.onSurfaceVariantLight,
        elevation: historyCount > 0 ? 3 : 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
