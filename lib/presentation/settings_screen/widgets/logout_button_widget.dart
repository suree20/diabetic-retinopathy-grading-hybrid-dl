import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Large Red Logout Button Widget for Settings Screen
/// Implements medical app security patterns with prominent visibility
class LogoutButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const LogoutButtonWidget({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 7.h,
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.error,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: colorScheme.error.withAlpha(77),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 6.w,
            vertical: 2.h,
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.error.withAlpha(128);
            }
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.error.withAlpha(204);
            }
            return colorScheme.error;
          }),
        ),
        child: isLoading
            ? SizedBox(
                height: 5.w,
                width: 5.w,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    size: 5.w,
                    color: Colors.white,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Logout',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      letterSpacing: 0.15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
