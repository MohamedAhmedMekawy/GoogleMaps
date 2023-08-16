import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maps_ex/cubit/cubit.dart';
import 'package:maps_ex/data/repository/map_repository.dart';
import 'package:maps_ex/data/web_services/place_web_service.dart';
import 'package:maps_ex/screens/maps_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
          create: (context) => MapsCubit(MapsRepository(PlaceWebServices())),
          child:const MapScreen()),
    );
  }
}
