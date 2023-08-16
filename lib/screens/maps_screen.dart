import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_ex/cubit/cubit.dart';
import 'package:maps_ex/cubit/state.dart';
import 'package:maps_ex/data/model/directional_model.dart';
import 'package:maps_ex/data/model/place_model.dart';
import 'package:maps_ex/data/model/place_suggestion.dart';
import 'package:maps_ex/helper/location_helper.dart';
import 'package:maps_ex/utils/widget/distance_time.dart';
import 'package:maps_ex/utils/widget/place_item.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:uuid/uuid.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _mapController = Completer();
  List<PlaceSuggestion> places = [];
  FloatingSearchBarController controller = FloatingSearchBarController();
  static Position? position;
  Set<Marker> makers = Set();
  late PlaceSuggestion placeSuggestion;
  late Place selectedPlace;
  late Marker searchedPlaceMaker;
  late CameraPosition goToSearchedForPlace;
  late Marker currentLocationMarker;

  /// this variable for get Directions

  PlaceDirections? placeDirections;
  var progressIndicator = false;
  late List<LatLng> polylinePoints;
  var isSearchedPlaceMakerChecked = false;
  var isTimeAndDistanceVisible = false;
  late String time;
  late String distance;
  late String startLocation;
  late String endLocation;

  void buildCameraNewPosition() {
    goToSearchedForPlace = CameraPosition(
        bearing: 0.0,
        tilt: 0.0,
        target: LatLng(selectedPlace.result.geometry.location.lat,
            selectedPlace.result.geometry.location.lng),
        zoom: 13);
  }

  static final CameraPosition _cameraPosition = CameraPosition(
      target: LatLng(position!.latitude, position!.longitude),
      bearing: 0.0,
      tilt: 0.0,
      zoom: 17);

  @override
  initState() {
    super.initState();
    getMyCurrentLocation();
  }

  Future<void> getMyCurrentLocation() async {
    position = await LocationHelper.getCurrentLocation().whenComplete(() {
      setState(() {});
    });
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        getPlaceSuggestions(query);
      },
      progress: progressIndicator,
      onFocusChanged: (_) {
        /// hide distance and time now
        setState(() {
          isTimeAndDistanceVisible = false;
        });
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildSuggestionBloc(),
              buildSelectedPlaceLocationBloc(),
              buildDirectionBloc(),
            ],
          ),
        );
      },
    );
  }

  Widget buildDirectionBloc() {
    return BlocListener<MapsCubit, MapsStates>(
      listener: (context, state) {
        if (state is DirectionLoadedState) {
          placeDirections = (state).placeDirections;
          getPolyLinePoints();
        }

      },
      child: Container(),
    );
  }

  void getPolyLinePoints() {
    polylinePoints = placeDirections!.polylinePoints
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();
  }

  Widget buildSelectedPlaceLocationBloc() {
    return BlocListener<MapsCubit, MapsStates>(
      listener: (context, state) {
        if (state is PlaceLocationLoadedState) {
          selectedPlace = state.place;
          goToMySearchedForLocation();
          getDirections();
        }
      },
      child: Container(),
    );
  }

  void getDirections() {
    BlocProvider.of<MapsCubit>(context).emitDirection(
      LatLng(position!.latitude, position!.longitude),
      LatLng(selectedPlace.result.geometry.location.lat,
          selectedPlace.result.geometry.location.lng),
    );
  }

  Future<void> goToMySearchedForLocation() async {
    buildCameraNewPosition();
    final GoogleMapController controller = await _mapController.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(goToSearchedForPlace));
    buildSearchedPlaceMaker();
  }

  void buildSearchedPlaceMaker() {
    searchedPlaceMaker = Marker(
        position: goToSearchedForPlace.target,
        markerId: MarkerId('2'),
        onTap: () {

          buildCurrentLocationMarker();
          setState(() {
            isSearchedPlaceMakerChecked = true;
            isTimeAndDistanceVisible = true;
          });
        },
        infoWindow: InfoWindow(title: '${placeSuggestion.description}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
    addMarkerToMarkersAndUpdateUI(searchedPlaceMaker);
  }

  void buildCurrentLocationMarker() {
    currentLocationMarker = Marker(
        markerId: const MarkerId('1'),
        position: LatLng(position!.latitude, position!.longitude),
        onTap: () {
          addMarkerToMarkersAndUpdateUI(currentLocationMarker);
        },
        infoWindow:  InfoWindow(title: placeDirections!.startAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
    addMarkerToMarkersAndUpdateUI(currentLocationMarker);
  }

  void addMarkerToMarkersAndUpdateUI(Marker marker) {
    setState(() {
      makers.add(marker);
    });
  }

  void getPlaceSuggestions(String query) {
    final sessionToken = Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceSuggestions(query, sessionToken);
  }

  Widget buildSuggestionBloc() {
    return BlocBuilder<MapsCubit, MapsStates>(
      builder: (context, state) {
        if (state is PlaceLoadedState) {
          places = state.place;
          if (places.length != 0) {
            return buildPlacesList();
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }

  Widget buildPlacesList() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () async {
            placeSuggestion = places[index];
            controller.close();
            getSelectedPlaceLocation();
            polylinePoints.clear();
            removeAllMarkersAndUpdateUI();
          },
          child: PlaceItem(
            suggestion: places[index],
          ),
        );
      },
      itemCount: places.length,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
    );
  }

  void removeAllMarkersAndUpdateUI() {
    setState(() {
      makers.clear();
    });
  }

  void getSelectedPlaceLocation() {
    final sessionToken = Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceLocation(placeSuggestion.placeId, sessionToken);
  }

  Widget buildMap() {
    return GoogleMap(
        initialCameraPosition: _cameraPosition,
        mapType: MapType.normal,
        markers: makers,
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
          buildCurrentLocationMarkerPlaceDetails();

        },
        polylines: placeDirections != null
            ? {
                Polyline(
                    polylineId: PolylineId('my_polyline'),
                    color: Colors.blue,
                    width: 2,
                    points: polylinePoints),
              }
            : {});
  }
  void buildCurrentLocationMarkerPlaceDetails() {
    currentLocationMarker = Marker(
      position: LatLng(position!.latitude, position!.longitude),
      markerId: const MarkerId('2'),
      onTap: () {
      },
      infoWindow: const InfoWindow(
        title: 'your current location',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),

    );

    addMarkerToMarkersAndUpdateUI(currentLocationMarker);
  }


  Future<void> _goToMyCurrentLocation() async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          position != null
              ? buildMap()
              : const Center(child: CircularProgressIndicator()),
          buildFloatingSearchBar(),
          isSearchedPlaceMakerChecked
              ? DistanceAndTime(
                  isTimeAndDistanceVisible: isTimeAndDistanceVisible,
                  placeDirections: placeDirections,
                )
              : Container(),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 8, 30),
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: _goToMyCurrentLocation,
          child: const Icon(
            Icons.place,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
