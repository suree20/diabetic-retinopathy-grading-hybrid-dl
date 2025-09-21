import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Biometric authentication widget for Face ID, Touch ID, and fingerprint login
/// Provides secure authentication fallback for returning users
class BiometricAuthWidget extends StatefulWidget {
  /// Callback when biometric authentication is successful
  final VoidCallback onBiometricSuccess;

  /// Callback when biometric authentication fails
  final VoidCallback onBiometricError;

  /// Whether to show biometric option
  final bool showBiometric;

  const BiometricAuthWidget({
    super.key,
    required this.onBiometricSuccess,
    required this.onBiometricError,
    required this.showBiometric,
  });

  @override
  State<BiometricAuthWidget> createState() => _BiometricAuthWidgetState();
}

class _BiometricAuthWidgetState extends State<BiometricAuthWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start subtle animation
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Initiates biometric authentication
  Future<void> _authenticateWithBiometrics() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      // Provide haptic feedback
      HapticFeedback.lightImpact();

      // Simulate biometric authentication process
      await Future.delayed(const Duration(milliseconds: 800));

      // For demo purposes, randomly succeed or fail
      final success = DateTime.now().millisecond % 3 != 0; // 66% success rate

      if (success) {
        HapticFeedback.mediumImpact();
        widget.onBiometricSuccess();
      } else {
        HapticFeedback.heavyImpact();
        widget.onBiometricError();
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      widget.onBiometricError();
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  /// Gets appropriate biometric icon based on platform
  String _getBiometricIcon() {
    // In a real app, you would detect the actual biometric type
    // For demo, we'll use fingerprint as default
    return 'fingerprint';
  }

  /// Gets appropriate biometric label based on platform
  String _getBiometricLabel() {
    // In a real app, you would detect the actual biometric type
    return 'Use Fingerprint';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showBiometric) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        SizedBox(height: 3.h),

        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: colorScheme.outline.withValues(alpha: 0.5),
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 11.sp,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: colorScheme.outline.withValues(alpha: 0.5),
                thickness: 1,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Biometric Authentication Button
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isAuthenticating ? 1.0 : _scaleAnimation.value,
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        _isAuthenticating ? null : _authenticateWithBiometrics,
                    borderRadius: BorderRadius.circular(10.w),
                    child: Center(
                      child: _isAuthenticating
                          ? SizedBox(
                              width: 6.w,
                              height: 6.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.primary,
                                ),
                              ),
                            )
                          : CustomIconWidget(
                              iconName: _getBiometricIcon(),
                              color: colorScheme.primary,
                              size: 8.w,
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: 2.h),

        // Biometric Label
        Text(
          _getBiometricLabel(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
          ),
        ),

        SizedBox(height: 1.h),

        // Security Badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 3.w,
            vertical: 0.5.h,
          ),
          decoration: BoxDecoration(
            color: colorScheme.tertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.tertiary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'security',
                color: colorScheme.tertiary,
                size: 3.w,
              ),
              SizedBox(width: 1.w),
              Text(
                'Secure Authentication',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.tertiary,
                  fontWeight: FontWeight.w500,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}