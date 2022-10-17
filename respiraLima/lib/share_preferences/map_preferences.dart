import 'package:flutter/material.dart';

class MapPreferences{
  static double initialTild = maxTild/2;
  // static double initialZoom = maxZoom - 5;
  static double initialZoom = maxZoom-1;

  static double initialBearing = minTild;

  static double maxTild = 90;
  static double minTild = 0;

  static double maxZoom = 19;
  static double minZoom = 8;

  static double minDrawingZoom = 12;
  static double maxDrawingZoom = 20;


  static int polylineWidthGood = 8;
  static int polylineWidthRegular = 9;
  static int polylineWidthBad = 10;
  static int polylineWidthTooBad = 11;
  
}
