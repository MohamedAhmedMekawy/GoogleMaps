import 'package:maps_ex/data/model/directional_model.dart';
import 'package:maps_ex/data/model/place_model.dart';
import 'package:maps_ex/data/model/place_suggestion.dart';

abstract class MapsStates{}

class MapsInitialStates extends MapsStates{}

class PlaceLoadedState extends MapsStates{
  final List<PlaceSuggestion> place;

  PlaceLoadedState(this.place);
}

class PlaceLocationLoadedState extends MapsStates{
  final Place place;

  PlaceLocationLoadedState(this.place);
}

class DirectionLoadedState extends MapsStates{
  final PlaceDirections placeDirections;

  DirectionLoadedState(this.placeDirections);
}