part of 'map_bloc.dart';

class MapState extends Equatable {
  final bool isLoading;
  final bool isMapInitialized;
  final bool isFollowingUser;
  final bool isTheCameraTargetOnAre;
  final CameraPosition cameraPosition;
  final List<TrackingRoute> plannedRoutes;
  final Map<String, Polyline> polylines;
  final Map<String, Marker> markers;
  final String forSearchStreetName;
  final bool updateData;
  // final List<Placemark> forSearchPlaceMark;
  final LatLng forSearchLatLng;

  const MapState({
    this.isTheCameraTargetOnAre = true,
    this.updateData = true,
    this.isLoading = false,
    CameraPosition? cameraPosition,
    this.isMapInitialized = false,
     this.isFollowingUser = false,
     Map<String, Polyline>? polylines,
     Map<String, Marker>? markers,
     this.forSearchStreetName = 'SN',
     plannedRoutes,
    //  List<Placemark>? forSearchPlaceMark,
     LatLng? forSearchLatLng,
     }): polylines = polylines ?? const {}, 
        //  forSearchPlaceMark = forSearchPlaceMark ?? const [],
         forSearchLatLng = forSearchLatLng ?? const LatLng(0, 0),
         markers = markers ?? const {}, 
         plannedRoutes = plannedRoutes ?? const [],
         cameraPosition = cameraPosition ?? const CameraPosition(target: LatLng(0, 0));

  MapState copyWith(
    {
     CameraPosition? cameraPosition,
     bool? isLoading,
     bool? isTheCameraTargetOnAre,
     bool? isMapInitialized,
     bool? isFollowingUser,
     bool? updateData,
     LatLng? forSearchLatLng,
     String? forSearchStreetName,
     List<Placemark>? forSearchPlaceMark,
     List<TrackingRoute>? plannedRoutes,
     Map<String, Polyline>? polylines,
     Map<String, Marker>? markers,
     }) => MapState(
        isTheCameraTargetOnAre: isTheCameraTargetOnAre ?? this.isTheCameraTargetOnAre,
        // forSearchPlaceMark    : forSearchPlaceMark     ?? this.forSearchPlaceMark,
        cameraPosition    : cameraPosition     ?? this.cameraPosition,
        forSearchStreetName   : forSearchStreetName    ?? this.forSearchStreetName,
        isMapInitialized      : isMapInitialized       ?? this.isMapInitialized,
        isFollowingUser       : isFollowingUser        ?? this.isFollowingUser,
        forSearchLatLng       : forSearchLatLng        ?? this.forSearchLatLng,
        updateData            : updateData             ?? this.updateData,
        isLoading             : isLoading              ?? this.isLoading,
        polylines             : polylines              ?? this.polylines,
        markers               : markers                ?? this.markers,
        plannedRoutes         : plannedRoutes          ?? this.plannedRoutes,
      );
  @override
  List<Object> get props => [
    isTheCameraTargetOnAre,
    cameraPosition, 
    isMapInitialized, 
    forSearchLatLng,
    forSearchStreetName,
    // forSearchPlaceMark,
    isFollowingUser,
    updateData,
    polylines, 
    markers,
    isLoading,
    plannedRoutes,
    ];
}
