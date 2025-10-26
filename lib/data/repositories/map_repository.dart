import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/map_models.dart';

class MapRepository {
  final FirebaseFirestore _firestore;

  MapRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _locationsCollection =>
      _firestore.collection('truck_locations');
  CollectionReference get _reviewsCollection =>
      _firestore.collection('location_reviews');
  CollectionReference get _parkingUpdatesCollection =>
      _firestore.collection('parking_updates');
  CollectionReference get _favoritesCollection =>
      _firestore.collection('favorite_locations');
  CollectionReference get _locationStatsCollection =>
      _firestore.collection('location_stats');

  // Location operations
  Future<List<TruckLocation>> getLocationsInBounds({
    required double northLat,
    required double southLat,
    required double eastLng,
    required double westLng,
  }) async {
    try {
      final query = await _locationsCollection
          .where('latitude', isGreaterThanOrEqualTo: southLat)
          .where('latitude', isLessThanOrEqualTo: northLat)
          .get();

      final locations = query.docs
          .map((doc) => TruckLocation.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .where((location) =>
              location.longitude >= westLng && location.longitude <= eastLng)
          .toList();

      return locations;
    } catch (e) {
      throw Exception('Failed to fetch locations: $e');
    }
  }

  Future<TruckLocation?> getLocationById(String locationId) async {
    try {
      final doc = await _locationsCollection.doc(locationId).get();
      if (!doc.exists) return null;

      return TruckLocation.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      throw Exception('Failed to fetch location: $e');
    }
  }

  Future<List<TruckLocation>> searchLocations(String query) async {
    try {
      final nameQuery = await _locationsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .limit(20)
          .get();

      final addressQuery = await _locationsCollection
          .where('address', isGreaterThanOrEqualTo: query)
          .where('address', isLessThan: query + 'z')
          .limit(20)
          .get();

      final Set<String> seenIds = {};
      final List<TruckLocation> results = [];

      for (final doc in [...nameQuery.docs, ...addressQuery.docs]) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add(TruckLocation.fromJson({
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          }));
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to search locations: $e');
    }
  }

  // Review operations
  Future<List<LocationReview>> getLocationReviews(String locationId) async {
    try {
      final query = await _reviewsCollection
          .where('locationId', isEqualTo: locationId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return query.docs
          .map((doc) => LocationReview.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  Future<void> addReview(LocationReview review) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Add the review
        final reviewRef = _reviewsCollection.doc(review.id);
        transaction.set(reviewRef, review.toJson());

        // Update location stats
        await _updateLocationStats(review.locationId, transaction);
      });
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  // Parking status operations
  Future<ParkingStatusUpdate?> getLatestParkingStatus(String locationId) async {
    try {
      final query = await _parkingUpdatesCollection
          .where('locationId', isEqualTo: locationId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      return ParkingStatusUpdate.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      throw Exception('Failed to fetch parking status: $e');
    }
  }

  Future<void> updateParkingStatus(ParkingStatusUpdate update) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Add the parking update
        final updateRef = _parkingUpdatesCollection.doc(update.id);
        transaction.set(updateRef, update.toJson());

        // Update location stats
        final statsRef = _locationStatsCollection.doc(update.locationId);
        transaction.update(statsRef, {
          'currentParkingStatus': update.status.name,
          'lastParkingUpdate': update.timestamp.toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      throw Exception('Failed to update parking status: $e');
    }
  }

  Stream<ParkingStatusUpdate?> watchParkingStatus(String locationId) {
    return _parkingUpdatesCollection
        .where('locationId', isEqualTo: locationId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return ParkingStatusUpdate.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    });
  }

  // Favorites operations
  Future<List<FavoriteLocation>> getUserFavorites(String userId) async {
    try {
      final query = await _favoritesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('addedAt', descending: true)
          .get();

      return query.docs
          .map((doc) => FavoriteLocation.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch favorites: $e');
    }
  }

  Future<bool> isLocationFavorited(String locationId, String userId) async {
    try {
      final query = await _favoritesCollection
          .where('locationId', isEqualTo: locationId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check favorite status: $e');
    }
  }

  Future<void> addToFavorites(FavoriteLocation favorite) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Add to favorites
        final favoriteRef = _favoritesCollection.doc(favorite.id);
        transaction.set(favoriteRef, favorite.toJson());

        // Update location stats
        final statsRef = _locationStatsCollection.doc(favorite.locationId);
        transaction.update(statsRef, {
          'favoriteCount': FieldValue.increment(1),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(String locationId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Find and remove the favorite
        final query = await _favoritesCollection
            .where('locationId', isEqualTo: locationId)
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final favoriteRef = _favoritesCollection.doc(query.docs.first.id);
          transaction.delete(favoriteRef);

          // Update location stats
          final statsRef = _locationStatsCollection.doc(locationId);
          transaction.update(statsRef, {
            'favoriteCount': FieldValue.increment(-1),
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  // Location stats operations
  Future<LocationStats?> getLocationStats(String locationId) async {
    try {
      final doc = await _locationStatsCollection.doc(locationId).get();
      if (!doc.exists) return null;

      return LocationStats.fromJson({
        'locationId': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      throw Exception('Failed to fetch location stats: $e');
    }
  }

  Stream<LocationStats?> watchLocationStats(String locationId) {
    return _locationStatsCollection.doc(locationId).snapshots().map((doc) {
      if (!doc.exists) return null;

      return LocationStats.fromJson({
        'locationId': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    });
  }

  // Private helper methods
  Future<void> _updateLocationStats(
      String locationId, Transaction transaction) async {
    // Get all reviews for this location
    final reviewsQuery = await _reviewsCollection
        .where('locationId', isEqualTo: locationId)
        .get();

    if (reviewsQuery.docs.isEmpty) return;

    // Calculate average rating
    final reviews = reviewsQuery.docs
        .map((doc) => LocationReview.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }))
        .toList();

    final totalRating = reviews.fold<int>(0, (sum, review) => sum + review.rating);
    final averageRating = totalRating / reviews.length;

    // Update stats
    final statsRef = _locationStatsCollection.doc(locationId);
    transaction.set(
      statsRef,
      {
        'locationId': locationId,
        'averageRating': averageRating,
        'totalReviews': reviews.length,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      SetOptions(merge: true),
    );
  }

  // Batch operations for initial data seeding
  Future<void> addLocationsBatch(List<TruckLocation> locations) async {
    try {
      final batch = _firestore.batch();

      for (final location in locations) {
        final locationRef = _locationsCollection.doc(location.id);
        batch.set(locationRef, location.toJson());

        // Initialize stats
        final statsRef = _locationStatsCollection.doc(location.id);
        batch.set(statsRef, {
          'locationId': location.id,
          'averageRating': 0.0,
          'totalReviews': 0,
          'favoriteCount': 0,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add locations batch: $e');
    }
  }
}

// Provider for MapRepository
final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepository();
});