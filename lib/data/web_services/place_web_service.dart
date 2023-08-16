import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_ex/utils/strings/string.dart';

class PlaceWebServices {
  late Dio dio;

  PlaceWebServices() {
    BaseOptions options = BaseOptions(
        connectTimeout: const Duration(seconds: 20 * 1000),
        receiveTimeout: const Duration(seconds: 20 * 1000),
        receiveDataWhenStatusError: true);
    dio = Dio(options);
  }

  Future<List<dynamic>> fetchSuggestion(
    String place,
    String sessionToken,
  ) async {
    try {
      Response response = await dio.get(
          suggestionsBaseUrl,
          queryParameters: {
            'input': place,
            'types': 'address',
            'components': 'country:eg',
            'key': API_KEY,
            'sessiontoken': sessionToken
          });
      print(response.data['predictions']);
      print(response.statusCode);
      return response.data['predictions'];
    } catch (error) {
      print(error.toString());
      return [];
    }
  }

  Future<dynamic> getPlaceLocation(
    String placeId,
    String sessionToken,
  ) async {
    try {
      Response response = await dio.get(
          placeLocationBaseUrl,
          queryParameters: {
            'place_id': placeId,
            'fields': 'geometry',
            'key': API_KEY,
            'sessiontoken': sessionToken
          });
      print(response.data);
      print(response.statusCode);
      return response.data;
    } catch (error) {
      print(error.toString());
      return Future.error(
          "Place Location Error : ",
          StackTrace.fromString(
              ('This is its trace *********************************')));
    }
  }

  Future<dynamic> getDirections(LatLng origin, LatLng destination)async{
    try{
      Response response = await dio.get(
          directionsBaseUrl,
      queryParameters: {
        'origin' : '${origin.latitude}, ${origin.longitude}',
        'destination' : '${destination.latitude}, ${destination.longitude}',
        'key' : API_KEY
      }
      );
      print(response.data);
      print(response.statusCode);
      return response.data;
    } catch (error) {
      print(error.toString());
      return Future.error(
          "Place Location Error : ",
          StackTrace.fromString(
              ('This is its trace *********************************')));
    }
  }
}
