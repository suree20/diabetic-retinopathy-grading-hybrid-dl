import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// App logo widget with medical branding and responsive design
/// Displays the Diabetic Retinopathy Detector logo with medical styling
class AppLogoWidget extends StatefulWidget {
  /// Size variant for different contexts
  final LogoSize size;

  /// Whether to show the app name below the logo
  final bool showAppName;

  /// Whether to animate the logo on appearance
  final bool animate;

  const AppLogoWidget({
    super.key,
    this.size = LogoSize.large,
    this.showAppName = true,
    this.animate = true,
  });

  @override
  State<AppLogoWidget> createState() => _AppLogoWidgetState();
}

class _AppLogoWidgetState extends State<AppLogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    if (widget.animate) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );

      _scaleAnimation = Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ));

      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      _animationController.forward();
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      _animationController.dispose();
    }
    super.dispose();
  }

  /// Gets logo size based on variant
  double _getLogoSize() {
    switch (widget.size) {
      case LogoSize.small:
        return 12.w;
      case LogoSize.medium:
        return 18.w;
      case LogoSize.large:
        return 25.w;
      case LogoSize.extraLarge:
        return 32.w;
    }
  }

  /// Gets app name font size based on logo size
  double _getAppNameSize() {
    switch (widget.size) {
      case LogoSize.small:
        return 12.sp;
      case LogoSize.medium:
        return 16.sp;
      case LogoSize.large:
        return 20.sp;
      case LogoSize.extraLarge:
        return 24.sp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget logoWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Container with Medical Cross Design
        Container(
          width: _getLogoSize(),
          height: _getLogoSize(),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(_getLogoSize() * 0.2),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Medical Cross Background
              CustomIconWidget(
                iconName: 'local_hospital',
                color: colorScheme.onPrimary.withValues(alpha: 0.2),
                size: _getLogoSize() * 0.6,
              ),

              // Eye Icon (Main Symbol)
              CustomIconWidget(
                iconName: 'visibility',
                color: colorScheme.onPrimary,
                size: _getLogoSize() * 0.4,
              ),

              // Small diagnostic indicator
              Positioned(
                top: _getLogoSize() * 0.15,
                right: _getLogoSize() * 0.15,
                child: Container(
                  width: _getLogoSize() * 0.15,
                  height: _getLogoSize() * 0.15,
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.onPrimary,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (widget.showAppName) ...[
          SizedBox(height: 2.h),

          // App Name
          Text(
            'Diabetic Retinopathy',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: _getAppNameSize(),
              letterSpacing: 0.5,
            ),
          ),

          SizedBox(height: 0.5.h),

          // Subtitle
          Text(
            'Detector',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: _getAppNameSize() * 0.8,
              letterSpacing: 1.0,
            ),
          ),

          SizedBox(height: 1.h),

          // Medical tagline
          Text(
            'Early Detection • Better Care',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: _getAppNameSize() * 0.5,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ],
    );

    if (widget.animate) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: logoWidget,
            ),
          );
        },
      );
    }

    return logoWidget;
  }
}

/// Enum for logo size variants
enum LogoSize {
  small,
  medium,
  large,
  extraLarge,
}
