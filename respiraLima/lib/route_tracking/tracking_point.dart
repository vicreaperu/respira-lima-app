import 'dart:math';

class TrackingPoint{
  final double x,y;
  TrackingPoint(
    this.x,
    this.y,
  );
  double distance(TrackingPoint op){
    return sqrt(pow(op.x- x, 2)+pow(op.y - y, 2));
  }
}