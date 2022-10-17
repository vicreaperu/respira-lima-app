import 'package:app4/route_tracking/route_tracking.dart';
import 'dart:math';

class TrackingSegment{
  late double x,y;
  late num l2Norm;
  late TrackingPoint startPoint;
  TrackingSegment(TrackingPoint p1,TrackingPoint p2){
    startPoint = p1;
    x = p2.x-p1.x;
    y = p2.y-p1.y;
    l2Norm = pow(x, 2)+pow(y, 2);
  }

  double minDistanceToPoint(TrackingPoint p){
    //get the closest point to p on segment
    TrackingPoint closestPoint;
    if(l2Norm==0.0) {
      closestPoint = startPoint; //the segment has len 0, start_point == end_point
      }
    else{
      double aX = p.x - startPoint.x;
      double aY = p.y - startPoint.y;
      double k = max(0,min((aX*x+aY*y)/l2Norm,1));
      closestPoint =  TrackingPoint(startPoint.x + k*x,startPoint.y + k*y);
    }
    return p.distance(closestPoint);
  }
}
