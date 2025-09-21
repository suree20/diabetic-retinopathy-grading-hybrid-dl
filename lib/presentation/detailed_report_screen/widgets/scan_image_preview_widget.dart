import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../../theme/app_theme.dart';

class ScanImagePreviewWidget extends StatelessWidget {
  final Uint8List? imageBytes;
  final bool isLoading;
  final VoidCallback? onZoom;

  const ScanImagePreviewWidget({
    Key? key,
    this.imageBytes,
    required this.isLoading,
    this.onZoom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineLight,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading scan image...',
                      style: TextStyle(
                        color: AppTheme.onSurfaceVariantLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : imageBytes != null
                ? Stack(
                    children: [
                      // Image
                      Image.memory(
                        imageBytes!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),

                      // Zoom overlay
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: onZoom,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.zoom_in,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: AppTheme.onSurfaceVariantLight.withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Scan image not available',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.onSurfaceVariantLight,
                                  ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
