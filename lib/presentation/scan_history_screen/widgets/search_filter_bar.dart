import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Search and filter bar for scan history with real-time filtering
class SearchFilterBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String?) onRiskFilterChanged;
  final Function(DateTimeRange?) onDateRangeChanged;
  final VoidCallback onClearFilters;
  final bool hasActiveFilters;

  const SearchFilterBar({
    super.key,
    required this.onSearchChanged,
    required this.onRiskFilterChanged,
    required this.onDateRangeChanged,
    required this.onClearFilters,
    required this.hasActiveFilters,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRiskFilter;
  DateTimeRange? _selectedDateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search scans by filename or date...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              ),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          SizedBox(height: 2.h),

          // Filter options
          Row(
            children: [
              // Risk level filter
              Expanded(
                child: _buildRiskFilterChip(context),
              ),
              SizedBox(width: 2.w),

              // Date range filter
              Expanded(
                child: _buildDateRangeChip(context),
              ),
              SizedBox(width: 2.w),

              // Clear filters button
              if (widget.hasActiveFilters)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRiskFilter = null;
                      _selectedDateRange = null;
                      _searchController.clear();
                    });
                    widget.onClearFilters();
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'clear_all',
                      color: colorScheme.error,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds risk level filter chip
  Widget _buildRiskFilterChip(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasFilter = _selectedRiskFilter != null;

    return GestureDetector(
      onTap: () => _showRiskFilterDialog(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: hasFilter
              ? colorScheme.primary.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasFilter
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'filter_list',
              color: hasFilter
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Expanded(
              child: Text(
                _selectedRiskFilter ?? 'Risk Level',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: hasFilter
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: hasFilter ? FontWeight.w500 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds date range filter chip
  Widget _buildDateRangeChip(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasFilter = _selectedDateRange != null;

    return GestureDetector(
      onTap: () => _showDateRangePicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: hasFilter
              ? colorScheme.primary.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasFilter
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'date_range',
              color: hasFilter
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Expanded(
              child: Text(
                hasFilter
                    ? '${_selectedDateRange!.start.month}/${_selectedDateRange!.start.day} - ${_selectedDateRange!.end.month}/${_selectedDateRange!.end.day}'
                    : 'Date Range',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: hasFilter
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: hasFilter ? FontWeight.w500 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows risk level filter dialog
  void _showRiskFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Risk Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRiskOption(context, null, 'All Risk Levels'),
            _buildRiskOption(context, 'Mild', 'Mild Risk'),
            _buildRiskOption(context, 'Moderate', 'Moderate Risk'),
            _buildRiskOption(context, 'Severe', 'Severe Risk'),
          ],
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

  /// Builds risk option in filter dialog
  Widget _buildRiskOption(BuildContext context, String? value, String label) {
    final isSelected = _selectedRiskFilter == value;

    return RadioListTile<String?>(
      title: Text(label),
      value: value,
      groupValue: _selectedRiskFilter,
      onChanged: (newValue) {
        setState(() {
          _selectedRiskFilter = newValue;
        });
        widget.onRiskFilterChanged(newValue);
        Navigator.pop(context);
      },
      selected: isSelected,
    );
  }

  /// Shows date range picker
  void _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      widget.onDateRangeChanged(picked);
    }
  }
}
