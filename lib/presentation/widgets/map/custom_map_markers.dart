import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/models/map_models.dart';
import '../../../core/themes/app_theme.dart';

class CustomMapMarkers {
  static Widget createMarkerWidget(LocationType type) {
    IconData iconData;
    Color color;
    
    switch (type) {
      case LocationType.restArea:
        iconData = Icons.local_parking;
        color = AppColors.primaryBlue;
        break;
      case LocationType.truckStop:
        iconData = Icons.local_shipping;
        color = AppColors.secondaryOrange;
        break;
      case LocationType.gasStation:
        iconData = Icons.local_gas_station;
        color = AppColors.successGreen;
        break;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  static List<Marker> createMarkersFromLocations(
    List<TruckLocation> locations,
    Function(TruckLocation) onMarkerTap,
  ) {
    return locations.map((location) {
      return Marker(
        point: LatLng(location.latitude, location.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => onMarkerTap(location),
          child: createMarkerWidget(location.type),
        ),
      );
    }).toList();
  }
}