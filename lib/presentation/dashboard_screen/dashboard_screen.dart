import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/action_card_widget.dart';
import './widgets/medical_disclaimer_widget.dart';
import './widgets/recent_scan_summary_widget.dart';
import './widgets/welcome_header_widget.dart';

/// Dashboard Screen - Primary hub for diabetic retinopathy monitoring
/// Provides quick access to core medical functions with tab navigation
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 0;
  bool _isLoading = false;
  String _userName = "Patient";
  final DateTime _currentDate = DateTime.now();

  // Mock recent scan data - in production, this would come from Firestore
  final DateTime? _lastScanDate =
      DateTime.now().subtract(const Duration(days: 3));
  final String? _riskLevel = "Mild";
  final double? _confidenceScore = 87.5;

  final String _emergencyContact = "911 - Emergency Services";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Loads dashboard data with pull-to-refresh functionality
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch user profile from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && mounted) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _userName = userData['fullName'] ?? 'Patient';
          });

          // Update last login timestamp
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Fallback to default name if Firestore fails
      setState(() {
        _userName = 'Patient';
      });
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Handles navigation to upload scan screen
  void _navigateToUploadScan() {
    Navigator.pushNamed(context, '/upload-scan-screen');
  }

  /// Handles navigation to scan history screen
  void _navigateToHistory() {
    Navigator.pushNamed(context, '/scan-history-screen');
  }

  /// Handles navigation to settings/registration screen
  void _navigateToSettings() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/settings-screen');
  }

  /// Handles navigation to profile screen
  void _navigateToProfile() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/profile-screen');
  }

  /// Handles navigation to results screen
  void _navigateToResults() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/results-screen');
  }

  /// Handles emergency contact action
  void _handleEmergencyContact() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Contact'),
        content: const Text(
          'In case of a medical emergency, please call 911 immediately or contact your healthcare provider.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In production, this would initiate a phone call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency services contacted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  /// Handles bottom navigation changes
  void _onBottomNavTap(int index) {
    setState(() => _currentBottomNavIndex = index);

    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        _navigateToUploadScan();
        break;
      case 2:
        _navigateToHistory();
        break;
      case 3:
        _navigateToResults();
        break;
    }
  }

  void _navigateToNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No new notifications')),
    );
  }

  void _navigateToHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar.dashboard(
        title: 'Dashboard',
        actions: [
          // Notifications
          IconButton(
            onPressed: _navigateToNotifications,
            icon: Icon(
              Icons.notifications_outlined,
              size: 20,
              color: colorScheme.onSurface,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(32, 32),
            ),
          ),
          // Profile Settings
          IconButton(
            onPressed: _navigateToProfile,
            icon: Icon(
              Icons.account_circle_outlined,
              size: 20,
              color: colorScheme.onSurface,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(32, 32),
            ),
          ),
          // Account Settings
          IconButton(
            onPressed: _navigateToSettings,
            icon: Icon(
              Icons.settings_outlined,
              size: 20,
              color: colorScheme.onSurface,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(32, 32),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Welcome Header
              WelcomeHeaderWidget(
                userName: _userName,
                currentDate: DateTime.now(),
              ),

              const SizedBox(height: 24),

              // Action Buttons - Arranged in a grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  // Upload Scan Button
                  _buildActionButton(
                    icon: Icons.upload_file,
                    title: 'Upload Scan',
                    subtitle: 'Analyze eye scan',
                    onTap: _navigateToUploadScan,
                    colorScheme: colorScheme,
                  ),
                  // View History Button
                  _buildActionButton(
                    icon: Icons.history,
                    title: 'View History',
                    subtitle: 'Past scans',
                    onTap: _navigateToHistory,
                    colorScheme: colorScheme,
                  ),
                  // Account Settings Button
                  _buildActionButton(
                    icon: Icons.settings,
                    title: 'Account',
                    subtitle: 'Manage profile',
                    onTap: _navigateToSettings,
                    colorScheme: colorScheme,
                  ),
                  // Help & Support Button
                  _buildActionButton(
                    icon: Icons.help_outline,
                    title: 'Help',
                    subtitle: 'Get support',
                    onTap: _navigateToHelp,
                    colorScheme: colorScheme,
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
