
import 'package:flutter/material.dart';
// import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart' show BitmapDescriptor;


Future<BitmapDescriptor> getAssetImageMarker()async{
  // final imageCodec = ui.instantiateImageCodec(

  // );
  return BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(5, 5)), 
    // 'assets/icons/qAIRita-01.png');
    // 'assets/icons/custom-pin.png');
    // 'assets/icons/marcador-de-ubicacion.png');
    'assets/icons/focus2.png');
}
Future<BitmapDescriptor> getFinishAssetImageMarker()async{
  // final imageCodec = ui.instantiateImageCodec(

  // );
  return BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(5, 5)), 
    // 'assets/icons/qAIRita-01.png');
    // 'assets/icons/terminar.png');
    'assets/icons/pin3.png');
}

