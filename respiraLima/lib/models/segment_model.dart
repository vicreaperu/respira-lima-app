import 'package:app4/helpers/helpers.dart';

class SegmentModel {
  final Map<String,dynamic> startPoint, endPoint;

  SegmentModel({
    required this.startPoint, 
    required this.endPoint
    });

   double distance_km() {
    return get_coordinates_distance(
      startPoint['latitude'], 
      startPoint['longitude'], 
      endPoint ['latitude'], 
      endPoint ['longitude']
      // startPoint['latLng']['latitude'], 
      // startPoint['latLng']['longitude'], 
      // endPoint['latLng']['latitude'], 
      // endPoint['latLng']['longitude']
    );
  }
   double distance_m() {
    return get_coordinates_distance_meters(
      startPoint['latitude'], 
      startPoint['longitude'], 
      endPoint ['latitude'], 
      endPoint ['longitude']
      // startPoint['latLng']['latitude'], 
      // startPoint['latLng']['longitude'], 
      // endPoint['latLng']['latitude'], 
      // endPoint['latLng']['longitude']
    );
  }

  double pm25() {
    return double.parse(((startPoint['pm25'] + endPoint['pm25']) / 2).toStringAsFixed(2));
  }
}
