
class PointModel {
  late int id;
  final double lat, lon;
  final String timestamp, streetName;
  final int pointNumber;
  final double pm25;

  PointModel({
    required this.lat, 
    required this.lon, 
    required this.timestamp, 
    required this.streetName, 
    required this.pointNumber, 
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
