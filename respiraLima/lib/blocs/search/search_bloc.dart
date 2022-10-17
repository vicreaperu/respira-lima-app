import 'package:app4/models/models.dart';
import 'package:app4/services/services.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {

  
  TraficService traficService;
  NavigationService navigationService;
  SearchBloc({
    required this.navigationService,
    required this.traficService
  }) : super(const SearchState()) {

    on<OnActivateManualMarkerEvent>((event, emit) {emit(state.copyWith(displayManualMarker: true));});
    on<OnDeactivateManualMarkerEvent>((event, emit) {emit(state.copyWith(displayManualMarker: false));});

    on<OnNewPlacesFoundEvent>((event, emit) {emit(state.copyWith(places: event.places));});
    
  }

  Future<RouteDestination> getCoorsStartToEnd(LatLng start, LatLng end, String profileWalkBike) async{
    final trafficResponse = await traficService.getCoorsStartToEnd(start, end, profileWalkBike);
    final distance = trafficResponse.routes[0].distance;
    final duration = trafficResponse.routes[0].duration;
    final geometry   = trafficResponse.routes[0].geometry;
    
    // DECODE
    final points = decodePolyline(geometry, accuracyExponent: 5);
    final latLngList = points.map((coors) => LatLng(coors[0].toDouble(), coors[1].toDouble())).toList();
    return RouteDestination(
      points: latLngList, 
      duration: duration, 
      distance: distance
      );
  }

  

  Future getPlacesByQuery(LatLng proximity, String query) async{
    final places = await traficService.getResultsByQuery(proximity, query);
    add(OnNewPlacesFoundEvent(places));
    // TODO: HERE MUST SAVE THE RESULT
  }
}

