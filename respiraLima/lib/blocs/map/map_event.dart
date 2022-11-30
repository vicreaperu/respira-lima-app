part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class OnMapInitializedEvent extends MapEvent {
  final GoogleMapController controller;

  const OnMapInitializedEvent(this.controller);
}

class OnStartLoading extends MapEvent {}
class OnStopLoading extends MapEvent {}


class UpdateForSearchData extends MapEvent {
  final double lat;
  final double lng;
  final String streetName;
  // final List<Placemark>? placeMarks;
  const UpdateForSearchData({
    required this.lat, 
    required this.lng, 
    //  this.placeMarks
    required this.streetName
    });
}

class WillStopFollowingUser extends MapEvent {}

class DataIsUpdatedEvent extends MapEvent{
  final CameraPosition cameraPosition;
  const DataIsUpdatedEvent({required this.cameraPosition});
}
class MustUpdateDataEvent extends MapEvent{}

class WillStartFollowingUser extends MapEvent {}

class UpdateUserPolylineEvent extends MapEvent {
  final List<LatLng> userLocation;
  const UpdateUserPolylineEvent(this.userLocation);

}

class DisplaysPolylineEvents extends MapEvent{
  final Map<String, Polyline> polylines;
  final Map<String, Marker> marker;

  const DisplaysPolylineEvents(this.polylines, this.marker);

}

class DrawPolylinesFromZoneEvent extends MapEvent {
  final List<Map<String,dynamic>> points;
  const DrawPolylinesFromZoneEvent(this.points);
}

class DrawPolylinesFromZoneEventPRO extends MapEvent {
  final Map<String,dynamic> points;
  const DrawPolylinesFromZoneEventPRO(this.points);
}

class DrawMarkersFromZoneEvent extends MapEvent {
  final List<LatLng> marks;
  const DrawMarkersFromZoneEvent(this.marks);
}
class DrawMarkerEvent extends MapEvent {
  final Map<String, Marker> markers;
  const DrawMarkerEvent(this.markers);
}


class IsTheCameraTargetOutAreEvent extends MapEvent{}
class IsTheCameraTargetInsideAreEvent extends MapEvent{}

class RemoveNavigationPolylinesAndMarkers extends MapEvent {}

class AddTrackingRoute extends MapEvent{
  final List<TrackingRoute> plannedRoute;

  const AddTrackingRoute(this.plannedRoute);
}
class RemoveTrackingRoute extends MapEvent{}