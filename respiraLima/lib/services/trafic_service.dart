import 'package:app4/global/enviroment.dart';
import 'package:app4/models/models.dart';
import 'package:app4/services/services.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class TraficService{
  final Dio _dioTrafic;
  final Dio _dioPlaces;

  

  TraficService()
  : _dioTrafic = Dio()..interceptors.add(TrafficInterceptor()), // TODO: Configure interceptors
    _dioPlaces = Dio()..interceptors.add(PlacesInterceptor()); // TODO: Configure interceptors

  Future<TrafficResponse> getCoorsStartToEnd(LatLng start, LatLng end, String profileWalkBike) async {
    final coorsString = '${ start.longitude },${ start.latitude };${ end.longitude },${end.latitude}';

    final url = '${Environment.baseTraficUrl}/$profileWalkBike/$coorsString';
    // '?alternatives=true&continue_straight=true&geometries=polyline&language=es&overview=simplified&steps=true&access_token=pk.eyJ1Ijoiam9zdWUtcG9uY2UtY2FybyIsImEiOiJjbDZjeTJ0MDUyYnc1M2JuM3B6NHYxYWg1In0.9x43xtb_xD8S-Ej-63QG_g';
    // final resp = await _dioTrafic.get('https://api.mapbox.com/directions/v5/mapbox/walking/-77.05363175888318,-12.073646931941227;-77.0482578807182,-12.074525816444819?alternatives=true&continue_straight=true&geometries=polyline&language=es&overview=simplified&steps=true&access_token=pk.eyJ1Ijoiam9zdWUtcG9uY2UtY2FybyIsImEiOiJjbDZjeTJ0MDUyYnc1M2JuM3B6NHYxYWg1In0.9x43xtb_xD8S-Ej-63QG_g');
    final resp = await _dioTrafic.get(url);

    final data = TrafficResponse.fromMap(resp.data);
    // print(data.routes[0].distance);
    // print(data.waypoints[0].name);
    return data;
  }

  Future<List<Feature>> getResultsByQuery(LatLng proximity, String query) async{
    if(query.isEmpty) return[];
    final url = '${Environment.basePlacesUrl}/$query.json';
    final resp = await _dioPlaces.get(url, queryParameters: {
      'proximity' : '${proximity.longitude},${proximity.latitude}'
    });
    print(resp);
    print(resp.data);
    print('TYPE IS ${resp.data.runtimeType}');
    final placesResponse = Places.fromMap(resp.data );
    print('places are ${placesResponse.features}');
    return placesResponse.features; // Lugares => Features
  }
}