import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/map_models.dart';
import '../../data/repositories/map_repository.dart';

// Map controller provider
final mapControllerProvider = StateProvider<MapController?>((ref) => null);

// Current location provider
final currentLocationProvider = StateProvider<LatLng?>((ref) => null);

// Map locations provider
final mapLocationsProvider = FutureProvider<List<TruckLocation>>((ref) async {
  final repository = ref.read(mapRepositoryProvider);
  // Get locations in a default bounds (can be updated based on map viewport)
  return await repository.getLocationsInBounds(
    northLat: 90.0,
    southLat: -90.0,
    eastLng: 180.0,
    westLng: -180.0,
  );
});

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Search results provider
final searchResultsProvider = Provider<List<TruckLocation>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final locationsAsync = ref.watch(mapLocationsProvider);
  
  return locationsAsync.when(
    data: (locations) {
      if (query.isEmpty) return [];
      
      return locations.where((location) {
        final searchLower = query.toLowerCase();
        return location.name.toLowerCase().contains(searchLower) ||
               location.address.toLowerCase().contains(searchLower) ||
               location.description?.toLowerCase().contains(searchLower) == true;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Selected location provider
final selectedLocationProvider = StateProvider<TruckLocation?>((ref) => null);

// Location reviews provider
final locationReviewsProvider = FutureProvider.family<List<LocationReview>, String>((ref, locationId) async {
  final repository = ref.read(mapRepositoryProvider);
  return await repository.getLocationReviews(locationId);
});

// Latest parking status provider
final latestParkingStatusProvider = FutureProvider.family<ParkingStatusUpdate?, String>((ref, locationId) async {
  final repository = ref.read(mapRepositoryProvider);
  return await repository.getLatestParkingStatus(locationId);
});

// User favorites provider
final userFavoritesProvider = FutureProvider<List<FavoriteLocation>>((ref) async {
  final repository = ref.read(mapRepositoryProvider);
  // TODO: Get current user ID from auth provider
  const userId = 'current_user_id'; // Placeholder
  return await repository.getUserFavorites(userId);
});

// Favorite location IDs provider (for quick lookup)
final favoriteLocationIdsProvider = Provider<Set<String>>((ref) {
  final favoritesAsync = ref.watch(userFavoritesProvider);
  
  return favoritesAsync.when(
    data: (favorites) => favorites.map((fav) => fav.locationId).toSet(),
    loading: () => <String>{},
    error: (_, __) => <String>{},
  );
});

// Map markers provider - using flutter_map Marker
final mapMarkersProvider = Provider<List<Marker>>((ref) {
  final locationsAsync = ref.watch(mapLocationsProvider);
  final selectedLocation = ref.watch(selectedLocationProvider);
  
  return locationsAsync.when(
    data: (locations) {
      return locations.map((location) {
        return Marker(
          point: LatLng(location.latitude, location.longitude),
          child: GestureDetector(
            onTap: () {
              ref.read(selectedLocationProvider.notifier).state = location;
            },
            child: Icon(
              Icons.location_on,
              color: _getMarkerColor(location.type),
              size: 30,
            ),
          ),
        );
      }).toList();
    },
    loading: () => <Marker>[],
    error: (_, __) => <Marker>[],
  );
});

Color _getMarkerColor(LocationType type) {
  switch (type) {
    case LocationType.restArea:
      return Colors.blue;
    case LocationType.truckStop:
      return Colors.green;
    case LocationType.gasStation:
      return Colors.red;
    default:
      return Colors.grey;
  }
}

// Map state provider
class MapState {
  final bool isLoading;
  final String? error;
  final bool showSearchResults;
  final LatLng? center;
  final double? zoom;

  const MapState({
    this.isLoading = false,
    this.error,
    this.showSearchResults = false,
    this.center,
    this.zoom,
  });

  MapState copyWith({
    bool? isLoading,
    String? error,
    bool? showSearchResults,
    LatLng? center,
    double? zoom,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      showSearchResults: showSearchResults ?? this.showSearchResults,
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
    );
  }
}

class MapStateNotifier extends StateNotifier<MapState> {
  final MapRepository _repository;

  MapStateNotifier(this._repository) : super(const MapState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void setShowSearchResults(bool show) {
    state = state.copyWith(showSearchResults: show);
  }

  void setMapPosition(LatLng center, double zoom) {
    state = state.copyWith(center: center, zoom: zoom);
  }

  Future<void> updateParkingStatus(String locationId, ParkingStatus status) async {
    try {
      setLoading(true);
      setError(null);
      
      final update = ParkingStatusUpdate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        locationId: locationId,
        userId: 'current_user_id', // TODO: Get from auth
        userName: 'Current User', // TODO: Get from auth
        status: status,
        timestamp: DateTime.now(),
      );
      
      await _repository.updateParkingStatus(update);
    } catch (e) {
      setError('Failed to update parking status: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> addReview(String locationId, int rating, String comment) async {
    try {
      setLoading(true);
      setError(null);
      
      final review = LocationReview(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        locationId: locationId,
        userId: 'current_user_id', // TODO: Get from auth
        userName: 'Current User', // TODO: Get from auth
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _repository.addReview(review);
    } catch (e) {
      setError('Failed to add review: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> toggleFavorite(String locationId, bool isFavorite) async {
    try {
      setLoading(true);
      setError(null);
      
      if (isFavorite) {
        await _repository.removeFromFavorites(locationId, 'current_user_id');
      } else {
        final favorite = FavoriteLocation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'current_user_id', // TODO: Get from auth
          locationId: locationId,
          addedAt: DateTime.now(),
        );
        await _repository.addToFavorites(favorite);
      }
    } catch (e) {
      setError('Failed to update favorite: $e');
    } finally {
      setLoading(false);
    }
  }
}

final mapStateProvider = StateNotifierProvider<MapStateNotifier, MapState>((ref) {
  final repository = ref.read(mapRepositoryProvider);
  return MapStateNotifier(repository);
});