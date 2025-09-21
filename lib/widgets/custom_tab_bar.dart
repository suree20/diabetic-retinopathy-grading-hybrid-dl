import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom Tab Bar implementing Clinical Minimalism design for medical applications
/// Provides contextual navigation within screens with medical-appropriate styling
class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// List of tab labels
  final List<String> tabs;

  /// Current selected tab index
  final int currentIndex;

  /// Callback when tab is selected
  final ValueChanged<int> onTap;

  /// Tab bar variant for different medical contexts
  final TabBarVariant variant;

  /// Whether tabs are scrollable
  final bool isScrollable;

  /// Custom tab controller (optional)
  final TabController? controller;

  /// Whether to show tab indicators
  final bool showIndicator;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.variant = TabBarVariant.primary,
    this.isScrollable = false,
    this.controller,
    this.showIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case TabBarVariant.primary:
        return _buildPrimaryTabBar(context, theme, colorScheme);
      case TabBarVariant.secondary:
        return _buildSecondaryTabBar(context, theme, colorScheme);
      case TabBarVariant.medical:
        return _buildMedicalTabBar(context, theme, colorScheme);
      case TabBarVariant.segmented:
        return _buildSegmentedTabBar(context, theme, colorScheme);
    }
  }

  /// Builds primary tab bar for main navigation
  Widget _buildPrimaryTabBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        onTap: (index) => _handleTabSelection(context, index),
        isScrollable: isScrollable,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor:
            showIndicator ? colorScheme.primary : Colors.transparent,
        indicatorWeight: 2.0,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        splashFactory: InkRipple.splashFactory,
        overlayColor: WidgetStateProperty.all(
          colorScheme.primary.withValues(alpha: 0.1),
        ),
        dividerColor: Colors.transparent,
        tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
      ),
    );
  }

  /// Builds secondary tab bar for sub-navigation
  Widget _buildSecondaryTabBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        onTap: (index) => _handleTabSelection(context, index),
        isScrollable: isScrollable,
        labelColor: colorScheme.onSurface,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor:
            showIndicator ? colorScheme.primary : Colors.transparent,
        indicatorWeight: 2.0,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: showIndicator
            ? BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        splashFactory: InkRipple.splashFactory,
        overlayColor: WidgetStateProperty.all(
          colorScheme.primary.withValues(alpha: 0.08),
        ),
        dividerColor: Colors.transparent,
        tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
      ),
    );
  }

  /// Builds medical-themed tab bar for clinical contexts
  Widget _buildMedicalTabBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs
            .map((tab) => Tab(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(tab),
                  ),
                ))
            .toList(),
        onTap: (index) => _handleTabSelection(context, index),
        isScrollable: isScrollable,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: Colors.transparent,
        indicator: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        splashFactory: InkRipple.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        dividerColor: Colors.transparent,
        tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
      ),
    );
  }

  /// Builds segmented tab bar for toggle-like navigation
  Widget _buildSegmentedTabBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == currentIndex;
          final isFirst = index == 0;
          final isLast = index == tabs.length - 1;

          return Expanded(
            child: GestureDetector(
              onTap: () => _handleTabSelection(context, index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: isFirst ? const Radius.circular(12) : Radius.zero,
                    right: isLast ? const Radius.circular(12) : Radius.zero,
                  ),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Handles tab selection with haptic feedback
  void _handleTabSelection(BuildContext context, int index) {
    if (index == currentIndex) return;

    // Provide haptic feedback for medical app interactions
    HapticFeedback.selectionClick();

    // Call the onTap callback
    onTap(index);
  }

  @override
  Size get preferredSize {
    switch (variant) {
      case TabBarVariant.primary:
      case TabBarVariant.secondary:
        return const Size.fromHeight(48);
      case TabBarVariant.medical:
        return const Size.fromHeight(64);
      case TabBarVariant.segmented:
        return const Size.fromHeight(80);
    }
  }

  /// Factory constructor for scan results tabs
  factory CustomTabBar.scanResults({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
    TabController? controller,
  }) {
    return CustomTabBar(
      key: key,
      tabs: const ['Overview', 'Details', 'History'],
      currentIndex: currentIndex,
      onTap: onTap,
      variant: TabBarVariant.medical,
      controller: controller,
    );
  }

  /// Factory constructor for dashboard tabs
  factory CustomTabBar.dashboard({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
    TabController? controller,
  }) {
    return CustomTabBar(
      key: key,
      tabs: const ['Recent', 'All Scans', 'Reports'],
      currentIndex: currentIndex,
      onTap: onTap,
      variant: TabBarVariant.primary,
      controller: controller,
      isScrollable: false,
    );
  }

  /// Factory constructor for history filter tabs
  factory CustomTabBar.historyFilter({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
    TabController? controller,
  }) {
    return CustomTabBar(
      key: key,
      tabs: const ['All', 'This Week', 'This Month', 'This Year'],
      currentIndex: currentIndex,
      onTap: onTap,
      variant: TabBarVariant.secondary,
      controller: controller,
      isScrollable: true,
    );
  }

  /// Factory constructor for upload type selection
  factory CustomTabBar.uploadType({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
    TabController? controller,
  }) {
    return CustomTabBar(
      key: key,
      tabs: const ['Camera', 'Gallery'],
      currentIndex: currentIndex,
      onTap: onTap,
      variant: TabBarVariant.segmented,
      controller: controller,
      showIndicator: false,
    );
  }

  /// Factory constructor for analysis view tabs
  factory CustomTabBar.analysisView({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
    TabController? controller,
  }) {
    return CustomTabBar(
      key: key,
      tabs: const ['Image', 'Analysis', 'Recommendations'],
      currentIndex: currentIndex,
      onTap: onTap,
      variant: TabBarVariant.medical,
      controller: controller,
      isScrollable: false,
    );
  }
}

/// Enum defining different tab bar variants for medical contexts
enum TabBarVariant {
  /// Standard primary tab bar for main navigation
  primary,

  /// Secondary tab bar for sub-navigation
  secondary,

  /// Medical-themed tab bar with enhanced styling
  medical,

  /// Segmented control style for toggle navigation
  segmented,
}
