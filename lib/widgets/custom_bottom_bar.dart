import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom Bottom Navigation Bar implementing Clinical Minimalism design
/// Provides adaptive navigation with haptic feedback for medical workflows
class CustomBottomBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when navigation item is tapped
  final ValueChanged<int> onTap;

  /// Navigation bar variant for different contexts
  final BottomBarVariant variant;

  /// Whether to show labels on navigation items
  final bool showLabels;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = BottomBarVariant.adaptive,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define navigation items for medical app
    final items = _getNavigationItems(context);

    switch (variant) {
      case BottomBarVariant.adaptive:
        return _buildNavigationBar(context, items, colorScheme);
      case BottomBarVariant.classic:
        return _buildBottomNavigationBar(context, items, colorScheme);
      case BottomBarVariant.floating:
        return _buildFloatingNavigationBar(context, items, colorScheme);
    }
  }

  /// Builds Material 3 NavigationBar (recommended for medical apps)
  Widget _buildNavigationBar(BuildContext context, List<NavigationItem> items,
      ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) => _handleNavigation(context, index),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: colorScheme.primary.withValues(alpha: 0.1),
          elevation: 0,
          height: 80,
          labelBehavior: showLabels
              ? NavigationDestinationLabelBehavior.alwaysShow
              : NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: items
              .map((item) => NavigationDestination(
                    icon: Icon(
                      item.icon,
                      size: 24,
                    ),
                    selectedIcon: Icon(
                      item.selectedIcon ?? item.icon,
                      size: 24,
                    ),
                    label: item.label,
                    tooltip: item.tooltip,
                  ))
              .toList(),
        ),
      ),
    );
  }

  /// Builds classic BottomNavigationBar for compatibility
  Widget _buildBottomNavigationBar(BuildContext context,
      List<NavigationItem> items, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _handleNavigation(context, index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurfaceVariant,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 24,
          showSelectedLabels: showLabels,
          showUnselectedLabels: showLabels,
          items: items
              .map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.selectedIcon ?? item.icon),
                    label: item.label,
                    tooltip: item.tooltip,
                  ))
              .toList(),
        ),
      ),
    );
  }

  /// Builds floating navigation bar for modern medical interfaces
  Widget _buildFloatingNavigationBar(BuildContext context,
      List<NavigationItem> items, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: SafeArea(
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => _handleNavigation(context, index),
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                    height: double.infinity,
                    decoration: isSelected
                        ? BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(32),
                          )
                        : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected
                              ? (item.selectedIcon ?? item.icon)
                              : item.icon,
                          size: 24,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        if (showLabels) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Handles navigation with haptic feedback and route management
  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return;

    // Provide haptic feedback for medical app interactions
    HapticFeedback.selectionClick();

    // Call the onTap callback
    onTap(index);

    // Navigate to the appropriate route
    final routes = [
      '/dashboard-screen',
      '/upload-scan-screen',
      '/scan-history-screen',
      '/results-screen',
    ];

    if (index < routes.length) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        routes[index],
        (route) => false,
      );
    }
  }

  /// Defines navigation items for medical diagnostic application
  List<NavigationItem> _getNavigationItems(BuildContext context) {
    return [
      NavigationItem(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        label: 'Dashboard',
        tooltip: 'Medical Dashboard',
      ),
      NavigationItem(
        icon: Icons.upload_file_outlined,
        selectedIcon: Icons.upload_file_rounded,
        label: 'Upload',
        tooltip: 'Upload Scan',
      ),
      NavigationItem(
        icon: Icons.history_outlined,
        selectedIcon: Icons.history_rounded,
        label: 'History',
        tooltip: 'Scan History',
      ),
      NavigationItem(
        icon: Icons.analytics_outlined,
        selectedIcon: Icons.analytics_rounded,
        label: 'Results',
        tooltip: 'Scan Results',
      ),
    ];
  }

  /// Factory constructor for dashboard navigation
  factory CustomBottomBar.dashboard({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
    bool showLabels = true,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      variant: BottomBarVariant.adaptive,
      showLabels: showLabels,
    );
  }

  /// Factory constructor for scan workflow navigation
  factory CustomBottomBar.scanWorkflow({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
    bool showLabels = true,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      variant: BottomBarVariant.floating,
      showLabels: showLabels,
    );
  }

  /// Factory constructor for minimal navigation
  factory CustomBottomBar.minimal({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      variant: BottomBarVariant.classic,
      showLabels: false,
    );
  }
}

/// Enum defining different bottom bar variants for medical contexts
enum BottomBarVariant {
  /// Adaptive Material 3 NavigationBar (recommended)
  adaptive,

  /// Classic BottomNavigationBar for compatibility
  classic,

  /// Floating navigation bar for modern interfaces
  floating,
}

/// Data class for navigation items
class NavigationItem {
  /// Icon to display when not selected
  final IconData icon;

  /// Icon to display when selected (optional)
  final IconData? selectedIcon;

  /// Label text for the navigation item
  final String label;

  /// Tooltip text for accessibility
  final String tooltip;

  const NavigationItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.tooltip,
  });
}