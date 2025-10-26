import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/models/map_models.dart';

class MapSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(List<TruckLocation>) onSearchResults;
  final VoidCallback? onClearSearch;
  final String? hintText;

  const MapSearchBar({
    super.key,
    required this.onSearchChanged,
    required this.onSearchResults,
    this.onClearSearch,
    this.hintText,
  });

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    widget.onSearchChanged(query);
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _isSearching = false;
    });
    widget.onClearSearch?.call();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search locations, cities, or zip codes...',
          hintStyle: TextStyle(
            color: AppColors.grey500,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.grey600,
            size: 24,
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.grey600,
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.grey900,
        ),
      ),
    );
  }
}

class MapSearchResults extends StatelessWidget {
  final List<TruckLocation> results;
  final Function(TruckLocation) onLocationSelected;
  final bool isVisible;

  const MapSearchResults({
    super.key,
    required this.results,
    required this.onLocationSelected,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || results.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 16,
                  color: AppColors.grey600,
                ),
                const SizedBox(width: 8),
                Text(
                  '${results.length} results found',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length > 5 ? 5 : results.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppColors.grey200,
            ),
            itemBuilder: (context, index) {
              final location = results[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: _getLocationTypeColor(location.type),
                  child: Icon(
                    _getLocationTypeIcon(location.type),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  location.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey900,
                  ),
                ),
                subtitle: Text(
                  location.address,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.grey400,
                ),
                onTap: () => onLocationSelected(location),
              );
            },
          ),
          if (results.length > 5)
            Container(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Showing first 5 results. Zoom in for more specific results.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey600,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Color _getLocationTypeColor(LocationType type) {
    switch (type) {
      case LocationType.restArea:
        return AppColors.primaryBlue;
      case LocationType.truckStop:
        return AppColors.secondaryOrange;
      case LocationType.gasStation:
        return AppColors.successGreen;
    }
  }

  IconData _getLocationTypeIcon(LocationType type) {
    switch (type) {
      case LocationType.restArea:
        return Icons.local_parking;
      case LocationType.truckStop:
        return Icons.local_shipping;
      case LocationType.gasStation:
        return Icons.local_gas_station;
    }
  }
}