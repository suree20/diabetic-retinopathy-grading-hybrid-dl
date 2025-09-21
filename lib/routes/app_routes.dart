import 'package:flutter/material.dart';
import '../presentation/scan_history_screen/scan_history_screen.dart';
import '../presentation/results_screen/results_screen.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/upload_scan_screen/upload_scan_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/history_screen/history_screen.dart';
import '../presentation/detailed_report_screen/detailed_report_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/processing_screen/processing_screen.dart';
import '../screens/profile_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String scanHistory = '/scan-history-screen';
  static const String results = '/results-screen';
  static const String dashboard = '/dashboard-screen';
  static const String login = '/login-screen';
  static const String uploadScan = '/upload-scan-screen';
  static const String registration = '/registration-screen';
  static const String historyScreen = '/history-screen';
  static const String detailedReportScreen = '/detailed-report-screen';
  static const String settingsScreen = '/settings-screen';
  static const String processingScreen = '/processing-screen';
  static const String profileScreen = '/profile-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    scanHistory: (context) => const ScanHistoryScreen(),
    results: (context) => const ResultsScreen(),
    dashboard: (context) => const DashboardScreen(),
    login: (context) => const LoginScreen(),
    uploadScan: (context) => const UploadScanScreen(),
    registration: (context) => const RegistrationScreen(),
    historyScreen: (context) => const HistoryScreen(),
    detailedReportScreen: (context) => const DetailedReportScreen(),
    settingsScreen: (context) => const SettingsScreen(),
    profileScreen: (context) => const ProfileScreen(),
    processingScreen: (context) => const ProcessingScreen(),
    // TODO: Add your other routes here
  };
}
