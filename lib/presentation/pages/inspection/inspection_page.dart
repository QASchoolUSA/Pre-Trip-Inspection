import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../generated/l10n/app_localizations.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/localized_inspection_data.dart';
import '../../../core/navigation/app_router.dart';
import '../../../data/models/inspection_models.dart';
import '../../providers/app_providers.dart';
import 'photo_capture_page.dart';
import '../signature/signature_page.dart';

/// Main inspection page with comprehensive checklist
class InspectionPage extends ConsumerStatefulWidget {
  final String? inspectionId;
  
  const InspectionPage({super.key, this.inspectionId});

  @override
  ConsumerState<InspectionPage> createState() => _InspectionPageState();
}

class _InspectionPageState extends ConsumerState<InspectionPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  Inspection? _currentInspection;
  Map<String, List<InspectionItem>> _categorizedItems = {};
  Set<String> _expandedItems = {}; // Track expanded items
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInspection();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_categorizedItems.isEmpty) {
      _setupCategories();
      _tabController = TabController(length: _categorizedItems.keys.length, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInspection() {
    if (widget.inspectionId != null) {
      final inspections = ref.read(inspectionsProvider);
      _currentInspection = inspections.firstWhere(
        (inspection) => inspection.id == widget.inspectionId,
        orElse: () => throw Exception('Inspection not found'),
      );
    } else {
      _currentInspection = ref.read(currentInspectionProvider);
    }
  }

  void _setupCategories() {
    final categories = LocalizedInspectionData.getAllCategories(context);
    _categorizedItems = {};
    
    for (final category in categories) {
      if (_currentInspection != null) {
        _categorizedItems[category] = _currentInspection!.items
            .where((item) => item.category == category)
            .toList();
      } else {
        _categorizedItems[category] = LocalizedInspectionData.getItemsByCategory(context, category);
      }
    }
    
    // Initialize tab controller after categories are set up
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateInspectionItem(InspectionItem item) async {
    if (_currentInspection == null) return;

    await ref.read(inspectionsProvider.notifier).updateInspectionItem(
      _currentInspection!.id,
      item,
    );

    // Refresh current inspection
    final updatedInspections = ref.read(inspectionsProvider);
    _currentInspection = updatedInspections.firstWhere(
      (inspection) => inspection.id == _currentInspection!.id,
    );
    
    // Update categorized items with fresh data
    _setupCategories();
    
    // Check if current category is complete and auto-advance
    _checkAndAdvanceTab();
    
    setState(() {});
  }

  void _checkAndAdvanceTab() {
    if (_tabController == null || _currentInspection == null) return;
    
    final currentIndex = _tabController!.index;
    final categories = _categorizedItems.keys.toList();
    
    if (currentIndex < categories.length) {
      final currentCategory = categories[currentIndex];
      
      // Get fresh data from current inspection
      final categoryItems = _currentInspection!.items
          .where((item) => item.category == currentCategory)
          .toList();
      
      print('Auto-advance check: Category=$currentCategory, Items=${categoryItems.length}');
      
      // Check if ALL items in current category are completed (have been explicitly checked)
      final allItems = categoryItems;
      final completedAllItems = allItems.where(
        (item) => item.checkedAt != null
      );
      
      print('All items: ${allItems.length}, Completed all: ${completedAllItems.length}');
      
      // Only advance when ALL items are completed (100% completion)
      final shouldAdvance = allItems.isNotEmpty && allItems.length == completedAllItems.length;
      
      print('Should advance: $shouldAdvance (${completedAllItems.length}/${allItems.length} completed)');
      
      if (shouldAdvance && currentIndex < categories.length - 1) {
        print('Auto-advancing from $currentCategory to next section...');
        
        // Auto-advance to next tab immediately
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _tabController != null) {
            _tabController!.animateTo(currentIndex + 1);
            
            // Show feedback after advancing
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('$currentCategory completed! All ${allItems.length} items done ✓'),
                    ),
                  ],
                ),
                backgroundColor: AppColors.successGreen,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentInspection == null || _tabController == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Inspection'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.errorRed,
              ),
              SizedBox(height: 16),
              Text(
                'No inspection found',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Please start a new inspection from the dashboard',
                style: TextStyle(color: AppColors.grey600),
              ),
            ],
          ),
        ),
      );
    }

    final progressPercentage = _currentInspection!.progressPercentage;
    final categories = _categorizedItems.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_getInspectionTypeText()} Inspection'),
            Text(
              '${_currentInspection!.vehicle.unitNumber} - ${_currentInspection!.vehicle.make}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress: ${progressPercentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${_currentInspection!.passedItemsCount}/${_currentInspection!.items.length} items',
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progressPercentage / 100,
                      backgroundColor: AppColors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  ],
                ),
              ),
              
              // Tab bar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.white,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                tabs: categories.map((category) {
                  final categoryItems = _categorizedItems[category] ?? [];
                  final completedItems = categoryItems.where((item) => 
                      item.checkedAt != null).length;
                  
                  return Tab(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(category),
                        const SizedBox(height: 2),
                        Text(
                          '$completedItems/${categoryItems.length}',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((category) {
          final items = _categorizedItems[category] ?? [];
          return _buildCategoryView(category, items);
        }).toList(),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save & Exit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.grey600,
                    foregroundColor: AppColors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _currentInspection!.isComplete
                      ? _completeInspection
                      : _canAdvanceToNext() ? _advanceToNextSection : null,
                  icon: Icon(_getNavigationIcon()),
                  label: Text(_getNavigationText()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentInspection!.isComplete 
                        ? AppColors.successGreen 
                        : AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shadowColor: _currentInspection!.isComplete 
                        ? AppColors.successGreen.withValues(alpha: 0.3)
                        : AppColors.primaryBlue.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryView(String category, List<InspectionItem> items) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildInspectionItemCard(item);
      },
    );
  }

  Widget _buildInspectionItemCard(InspectionItem item) {
    final hasPhotos = item.photoUrls.isNotEmpty;
    final hasNotes = item.notes != null && item.notes!.isNotEmpty;
    final isExpanded = _expandedItems.contains(item.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: item.checkedAt != null 
              ? _getStatusColor(item.status)
              : hasPhotos 
                  ? AppColors.primaryBlue.withValues(alpha: 0.3)
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: ExpansionTile(
        key: Key(item.id), // Add key for better state management
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            if (expanded) {
              _expandedItems.add(item.id);
              // Scroll to show the expanded content
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToExpandedItem();
              });
            } else {
              _expandedItems.remove(item.id);
            }
          });
        },
        backgroundColor: item.checkedAt != null 
            ? _getStatusColor(item.status).withValues(alpha: 0.05)
            : hasPhotos 
                ? AppColors.primaryBlue.withValues(alpha: 0.05)
                : null,
        title: Row(
          children: [
            _buildStatusIcon(item.status),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: item.status == InspectionItemStatus.failed 
                          ? AppColors.errorRed 
                          : AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (item.isRequired) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.errorRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.required,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (hasPhotos) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.photo_camera, size: 12, color: AppColors.white),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context)!.photoAttached(item.photoUrls.length),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (hasNotes) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryOrange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.note, size: 10, color: AppColors.white),
                              const SizedBox(width: 2),
                              Text(
                                AppLocalizations.of(context)!.notes,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (item.checkedAt != null)
              Icon(
                Icons.check_circle,
                color: _getStatusColor(item.status),
                size: 24,
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            item.description,
            style: const TextStyle(
              color: AppColors.grey600,
              fontSize: 13,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status selection
                const Text(
                    'Status:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: InspectionItemStatus.values.map((status) {
                    final isSelected = item.status == status;
                    return GestureDetector(
                      onTap: () {
                        final updatedItem = item.copyWith(
                          status: status,
                          checkedAt: DateTime.now(),
                        );
                        _updateInspectionItem(updatedItem);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? _getStatusColor(status)
                              : AppColors.grey100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? _getStatusColor(status)
                                : AppColors.grey300,
                            width: isSelected ? 5 : 2,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: _getStatusColor(status).withValues(alpha: 0.8),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: _getStatusColor(status).withValues(alpha: 0.4),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                              spreadRadius: 4,
                            ),
                          ] : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon2(status),
                              size: 20,
                              color: isSelected 
                                  ? AppColors.white
                                  : AppColors.grey600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getStatusText(status),
                              style: TextStyle(
                                color: isSelected 
                                    ? AppColors.white
                                    : AppColors.grey700,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                                fontSize: isSelected ? 16 : 14,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 4),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                // Defect severity (if failed)
                if (item.status == InspectionItemStatus.failed) ...[
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.defectSeverityLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: DefectSeverity.values.map((severity) {
                      return ChoiceChip(
                        label: Text(_getSeverityText(severity)),
                        selected: item.defectSeverity == severity,
                        onSelected: (selected) {
                          if (selected) {
                            final updatedItem = item.copyWith(
                              defectSeverity: severity,
                            );
                            _updateInspectionItem(updatedItem);
                          }
                        },
                        selectedColor: _getSeverityColor(severity).withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: item.defectSeverity == severity 
                              ? _getSeverityColor(severity) 
                              : AppColors.grey600,
                          fontWeight: item.defectSeverity == severity 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],
                
                // Action buttons
                const SizedBox(height: 16),
                
                // Photo upload status indicator (if photos exist)
                if (hasPhotos) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.photo_camera,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '✓ Photos Uploaded',
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.photosAttachedToItem(item.photoUrls.length),
                                style: TextStyle(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PhotoCapturePage(
                                inspectionId: _currentInspection!.id,
                                itemId: item.id,
                                existingPhotos: item.photoUrls,
                              ),
                            ),
                          );
                          
                          // Always refresh the inspection data when returning from photo capture
                          // The PhotoCapturePage updates the state, so we need to reload it
                          final updatedInspections = ref.read(inspectionsProvider);
                          _currentInspection = updatedInspections.firstWhere(
                            (inspection) => inspection.id == _currentInspection!.id,
                          );
                          
                          // Update categorized items with fresh data
                          _setupCategories();
                          
                          // Force a complete rebuild of the UI
                          setState(() {});
                          
                          // Show immediate feedback if photos were added/updated
                          final updatedItem = _currentInspection!.items.firstWhere(
                            (i) => i.id == item.id,
                          );
                          if (updatedItem.photoUrls.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.photo_camera, color: AppColors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text('${AppLocalizations.of(context)!.photosUpdated} ${AppLocalizations.of(context)!.photoAttached(updatedItem.photoUrls.length)}'),
                                  ],
                                ),
                                backgroundColor: AppColors.primaryBlue,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasPhotos ? AppColors.successGreen : AppColors.infoBlue,
                          foregroundColor: AppColors.white,
                          elevation: hasPhotos ? 6 : 2,
                          shadowColor: hasPhotos ? AppColors.successGreen.withValues(alpha: 0.3) : null,
                        ),
                        icon: Icon(hasPhotos ? Icons.photo_library : Icons.add_a_photo),
                        label: Text(hasPhotos ? 'Photos' : AppLocalizations.of(context)!.addPhoto),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showNotesDialog(item);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasNotes ? AppColors.secondaryOrange : AppColors.warningYellow,
                          foregroundColor: AppColors.white,
                          elevation: hasNotes ? 4 : 2,
                        ),
                        icon: Icon(hasNotes ? Icons.note : Icons.note_add),
                        label: Text(hasNotes ? 'Notes Added' : AppLocalizations.of(context)!.addNotes),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(InspectionItemStatus status) {
    switch (status) {
      case InspectionItemStatus.passed:
        return const CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.successGreen,
          child: Icon(Icons.check, size: 16, color: AppColors.white),
        );
      case InspectionItemStatus.failed:
        return const CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.errorRed,
          child: Icon(Icons.close, size: 16, color: AppColors.white),
        );
      case InspectionItemStatus.notApplicable:
        return const CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.grey400,
          child: Icon(Icons.remove, size: 16, color: AppColors.white),
        );
    }
  }

  String _getStatusText(InspectionItemStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case InspectionItemStatus.passed:
        return l10n.pass;
      case InspectionItemStatus.failed:
        return l10n.fail;
      case InspectionItemStatus.notApplicable:
        return l10n.notApplicable;
    }
  }

  Color _getStatusColor(InspectionItemStatus status) {
    switch (status) {
      case InspectionItemStatus.passed:
        return AppColors.successGreen;
      case InspectionItemStatus.failed:
        return AppColors.errorRed;
      case InspectionItemStatus.notApplicable:
        return AppColors.grey500;
    }
  }

  String _getSeverityText(DefectSeverity severity) {
    final l10n = AppLocalizations.of(context)!;
    switch (severity) {
      case DefectSeverity.minor:
        return l10n.minor;
      case DefectSeverity.major:
        return l10n.major;
      case DefectSeverity.critical:
        return l10n.critical;
      case DefectSeverity.outOfService:
        return l10n.outOfService;
    }
  }

  Color _getSeverityColor(DefectSeverity severity) {
    switch (severity) {
      case DefectSeverity.minor:
        return AppColors.warningYellow;
      case DefectSeverity.major:
        return AppColors.secondaryOrange;
      case DefectSeverity.critical:
        return AppColors.errorRed;
      case DefectSeverity.outOfService:
        return AppColors.criticalRed;
    }
  }

  String _getInspectionTypeText() {
    final l10n = AppLocalizations.of(context)!;
    switch (_currentInspection!.type) {
      case InspectionType.preTrip:
        return l10n.preTrip;
      case InspectionType.postTrip:
        return l10n.postTrip;
      case InspectionType.annual:
        return l10n.annual;
    }
  }

  IconData _getStatusIcon2(InspectionItemStatus status) {
    switch (status) {
      case InspectionItemStatus.passed:
        return Icons.check_circle;
      case InspectionItemStatus.failed:
        return Icons.cancel;
      case InspectionItemStatus.notApplicable:
        return Icons.not_interested;
    }
  }

  void _scrollToExpandedItem() {
    // Small delay to allow expansion animation to complete
    Future.delayed(const Duration(milliseconds: 350), () {
      if (_scrollController.hasClients) {
        // Calculate better scroll position
        final currentOffset = _scrollController.offset;
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        final viewportHeight = _scrollController.position.viewportDimension;
        
        // Scroll down by a reasonable amount, but not past the end
        final targetOffset = (currentOffset + 150).clamp(0.0, maxScrollExtent);
        
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _showNotesDialog(InspectionItem item) {
    final notesController = TextEditingController(text: item.notes ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notes for ${item.name}'),
        content: TextField(
          controller: notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Add notes about this inspection item...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedItem = item.copyWith(notes: notesController.text);
              _updateInspectionItem(updatedItem);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _completeInspection() {
    context.pushSignature(_currentInspection!.id);
  }

  bool _canAdvanceToNext() {
    final currentIndex = _tabController?.index ?? 0;
    final categories = _categorizedItems.keys.toList();
    
    if (currentIndex >= categories.length - 1) {
      return false; // Already on last tab
    }
    
    // Check if current section is 100% complete
    final currentCategory = categories[currentIndex];
    final categoryItems = _categorizedItems[currentCategory] ?? [];
    final completedItems = categoryItems.where((item) => 
        item.checkedAt != null).toList();
    
    return categoryItems.isNotEmpty && completedItems.length == categoryItems.length;
  }

  void _advanceToNextSection() {
    final currentIndex = _tabController?.index ?? 0;
    final categories = _categorizedItems.keys.toList();
    
    if (currentIndex < categories.length - 1) {
      _tabController?.animateTo(currentIndex + 1);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.white),
              const SizedBox(width: 8),
              Text('Section "${categories[currentIndex]}" completed! Moving to next section.'),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getNavigationText() {
    final currentIndex = _tabController?.index ?? 0;
    final categories = _categorizedItems.keys.toList();
    
    if (_currentInspection!.isComplete) {
      return 'Complete';
    }
    
    if (currentIndex >= categories.length - 1) {
      return 'Complete';
    }
    
    return 'Next';
  }

  IconData _getNavigationIcon() {
    final currentIndex = _tabController?.index ?? 0;
    final categories = _categorizedItems.keys.toList();
    
    if (_currentInspection!.isComplete || currentIndex >= categories.length - 1) {
      return Icons.check_circle;
    }
    
    return Icons.arrow_forward;
  }
}