import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_ex/data/model/directional_model.dart';
import 'package:maps_ex/data/model/place_model.dart';
import 'package:maps_ex/data/model/place_suggestion.dart';
import 'package:maps_ex/data/web_services/place_web_service.dart';

class MapsRepository{
  final PlaceWebServices placeWebServices;

  MapsRepository(this.placeWebServices);

  Future<List<PlaceSuggestion>> fetchSuggestion(String place, String sessionToken) async{
    final suggestion = await placeWebServices.fetchSuggestion(place, sessionToken);
    return suggestion.map((e) => PlaceSuggestion.fromJson(e)).toList();
  }

  Future<Place> getPlaceLocation(String placeId, String sessionToken) async{
    final place = await placeWebServices.getPlaceLocation(placeId, sessionToken);
    return Place.fromJson(place);
  }

  Future<PlaceDirections> getDirection(LatLng origin, LatLng destinations) async{
    final direction = await placeWebServices.getDirections(origin, destinations);
    return PlaceDirections.fromJson(direction);
  }
}