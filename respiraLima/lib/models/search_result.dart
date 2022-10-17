
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchResult {
  final bool cancel;
  final bool manual;
  final LatLng? coordinates;
  final String? streetName;

  SearchResult({
    required this.cancel, 
    this.manual = false,
    this.coordinates,
    this.streetName,
    });
  // TODO: name, description, latlon
  @override
  String toString() {
    // TODO: implement toString
    return '{cancel: $cancel, manual $manual, coordinates:$coordinates}';
  }
}