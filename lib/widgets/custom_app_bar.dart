import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom AppBar widget implementing Clinical Minimalism design for medical applications
/// Provides consistent navigation and branding across all screens
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String title;

  /// Whether to show the back button (defaults to true when there's a previous route)
  final bool showBackButton;

  /// Custom leading widget (overrides back button if provided)
  final Widget? leading;

  /// List of action widgets to display on the right side
  final List<Widget>? actions;

  /// Whether to center the title (defaults to true for medical apps)
  final bool centerTitle;

  /// Custom background color (uses theme color if not provided)
  final Color? backgroundColor;

  /// Whether to show elevation shadow
  final bool showElevation;

  /// App bar variant for different contexts
  final AppBarVariant variant;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.showElevation = true,
    this.variant = AppBarVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine background color based on variant
    Color effectiveBackgroundColor;
    Color effectiveForegroundColor;

    switch (variant) {
      case AppBarVariant.primary:
        effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
        effectiveForegroundColor = colorScheme.onSurface;
        break;
      case AppBarVariant.transparent:
        effectiveBackgroundColor = Colors.transparent;
        effectiveForegroundColor = colorScheme.onSurface;
        break;
      case AppBarVariant.medical:
        effectiveBackgroundColor =
            backgroundColor ?? colorScheme.primary.withValues(alpha: 0.05);
        effectiveForegroundColor = colorScheme.onSurface;
        break;
    }

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: effectiveForegroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: showElevation ? 1.0 : 0.0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: theme.brightness,
      ),
      leading: _buildLeading(context, effectiveForegroundColor),
      actions: _buildActions(context, effectiveForegroundColor),
      shape: variant == AppBarVariant.transparent
          ? null
          : Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
    );
  }

  /// Builds the leading widget (back button or custom widget)
  Widget? _buildLeading(BuildContext context, Color foregroundColor) {
    if (leading != null) return leading;

    if (showBackButton && Navigator.of(context).canPop()) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: foregroundColor,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
        splashRadius: 20,
      );
    }

    return null;
  }

  /// Builds the action widgets with consistent styling
  List<Widget>? _buildActions(BuildContext context, Color foregroundColor) {
    if (actions == null) return null;

    return actions!.map((action) {
      if (action is IconButton) {
        return IconButton(
          icon: action.icon,
          onPressed: action.onPressed,
          tooltip: action.tooltip,
          color: foregroundColor,
          splashRadius: 20,
        );
      }
      return action;
    }).toList();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// Factory constructor for dashboard screen
  factory CustomAppBar.dashboard({
    Key? key,
    String title = 'Medical Dashboard',
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      showBackButton: false,
      variant: AppBarVariant.medical,
      actions: actions ??
          [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // Handle notifications
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications opened')),
                  );
                },
                tooltip: 'Notifications',
              ),
            ),
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, '/registration-screen');
                },
                tooltip: 'Profile',
              ),
            ),
          ],
    );
  }

  /// Factory constructor for scan screens
  factory CustomAppBar.scan({
    Key? key,
    String title = 'Scan Analysis',
    bool showBackButton = true,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      showBackButton: showBackButton,
      variant: AppBarVariant.primary,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {
              // Show help dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Scan Help'),
                  content: const Text(
                      'Upload a clear image of your medical scan for analysis.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Help',
          ),
        ),
      ],
    );
  }

  /// Factory constructor for results screen
  factory CustomAppBar.results({
    Key? key,
    String title = 'Scan Results',
    bool showBackButton = true,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      showBackButton: showBackButton,
      variant: AppBarVariant.primary,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // Handle share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Share functionality coming soon')),
              );
            },
            tooltip: 'Share Results',
          ),
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              // Handle download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Results downloaded')),
              );
            },
            tooltip: 'Download Results',
          ),
        ),
      ],
    );
  }

  /// Factory constructor for history screen
  factory CustomAppBar.history({
    Key? key,
    String title = 'Scan History',
    bool showBackButton = true,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      showBackButton: showBackButton,
      variant: AppBarVariant.primary,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              // Handle search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Search functionality coming soon')),
              );
            },
            tooltip: 'Search History',
          ),
        ),
        Builder(
          builder: (context) => PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: 'More Options',
            onSelected: (value) {
              switch (value) {
                case 'filter':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filter options coming soon')),
                  );
                  break;
                case 'export':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Export functionality coming soon')),
                  );
                  break;
                case 'clear':
                  _showClearHistoryDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.filter_list_rounded),
                    SizedBox(width: 12),
                    Text('Filter'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download_outlined),
                    SizedBox(width: 12),
                    Text('Export'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded),
                    SizedBox(width: 12),
                    Text('Clear History'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Factory constructor for authentication screens
  factory CustomAppBar.auth({
    Key? key,
    String title = 'Medical App',
    bool showBackButton = false,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      showBackButton: showBackButton,
      variant: AppBarVariant.transparent,
      centerTitle: true,
    );
  }

  /// Shows clear history confirmation dialog
  static void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all scan history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

/// Enum defining different app bar variants for medical contexts
enum AppBarVariant {
  /// Standard app bar with surface background
  primary,

  /// Transparent app bar for overlay contexts
  transparent,

  /// Medical-themed app bar with subtle primary tint
  medical,
}
