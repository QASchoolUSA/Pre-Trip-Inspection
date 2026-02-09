import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/inspection_models.dart';
import '../../providers/app_providers.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_router.dart';
import '../../../generated/l10n/app_localizations.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  String _searchQuery = '';
  InspectionStatus? _selectedStatus;
  DateTimeRange? _selectedDateRange;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inspections = ref.watch(enhancedInspectionsProvider);
    final filteredInspections = _filterInspections(inspections);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.viewReports),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.dashboard),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by vehicle, driver, or unit number...',
                    hintStyle: TextStyle(color: AppColors.grey400),
                    prefixIcon: Icon(Icons.search, color: AppColors.grey600),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppColors.grey600),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filter Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusFilter(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateRangeFilter(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Results Section
          Expanded(
            child: filteredInspections.isEmpty
                ? _buildEmptyState()
                : _buildInspectionsList(filteredInspections),
          ),
        ],
      ),
    );
  }

  List<Inspection> _filterInspections(List<Inspection> inspections) {
    var filtered = inspections.where((inspection) => !inspection.isDeleted).toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((inspection) {
        return inspection.vehicle.unitNumber.toLowerCase().contains(_searchQuery) ||
               inspection.driverName.toLowerCase().contains(_searchQuery) ||
               inspection.vehicle.make.toLowerCase().contains(_searchQuery) ||
               inspection.vehicle.model.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply status filter
    if (_selectedStatus != null) {
      filtered = filtered.where((inspection) => inspection.status == _selectedStatus).toList();
    } else {
      // Default: show only completed inspections for "past reports"
      filtered = filtered.where((inspection) => inspection.status == InspectionStatus.completed).toList();
    }

    // Apply date range filter
    if (_selectedDateRange != null) {
      filtered = filtered.where((inspection) {
        final date = inspection.createdAt;
        return date.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
               date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return filtered;
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<InspectionStatus?>(
          value: _selectedStatus,
          hint: const Text('All Status'),
          isExpanded: true,
          items: [
            const DropdownMenuItem<InspectionStatus?>(
              value: null,
              child: Text('All Status'),
            ),
            ...InspectionStatus.values.map((status) {
              return DropdownMenuItem<InspectionStatus?>(
                value: status,
                child: Text(_getStatusText(status)),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedStatus = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return GestureDetector(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range, color: AppColors.grey600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedDateRange != null
                    ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                    : 'All Dates',
                style: TextStyle(
                  color: _selectedDateRange != null ? AppColors.grey900 : AppColors.grey600,
                ),
              ),
            ),
            if (_selectedDateRange != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDateRange = null;
                  });
                },
                child: Icon(Icons.clear, color: AppColors.grey600, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'No reports found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete some inspections to see reports here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.go(RouteNames.dashboard);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionsList(List<Inspection> inspections) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: inspections.length,
      itemBuilder: (context, index) {
        final inspection = inspections[index];
        return _buildInspectionCard(inspection);
      },
    );
  }

  Widget _buildInspectionCard(Inspection inspection) {
    final statusColor = _getStatusColor(inspection.status);
    final completedItems = inspection.items.where((item) => item.checkedAt != null).length;
    final totalItems = inspection.items.length;
    final progressPercentage = totalItems > 0 ? (completedItems / totalItems) : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewInspectionDetails(inspection),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unit ${inspection.vehicle.unitNumber}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${inspection.vehicle.make} ${inspection.vehicle.model} (${inspection.vehicle.year})',
                          style: TextStyle(
                            color: AppColors.grey600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(inspection.status),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Driver and Date Info
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: AppColors.grey600),
                  const SizedBox(width: 6),
                  Text(
                    inspection.driverName,
                    style: TextStyle(color: AppColors.grey700),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 16, color: AppColors.grey600),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(inspection.createdAt),
                    style: TextStyle(color: AppColors.grey700),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$completedItems/$totalItems items',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progressPercentage,
                    backgroundColor: AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 6,
                  ),
                ],
              ),
              
              // Additional Info
              if (inspection.completedAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: AppColors.successGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Completed ${_formatDate(inspection.completedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryBlue,
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
    }
  }

  void _viewInspectionDetails(Inspection inspection) {
    context.goToInspectionDetails(inspection.id);
  }

  String _getStatusText(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.pending:
        return 'Pending';
      case InspectionStatus.inProgress:
        return 'In Progress';
      case InspectionStatus.completed:
        return 'Completed';
      case InspectionStatus.failed:
        return 'Failed';
    }
  }

  Color _getStatusColor(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.pending:
        return AppColors.warningYellow;
      case InspectionStatus.inProgress:
        return AppColors.primaryBlue;
      case InspectionStatus.completed:
        return AppColors.successGreen;
      case InspectionStatus.failed:
        return AppColors.errorRed;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}