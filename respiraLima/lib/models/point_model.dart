
class PointModel {
  late int id;
  final double lat, lon;
  final String timestamp, streetName;
  final int pointNumber;
  final int i;
  final int j;
  final String gridTimeId;
  final double pm25;

  PointModel({
    required this.lat, 
    required this.lon, 
    required this.timestamp, 
    required this.streetName, 
    required this.pointNumber, 
    this.i = 0,
    this.j = 0,
    this.gridTimeId = '2022-01-01-00-00-00',
    this.pm25 = 0,
    });


  static PointModel fromMap(Map<String,dynamic> map){
    return PointModel(
      lat        : map["lat"]          , 
      lon        : map["lon"]          , 
      pointNumber: map["point_number"] , 
      timestamp  : map["time_stamp"] , 
      streetName : map["street_name"]  , 
      pm25       : map["pm25"]         ,
      i          : map["i"]  ?? 0      ,
      j          : map["j"]  ?? 0     ,
      gridTimeId : map["gridTimeId"] ?? '2022-01-01-01-01-01',
      );
  }


  Map<String, dynamic> toMap() {
    return {
      "lat"          : lat,
      "lon"          : lon,
      "point_number" : pointNumber,
      "time_stamp"   : timestamp,
      "street_name"  : streetName,
      "pm25"         : pm25,
      "i"            : i,
      "j"            : j,
      "gridTimeId"   : gridTimeId,


    };
  }

  Map<String, dynamic> toMapToSend() {
    return {
      "coordinates"   : "${lat}_$lon",
      "point_number"  : pointNumber,
      "timestamp"     : timestamp,
      "pm25"          : pm25,
      // "street_name"  : streetName,

    };
  }
  Map<String, dynamic> toMapToSendNew() {
    return {
      "coordinates"   : "${lat}_$lon",
      "point_number"  : pointNumber,
      "timestamp"     : timestamp,
      "pm25"          : pm25,
      "code"          : "${i}_${j}_$gridTimeId",
      // "street_name"  : streetName,
    };
  }
}
// class PointModel {
//   late double lat, lon;
//   late String timestamp, streetName;
//   late int pointNumber;
//   double pm25 = 0;

//   PointModel(LatLng latLng, int pointNumber, String timestamp,
//       String streetName, NavigationPredictions predictions) {
//     lat          = latLng.latitude;
//     lon          = latLng.latitude;
//     pointNumber = pointNumber;
//     timestamp    = timestamp;
//     streetName  = streetName;
//     //TO-DO: this possibly launchs an exception, that must be fixed
//     pm25 = predictions.get_coordinates_prediction(latLng);
//   }

//   Map<String, dynamic> toMap() {
//     Map<String, dynamic> pointData = {};
//     pointData["lat"]          = lat;
//     pointData["lon"]          = lon;
//     pointData["point_number"] = pointNumber;
//     pointData["street_name"]  = streetName;
//     pointData["pm25"]         = pm25;
//     return pointData;
//   }
// }
