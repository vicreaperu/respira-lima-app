import 'dart:async';
import 'dart:convert';
import 'package:app4/dataTest/pred1.dart';
import 'package:app4/db/db.dart';
import 'package:app4/helpers/helpers.dart';
import 'package:app4/models/models.dart';
import 'package:app4/route_tracking/route_tracking.dart';
import 'package:app4/services/map_service.dart';
import 'package:app4/share_preferences/share_preferences.dart';
import 'package:flutter/material.dart';
import 'package:app4/blocs/blocs.dart';
import 'package:app4/themes/themes.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {

  final LocationBloc locationBloc;
  final MapService mapService;
  final NavigationBloc navigationBloc;
  // final SocketService socketService;
  GoogleMapController? _mapController;
  CameraPosition? cameraPosition = const CameraPosition(target: LatLng(0,0));

  LatLng? lastPositionToCompare = const LatLng(0, 0);
  bool updateData = true;
  bool isCameraTargerOnArea = true;
  late double maxLatitude ;
  late double maxLongitude;
  late double minLatitude ;
  late double minLongitude;



  MapBloc( {
    required this.mapService,        
    required this.locationBloc, 
    required this.navigationBloc, 
    // required this.socketService
    }) : super(const MapState()) {
  //   socketService.socket.on('new_map_paint', (data) {
  //   print('socket new map $data');
    
  //   // notifyListeners();
  // } );
    on<OnMapInitializedEvent>(_onInitMap);

    on<UpdateForSearchData>((event, emit) {
      
      emit(state.copyWith(forSearchLatLng: LatLng(event.lat, event.lng), forSearchStreetName: event.streetName));
      // emit(state.copyWith(forSearchLatLng: LatLng(event.lat, event.lng), forSearchPlaceMark: event.placeMarks));
      
    },);
    
    
    
    on<AddTrackingRoute>((event, emit) => emit(state.copyWith(plannedRoutes: event.plannedRoute)),);
    on<RemoveTrackingRoute>((event, emit) => emit(state.copyWith(plannedRoutes: [])),);


    on<IsTheCameraTargetInsideAreEvent>((event, emit) => emit(state.copyWith(isTheCameraTargetOnAre: true)),);
    on<IsTheCameraTargetOutAreEvent>((event, emit) => emit(state.copyWith(isTheCameraTargetOnAre: false)),);
    on<OnStartLoading>((event, emit)  {
      emit(state.copyWith(isLoading: true));
      navigationBloc.add(OnNavLoadingEvent());
    },);

    on<OnStopLoading>((event, emit) {
      emit(state.copyWith(isLoading: false));
      navigationBloc.add(OffNavLoadingEvent());
    },);
    on<RemoveNavigationPolylinesAndMarkers>((event, emit) {
      print('Removing....!');
      final Map<String, Polyline>newPolylines = Map.from(state.polylines);
      final Map<String, Marker> newMarkers = Map.from(state.markers);
      print('Removing polylines keys: ${newPolylines.keys}');
      print('Removing markers keys: ${newMarkers.keys}');
      if(newPolylines['.route'] != null){
        newPolylines.remove('.route');
      }
      if(newPolylines['.myRoute'] != null){
        newPolylines.remove('.myRoute');
      }
      if(newMarkers['startMark'] != null){
        newMarkers.remove('startMark');
      }
      if(newMarkers['endMark'] != null){
        newMarkers.remove('endMark');
      }
      print('Removing polylines keys: ${newPolylines.keys}');
      print('Removing markers keys: ${newMarkers.keys}');
      locationBloc.add(ClearLocationHistoryEvent());
      emit(state.copyWith(polylines: newPolylines, markers: {}, plannedRoutes: []));

    },);

    on<WillStopFollowingUser>((event, emit) => emit(state.copyWith(isFollowingUser: false)),);
    on<WillStartFollowingUser>(_onStartFollowing,);
    // on<UpdateUserPolylineEvent>(_onPolilyneNewPointPRO);
    on<UpdateUserPolylineEvent>(_onPolilyneNewPoint);

    on<DrawPolylinesFromZoneEvent>(_onDrawingPolylinesFromZone);
    on<DrawPolylinesFromZoneEventPRO>(_onDrawingPolylinesFromZonePRO);

    on<DrawMarkersFromZoneEvent>(_onDrawingMarkersFromZone);
    on<DisplaysPolylineEvents>((event, emit) => emit(state.copyWith(polylines: event.polylines, markers: event.marker)),);

    locationBloc.stream.listen((locationState) async{
     
      if (locationState.lastKnownLocation == null) return;
      if (locationState.lastKnownLocation != null) {     
        add(UpdateUserPolylineEvent(locationState.myLocationHistory));
        if(isOnAreaFastQuestionWithPoint(locationState.lastKnownLocation!) != 1){
          navigationBloc.add(OnOutOfAreaAlertEvent());
        } else {
          navigationBloc.add(OffOutOfAreaAlertEvent());
        }
      }
      if(navigationBloc.state.isNavigating && state.plannedRoutes.isNotEmpty){
        final TrackingPoint actualPoint = TrackingPoint(locationBloc.state.lastKnownLocation!.latitude, locationBloc.state.lastKnownLocation!.longitude);
        final Map<String, dynamic> minDistanc = state.plannedRoutes.first.getMinDistances(actualPoint);
        print('Min distance is $minDistanc');
        if(minDistanc['global_min_distance']*10000>2){
          print('Min distance OUT OF ROUTE');
          add(RemoveTrackingRoute());
          final finalDestin = locationBloc.state.myRoute.last;
          navigationBloc.add(OnSelectingRoute(finalDestin));  
          await navigationBloc.setRouteWithPrediction();
          print('Min distance  WAITING');
        }
      }
      if(locationState.myRoute.isNotEmpty) {
        List<LatLng> route = locationState.myRoute;
        final destination = RouteDestination(
          points: route, 
          duration: 10, 
          distance: 14
        );
        drawRoutePolyline(destination);
        if(state.plannedRoutes.isEmpty){
          List<TrackingPoint> plannedRoutePoints = [];
          for (var point in route) {plannedRoutePoints.add(TrackingPoint(point.latitude,point.longitude));}
          List<TrackingRoute> plannedRoute = [TrackingRoute(plannedRoutePoints)];
          add(AddTrackingRoute(plannedRoute));
        } 
      }
      
      if (!state.isFollowingUser) return;
      moveCamera(locationState.lastKnownLocation!);
    });

    _init();
  }

   void _init() async {
    await PrincipalDB.getMinMaxLatLng().then((map) async{
      final limits = LimitModel.fromMap(map);
      maxLatitude  = limits.maxLat;
      maxLongitude = limits.maxLng;
      minLatitude  = limits.minLat;
      minLongitude = limits.minLng;
      if(map['updateForActualLimit'] != null){
        add(OnStartLoading());
        await getGridLimits();
        add(OnStopLoading());
      } 


    });
   }

  Future updateForSearchData() async{
    // final double lat = locationBloc.state.lastKnownLocation?.latitude ?? 0;
    // final double lng = locationBloc.state.lastKnownLocation?.longitude ?? 0;
    final lat = cameraPosition?.target.latitude ?? 0;
    final lng = cameraPosition?.target.longitude ?? 0;
    if(lat != 0 && lng != 0) {
        print('For updating name $lat, $lng');
        String streetName = 'SN';
        List<Placemark>? placemarks = await locationBloc.getPlaceFromLatLng(lat,lng);
        if(placemarks !=null && placemarks.isNotEmpty){
          streetName = placemarks[0].street ?? "S/N";
          print('For updating name ${placemarks[0].street ?? 'S./N.'}');
        } 
        add(UpdateForSearchData(lat: lat, lng: lng, streetName: streetName));
      }
  }
  Future updateForSearchData2({required LatLng coordinates, required String streetName}) async{
    
    add(UpdateForSearchData(lat: coordinates.latitude, lng: coordinates.longitude, streetName: streetName));
      
  }


  void drawRoutePolyline( RouteDestination destination) async {
    final customMakers = await getAssetImageMarker();
    final startMarker = Marker(
      markerId: const MarkerId('startMark'),
      position: destination.points.first,
      icon: customMakers,
      infoWindow: const  InfoWindow(
        title: 'Inicio',
        snippet: 'Este es el punto de incio de mi ruta'
      ),
      );
    final endMarker = Marker(
      markerId: const MarkerId('endMark'),
      position: destination.points.last,
      icon: customMakers,
      infoWindow: const InfoWindow(
      title: 'Fin',
        snippet: 'Este es el punto de final de mi ruta'
      ),
      );
    final myRoute = Polyline(
      polylineId: const PolylineId('.route'),
      color: Color.fromARGB(137, 0, 0, 0),
      width: 11,
      points: destination.points,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap
    );
    final currentPolylines = Map<String, Polyline>.from(state.polylines);
    currentPolylines['.route'] = myRoute;
    final currentMarkers = Map<String, Marker>.from(state.markers);
    currentMarkers['startMark'] = startMarker;
    currentMarkers['endMark'] = endMarker;



    add(DisplaysPolylineEvents(currentPolylines, currentMarkers));

    await Future.delayed(const Duration(milliseconds: 100));
    // _mapController?.showMarkerInfoWindow(const MarkerId('startMark'));
  }

  void drawAllAlertMarkers( RouteDestination destination) async {
    final customMakers = await getAssetImageMarker();
    final startMarker = Marker(
      markerId: const MarkerId('startMark'),
      position: destination.points.first,
      icon: customMakers,
      infoWindow: const  InfoWindow(
        title: 'Inicio',
        snippet: 'Este es el punto de incio de mi ruta'
      ),
      );
    final endMarker = Marker(
      markerId: const MarkerId('endMark'),
      position: destination.points.last,
      icon: customMakers,
      infoWindow: const InfoWindow(
      title: 'Fin',
        snippet: 'Este es el punto de final de mi ruta'
      ),
      );
    final myRoute = Polyline(
      polylineId: const PolylineId('.route'),
      color: Color.fromARGB(137, 0, 0, 0),
      width: 11,
      points: destination.points,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap
    );
    final currentPolylines = Map<String, Polyline>.from(state.polylines);
    currentPolylines['.route'] = myRoute;
    final currentMarkers = Map<String, Marker>.from(state.markers);
    currentMarkers['startMark'] = startMarker;
    currentMarkers['endMark'] = endMarker;



    add(DisplaysPolylineEvents(currentPolylines, currentMarkers));

    await Future.delayed(const Duration(milliseconds: 100));
    // _mapController?.showMarkerInfoWindow(const MarkerId('startMark'));
  }


  void _onStartFollowing(WillStartFollowingUser event, Emitter<MapState> emit){
    emit(state.copyWith(isFollowingUser: true));
    if (locationBloc.state.lastKnownLocation == null) return;
    moveCamera(locationBloc.state.lastKnownLocation!);
  }


  void _onInitMap(OnMapInitializedEvent event, Emitter<MapState> emit) {
    _mapController = event.controller;
    // _mapController!.setMapStyle(jsonEncode(MapThemes.retroMap));
    _mapController!.setMapStyle(jsonEncode(MapThemes.simpleMap));
    emit(state.copyWith(isMapInitialized: true));
  }

  void _onPolilyneNewPoint( UpdateUserPolylineEvent event, Emitter<MapState> emit) {
    // final color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    final myRoute = Polyline(
      polylineId:  const PolylineId('.myRoute'),
      color: Color.fromARGB(160, 33, 149, 243),
      // color: AppTheme.gray80,
      // color: Colors.red,
      width: 10,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      points: event.userLocation,
      geodesic: true,
    );

    final currentPolylines = Map<String, Polyline>.from(state.polylines);
    currentPolylines['.myRoute'] = myRoute;
    emit(state.copyWith(polylines: currentPolylines));
  }



  void _onDrawingMarkersFromZone(DrawMarkersFromZoneEvent event, Emitter<MapState> emit) {
    final allMarks = Map<String, Marker>.from(state.markers);
    for(int i = 0; i < event.marks.length; i++){
      final myMark = Marker(
        markerId: MarkerId('$i'),
        position: event.marks[i],
        );
      allMarks['$i'] = myMark;
    }
    emit(state.copyWith(markers: allMarks));
  }

  Future<LatLngBounds?> getBound() async{
    try{
      LatLngBounds coordinates = await _mapController!.getVisibleRegion();
      return coordinates;
    } on Exception catch(e) {
      return null;
    }
  }
  

  void _onDrawingPolylinesFromZonePRO(DrawPolylinesFromZoneEventPRO event, Emitter<MapState> emit) {

    // if(state.lastCameraPosition.zoom != event.cameraPosition.zoom) {
    //   changeTild(event.cameraPosition);
    //   emit(state.copyWith(lastCameraPosition: event.cameraPosition));
    // }
    try{
      if(true){ // SET CONDITION TO DRAW POLYLINES

      final Map<String, Polyline>currentPolylines = {};
      
      // final actualPolylines = Map<String, Polyline>.from(state.polylines);

      if(navigationBloc.state.isNavigating && state.polylines['.route'] != null){
        currentPolylines['.route'] = state.polylines['.route']!;
      }
      if(navigationBloc.state.isNavigating && state.polylines['.myRoute'] != null){
        currentPolylines['.myRoute'] = state.polylines['.myRoute']!;
      }
      // currentPolylines['.myRoute'] = actualPolylines?.route ?? null;
      List<LatLng> newPoint = [];
      Color theColor;
      int widthLine = 0;
  

      int cantI = event.points['num_polylines'];
      int cantJ = 0;
      final cantPolilynes = cantI > 200 ? 199 : cantI/1-1;

      for(int i = 0; i < cantPolilynes; i++){
        cantJ = event.points["polylines"][i]['num_coords'];
        for(int j = 0; j < cantJ; j++){

          newPoint.add(LatLng(
            event.points["polylines"][i]["coords_lat"][j],
            event.points["polylines"][i]["coords_lon"][j]
             ));
        }
        theColor = Color(int.parse(event.points["polylines"][i]["color"])).withOpacity(0.4);
        widthLine = event.points["polylines"][i]["thickness"];
        final theRoute = Polyline(
              polylineId:  PolylineId(event.points["polylines"][i]['id']),
              // color: Color.fromARGB(108, 255, 235, 59),
              color: theColor,
              // color: Colors.red,
              width: widthLine,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              points: newPoint,
              geodesic: true,
            );
            currentPolylines[event.points["polylines"][i]["id"]] = theRoute;
            newPoint = [];
      }
      

      // currentPolylines['.myRoute'] = myRoute;
      emit(state.copyWith(polylines: currentPolylines));
      // TODO: VERIFY THIS...
      if(lastPositionToCompare?.latitude == cameraPosition?.target.latitude){
        updateData = false;
      } else{
        lastPositionToCompare = cameraPosition?.target ?? const LatLng(0, 0);
      }

      }
    } on Exception catch (e){
        print('The error is 2222:________________');
        print(e);
    }
    
    
  }

  void _onDrawingPolylinesFromZone(DrawPolylinesFromZoneEvent event, Emitter<MapState> emit) {

    // if(state.lastCameraPosition.zoom != event.cameraPosition.zoom) {
    //   changeTild(event.cameraPosition);
    //   emit(state.copyWith(lastCameraPosition: event.cameraPosition));
    // }
    if(true){ // SET CONDITION TO DRAW POLYLINES

      final Map<String, Polyline>currentPolylines = {};
      List<LatLng> newPointX = [];
      double p10Compare = 0;
      int widthLine = 0;
      final cantPolilynes = event.points.length > 200 ? 199 : event.points.length/1-1;
      for(int i = 0; i < cantPolilynes; i++){
        
        double lon1 = event.points[i]['lon_node_1'];
        double lat1 = event.points[i]['lat_node_1'];
        double lat2 = event.points[i]['lat_node_2'];
        double lon2 = event.points[i]['lon_node_2'];
    
          newPointX.add(LatLng(lat1, lon1 ));

          p10Compare = event.points[i]['PM10_predicted'] - event.points[i+1]['PM10_predicted'];
          p10Compare > 0 ? p10Compare : - p10Compare;
          if(
            event.points[i]["name"] != event.points[i+1]["name"] ||
            event.points[i]["lat_node_2"] != event.points[i+1]["lat_node_1"] ||
            event.points[i]["lon_node_2"] != event.points[i+1]["lon_node_1"] ||
            p10Compare > 1               
          ){ //x


            newPointX.add(LatLng(lat2, lon2 ));
            final Color theColor;
            if(event.points[i]['PM10_predicted'] < InkaValues.pm10Buena){
              theColor = InkaValues.inkaColorBuena;
              widthLine = MapPreferences.polylineWidthGood;
            } else if(event.points[i]['PM10_predicted'] < InkaValues.pm10Regular){
              theColor = InkaValues.inkaColorRegular;
              widthLine = MapPreferences.polylineWidthRegular;
            } else if(event.points[i]['PM10_predicted'] < InkaValues.pm10Mala){
              theColor = InkaValues.inkaColorMala;
              widthLine = MapPreferences.polylineWidthBad;
            } else{
              theColor = InkaValues.inkaColorMuyMala;
              widthLine = MapPreferences.polylineWidthTooBad;
            } 
            final theRoute = Polyline(
              polylineId:  PolylineId(event.points[i]['id']),
              color: theColor,
              // color: Colors.red,
              width: widthLine,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              points: newPointX,
              geodesic: true,
            );
            currentPolylines[event.points[i]['id']] = theRoute;
            newPointX = [];
          } //x
        
        
      }


      // currentPolylines['.myRoute'] = myRoute;
      emit(state.copyWith(polylines: currentPolylines));
    }
    
  }


  void updateCameraPosition(){
    

    print('---------NEW TILD-----ww----');
    
    double newBearing = cameraPosition?.bearing ?? MapPreferences.initialBearing;
    // if(newBearing > 0 && )
    

    CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(CameraPosition(
      target : cameraPosition?.target ?? locationBloc.state.lastKnownLocation!,
      tilt   : cameraPosition?.tilt ?? MapPreferences.initialTild,
      zoom   : cameraPosition?.zoom ?? MapPreferences.initialZoom,
      bearing: newBearing + 1,    
      ));
    _mapController!.animateCamera(cameraUpdate);
    cameraUpdate = CameraUpdate.newCameraPosition(CameraPosition(
      target : cameraPosition?.target ?? locationBloc.state.lastKnownLocation!,
      tilt   : cameraPosition?.tilt ?? MapPreferences.initialTild,
      zoom   : cameraPosition?.zoom ?? MapPreferences.initialZoom,
      bearing: newBearing - 1,    
      ));
      print('The bearing is ${cameraPosition?.tilt ?? MapPreferences.initialTild}');
    _mapController!.animateCamera(cameraUpdate);
  }
  
  void changeTild(CameraPosition cameraPosition){
    
    double newTild; 
    double maxZoom = MapPreferences.maxZoom - (MapPreferences.maxZoom - MapPreferences.minZoom)/4;
    double minZoom = MapPreferences.minZoom - (MapPreferences.maxZoom - MapPreferences.minZoom)/4;
    if(cameraPosition.zoom < maxZoom && cameraPosition.zoom > minZoom){
      newTild = 90 * (cameraPosition.zoom - minZoom)/(maxZoom - minZoom);
    } else if(cameraPosition.zoom < minZoom){
      newTild = 0;
    } else {
      newTild = 90;
    }

    print('---------NEW TILD---------$newTild');

    final cameraUpdate = CameraUpdate.newCameraPosition(CameraPosition(
      target : cameraPosition.target,
      tilt   : newTild,
      zoom   : cameraPosition.zoom,
      bearing: cameraPosition.bearing    
      ));
    _mapController!.animateCamera(cameraUpdate);
  }


  void _onPolilyneNewPointPRO( UpdateUserPolylineEvent event, Emitter<MapState> emit) {
    
    
    final currentPolylines = Map<String, Polyline>.from(state.polylines);
    if(currentPolylines.isEmpty){
      // for(int i = 0; i < 5000; i++){
      for(int i = 0; i < datamapXX.length/10; i++){
      // for(int i = 0; i < datamap.length; i++){
      
        List<LatLng> newPointX = [];
        newPointX.add(LatLng(double.parse(datamapXX[i]['lat_node_1']), double.parse(datamapXX[i]['lon_node_1'])));
        newPointX.add(LatLng(double.parse(datamapXX[i]['lat_node_2']), double.parse(datamapXX[i]['lon_node_2'])));
        final theColor;
        if(datamapXX[i]['PM10_predicted'] < InkaValues.pm10Buena){
          theColor = InkaValues.inkaColorBuena;
        } else if(datamapXX[i]['PM10_predicted'] < InkaValues.pm10Regular){
          theColor = InkaValues.inkaColorRegular;
        } else if(datamapXX[i]['PM10_predicted'] < InkaValues.pm10Mala){
          theColor = InkaValues.inkaColorMala;
        } else{
          theColor = InkaValues.inkaColorMuyMala;
        } 
        
        final theRoute = Polyline(
          polylineId:  PolylineId(datamapXX[i]['id']),
          color: theColor,
          // color: Colors.red,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          points: newPointX,
          geodesic: true,
        );

        currentPolylines[datamapXX[i]['id']] = theRoute;
      }

      // currentPolylines['.myRoute'] = myRoute;
      emit(state.copyWith(polylines: currentPolylines));
    }
  }

  void moveCamera(LatLng newLocation) {
    final cameraUpdate = CameraUpdate.newCameraPosition(CameraPosition(
      target: newLocation, 
      zoom: MapPreferences.initialZoom,
      bearing: MapPreferences.initialBearing,
      tilt: MapPreferences.initialTild,
      ));
    // final cameraUpdate = CameraUpdate.newLatLng(newLocation);
    _mapController!.animateCamera(cameraUpdate);
  }


  Future<bool> getGridLimits() async {
    final String token = await PrincipalDB.getFirebaseToken();
    final resp = await mapService.getGridLimits(
      idToken: token,
      // idToken: Preferences.firebaseToken,
    );

    print('Grid limit final anwaer ----- $resp');
    if (resp['error'] == null){
      PrincipalDB.minMaxLatLng(resp);
      maxLatitude  = resp['max_latitude']!;
      maxLongitude = resp['max_longitude']!;
      minLatitude  = resp['min_latitude']!;
      minLongitude = resp['min_longitude']!;

      return true;
    }
    return false;
  }
  int isOnAreaFastQuestion(){
    int response = 0;
    if(maxLatitude != 0){
      try{
        if(
          maxLongitude > locationBloc.state.lastKnownLocation!.longitude && 
          minLongitude < locationBloc.state.lastKnownLocation!.longitude && 
          maxLatitude  > locationBloc.state.lastKnownLocation!.latitude &&
          minLatitude  < locationBloc.state.lastKnownLocation!.latitude
        ) {
          response = 1;
        } 
      } on Exception catch (e){
        response = 2;
    }
    }
    return response;
  }
  int isOnAreaFastQuestionWithPoint(LatLng pointToCompare){
    int response = 0;
    if(maxLatitude != 0){
      try{
        if(
          maxLongitude > pointToCompare.longitude && 
          minLongitude < pointToCompare.longitude && 
          maxLatitude  > pointToCompare.latitude &&
          minLatitude  < pointToCompare.latitude
        ) {
          response = 1;
        } 
      } on Exception catch (e){
        response = 2;
    }
    }
    return response;
  }
  
  bool mustAskForPoint() {
    final double lonDelta = (lastPositionToCompare!.longitude - cameraPosition!.target.longitude).abs();
    final double latDelta = (lastPositionToCompare!.latitude -  cameraPosition!.target.latitude).abs();
    bool isInSide = false;
    if(maxLatitude != 0){
      if(
        maxLongitude > cameraPosition!.target.longitude && 
        minLongitude < cameraPosition!.target.longitude && 
        maxLatitude  > cameraPosition!.target.latitude &&
        minLatitude  < cameraPosition!.target.latitude
      ) {
        isInSide = true;
        add(IsTheCameraTargetInsideAreEvent());
        print('GRID INSIDE');

      } 
      else{
        add(IsTheCameraTargetOutAreEvent());
        print('GRID OUTSIDE');
      }
    }
    if((latDelta > 0.0005 || lonDelta > 0.0005) && isInSide){
      print('GRID WILL ASK FOR POINT');
      return true;
    }

    print('GRID WILL NOT ASK FOR AREA');
    return false;
  }
 

}
