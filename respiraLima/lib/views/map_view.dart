import 'package:app4/blocs/blocs.dart';
import 'package:app4/db/principal_db.dart';
import 'package:app4/services/services.dart';
import 'package:app4/share_preferences/share_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class MapView extends StatelessWidget {
  final LatLng inicialLocation;
  final Set<Polyline> polylines;
  final Set<Marker> markers;
  final Set<TileOverlay> onverlay;
  const MapView(
      {Key? key, required this.inicialLocation, required this.polylines, required this.onverlay, required this.markers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    final mapService = Provider.of<MapService>(context);
    final authService = Provider.of<AuthService>(context);
    
    final CameraPosition inicialCameraPosition = CameraPosition( bearing: MapPreferences.initialBearing,
        target: inicialLocation, zoom: MapPreferences.initialZoom, tilt: MapPreferences.initialTild);
    final size = MediaQuery.of(context).size;
    bool isInit = false;
    double divisor = (size.height + size.width) * 100;
    GoogleMapController _controller;
    return SizedBox(
        width: size.width,
        height: size.height,
        child: Listener(
          // Implement Following
          onPointerMove: (pointerMoveEvent) {
            mapBloc.add(WillStopFollowingUser());
          },
          child: GoogleMap(
            
            minMaxZoomPreference: MinMaxZoomPreference(MapPreferences.minZoom, MapPreferences.maxZoom),
            tileOverlays: onverlay,
            
            initialCameraPosition: inicialCameraPosition,
            myLocationEnabled: true,
            compassEnabled: false,

            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            buildingsEnabled: false,
            onCameraIdle:
             !mapBloc.state.updateData ? () {} :
             () async {

              
              // print('DELTA ---- LAT: ${mapBloc.lastPositionToCompare!.latitude}'); 
              // print('DELTA ---- LON: ${mapBloc.lastPositionToCompare!.longitude}');
              if(searchBloc.state.displayManualMarker){
                
                await mapBloc.updateForSearchData();
              }
              if (mapBloc.mustAskForPoint()){
                mapBloc.getBound().then((boundCoor) async{
                  if(boundCoor != null){
                    final String token = await PrincipalDB.getFirebaseToken();
                    // print('THE SAVED TOKEN ISSS :::::::: $token');
                    // mapService.getAllPoints(idToken: Preferences.firebaseToken, type: 'complete').then((value) {   
                    mapService.getAllPolylines4Coordinates(idToken: token, type: 'rectangle2p', format: 'polylines', upLeft: boundCoor.northeast, downRight: boundCoor.southwest).then((value) async {   
                    // mapService.getAllPolylines4Coordinates(idToken: Preferences.firebaseToken, type: 'rectangle2p', format: 'polylines', upLeft: boundCoor.northeast, downRight: boundCoor.southwest).then((value) async {   
                    // mapService.getAllPoints4Coordinates(idToken: Preferences.firebaseToken, type: 'rectangle2p', format: 'polylines', upLeft: boundCoor.northeast, downRight: boundCoor.southwest).then((value) {   
                    // mapService.getAllPoints4Coordinates(
                    //   idToken: Preferences.firebaseToken,
                    //    type: 'rectangle4p',
                    //    upLeft: upL, 
                    //    downRight: downR,
                    //    upRight: upR,
                    //    downLeft: downL
                    //    ).then((value) {  
                    
                      print('This is the valueww $value');
                      print(value);
                      if(value['error'] == null) {
                        
                        mapBloc.add(DrawPolylinesFromZoneEventPRO(
                        value //TODO: MUST DELATE THE datamapXX, ITS just for testing
                        // cameraPosition, value.length > 1 ? value : datamapXX //TODO: MUST DELATE THE datamapXX, ITS just for testing
                        ));
                        print('END----------- Drawing BEF 1 $isInit');
                        // isInit = false;
                        print('END----------- Before  AFF 2 $isInit');

                      } else if(value['error'] == 401) {
                        await authService.askForTokenUpdating().then((value) {
                          print('TOKEN IS UPDATED XXXXXXX? $value');
                        });
                      }
                      
                    });
                    
                  }


                  });
              }

            }, 
            onCameraMove: (CameraPosition cameraPosition) {

              print('CAMERA------->> ${cameraPosition.bearing}');
              mapBloc.add(DataIsUpdatedEvent(cameraPosition: cameraPosition));
              // mapBloc.cameraPosition = cameraPosition;
              // mapBloc.updateData = true; // TODO: evaluate if put this on start moving camera
  

            },
            // padding: const EdgeInsets.only(top: 100, left: 10),
            onMapCreated: (controller) {
                
                mapBloc.add(OnMapInitializedEvent(controller));
            },
            polylines: polylines,
            markers: markers,
            
          ),
        ),
        );
  }
}

// LatLng rotationWrong (LatLng coo, LatLng point, double cosVal, double sinVal) {
//   double lat = point.latitude*cosVal + point.longitude*sinVal;
//   double lon = point.longitude*cosVal - point.latitude*sinVal;
//   return LatLng(coo.latitude + lat, coo.longitude + lon);
// }
LatLng rotationFormula (LatLng coo, LatLng point, double cosVal, double sinVal) {
  double lat = point.latitude*cosVal - point.longitude*sinVal;
  double lon = point.longitude*cosVal + point.latitude*sinVal;
  return LatLng(coo.latitude + lat, coo.longitude + lon);
}
