
import 'package:app4/grid/predictions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PointMi {
  late LatLng latLng;
  late String timestamp, streetName;
  late int pointNumber;
  double pm25 = 0;
  PointMi(latLon, int pointNumber, String timestamp, String streetName, double pm25) {
      latLng       = latLon;
      pointNumber = pointNumber;
      timestamp    = timestamp;
      streetName  = streetName;
    //TO-DO: this possibly launchs an exception, that must be fixed
      pm25 =  999 ;//predictions.get_coordinates_prediction(latLng);
  }

  PointMi.withPM25(LatLng latLng, int pointNumber, String timestamp,
      String streetName, double pm25) {
    latLng       = latLng;
    pointNumber = pointNumber;
    timestamp    = timestamp;
    streetName  = streetName;
    //TO-DO: this possibly launchs an exception, that must be fixed
    pm25         = pm25;
  }

  //TODO DB: query que obtenga todos los datos de un punto a partir de su point_number y construya el objeto punto
  // SI EL NUMERO DE PUNTO NO EXISTE SE DEBE RETORNAR UN NULL
  static PointMi? findByNumber(int pointNumber) {
    return null;
    // return Point.withPM25(lat, lon, point_number, timestamp, street_name ,pm25 );
  }

  //TODO DB: OPCIONAL se puede usar este metodo para luego de crear el punto sin errores poder llamarlo para guardarlo en db, y ser
  //recuperado por el metodo anterior
  void save(){
  }
  Map<String, dynamic> toMap() {
    Map<String, dynamic> pointData = {};
    pointData["lat"]          = latLng.latitude;
    pointData["lon"]          = latLng.longitude;
    pointData["point_number"] = pointNumber;
    pointData["street_name"]  = streetName;
    pointData["pm25"]         = pm25;
    return pointData;
  }
}
