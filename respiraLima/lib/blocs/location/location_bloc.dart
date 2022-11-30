import 'dart:async';

import 'package:app4/dataTest/pred1.dart';
import 'package:app4/helpers/helpers.dart';
import 'package:app4/repositories/repositories.dart';
import 'package:app4/share_preferences/preferences.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:location/location.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  StreamSubscription<Position>? positionStream;
  StreamSubscription<LocationData>? locationStream;
  final Location location;
  final BackgroundLocationRepository backgroundLocationRepository;
  LocationBloc({
    required this.location,
    required this.backgroundLocationRepository

    }
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
    on<OnBackgroundEvent>(
        (event, emit) { 
          // backgroundLocationRepository.startForegroundService();
          emit(state.copyWith(isInBackground: true));
          });
    on<OnBackgroundNoNavigationEvent>(
        (event, emit) { 
          // backgroundLocationRepository.startForegroundService();
          emit(state.copyWith(isInBackground: true, readLocation: false, timeWaiting: event.timeWait));
          });
    on<OnForegroundEvent>(
        (event, emit)  {
          emit(state.copyWith(isInBackground: false, readLocation: true));
          // backgroundLocationRepository.stopForegroundService();
          });

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
          lastKnownLocationHeading   : event.heading ?? state.lastKnownLocationHeading,
        ));
      } else{
        emit(state.copyWith(
          lastKnownLocation          : event.newLocation,
          lastKnownLocationStreetName: event.streetName,
          lastKnownLocationHeading   : event.heading ?? state.lastKnownLocationHeading, 
        ));
      }

    });
  }

 

  Future getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition();
    print('Position: $position');
    // TODO: return an object with LatLng type
  }

  void startFollowingUser() async {
    print('startFollowingUser');
    print('locationxx START');
    if(isAndroid){
      final bool? isAndroidNew = await isAndroidDeviceIgualUpper10();
      if(isAndroidNew != null){
        if(isAndroidNew){
          print('MODE---->>> before android mode');
          if(isAndroid) backgroundLocationRepository.startForegroundService(); // pool
          print('MODE---->>> after android mode');
        } else{
          print('MODE---->>> before like ios mode');
          location.enableBackgroundMode(enable: true);
          await Preferences.setoldAndroid(true);
          print('MODE---->>> after like ios mode');
        }
      } else{
        print('MODE---->>> before null like ios mode');
        location.enableBackgroundMode(enable: true);
        await Preferences.setoldAndroid(true);
        print('MODE---->>> after null like ios mode');
      }
    }
    if(isIOS) location.enableBackgroundMode(enable: true); //BACKGROUNDXXXX add also for // pool
    positionStream = Geolocator.getPositionStream().listen((event) async {
    // locationStream = location.onLocationChanged.listen((event) async {
      // ignore: unnecessary_null_comparison
      final position = event;
        print('locationx ${event.latitude} ${event.longitude}');
      if(position.latitude != null && position.longitude != null)
      {
        if(state.modifyForTesting){
          List<geocoding.Placemark>? placemarks = await getPlaceFromLatLng(position.latitude, position.longitude);
          // print('locationx $placemarks');
          String streetName = 'S/N';
          if(placemarks !=null && placemarks.isNotEmpty){
            streetName = placemarks[0].street ?? 'S/N';
          } 
          add(OnNewUserLocationAndStreetNameEvent( const LatLng(-12.047341, -77.031782), streetName, position.heading)); // MUST DECOMMENT THIS
          // add(const OnNewUserLocationEvent(LatLng(-12.047341, -77.031782)));
          // LatLng(position.latitude, position.longitude))); // MUST DECOMMENT THIS
        }
        else{
          try{
      
            List<geocoding.Placemark>? placemarks = await getPlaceFromLatLng(position.latitude, position.longitude);
            // print('locationx $placemarks');
            String streetName = 'S/N';
            if(placemarks !=null && placemarks.isNotEmpty){
              streetName = placemarks[0].street ?? 'S/N';
            } 
            add(OnNewUserLocationAndStreetNameEvent(LatLng(position.latitude, position.longitude), streetName, position.heading)); // MUST DECOMMENT THIS
            // add(OnNewUserLocationEvent(LatLng(position.latitude, position.longitude))); // MUST DECOMMENT THIS
          } on Exception catch (e){
            print('locationx $e');
            add(OnNewUserLocationAndStreetNameEvent(LatLng(position.latitude, position.longitude), 'S/N', position.heading)); // MUST DECOMMENT THIS
          } 

        }
        // List<Placemark> placemarks = await placemarkFromCoordinates(-12.047341, -77.031782);
        // print('The street name ${placemarks[0].street ?? "NO NAME"}');
      } 
      if(state.isInBackground && !state.readLocation){
        Timer(Duration(seconds: state.timeWaiting), (() {
          if(state.isInBackground && !state.readLocation){
            getOutOfApp();
            print('OFF---> CLOSING APP');
          }
        }));

      }
    });
    add(OnStartFollowingUser());
  }

  void stopFollowingUser() {
    positionStream?.cancel();
    add(OnStopFollowingUser());
  }

  @override
  Future<void> close() {
    // TODO: implement close
    stopFollowingUser();
    
    if(!Preferences.oldAndroid) backgroundLocationRepository.stopForegroundService(); // pool
  
    return super.close();
  }
  List<LatLng> generatePoint(){
    List<LatLng> newPoint = [];
    for(int i = 0; i < datamapXX.length; i++){
    // for(int i = 0; i < datamap.length; i++){
      newPoint.add(LatLng(double.parse(datamapXX[i]['lat_node_1']), double.parse(datamapXX[i]['lon_node_1'])));
      newPoint.add(LatLng(double.parse(datamapXX[i]['lat_node_2']), double.parse(datamapXX[i]['lon_node_2'])));
    }
    return newPoint;
  }

  Future<List<geocoding.Placemark>?> getPlaceFromLatLng(double lat,double lng) async{
    try{
      List<geocoding.Placemark>? placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
      return placemarks;
    } on Exception catch(e){
      return null;
    }
  }
}
