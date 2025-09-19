import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_router.dart';
import '../../../data/models/inspection_models.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../inspection/inspection_page.dart';

/// Vehicle selection page with QR scanning capability
class VehicleSelectionPage extends ConsumerStatefulWidget {
  const VehicleSelectionPage({super.key});

  @override
  ConsumerState<VehicleSelectionPage> createState() => _VehicleSelectionPageState();
}

class _VehicleSelectionPageState extends ConsumerState<VehicleSelectionPage> {
  final _searchController = TextEditingController();
  bool _showScanner = false;
  MobileScannerController? _scannerController;
  Vehicle? _selectedVehicle;
  InspectionType _selectedInspectionType = InspectionType.preTrip;

  @override
  void initState() {
    super.initState();
    // Load sample vehicles if none exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSampleDataIfNeeded();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _loadSampleDataIfNeeded() async {
    final vehicles = ref.read(vehiclesProvider);
    print('DEBUG: Current vehicles count: ${vehicles.length}');
    
    if (vehicles.isEmpty) {
      print('DEBUG: No vehicles found, adding sample vehicles...');
      await ref.read(vehicleRepositoryProvider).addSampleVehicles();
      print('DEBUG: Sample vehicles added, reloading...');
      ref.read(vehiclesProvider.notifier).loadVehicles();
      
      // Check again after loading
      final updatedVehicles = ref.read(vehiclesProvider);
      print('DEBUG: Vehicles after reload: ${updatedVehicles.length}');
      for (final vehicle in updatedVehicles) {
        print('DEBUG: Vehicle - ${vehicle.unitNumber}: ${vehicle.make} ${vehicle.model}');
      }
      
      // Force UI update
      if (mounted) {
        setState(() {});
      }
    } else {
      print('DEBUG: Found ${vehicles.length} existing vehicles');
      for (final vehicle in vehicles) {
        print('DEBUG: Existing Vehicle - ${vehicle.unitNumber}: ${vehicle.make} ${vehicle.model}');
      }
    }
  }

  void _startScanning() {
    setState(() {
      _showScanner = true;
      _scannerController = MobileScannerController();
    });
  }

  void _stopScanning() {
    _scannerController?.dispose();
    setState(() {
      _showScanner = false;
      _scannerController = null;
    });
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final String? scannedData = capture.barcodes.first.rawValue;
    if (scannedData != null) {
      _stopScanning();
      _handleScannedVehicle(scannedData);
    }
  }

  void _handleScannedVehicle(String scannedData) {
    // Try to find vehicle by unit number or VIN
    final vehicles = ref.read(vehiclesProvider);
    final vehicle = vehicles.firstWhere(
      (v) => v.unitNumber == scannedData || v.vinNumber == scannedData,
      orElse: () => vehicles.first, // Fallback to first vehicle for demo
    );

    setState(() {
      _selectedVehicle = vehicle;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.vehicleSelected(vehicle.unitNumber)),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  Future<void> _startInspection() async {
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseSelectVehicle),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.userNotFound),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    try {
      // Create new inspection
      final inspection = await ref.read(inspectionsProvider.notifier).createInspection(
        context: context,
        driverId: currentUser.id,
        driverName: currentUser.name,
        vehicle: _selectedVehicle!,
        type: _selectedInspectionType,
      );

      // Set as current inspection
      ref.read(currentInspectionProvider.notifier).state = inspection;

      // Navigate to inspection page
      if (mounted) {
        context.goToInspection(inspection.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToStartInspection(e.toString())),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(vehiclesProvider);
    final activeVehicles = vehicles.where((v) => v.isActive).toList();
    
    final filteredVehicles = _searchController.text.isEmpty
        ? activeVehicles
        : activeVehicles.where((vehicle) {
            final query = _searchController.text.toLowerCase();
            return vehicle.unitNumber.toLowerCase().contains(query) ||
                   vehicle.make.toLowerCase().contains(query) ||
                   vehicle.model.toLowerCase().contains(query) ||
                   vehicle.plateNumber.toLowerCase().contains(query);
          }).toList();

    if (_showScanner) {
      return _buildScannerView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selectVehicle),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and scan section
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchVehicles,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                
                const SizedBox(height: 16),
                
                // QR Scan button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _startScanning,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(AppLocalizations.of(context)!.scanQRCode),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Inspection type selector
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.inspectionType,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInspectionTypeChip(
                        InspectionType.preTrip,
                        AppLocalizations.of(context)!.preTrip,
                        Icons.departure_board,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInspectionTypeChip(
                        InspectionType.postTrip,
                        AppLocalizations.of(context)!.postTrip,
                        Icons.assignment_return,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInspectionTypeChip(
                        InspectionType.annual,
                        AppLocalizations.of(context)!.annual,
                        Icons.event_note,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Vehicle list
          Expanded(
            child: filteredVehicles.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                    ),
                    itemCount: filteredVehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = filteredVehicles[index];
                      return _buildVehicleCard(vehicle);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedVehicle != null
          ? Container(
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_shipping,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_selectedVehicle!.make} ${_selectedVehicle!.model}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.unitNumber(_selectedVehicle!.unitNumber),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _startInspection,
                        icon: const Icon(Icons.assignment_add),
                        label: Text(AppLocalizations.of(context)!.startInspection(_getInspectionTypeText())),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildScannerView() {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.scanVehicleQRCode),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _stopScanning,
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onBarcodeDetected,
          ),
          
          // Scanner overlay
          Container(
            decoration: const ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: AppColors.primaryBlue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 8,
                cutOutSize: 250,
              ),
            ),
          ),
          
          // Instructions
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalizations.of(context)!.scanInstructions,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionTypeChip(InspectionType type, String label, IconData icon) {
    final isSelected = _selectedInspectionType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedInspectionType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.grey100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.grey300,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.grey600,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    final isSelected = _selectedVehicle?.id == vehicle.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedVehicle = isSelected ? null : vehicle;
          });
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: isSelected
                ? Border.all(color: AppColors.primaryBlue, width: 2)
                : null,
          ),
          child: Row(
            children: [
              // Vehicle icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primaryBlue 
                      : AppColors.grey200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: isSelected ? AppColors.white : AppColors.grey600,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Vehicle details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          vehicle.unitNumber,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primaryBlue : null,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehicle.make} ${vehicle.model} (${vehicle.year})',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.confirmation_number,
                          size: 16,
                          color: AppColors.grey600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.plateNumber,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                        if (vehicle.mileage != null) ...[
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.speed,
                            size: 16,
                            color: AppColors.grey600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${vehicle.mileage!.toStringAsFixed(0)} mi',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
            Icons.local_shipping_outlined,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noVehiclesFound,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? AppLocalizations.of(context)!.addVehiclesToStart
                : AppLocalizations.of(context)!.tryAdjustingSearch,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.refresh),
          ),
        ],
      ),
    );
  }

  String _getInspectionTypeText() {
    switch (_selectedInspectionType) {
      case InspectionType.preTrip:
        return AppLocalizations.of(context)!.preTrip;
      case InspectionType.postTrip:
        return AppLocalizations.of(context)!.postTrip;
      case InspectionType.annual:
        return AppLocalizations.of(context)!.annual;
    }
  }
}

