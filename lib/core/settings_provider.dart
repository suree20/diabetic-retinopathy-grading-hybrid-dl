import 'package:flutter/material.dart';

// Provider class for managing settings state
class SettingsProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _dataSharingEnabled = false;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get dataSharingEnabled => _dataSharingEnabled;

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    _darkModeEnabled = value;
    notifyListeners();
  }

  void toggleDataSharing(bool value) {
    _dataSharingEnabled = value;
    notifyListeners();
  }
}
