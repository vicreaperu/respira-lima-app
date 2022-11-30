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
  final double? heading;
  const OnNewUserLocationAndStreetNameEvent(this.newLocation, this.streetName, this.heading);
}

class OnStartFollowingUser extends LocationEvent {}
class OnStopFollowingUser extends LocationEvent {}

class WillModifyForTesting extends LocationEvent{}
class WillStopModifyingForTesting extends LocationEvent{}

class ClearLocationHistoryEvent extends LocationEvent{}

class OnStartSavingLocationHistory extends LocationEvent{}
class OffSavingLocationHistory extends LocationEvent{}

class OnBackgroundEvent extends LocationEvent{}
class OnBackgroundNoNavigationEvent extends LocationEvent{
  final int? timeWait;

  const OnBackgroundNoNavigationEvent({this.timeWait = 10});
}
class OnForegroundEvent extends LocationEvent{}

class AddMyRoute extends LocationEvent{
  final List<LatLng> points;
  const AddMyRoute(this.points);
}