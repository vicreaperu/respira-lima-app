part of 'navigation_bloc.dart';

class NavigationEvent extends Equatable {

  const NavigationEvent(
  );

  @override
  List<Object> get props => [];
}


class MonitoreoNavigationModeEvent extends NavigationEvent {}
class RuteoNavigationModeEvent extends NavigationEvent {}

class OnNavLoadingEvent extends NavigationEvent {}
class OffNavLoadingEvent extends NavigationEvent {}


class SelectNavigationModeEvent extends NavigationEvent {}
class DeactivateNavigationModeEvent extends NavigationEvent {}


class WalkingNavigationProfileEvent extends NavigationEvent {}
class CyclingNavigationProfileEvent extends NavigationEvent {}

class StartNavigationEvent extends NavigationEvent {}
class LiteStartNavigationEvent extends NavigationEvent {}
class StopNavigationEvent extends NavigationEvent {

}
class EndNavigationEvent extends NavigationEvent {
  final double rating;
  const EndNavigationEvent(this.rating);
}
class NoRatingEvent extends NavigationEvent {}


class TrackingEvent extends NavigationEvent {
  final PositionReport reportMap;
  const TrackingEvent(this.reportMap);
}
class EndingEvent extends NavigationEvent {
  final Map<String,dynamic> mapEndingData;
  const EndingEvent(this.mapEndingData);
}
class ClearAllDataToshow extends NavigationEvent {}

class OutOfAreaEvent extends NavigationEvent {}
class IsOnAreaEvent extends NavigationEvent {}


class OnPollutionAlertEvent extends NavigationEvent {}
class OffPollutionAlertEvent extends NavigationEvent {}

class OnPlaceAlertShowDetailsEvent extends NavigationEvent {}
class OffPlaceAlertShowDetailsEvent extends NavigationEvent {}


class OnOutOfAreaAlertEvent extends NavigationEvent {}
class OffOutOfAreaAlertEvent extends NavigationEvent {}


class LikedEvent extends NavigationEvent {}
class UnLikedEvent extends NavigationEvent {}
class SetStartsEvent extends NavigationEvent {
  final double score;
  const SetStartsEvent(this.score);
}
class PlaceVotesEvent extends NavigationEvent {
  final double score;
  final int votes;
  final bool liked;
  const PlaceVotesEvent(this.score, this.votes, this.liked);
}


class OnLoadingEvent extends NavigationEvent {}
class OffLoadingEvent extends NavigationEvent {}


class OnAlertScreenOnEvent extends NavigationEvent {}
class OffAlertScreenOnEvent extends NavigationEvent {}


class AddHistoryData extends NavigationEvent {
  final List<Map<String,dynamic>> historyData;
  const AddHistoryData(this.historyData);
}


class OnPlacesAlertEvent extends NavigationEvent {
  final List<Map<String,dynamic>> pollutionAletData;
  const OnPlacesAlertEvent(this.pollutionAletData);
}
class OffPlacesAlertEvent extends NavigationEvent {}



class ReturnToNavigationTrackingMonitoreo extends NavigationEvent{
  final String mode;
  final String profile;
  final PositionReport? initialReport;
  final PositionReport? lastKnowReport;

  const ReturnToNavigationTrackingMonitoreo(this.mode, this.profile, this.initialReport, this.lastKnowReport);
}
class ReturnToNavigationTrackingRuteo extends NavigationEvent{
  final String mode;
  final String profile;
  final PositionReport? initialReport;
  final PositionReport? lastKnowReport;
  final LatLng finalDestination;
  final LatLng startDestination;

  const ReturnToNavigationTrackingRuteo(
  {  
    required this.mode, 
    required this.profile, 
    this.initialReport, 
    this.lastKnowReport, 
    required this.finalDestination,
    required this.startDestination,
  }
    );
}


class OnSelectingRoute extends NavigationEvent{
  final LatLng destination;

  const OnSelectingRoute(this.destination);
}
class OffSelectingRoute extends NavigationEvent{}

