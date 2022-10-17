import 'package:app4/route_tracking/route_tracking.dart';


class TrackingRoute{
  late List<TrackingPoint> pointList;
  late int lenPoints;
  TrackingRoute(List<TrackingPoint> pointList){
    this.pointList = pointList;
    this.lenPoints = pointList.length;
  }
  Map<String,dynamic> getMinDistances(TrackingPoint p){
    double gMinDistance = double.maxFinite;
    int iGMinDistance = -1;
    //se pueden tener los segmentos en memoria
    for(int i=0;i<lenPoints-1;i++){
      TrackingPoint currentPoint = pointList[i], nextPoint = pointList[i+1]; 
      TrackingSegment currentSegment = TrackingSegment(currentPoint, nextPoint);
      double minDistance = currentSegment.minDistanceToPoint(p);
      print("segment $i -> min_distance_to_point: $minDistance");
      if(minDistance<gMinDistance) {
        gMinDistance = minDistance;
        iGMinDistance = i;
      }
    }
    print("global_min_distance_to_point: $gMinDistance");

    return {
      "global_min_distance": gMinDistance,
      "segment": [iGMinDistance,iGMinDistance+1]
    };
  }
}

