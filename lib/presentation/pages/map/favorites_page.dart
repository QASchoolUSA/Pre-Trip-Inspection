import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/models/map_models.dart';
import '../../widgets/map/favorites_widget.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  List<TruckLocation> _favoriteLocations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    // TODO: Load favorites from provider/repository
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock data for demonstration
    setState(() {
      _favoriteLocations = [
        TruckLocation(
          id: 'fav1',
          name: 'Flying J Travel Center',
          address: '123 Highway 95, Las Vegas, NV',
          latitude: 36.1699,
          longitude: -115.1398,
          type: LocationType.truckStop,
          description: 'Full-service truck stop with amenities',
          amenities: ['Fuel', 'Restaurant', 'Showers', 'Parking'],
          phoneNumber: '(555) 123-4567',
          website: 'https://flyingj.com',
          isOpen24Hours: true,
          operatingHours: '24/7',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        TruckLocation(
          id: 'fav2',
          name: 'TA Travel Center',
          address: '456 Interstate 40, Flagstaff, AZ',
          latitude: 35.1983,
          longitude: -111.6513,
          type: LocationType.truckStop,
          description: 'Large truck stop with full amenities',
          amenities: ['Fuel', 'Food Court', 'Laundry', 'WiFi'],
          phoneNumber: '(555) 987-6543',
          website: 'https://ta-petro.com',
          isOpen24Hours: true,
          operatingHours: '24/7',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Favorites',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        if (_favoriteLocations.isNotEmpty)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear All Favorites'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Export Favorites'),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: FavoritesListWidget(
            favoriteLocations: _favoriteLocations,
            onLocationTap: _navigateToLocation,
            onRemoveFavorite: _removeFavorite,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_favoriteLocations.length} Favorite${_favoriteLocations.length != 1 ? 's' : ''}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _favoriteLocations.isEmpty
                ? 'No favorite locations yet'
                : 'Your saved truck stops and rest areas',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear_all':
        _showClearAllDialog();
        break;
      case 'export':
        _exportFavorites();
        break;
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text(
          'Are you sure you want to remove all favorite locations? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllFavorites();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _clearAllFavorites() {
    setState(() {
      _favoriteLocations.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All favorites cleared'),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Implement undo functionality
            _loadFavorites();
          },
        ),
      ),
    );
  }

  void _exportFavorites() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Export feature coming soon!'),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToLocation(TruckLocation location) {
    // TODO: Navigate to map with selected location
    Navigator.of(context).pop(); // Go back to map
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to ${location.name}'),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeFavorite(TruckLocation location) {
    setState(() {
      _favoriteLocations.removeWhere((loc) => loc.id == location.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${location.name} removed from favorites'),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _favoriteLocations.add(location);
            });
          },
        ),
      ),
    );
  }
}