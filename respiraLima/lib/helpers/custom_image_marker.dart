
import 'package:flutter/material.dart';
// import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart' show BitmapDescriptor;


Future<BitmapDescriptor> getAssetImageMarker()async{
  // final imageCodec = ui.instantiateImageCodec(

  // );
  return BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(10, 10)), 
    // 'assets/icons/qAIRita-01.png');
    'assets/icons/custom-pin.png');
}

