import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/models/map_models.dart';
import '../../../data/repositories/map_repository.dart';
import '../../providers/map_providers.dart';
import '../../widgets/map/location_details_bottom_sheet.dart';
import '../../widgets/map/parking_status_widget.dart';
import '../../widgets/map/map_search_bar.dart';
import '../../widgets/map/custom_map_markers.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  MapController? _mapController;
  Position? _currentPosition;
  final List<Marker> _markers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  TruckLocation? _selectedLocation;

  // Default location (center of US) if location permission is denied
  static const LatLng _defaultPosition = LatLng(39.8283, -98.5795);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeMap();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      await _getCurrentLocation();
      await _loadNearbyLocations();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize map: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      // Move map to current location
      if (_mapController != null) {
        _mapController!.move(
          LatLng(position.latitude, position.longitude),
          12.0,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNearbyLocations() async {
    try {
      final mapRepository = ref.read(mapRepositoryProvider);
      
      // Get current map bounds or use default
      LatLng center = _currentPosition != null
          ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
          : _defaultPosition;

      // Create bounds around current location (approximately 50km radius)
      double latOffset = 0.45; // ~50km
      double lngOffset = 0.45; // ~50km

      final locations = await mapRepository.getLocationsInBounds(
        northLat: center.latitude + latOffset,
        southLat: center.latitude - latOffset,
        eastLng: center.longitude + lngOffset,
        westLng: center.longitude - lngOffset,
      );

      setState(() {
        _markers.clear();
        _markers.addAll(
          CustomMapMarkers.createMarkersFromLocations(
            locations,
            (location) {
              setState(() {
                _selectedLocation = location;
              });
            },
          ),
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load nearby locations: $e';
      });
    }
  }

  Future<void> _updateMarkers(List<TruckLocation> locations) async {
    final List<Marker> newMarkers = [];

    // Add current location marker if available
    if (_currentPosition != null) {
      newMarkers.add(
        Marker(
          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 3),
            ),
            child: const Icon(
              Icons.my_location,
              color: AppColors.white,
              size: 20,
            ),
          ),
        ),
      );
    }

    // Add location markers
    for (final location in locations) {
      newMarkers.add(
        Marker(
          point: LatLng(location.latitude, location.longitude),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showLocationDetails(location),
            child: Container(
              decoration: BoxDecoration(
                color: _getMarkerColor(location.type),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: Icon(
                _getMarkerIcon(location.type),
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }

  Color _getMarkerColor(LocationType type) {
    switch (type) {
      case LocationType.restArea:
        return AppColors.primaryBlue;
      case LocationType.truckStop:
        return AppColors.secondaryOrange;
      case LocationType.gasStation:
        return AppColors.successGreen;
    }
  }

  IconData _getMarkerIcon(LocationType type) {
    switch (type) {
      case LocationType.truckStop:
        return Icons.local_shipping;
      case LocationType.restArea:
        return Icons.local_parking;
      case LocationType.gasStation:
        return Icons.local_gas_station;
    }
  }

  void _showLocationDetails(TruckLocation location) {
    setState(() {
      _selectedLocation = location;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationDetailsBottomSheet(
        location: location,
        reviews: [], // TODO: Load actual reviews
        isFavorite: false, // TODO: Check actual favorite status
        onFavoriteToggle: (isFavorite) {
          // TODO: Implement favorite toggle
        },
        onParkingStatusUpdate: (status) {
          // TODO: Implement parking status update
        },
        onAddReview: () {
          // TODO: Implement add review
        },
      ),
    );
  }

  Future<void> _onSearchSubmitted(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final mapRepository = ref.read(mapRepositoryProvider);
      final searchResults = await mapRepository.searchLocations(query.trim());

      if (searchResults.isNotEmpty) {
        final firstResult = searchResults.first;
        
        // Move camera to first result
        _mapController?.move(
          LatLng(firstResult.latitude, firstResult.longitude),
          14.0,
        );

        // Update markers with search results
        await _updateMarkers(searchResults);
        
        // Show details of first result
        _showLocationDetails(firstResult);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No locations found for your search'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _onPositionChanged(MapCamera position, bool hasGesture) {
    if (hasGesture) {
      // Debounce map moves to avoid too many API calls
      Timer(const Duration(milliseconds: 500), () {
        _loadNearbyLocations();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // Flutter Map with OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : _defaultPosition,
              initialZoom: _currentPosition != null ? 12.0 : 4.0,
              onPositionChanged: _onPositionChanged,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.pti.mobile_app',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),

          // Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: MapSearchBar(
              onSearchChanged: (query) {
                // TODO: Implement search functionality
              },
              onSearchResults: (results) {
                // TODO: Handle search results
              },
            ),
          ),

          // My Location Button
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primaryBlue,
              onPressed: _getCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: AppColors.lightBackground.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                ),
              ),
            ),

          // Error Message
          if (_errorMessage != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Parking Status Widget
          if (_selectedLocation != null)
            Positioned(
              bottom: 16,
              left: 16,
              child: ParkingStatusWidget(
                location: _selectedLocation!,
                latestStatus: null, // TODO: Get from provider
                onStatusUpdate: (status) {
                  // TODO: Update parking status
                },
              ),
            ),
        ],
      ),
    );
  }
}