import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class EmptyHistoryWidget extends StatelessWidget {
  const EmptyHistoryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Medical illustration placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withAlpha(26),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.visibility,
                size: 64,
                color: AppTheme.primaryLight.withAlpha(153),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'No Scan History',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceLight,
                  ),
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              'Your diabetic retinopathy scan history will appear here once you upload your first retinal image.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariantLight,
                    height: 1.5,
                  ),
            ),

            const SizedBox(height: 32),

            // Call-to-action button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.uploadScan);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Upload Your First Scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Secondary info
            Text(
              'Track your eye health progress over time',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceVariantLight.withAlpha(179),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
