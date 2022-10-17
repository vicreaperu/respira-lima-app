import 'package:app4/helpers/helpers.dart';
import 'package:app4/route_tracking/route_tracking.dart';


class Segment {
  late PointMi startPoint, endPoint;

  Segment(PointMi startPoint, PointMi endPoint) {
    startPoint = startPoint;
    endPoint = endPoint;
  }

  double distance() {
    return get_coordinates_distance(
      startPoint.latLng.latitude, 
      startPoint.latLng.longitude, 
      endPoint.latLng.latitude, 
      endPoint.latLng.longitude
    );
  }

  double pm25() {
    return (startPoint.pm25 + endPoint.pm25) / 2;
  }
}
