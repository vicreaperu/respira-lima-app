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
  final double dataPercent;
  final bool navLoading;
  final bool speakRoute;
  final List<LatLng> startAndFinalDestination;
  final bool pollutionAlert;
  final bool outOffAreaAlert;
  final List<PlaceAlertModel> placeAlerData;
  final bool placesAlert;
  final bool placeAlertShowDetails;
  final bool isOnArea;
  final List<PositionReport> navigationDataToShowTracking;
  final List<HistoryModel> historyData;
  final List<FavoritePlacesModel> favoritePlacesData;
  final List<InstructionsModel> navigationInstruction;
  final bool loading;
  final bool changed;
  final bool isRouteSelected;
  final bool isFavoriteRouteSelected;
  final Map<String,dynamic> navigationDataToShowEnding;
  final String navigationAirQualityPref; // time and pollutant
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
      List<FavoritePlacesModel>? favoritePlacesData,
      List<LatLng>? startAndFinalDestination,
      List<InstructionsModel>? navigationInstruction,
      this.navigationMode = 'monitoreo', 
      this.navigationProfile = 'walking', 
      this.navigationAirQualityPref = 'pollutant',
      this.navigationState = 0,
      this.isNavigating = false,
      this.locationStars = 0,
      this.totalStars = 0,
      this.dataPercent = 1,  // Percent value between 0.0 and 1.0
      this.locationScored = false,
      this.locationLiked = false,
      this.pollutionAlert = false,
      this.outOffAreaAlert = false,
      this.placesAlert = false,
      this.isOnArea = true,
      this.navLoading= false,
      this.speakRoute = true,
      this.alertScreenON= false,
      this.loading= false,
      this.changed= false,
      this.isRouteSelected= false,
      this.placeAlertShowDetails= false,
      this.isFavoriteRouteSelected= false,

      }):navigationDataToShowEnding = navigationDataToShowEnding ?? const {}, 
        navigationDataToShowTracking = navigationDataToShowTracking ?? const [],
        placeAlerData = placeAlerData ?? const [],
        startAndFinalDestination = startAndFinalDestination ?? const [],
        navigationInstruction = navigationInstruction ?? const [],
        historyData = historyData ?? const [],
        favoritePlacesData = favoritePlacesData ?? const [];
  NavigationState copyWith({
    List<PositionReport>? navigationDataToShowTracking,
    Map<String,dynamic>? navigationDataToShowEnding,
    List<PlaceAlertModel>? placeAlerData,
    List<HistoryModel>? historyData,
    List<FavoritePlacesModel>? favoritePlacesData,
    List<LatLng>? startAndFinalDestination,
    List<InstructionsModel>? navigationInstruction,
    String? navigationAirQualityPref,
    String? navigationProfile,
    String? navigationMode,
    bool? isFavoriteRouteSelected,
    bool? placeAlertShowDetails,
    bool? alertScreenON,
    bool? speakRoute,
    bool? locationScored,
    bool? locationLiked,
    double? locationStars,
    double? dataPercent,
    int? totalStars,
    bool? isRouteSelected,
    bool? outOffAreaAlert,
    int? navigationState,
    bool? pollutionAlert,
    bool? loading,
    bool? changed,
    bool? isNavigating,
    bool? placesAlert,
    bool? navLoading,
    bool? isOnArea,

  }) => NavigationState(
    navigationDataToShowTracking: navigationDataToShowTracking  ?? this.navigationDataToShowTracking,
    navigationDataToShowEnding  : navigationDataToShowEnding    ?? this.navigationDataToShowEnding,
    startAndFinalDestination    : startAndFinalDestination      ?? this.startAndFinalDestination,
    isFavoriteRouteSelected     : isFavoriteRouteSelected       ?? this.isFavoriteRouteSelected,
    navigationAirQualityPref       : navigationAirQualityPref         ?? this.navigationAirQualityPref,
    placeAlertShowDetails       : placeAlertShowDetails         ?? this.placeAlertShowDetails,
    navigationInstruction       : navigationInstruction         ?? this.navigationInstruction,
    favoritePlacesData          : favoritePlacesData            ?? this.favoritePlacesData,
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
    dataPercent                 : dataPercent                   ?? this.dataPercent,   
    historyData                 : historyData                   ?? this.historyData,
    placesAlert                 : placesAlert                   ?? this.placesAlert, 
    totalStars                  : totalStars                    ?? this.totalStars,   
    speakRoute                  : speakRoute                    ?? this.speakRoute,   
    navLoading                  : navLoading                    ?? this.navLoading,   
    isOnArea                    : isOnArea                      ?? this.isOnArea, 
    loading                     : loading                       ?? this.loading, 
    changed                     : changed                       ?? this.changed, 
  );
  
  @override
  List<Object> get props => [
    placeAlerData,
    navigationDataToShowEnding,
    navigationDataToShowTracking,
    startAndFinalDestination,
    isFavoriteRouteSelected,
    navigationInstruction,
    placeAlertShowDetails,
    navigationAirQualityPref,
    favoritePlacesData,
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
    dataPercent,
    speakRoute,
    navLoading,
    totalStars,
    isOnArea,
    loading,
    changed,
  ];
}

