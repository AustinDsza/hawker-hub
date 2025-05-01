import 'dart:math' show cos, sqrt, sin, pi, asin;
import 'package:latlong2/latlong.dart';

class Location {
  final double latitude;
  final double longitude;

  // Support both named and positional parameters
  const Location(this.latitude, this.longitude);

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      json['latitude'] as double,
      json['longitude'] as double,
    );
  }
  
  // Convert to LatLng for use with flutter_map
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
  
  // Create from LatLng
  factory Location.fromLatLng(LatLng latLng) {
    return Location(latLng.latitude, latLng.longitude);
  }

  @override
  String toString() {
    return 'Location($latitude, $longitude)';
  }
  
  /// Calculate the distance between two locations using the Haversine formula
  double distanceTo(Location other) {
    const double earthRadius = 6371.0; // Earth's radius in kilometers
    
    double lat1 = latitude * pi / 180.0;
    double lon1 = longitude * pi / 180.0;
    double lat2 = other.latitude * pi / 180.0;
    double lon2 = other.longitude * pi / 180.0;
    
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
               cos(lat1) * cos(lat2) * 
               sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }
} 