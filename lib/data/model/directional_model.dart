import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceDirections {
  late LatLngBounds bounds;
  late List<PointLatLng> polylinePoints;
  late String totalDistance;
  late String totalDuration;
  late String startAddress;
  late String endAddress;

  PlaceDirections({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
    required this.startAddress,
    required this.endAddress,
  });

  factory PlaceDirections.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['routes'][0]);
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']),
    );
    late String distance;
    late String duration;
    late String startAddress;
    late String endAddress;

    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
      startAddress = leg['start_address'];
      endAddress = leg['end_address'];
    }
    return PlaceDirections(
        bounds: bounds,
        polylinePoints:
            PolylinePoints().decodePolyline(data['overview_polyline']['points']),
        totalDistance: distance,
        totalDuration: duration,
        startAddress: startAddress,
        endAddress: endAddress);
  }
}
