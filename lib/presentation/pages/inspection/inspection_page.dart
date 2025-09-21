import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/l10n/app_localizations.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/localized_inspection_data.dart';
import '../../../core/navigation/app_router.dart';
import '../../../data/models/inspection_models.dart';
import '../../providers/app_providers.dart';
import 'photo_capture_page.dart';
import '../signature/signature_page.dart';
import '../document_scanner_page.dart';

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
  bool _hasModifications = false; // Track if any items have been modified
  bool _isLoading = true; // Track loading state to prevent error UI flash

  @override
  void initState() {
    super.initState();
    // Delay the provider modification to avoid lifecycle error
    Future(() {
      _loadInspection();
    });
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

  void _loadInspection() async {
    if (widget.inspectionId != null) {
      // Load inspections first and wait for completion
      final inspectionsNotifier = ref.read(enhancedInspectionsProvider.notifier);
      inspectionsNotifier.loadInspections();
      
      // Add a small delay to ensure data is loaded
      await Future.delayed(const Duration(milliseconds: 100));
      
      final inspections = ref.read(enhancedInspectionsProvider);
      print('DEBUG: Available inspections: ${inspections.length}');
      for (var inspection in inspections) {
        print('DEBUG: Available inspection ID: ${inspection.id}');
      }
      
      try {
        _currentInspection = inspections.firstWhere(
          (inspection) => inspection.id == widget.inspectionId,
        );
        print('DEBUG: Loading existing inspection ${_currentInspection!.id} with ${_currentInspection!.items.length} items');
        for (var item in _currentInspection!.items) {
          print('DEBUG: Inspection item: ${item.id} - ${item.name} (${item.documentAttachments.length} docs)');
        }
      } catch (e) {
        print('DEBUG: Inspection ${widget.inspectionId} not found in provider, checking current inspection provider');
        _currentInspection = ref.read(currentInspectionProvider);
        if (_currentInspection?.id != widget.inspectionId) {
          print('ERROR: Could not find inspection ${widget.inspectionId}');
          // Handle the error gracefully - navigate back or show error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inspection not found. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.of(context).pop();
          }
          return;
        }
      }
    } else {
      _currentInspection = ref.read(currentInspectionProvider);
      print('DEBUG: Loading current inspection from provider');
      if (_currentInspection != null) {
        print('DEBUG: Current inspection ${_currentInspection!.id} with ${_currentInspection!.items.length} items');
        for (var item in _currentInspection!.items) {
          print('DEBUG: Current inspection item: ${item.id} - ${item.name} (${item.documentAttachments.length} docs)');
        }
      }
    }
    
    // Trigger UI update after loading
    if (mounted) {
      setState(() {
        _isLoading = false; // Set loading to false after inspection is loaded
      });
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

    await ref.read(enhancedInspectionsProvider.notifier).updateInspectionItem(
      _currentInspection!.id,
      item,
    );

    // Mark that modifications have been made
    setState(() {
      _hasModifications = true;
    });

    // Refresh current inspection
    final updatedInspections = ref.read(enhancedInspectionsProvider);
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
    // Show loading indicator while data is being loaded
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Inspection'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
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
                  onPressed: _handleExitButton,
                  icon: const Icon(Icons.save),
                  label: Text(_getSaveExitButtonText()),
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
    final hasPhotos = item.photoUrls.isNotEmpty || item.documentAttachments.isNotEmpty;
    final hasNotes = item.notes != null && item.notes!.isNotEmpty;
    final hasDocuments = item.documentAttachments.isNotEmpty;
    final isExpanded = _expandedItems.contains(item.id);
    
    // Debug print to check photo and document data
    print('DEBUG: Item ${item.id}:');
    print('  - photoUrls.length: ${item.photoUrls.length}');
    print('  - documentAttachments.length: ${item.documentAttachments.length}');
    print('  - hasPhotos: $hasPhotos');
    print('  - hasDocuments: $hasDocuments');
    if (item.photoUrls.isNotEmpty) {
      print('  - photoUrls: ${item.photoUrls}');
    }
    if (item.documentAttachments.isNotEmpty) {
      for (var doc in item.documentAttachments) {
        print('  - Document: ${doc.fileName} at ${doc.filePath}');
      }
    }
    
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
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
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
                                item.photoUrls.isNotEmpty 
                                  ? AppLocalizations.of(context)!.photoAttached(item.photoUrls.length)
                                  : AppLocalizations.of(context)!.documentAttached(item.documentAttachments.length),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                      if (hasDocuments) ...[
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                           decoration: BoxDecoration(
                             color: AppColors.successGreen,
                             borderRadius: BorderRadius.circular(4),
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               const Icon(Icons.description, size: 10, color: AppColors.white),
                               const SizedBox(width: 2),
                               Text(
                                 AppLocalizations.of(context)!.documentAttached(item.documentAttachments.length),
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
            // Removed the right status indicator as requested - left indicator and border color are sufficient
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? _getStatusColor(status)
                              : AppColors.grey100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected 
                                ? _getStatusColor(status)
                                : AppColors.grey300,
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: _getStatusColor(status).withValues(alpha: 0.6),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: _getStatusColor(status).withValues(alpha: 0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                              spreadRadius: 2,
                            ),
                          ] : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon2(status),
                              size: 18,
                              color: isSelected 
                                  ? AppColors.white
                                  : AppColors.grey600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getStatusText(status),
                              style: TextStyle(
                                color: isSelected 
                                    ? AppColors.white
                                    : AppColors.grey700,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: isSelected ? 14 : 13,
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
                
                // Document upload status indicator (if documents exist)
                if (hasDocuments) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.successGreen.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.description,
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
                                '✓ Documents Attached',
                                style: const TextStyle(
                                  color: AppColors.successGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.documentsAttachedToItem(item.documentAttachments.length),
                                style: TextStyle(
                                  color: AppColors.successGreen.withValues(alpha: 0.8),
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
                    // Show photo button for all items on web, or for non-document items on mobile
                    if (!_shouldShowDocumentScanner(item) || kIsWeb)
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
                            final updatedInspections = ref.read(enhancedInspectionsProvider);
                            _currentInspection = updatedInspections.firstWhere(
                              (inspection) => inspection.id == _currentInspection!.id,
                            );
                            
                            // Also update the currentInspectionProvider to keep them in sync
                            ref.read(currentInspectionProvider.notifier).state = _currentInspection;
                            
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
                                      const Icon(Icons.photo_camera, color: AppColors.white, size: 16),
                                      const SizedBox(width: 6),
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
                          elevation: hasPhotos ? 4 : 1,
                          shadowColor: hasPhotos ? AppColors.successGreen.withValues(alpha: 0.2) : null,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          minimumSize: const Size(0, 36),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        icon: Icon(
                          hasPhotos ? Icons.photo_library : Icons.add_a_photo, 
                          size: 16,
                        ),
                        label: Text(
                          hasPhotos ? 'Photos' : 'Photo',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    // Only show spacing when photo button is visible
                    if (!_shouldShowDocumentScanner(item) || kIsWeb)
                      const SizedBox(width: 6),
                    // Only show document scanner for specific items that require documentation on mobile platforms
                    if (_shouldShowDocumentScanner(item) && !kIsWeb)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DocumentScannerPage(
                                  inspectionId: _currentInspection!.id,
                                  inspectionItemId: item.id,
                                  itemName: item.name,
                                  itemCategory: item.category,
                                ),
                              ),
                            );
                            
                            // Refresh the inspection data when returning from document scanner
                            final updatedInspections = ref.read(enhancedInspectionsProvider);
                            _currentInspection = updatedInspections.firstWhere(
                              (inspection) => inspection.id == _currentInspection!.id,
                            );
                            
                            // Update categorized items with fresh data
                            _setupCategories();
                            
                            // Force a complete rebuild of the UI
                            setState(() {});
                            
                            // Show immediate feedback if documents were added/updated
                          final updatedItem = _currentInspection!.items.firstWhere(
                            (i) => i.id == item.id,
                          );
                          if (updatedItem.documentAttachments.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.description, color: AppColors.white, size: 16),
                                    const SizedBox(width: 6),
                                    Text('Documents updated: ${AppLocalizations.of(context)!.documentAttached(updatedItem.documentAttachments.length)}'),
                                  ],
                                ),
                                backgroundColor: AppColors.successGreen,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasDocuments ? AppColors.successGreen : AppColors.warningYellow,
                            foregroundColor: AppColors.white,
                            elevation: hasDocuments ? 4 : 1,
                            shadowColor: hasDocuments ? AppColors.successGreen.withValues(alpha: 0.2) : null,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            minimumSize: const Size(0, 36),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          icon: Icon(
                            hasDocuments ? Icons.description : Icons.document_scanner, 
                            size: 16,
                          ),
                          label: Text(
                            hasDocuments ? 'Docs' : 'Scan',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    if (_shouldShowDocumentScanner(item) && !kIsWeb)
                      const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showNotesDialog(item);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasNotes ? AppColors.secondaryOrange : AppColors.warningYellow,
                          foregroundColor: AppColors.white,
                          elevation: hasNotes ? 3 : 1,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          minimumSize: const Size(0, 36),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        icon: Icon(
                          hasNotes ? Icons.note : Icons.note_add, 
                          size: 16,
                        ),
                        label: Text(
                          hasNotes ? 'Notes' : 'Note',
                          style: const TextStyle(fontSize: 12),
                        ),
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

  /// Determines if an inspection item should show the document scanner button
  /// Only specific document types require scanning: CDL, DOT Medical Card, and paperwork
  bool _shouldShowDocumentScanner(InspectionItem item) {
    const documentRequiredItems = {
      'cdl_license',
      'dot_medical_card', 
      'paperwork',
    };
    return documentRequiredItems.contains(item.id);
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

  String _getSaveExitButtonText() {
    if (_currentInspection?.isComplete == true) {
      return 'Complete';
    }
    
    if (!_hasModifications) {
      return 'Exit';
    }
    
    return 'Save & Exit';
  }

  void _handleExitButton() async {
    if (_currentInspection?.isComplete == true) {
      // If inspection is complete, navigate normally
      context.go(RouteNames.dashboard);
      return;
    }

    if (!_hasModifications) {
      // Show confirmation dialog for exit without saving
      final shouldExit = await _showExitConfirmationDialog();
      if (shouldExit) {
        // Delete the unsaved inspection
        await ref.read(enhancedInspectionsProvider.notifier).deleteInspection(_currentInspection!.id);
        context.go(RouteNames.dashboard);
      }
    } else {
      // Save and exit
      context.go(RouteNames.dashboard);
    }
  }

  Future<bool> _showExitConfirmationDialog() async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Inspection'),
          content: const Text('This inspection has not been modified. Exiting will remove it from your reports. Are you sure you want to exit?'),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.grey400),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Exit',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ) ?? false;
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