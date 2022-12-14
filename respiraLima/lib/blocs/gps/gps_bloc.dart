// import 'dart:html';

import 'dart:async';

import 'package:app4/helpers/helpers.dart';
import 'package:app4/share_preferences/share_preferences.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
import 'package:permission_handler/permission_handler.dart' as ph;

part 'gps_event.dart';
part 'gps_state.dart';

class GpsBloc extends Bloc<GpsEvent, GpsState> {
  final location.Location locationPlugin;
  StreamSubscription? gpsServiceSubscription;
  GpsBloc({
    required this.locationPlugin
    })
      : super(const GpsState(
            isGPSEnabled: false, isGpsPermissionGranted: false)) {
    on<GpsAndPermissionEvent>((event, emit) {
      emit(state.copyWith(
          isGPSEnabled: event.isGpsEnabled,
          isGpsPermissionGranted: event.isGpsPermissionGranted));
    });
    _init();
  }
  Future<void> _init() async {
    // final isEnabled = await _checkGpsStatus();
    // final isGranted = await _isPermissionGranted();
    final gpsInitStatus =
        await Future.wait([_checkGpsStatus(), _isPermissionGranted()]);
    print('is Enable: ${gpsInitStatus[0]}, is Granted: ${gpsInitStatus[1]} DB GPS');

    add(GpsAndPermissionEvent(
        isGpsEnabled: gpsInitStatus[0], isGpsPermissionGranted: gpsInitStatus[1]));
    if(isAndroid){
      await getAndroidDeviceReleaseType().then((release) {
        final double? releaseVal = double.tryParse(release);
        print('MODE----> DEVICE FINAL RESP. $release');
        if(releaseVal !=null){
          print('MODE----> DEVICE is $releaseVal < 10 ?? ${releaseVal < 10}');

        } else{
          print('MODE----> DEVICE FINAL RESP. $releaseVal');

        }
        
      });
    }
  }

  Future<bool> _isPermissionGranted() async {
    final isGranted = await ph.Permission.location.isGranted;
    return isGranted;
  }

  Future<bool> _checkGpsStatus() async {
    final isEnable = await Geolocator.isLocationServiceEnabled();
    gpsServiceSubscription =
        Geolocator.getServiceStatusStream().listen((event) {
      final isEnabled = (event.index == 1) ? true : false;
      print('service status $isEnabled');
      // print('service status ${event.index}');
      add(GpsAndPermissionEvent(
          isGpsEnabled: isEnabled,
          isGpsPermissionGranted: state.isGpsPermissionGranted));
    });
    return isEnable;
  }

  Future<void> askGpsAccess() async {
    final status = await ph.Permission.location.request();

    switch (status) {
      case ph.PermissionStatus.granted:

      if(isAndroid){
        final bool? isAndroidNew = await isAndroidDeviceIgualUpper10();
        if(isAndroidNew != null){
          if(!isAndroidNew){
            print('MODE---->>> before like ios mode');
          locationPlugin.enableBackgroundMode(enable: true);
          await Preferences.setoldAndroid(true);
          print('MODE---->>> after like ios mode');
          } 
        } else{
          print('MODE---->>> before null like ios mode');
          locationPlugin.enableBackgroundMode(enable: true);
          await Preferences.setoldAndroid(true);
          print('MODE---->>> after null like ios mode');
        }
      }
        if(isIOS) locationPlugin.enableBackgroundMode(enable: true); //BACKGROUNDXXXX add also for // pool
        add(GpsAndPermissionEvent(
            isGpsEnabled: state.isGPSEnabled, isGpsPermissionGranted: true));
        break;
      case ph.PermissionStatus.denied:
      case ph.PermissionStatus.restricted:
      case ph.PermissionStatus.limited:
      case ph.PermissionStatus.permanentlyDenied:
        add(GpsAndPermissionEvent(
            isGpsEnabled: state.isGPSEnabled, isGpsPermissionGranted: false));
        ph.openAppSettings();
    }
  }

  @override
  Future<void> close() {
    // always recomended to implement when having a listener
    // TODO: service status stream
    gpsServiceSubscription?.cancel();
    return super.close();
  }
}
