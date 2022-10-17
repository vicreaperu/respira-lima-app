part of 'navigation_bloc.dart';

class NavigationState extends Equatable {
  // {
  //air_quality: Mala, 
  //distance: 0, 
  //exposure: 122.3, 
  //street_name: Calle nn, 
  //timestamp: 2022-08-26 14:56:11.554185
  //}
  final bool alertScreenON;
  final bool locationLiked;
  final bool locationScored;
  final double locationStars;
  final int totalStars;
  final bool navLoading;
  final List<LatLng> startAndFinalDestination;
  final bool pollutionAlert;
  final bool outOffAreaAlert;
  final List<PlaceAlertModel> placeAlerData;
  final bool placesAlert;
  final bool placeAlertShowDetails;
  final bool isOnArea;
  final List<PositionReport> navigationDataToShowTracking;
  final List<HistoryModel> historyData;
  final bool loading;
  final bool isRouteSelected;
  final Map<String,dynamic> navigationDataToShowEnding;
  final String navigationMode; // monitoreo and ruteo
  final String navigationProfile; // walking and cycling
  final bool isNavigating; // true only when the navigation state is 2
  final int navigationState; // 0: not navigating, 
                             //1: navigation mode selected, 
                             //2: on navigation
                             //3: end the navigation, waiting to send the navigation report
  const NavigationState(
    {
      Map<String,dynamic>? navigationDataToShowEnding,
      List<PositionReport>? navigationDataToShowTracking,
      List<PlaceAlertModel>? placeAlerData,
      List<HistoryModel>? historyData,
      List<LatLng>? startAndFinalDestination,
      this.navigationMode = 'monitoreo', 
      this.navigationProfile = 'walking', 
      this.navigationState = 0,
      this.isNavigating = false,
      this.locationStars = 0,
      this.totalStars = 0,
      this.locationScored = false,
      this.locationLiked = false,
      this.pollutionAlert = false,
      this.outOffAreaAlert = false,
      this.placesAlert = false,
      this.isOnArea = true,
      this.navLoading= false,
      this.alertScreenON= false,
      this.loading= false,
      this.isRouteSelected= false,
      this.placeAlertShowDetails= false,

      }):navigationDataToShowEnding = navigationDataToShowEnding ?? const {}, 
        navigationDataToShowTracking = navigationDataToShowTracking ?? const [],
        placeAlerData = placeAlerData ?? const [],
        startAndFinalDestination = startAndFinalDestination ?? const [],
        historyData = historyData ?? const [];
  NavigationState copyWith({
    List<PositionReport>? navigationDataToShowTracking,
    Map<String,dynamic>? navigationDataToShowEnding,
    List<PlaceAlertModel>? placeAlerData,
    List<HistoryModel>? historyData,
    List<LatLng>? startAndFinalDestination,
    String? navigationProfile,
    String? navigationMode,
    bool? placeAlertShowDetails,
    bool? alertScreenON,
    bool? locationScored,
    bool? locationLiked,
    double? locationStars,
    int? totalStars,
    bool? isRouteSelected,
    bool? outOffAreaAlert,
    int? navigationState,
    bool? pollutionAlert,
    bool? loading,
    bool? isNavigating,
    bool? placesAlert,
    bool? navLoading,
    bool? isOnArea,

  }) => NavigationState(
    navigationDataToShowTracking: navigationDataToShowTracking  ?? this.navigationDataToShowTracking,
    navigationDataToShowEnding  : navigationDataToShowEnding    ?? this.navigationDataToShowEnding,
    startAndFinalDestination    : startAndFinalDestination      ?? this.startAndFinalDestination,
    placeAlertShowDetails       : placeAlertShowDetails         ?? this.placeAlertShowDetails,
    navigationProfile           : navigationProfile             ?? this.navigationProfile,
    navigationState             : navigationState               ?? this.navigationState,
    isRouteSelected             : isRouteSelected               ?? this.isRouteSelected,
    locationLiked               : locationLiked                 ?? this.locationLiked,
    outOffAreaAlert             : outOffAreaAlert               ?? this.outOffAreaAlert,
    pollutionAlert              : pollutionAlert                ?? this.pollutionAlert, 
    locationScored              : locationScored                ?? this.locationScored,
    navigationMode              : navigationMode                ?? this.navigationMode,
    alertScreenON               : alertScreenON                 ?? this.alertScreenON, 
    locationStars               : locationStars                 ?? this.locationStars,
    placeAlerData               : placeAlerData                 ?? this.placeAlerData,
    isNavigating                : isNavigating                  ?? this.isNavigating,   
    totalStars                  : totalStars                    ?? this.totalStars,   
    historyData                 : historyData                   ?? this.historyData,
    placesAlert                 : placesAlert                   ?? this.placesAlert, 
    navLoading                  : navLoading                    ?? this.navLoading,   
    isOnArea                    : isOnArea                      ?? this.isOnArea, 
    loading                     : loading                       ?? this.loading, 
  );
  
  @override
  List<Object> get props => [
    placeAlerData,
    navigationDataToShowEnding,
    navigationDataToShowTracking,
    startAndFinalDestination,
    placeAlertShowDetails,
    navigationProfile,
    isRouteSelected,
    navigationState,
    outOffAreaAlert,
    navigationMode, 
    pollutionAlert,
    locationScored,
    locationStars,
    locationLiked,
    alertScreenON,
    isNavigating,
    historyData,
    placesAlert,
    navLoading,
    totalStars,
    isOnArea,
    loading,
  ];
}

