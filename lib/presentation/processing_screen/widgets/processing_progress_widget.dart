import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ProcessingProgressWidget extends StatelessWidget {
  final double progress;
  final String statusMessage;
  final List<String> steps;
  final int currentStep;
  
  const ProcessingProgressWidget({
    Key? key,
    required this.progress,
    required this.statusMessage,
    required this.steps,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress Bar
        Container(
          width: 80.w,
          height: 1.h,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(0.5.h),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(0.5.h),
              ),
            ),
          ),
        ),
        
        SizedBox(height: 2.h),
        
        // Progress Percentage
        Text(
          '${(progress * 100).toInt()}%',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        
        SizedBox(height: 4.h),
        
        // Current Step
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 4.w,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 2.w),
              Flexible(
                child: Text(
                  statusMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 4.h),
        
        // Processing Steps
        Container(
          width: 80.w,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Processing Steps:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              ...List.generate(steps.length, (index) {
                final isCompleted = index < currentStep;
                final isCurrent = index == currentStep;
                
                return Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle
                            : isCurrent
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                        size: 4.w,
                        color: isCompleted
                            ? Theme.of(context).colorScheme.tertiary
                            : isCurrent
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          steps[index],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isCompleted
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : isCurrent
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.outline,
                            fontWeight: isCurrent ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
