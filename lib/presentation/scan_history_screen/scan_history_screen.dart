import 'package:flutter/material.dart';

import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_history_state.dart';
import './widgets/search_filter_bar.dart';

/// Scan History Screen for comprehensive diabetic retinopathy monitoring
/// Provides chronological tracking with medical timeline visualization
class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // State management
  List<Map<String, dynamic>> _allScans = [];
  List<Map<String, dynamic>> _filteredScans = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _riskFilter;
  DateTimeRange? _dateRangeFilter;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    _loadScanHistory();
  }

  @override
  void dispose() {
    // Remove listeners to prevent setState after dispose
    _tabController.removeListener(_onTabChanged);
    _scrollController.removeListener(_onScroll);

    // Dispose controllers
    _tabController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            // Tab bar for history filtering
            Container(
              color: colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'This Week'),
                  Tab(text: 'This Month'),
                  Tab(text: 'This Year'),
                ],
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                indicatorColor: colorScheme.primary,
                indicatorWeight: 2,
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ),

            // Search and filter bar
            SearchFilterBar(
              onSearchChanged: _onSearchChanged,
              onRiskFilterChanged: _onRiskFilterChanged,
              onDateRangeChanged: _onDateRangeChanged,
              onClearFilters: _clearAllFilters,
              hasActiveFilters: _hasActiveFilters(),
            ),

            // Main content with proper scrolling
            Expanded(
              child: _buildContent(context),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  /// Builds the app bar with search functionality
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 48,
      title: Text(
        'Scan History',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () =>
            Navigator.pushReplacementNamed(context, '/dashboard-screen'),
        icon: CustomIconWidget(
          iconName: 'arrow_back_ios',
          color: colorScheme.onSurface,
          size: 18,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showSearchDialog,
          icon: CustomIconWidget(
            iconName: 'search',
            color: colorScheme.onSurface,
            size: 20,
          ),
          tooltip: 'Search Scans',
        ),
        PopupMenuButton<String>(
          icon: CustomIconWidget(
            iconName: 'more_vert',
            color: colorScheme.onSurface,
            size: 20,
          ),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.file_download_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Export History', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sync',
              child: Row(
                children: [
                  Icon(Icons.sync, size: 16),
                  SizedBox(width: 8),
                  Text('Sync Data', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Settings', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds main content based on current state
  Widget _buildContent(BuildContext context) {
    if (_isLoading && _filteredScans.isEmpty) {
      return _buildLoadingState();
    }

    if (_filteredScans.isEmpty) {
      return EmptyHistoryState(
        onUploadScan: () => Navigator.pushNamed(context, '/upload-scan-screen'),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshHistory,
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: _filteredScans.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredScans.length) {
            return _buildLoadingMoreIndicator();
          }

          final scan = _filteredScans[index];
          return _buildScanHistoryCard(scan, context);
        },
      ),
    );
  }

  Widget _buildScanHistoryCard(
      Map<String, dynamic> scan, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Scan Preview Image - Compact size
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                scan['imageUrl'] as String? ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Scan Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan['fileName'] as String? ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  scan['scanDate'] as String? ?? 'Unknown Date',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: _getRiskColor(scan['riskLevel'] as String? ?? '')
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        scan['riskLevel'] as String? ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color:
                              _getRiskColor(scan['riskLevel'] as String? ?? ''),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${scan['confidence']?.toStringAsFixed(1) ?? '0'}%',
                      style: TextStyle(
                        fontSize: 9,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Menu
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            onSelected: (value) => _handleScanAction(value, scan),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 14),
                    SizedBox(width: 6),
                    Text('View', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 14),
                    SizedBox(width: 6),
                    Text('Share', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 14),
                    SizedBox(width: 6),
                    Text('Delete', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds loading state
  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading scan history...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }

  /// Builds loading indicator for infinite scroll
  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  /// Builds floating action button for new scan upload
  Widget _buildFloatingActionButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
      onPressed: () => Navigator.pushNamed(context, '/upload-scan-screen'),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      icon: CustomIconWidget(
        iconName: 'add',
        color: colorScheme.onPrimary,
        size: 20,
      ),
      label: const Text(
        'New Scan',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      tooltip: 'Upload New Scan',
    );
  }

  /// Loads scan history data from mock source
  Future<void> _loadScanHistory() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      // Mock scan history data
      final mockScans = [
        {
          'id': '1',
          'fileName': 'retinal_scan_08_25.jpg',
          'scanDate': '08/25/2024',
          'riskLevel': 'Low',
          'confidence': 87.5,
          'imageUrl':
              'https://images.pexels.com/photos/5327585/pexels-photo-5327585.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'id': '2',
          'fileName': 'eye_examination_08_20.pdf',
          'scanDate': '08/20/2024',
          'riskLevel': 'Moderate',
          'confidence': 92.3,
          'imageUrl':
              'https://images.pexels.com/photos/5327585/pexels-photo-5327585.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          'timestamp': DateTime.now().subtract(const Duration(days: 3)),
        },
        {
          'id': '3',
          'fileName': 'diabetic_screening_08_15.jpg',
          'scanDate': '08/15/2024',
          'riskLevel': 'Severe',
          'confidence': 95.8,
          'imageUrl':
              'https://images.pexels.com/photos/7659737/pexels-photo-7659737.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          'timestamp': DateTime.now().subtract(const Duration(days: 8)),
        },
        {
          'id': '4',
          'fileName': 'routine_check_08_10.jpg',
          'scanDate': '08/10/2024',
          'riskLevel': 'Mild',
          'confidence': 84.2,
          'imageUrl':
              'https://images.pexels.com/photos/5327921/pexels-photo-5327921.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          'timestamp': DateTime.now().subtract(const Duration(days: 13)),
        },
        {
          'id': '5',
          'fileName': 'follow_up_scan_08_05.pdf',
          'scanDate': '08/05/2024',
          'riskLevel': 'Moderate',
          'confidence': 89.7,
          'imageUrl':
              'https://images.pexels.com/photos/7659564/pexels-photo-7659564.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          'timestamp': DateTime.now().subtract(const Duration(days: 18)),
        },
      ];

      if (mounted) {
        setState(() {
          _allScans = mockScans;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load scan history');
      }
    }
  }

  /// Refreshes scan history with pull-to-refresh
  Future<void> _refreshHistory() async {
    if (!mounted) return;

    try {
      await _loadScanHistory();
      if (mounted) {
        _showSuccessSnackBar('History updated');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to refresh history');
      }
    }
  }

  /// Handles tab changes for time-based filtering
  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;

    final now = DateTime.now();
    DateTimeRange? timeFilter;

    switch (_tabController.index) {
      case 1: // This Week
        timeFilter = DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );
        break;
      case 2: // This Month
        timeFilter = DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
        break;
      case 3: // This Year
        timeFilter = DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        );
        break;
      default: // All
        timeFilter = null;
    }

    setState(() {
      _dateRangeFilter = timeFilter;
    });
    _applyFilters();
  }

  /// Handles scroll events for infinite loading
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreScans();
    }
  }

  /// Loads more scans for infinite scroll
  Future<void> _loadMoreScans() async {
    if (_isLoading || !_hasMoreData || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate loading more data
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _hasMoreData = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handles search query changes
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
    _applyFilters();
  }

  /// Handles risk filter changes
  void _onRiskFilterChanged(String? riskLevel) {
    setState(() {
      _riskFilter = riskLevel;
    });
    _applyFilters();
  }

  /// Handles date range filter changes
  void _onDateRangeChanged(DateTimeRange? dateRange) {
    setState(() {
      _dateRangeFilter = dateRange;
    });
    _applyFilters();
  }

  /// Clears all active filters
  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _riskFilter = null;
      _dateRangeFilter = null;
      _tabController.animateTo(0); // Reset to "All" tab
    });
    _applyFilters();
  }

  /// Checks if any filters are active
  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty ||
        _riskFilter != null ||
        _dateRangeFilter != null;
  }

  /// Applies current filters to scan list
  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allScans);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((scan) {
        final fileName = (scan['fileName'] as String? ?? '').toLowerCase();
        final scanDate = (scan['scanDate'] as String? ?? '').toLowerCase();
        return fileName.contains(_searchQuery) ||
            scanDate.contains(_searchQuery);
      }).toList();
    }

    // Apply risk level filter
    if (_riskFilter != null) {
      filtered = filtered.where((scan) {
        final riskLevel = (scan['riskLevel'] as String? ?? '').toLowerCase();
        return riskLevel == _riskFilter!.toLowerCase();
      }).toList();
    }

    // Apply date range filter
    if (_dateRangeFilter != null) {
      filtered = filtered.where((scan) {
        final timestamp = scan['timestamp'] as DateTime?;
        if (timestamp == null) return false;
        return timestamp.isAfter(_dateRangeFilter!.start) &&
            timestamp
                .isBefore(_dateRangeFilter!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) {
      final timestampA = a['timestamp'] as DateTime? ?? DateTime.now();
      final timestampB = b['timestamp'] as DateTime? ?? DateTime.now();
      return timestampB.compareTo(timestampA);
    });

    setState(() {
      _filteredScans = filtered;
    });
  }

  /// Shows search dialog
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Scans'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter filename or date...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            _onSearchChanged(value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Handles menu actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportHistory();
        break;
      case 'sync':
        _refreshHistory();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
    }
  }

  /// Exports scan history
  void _exportHistory() {
    _showSuccessSnackBar('Export functionality coming soon');
  }

  /// Shows settings dialog
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('History Settings'),
        content: const Text('Settings functionality coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Navigates to results screen
  void _navigateToResults(Map<String, dynamic> scanData) {
    Navigator.pushNamed(
      context,
      '/results-screen',
      arguments: scanData,
    );
  }

  /// Shares scan results
  void _shareScan(Map<String, dynamic> scanData) {
    final fileName = scanData['fileName'] as String? ?? 'Unknown';
    _showSuccessSnackBar('Sharing $fileName...');
  }

  /// Deletes scan from history
  void _deleteScan(Map<String, dynamic> scanData) {
    if (!mounted) return;

    final scanId = scanData['id'] as String?;
    if (scanId == null) return;

    setState(() {
      _allScans.removeWhere((scan) => scan['id'] == scanId);
    });
    _applyFilters();

    final fileName = scanData['fileName'] as String? ?? 'scan';
    if (mounted) {
      _showSuccessSnackBar('$fileName deleted');
    }
  }

  /// Shows success snackbar
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Shows error snackbar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Handles individual scan actions (view, share, delete)
  void _handleScanAction(String action, Map<String, dynamic> scanData) {
    switch (action) {
      case 'view':
        _navigateToResults(scanData);
        break;
      case 'share':
        _shareScan(scanData);
        break;
      case 'delete':
        _deleteScan(scanData);
        break;
    }
  }

  /// Gets color based on risk level
  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'Mild':
        return Colors.green;
      case 'Moderate':
        return Colors.orange;
      case 'Severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