/// Custom shape for QR scanner overlay
class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path()..addRect(rect);
    Path cutOut = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutSize,
            height: cutOutSize,
          ),
          Radius.circular(borderRadius),
        ),
      );
    return Path.combine(PathOperation.difference, path, cutOut);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final borderOffset = borderWidth / 2;
    final borderLengthSize = borderLength > borderWidthSize
        ? borderWidthSize
        : borderLength;

    Paint borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    Offset topLeftOffset = rect.center - Offset(cutOutSize / 2, cutOutSize / 2);
    Offset topRightOffset = rect.center + Offset(cutOutSize / 2, -cutOutSize / 2);
    Offset bottomLeftOffset = rect.center + Offset(-cutOutSize / 2, cutOutSize / 2);
    Offset bottomRightOffset = rect.center + Offset(cutOutSize / 2, cutOutSize / 2);

    Path topLeftPath = Path()
      ..moveTo(topLeftOffset.dx - borderOffset, topLeftOffset.dy + borderLengthSize)
      ..lineTo(topLeftOffset.dx - borderOffset, topLeftOffset.dy + borderRadius)
      ..quadraticBezierTo(topLeftOffset.dx - borderOffset, topLeftOffset.dy - borderOffset,
          topLeftOffset.dx + borderRadius, topLeftOffset.dy - borderOffset)
      ..lineTo(topLeftOffset.dx + borderLengthSize, topLeftOffset.dy - borderOffset);

    Path topRightPath = Path()
      ..moveTo(topRightOffset.dx - borderLengthSize, topRightOffset.dy - borderOffset)
      ..lineTo(topRightOffset.dx - borderRadius, topRightOffset.dy - borderOffset)
      ..quadraticBezierTo(topRightOffset.dx + borderOffset, topRightOffset.dy - borderOffset,
          topRightOffset.dx + borderOffset, topRightOffset.dy + borderRadius)
      ..lineTo(topRightOffset.dx + borderOffset, topRightOffset.dy + borderLengthSize);

    Path bottomLeftPath = Path()
      ..moveTo(bottomLeftOffset.dx - borderOffset, bottomLeftOffset.dy - borderLengthSize)
      ..lineTo(bottomLeftOffset.dx - borderOffset, bottomLeftOffset.dy - borderRadius)
      ..quadraticBezierTo(bottomLeftOffset.dx - borderOffset, bottomLeftOffset.dy + borderOffset,
          bottomLeftOffset.dx + borderRadius, bottomLeftOffset.dy + borderOffset)
      ..lineTo(bottomLeftOffset.dx + borderLengthSize, bottomLeftOffset.dy + borderOffset);

    Path bottomRightPath = Path()
      ..moveTo(bottomRightOffset.dx + borderOffset, bottomRightOffset.dy - borderLengthSize)
      ..lineTo(bottomRightOffset.dx + borderOffset, bottomRightOffset.dy - borderRadius)
      ..quadraticBezierTo(bottomRightOffset.dx + borderOffset, bottomRightOffset.dy + borderOffset,
          bottomRightOffset.dx - borderRadius, bottomRightOffset.dy + borderOffset)
      ..lineTo(bottomRightOffset.dx - borderLengthSize, bottomRightOffset.dy + borderOffset);

    canvas.drawPath(topLeftPath, borderPaint);
    canvas.drawPath(topRightPath, borderPaint);
    canvas.drawPath(bottomLeftPath, borderPaint);
    canvas.drawPath(bottomRightPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => QrScannerOverlayShape(
        borderColor: borderColor,
        borderWidth: borderWidth,
        overlayColor: overlayColor,
        borderRadius: borderRadius,
        borderLength: borderLength,
        cutOutSize: cutOutSize,
      );
}