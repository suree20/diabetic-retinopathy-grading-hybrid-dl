import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './widgets/settings_header_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/settings_toggle_widget.dart';
import './widgets/logout_button_widget.dart';

/// Settings Screen for Diabetic Retinopathy Early Detection App
/// Provides comprehensive app configuration with medical-grade security
/// and user preference management using Provider state management
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  bool _isNotificationsEnabled = true;
  bool _isDarkModeEnabled = false;
  bool _isDataSharingEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSettings();
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  /// Initialize animations for smooth UI transitions
  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeIn,
    ));

    // Start animations
    _slideAnimationController.forward();
    _fadeAnimationController.forward();
  }

  /// Load user settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isNotificationsEnabled =
            prefs.getBool('notifications_enabled') ?? true;
        _isDarkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
        _isDataSharingEnabled = prefs.getBool('data_sharing_enabled') ?? false;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  /// Save user settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _isNotificationsEnabled);
      await prefs.setBool('dark_mode_enabled', _isDarkModeEnabled);
      await prefs.setBool('data_sharing_enabled', _isDataSharingEnabled);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  /// Handle notifications toggle
  Future<void> _handleNotificationsToggle(bool value) async {
    HapticFeedback.selectionClick();

    setState(() {
      _isNotificationsEnabled = value;
    });

    await _saveSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Medical notifications enabled'
                : 'Medical notifications disabled',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(4.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Handle dark mode toggle
  Future<void> _handleDarkModeToggle(bool value) async {
    HapticFeedback.selectionClick();

    setState(() {
      _isDarkModeEnabled = value;
    });

    await _saveSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Dark mode enabled for better visibility'
                : 'Light mode enabled for clinical use',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(4.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Handle data sharing toggle
  Future<void> _handleDataSharingToggle(bool value) async {
    HapticFeedback.selectionClick();

    if (value) {
      // Show data sharing consent dialog
      final consent = await _showDataSharingConsent();
      if (!consent) return;
    }

    setState(() {
      _isDataSharingEnabled = value;
    });

    await _saveSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Anonymous data sharing enabled for research'
                : 'Data sharing disabled - all data remains private',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(4.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show data sharing consent dialog
  Future<bool> _showDataSharingConsent() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Data Sharing Consent'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Help improve diabetic retinopathy detection by sharing anonymous scan data for medical research.',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your data will be:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text('• Completely anonymized'),
                  Text('• Used only for medical research'),
                  Text('• Never shared with third parties'),
                  Text('• Securely stored and encrypted'),
                  SizedBox(height: 16),
                  Text(
                    'You can disable this anytime in settings.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Decline'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Accept'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Handle logout with confirmation dialog
  Future<void> _handleLogout() async {
    HapticFeedback.heavyImpact();

    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text(
            'Are you sure you want to logout? You will need to sign in again to access your medical data.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate Firebase Auth signOut
        await Future.delayed(const Duration(milliseconds: 1000));

        // Clear all stored preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        HapticFeedback.heavyImpact();

        if (mounted) {
          // Navigate to login screen and clear navigation stack
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login-screen',
            (route) => false,
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Logout failed. Please try again.'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(4.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Settings Header
                  SettingsHeaderWidget(),

                  SizedBox(height: 3.h),

                  // Preferences Section
                  SettingsSectionWidget(
                    title: 'Preferences',
                    icon: Icons.tune,
                    children: [
                      SettingsToggleWidget(
                        title: 'Notifications',
                        subtitle: 'Medical alerts and scan reminders',
                        icon: Icons.notifications_outlined,
                        value: _isNotificationsEnabled,
                        onChanged: _handleNotificationsToggle,
                      ),
                      SettingsToggleWidget(
                        title: 'Dark Mode',
                        subtitle: 'Better visibility in low light',
                        icon: Icons.dark_mode_outlined,
                        value: _isDarkModeEnabled,
                        onChanged: _handleDarkModeToggle,
                      ),
                      SettingsToggleWidget(
                        title: 'Data Sharing',
                        subtitle: 'Help improve medical research',
                        icon: Icons.share_outlined,
                        value: _isDataSharingEnabled,
                        onChanged: _handleDataSharingToggle,
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Medical Disclaimer
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withAlpha(51),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              color: colorScheme.primary,
                              size: 5.w,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Medical Disclaimer',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'This app is for screening purposes only and should not replace professional medical diagnosis. Always consult with a healthcare provider for medical concerns.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // App Information
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'App Information',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Version',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '1.0.0',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Build',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '2025.01.22',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Logout Button
                  LogoutButtonWidget(
                    onPressed: _isLoading ? null : _handleLogout,
                    isLoading: _isLoading,
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
