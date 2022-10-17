part of 'location_bloc.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class OnNewUserLocationEvent extends LocationEvent {
  final LatLng newLocation;
  const OnNewUserLocationEvent(this.newLocation);
   
}
class OnNewUserLocationAndStreetNameEvent extends LocationEvent {
  final LatLng newLocation;
  final String streetName;
  const OnNewUserLocationAndStreetNameEvent(this.newLocation, this.streetName);
   
}
class OnStartFollowingUser extends LocationEvent {}
class OnStopFollowingUser extends LocationEvent {}

class WillModifyForTesting extends LocationEvent{}
class WillStopModifyingForTesting extends LocationEvent{}

class ClearLocationHistoryEvent extends LocationEvent{}

class OnStartSavingLocationHistory extends LocationEvent{}
class OffSavingLocationHistory extends LocationEvent{}

class AddMyRoute extends LocationEvent{
  final List<LatLng> points;
  const AddMyRoute(this.points);
}