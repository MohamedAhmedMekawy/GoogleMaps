import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_ex/cubit/state.dart';
import 'package:maps_ex/data/repository/map_repository.dart';

class MapsCubit extends Cubit<MapsStates> {
  final MapsRepository mapsRepository;

  MapsCubit(this.mapsRepository) : super(MapsInitialStates());

  void emitPlaceSuggestions(String place, String sessionToken) {
    mapsRepository.fetchSuggestion(place, sessionToken).then((suggestions) {
      emit(PlaceLoadedState(suggestions));
    });
  }

  void emitPlaceLocation(String placeId, String sessionToken) {
    mapsRepository.getPlaceLocation(placeId, sessionToken).then((place) {
      emit(PlaceLocationLoadedState(place));
    });
  }

  void emitDirection(LatLng origin, LatLng destination) {
    mapsRepository.getDirection(origin, destination).then((place) {
      emit(DirectionLoadedState(place));
    });
  }
}
