import 'dart:async';

import 'package:app4/dataTest/pred1.dart';
import 'package:app4/repositories/repositories.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  StreamSubscription<Position>? positionStream;
  // final BackgroundLocationRepository backgroundLocationRepository;
  LocationBloc(
      // required this.backgroundLocationRepository
    ) : super(const LocationState()) {
    on<WillModifyForTesting>(
        (event, emit) {
          add(const OnNewUserLocationEvent(
          LatLng(-12.047341, -77.031782)));

          emit(state.copyWith(modifyForTesting: true));
        } 
      );
    on<AddMyRoute>(
        (event, emit) => emit(state.copyWith(myRoute: event.points)));
    on<WillStopModifyingForTesting>(
        (event, emit) => emit(state.copyWith(followingUser: false)));
    on<OnStartFollowingUser>(
        (event, emit) => emit(state.copyWith(followingUser: true)));
    on<OnStopFollowingUser>(
        (event, emit) => emit(state.copyWith(followingUser: false)));
    on<OnStartSavingLocationHistory>( (event, emit) 
    {
      
      emit(state.copyWith(saveLocationHistory: true));       
    });
    on<OffSavingLocationHistory>( (event, emit)
    {
      
      emit(state.copyWith(saveLocationHistory: false));
    });

    on<OnNewUserLocationEvent>((event, emit) {
      emit(state.copyWith(
        lastKnownLocation: event.newLocation,
        myLocationHistory: [...state.myLocationHistory, event.newLocation],
      ));

      // state.myLocationHistory.isEmpty ? 
      // emit(state.copyWith(
      //   lastKnownLocation: event.newLocation,
      //   myLocationHistory: [...generatePoint(), event.newLocation],
      // ))
      // : 
      // emit(state.copyWith(
      //   lastKnownLocation: event.newLocation,
      //   myLocationHistory: [...state.myLocationHistory, event.newLocation],
      // ));

      // TODO: implement event handler
    });
    
    on<ClearLocationHistoryEvent>((event, emit) {
      emit(state.copyWith(myLocationHistory: [], myRoute: []));
    });
    
    on<OnNewUserLocationAndStreetNameEvent>((event, emit) {
      if(state.saveLocationHistory) {
        emit(state.copyWith(
          lastKnownLocation          : event.newLocation,
          lastKnownLocationStreetName: event.streetName,
          myLocationHistory          : [...state.myLocationHistory, event.newLocation],
        ));
      } else{
        emit(state.copyWith(
          lastKnownLocation          : event.newLocation,
          lastKnownLocationStreetName: event.streetName,
        ));
      }

    });
  }

 

  Future getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition();
    print('Position: $position');
    // TODO: return an object with LatLng type
  }

  void startFollowingUser() {
    print('startFollowingUser');
    print('locationxx START');
    // backgroundLocationRepository.startForegroundService();
    positionStream = Geolocator.getPositionStream().listen((event) async {
      // ignore: unnecessary_null_comparison
      if(event.latitude != null && event.longitude != null)
      {
        print('locationx ${event.latitude} ${event.longitude}');
      final position = event;
        if(state.modifyForTesting){
          List<Placemark>? placemarks = await getPlaceFromLatLng(position.latitude, position.longitude);
            String streetName = 'S/N';
            if(placemarks !=null && placemarks.isNotEmpty){
              streetName = placemarks[0].street ?? 'S/N';
            } 
          add(OnNewUserLocationAndStreetNameEvent( const LatLng(-12.047341, -77.031782), streetName)); // MUST DECOMMENT THIS
          // add(const OnNewUserLocationEvent(LatLng(-12.047341, -77.031782)));
          // LatLng(position.latitude, position.longitude))); // MUST DECOMMENT THIS
        }
        else{
          try{
      
            List<Placemark>? placemarks = await getPlaceFromLatLng(position.latitude, position.longitude);
            String streetName = 'S/N';
            if(placemarks !=null && placemarks.isNotEmpty){
              streetName = placemarks[0].street ?? 'S/N';
            } 
            add(OnNewUserLocationAndStreetNameEvent(LatLng(position.latitude, position.longitude), streetName)); // MUST DECOMMENT THIS
            // add(OnNewUserLocationEvent(LatLng(position.latitude, position.longitude))); // MUST DECOMMENT THIS
          } on Exception catch (e){
            add(OnNewUserLocationAndStreetNameEvent(LatLng(position.latitude, position.longitude), 'S/N')); // MUST DECOMMENT THIS
            print('placemarkFromCoordinates_________$e _______');
          } 

        }
        // List<Placemark> placemarks = await placemarkFromCoordinates(-12.047341, -77.031782);
        // print('The street name ${placemarks[0].street ?? "NO NAME"}');
      }
    });
    add(OnStartFollowingUser());
  }

  void stopFollowingUser() {
    positionStream?.cancel();
    add(OnStopFollowingUser());
    print('stopFollowingUser');
  }

  @override
  Future<void> close() {
    // TODO: implement close
    print('locationx STOP');
    // backgroundLocationRepository.stopForegroundService();
    stopFollowingUser();
    return super.close();
  }
  List<LatLng> generatePoint(){
    List<LatLng> newPoint = [];
    for(int i = 0; i < datamapXX.length; i++){
    // for(int i = 0; i < datamap.length; i++){
      newPoint.add(LatLng(double.parse(datamapXX[i]['lat_node_1']), double.parse(datamapXX[i]['lon_node_1'])));
      newPoint.add(LatLng(double.parse(datamapXX[i]['lat_node_2']), double.parse(datamapXX[i]['lon_node_2'])));
    }
    print('ENDDD..........');
    print(datamapXX.length);
    print('ENDDD.....................');
    return newPoint;
  }

  Future<List<Placemark>?> getPlaceFromLatLng(double lat,double lng) async{
    try{
      List<Placemark>? placemarks = await placemarkFromCoordinates(lat, lng);
      return placemarks;
    } on Exception catch(e){
      print('Place lookUp Error $e');
      return null;
    }
  }
}
