import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class StartNavigationModel{
  final String profile;
  final String mode;
  final String startTime;
  final double lat;
  final double lng;
  final String startStreetName;
  final double destinationLat;
  final double destinationLng;

  StartNavigationModel({
    required this.profile, 
    required this.mode, 
    required this.startTime, 
    required this.lat, 
    required this.lng, 
    required this.startStreetName,
    required this.destinationLat,
    required this.destinationLng,
    });
  static StartNavigationModel fromMap(Map<String, dynamic> map){
    return StartNavigationModel(
      profile        : map['profile'] , 
      mode           : map['mode'] , 
      startTime      : map['startTime'] , 
      lat            : map['latitud'] , 
      lng            : map['longitud'] , 
      startStreetName: map['startStretName'] ,
      destinationLat : map['destinationLat'] ,
      destinationLng : map['destinationLng'] ,
      );
  }
  Map<String,dynamic> toMap(){
    return {
      'profile'       : profile,
      'mode'          : mode,
      'startTime'     : startTime,
      'latitud'       : lat,
      'longitud'      : lng,
      'startStretName': startStreetName,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
    };
  }

}