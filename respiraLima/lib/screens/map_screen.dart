import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:app4/blocs/blocs.dart';
import 'package:app4/screens_alerts/alert_screen_on.dart';
import 'package:app4/screens_alerts/screens_alerts.dart';
import 'package:app4/services/services.dart';
import 'package:app4/share_preferences/share_preferences.dart';
import 'package:app4/themes/themes.dart';
import 'package:app4/views/views.dart';
import 'package:app4/widgets/navigation_mode_sheet.dart';
import 'package:app4/widgets/place_alert_information.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  // To use it life cycle
  static String pageRoute = 'mapScreen';
  const MapScreen({Key? key}) : super(key: key);
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  // StreamSubscription<Position>? positionStreamX;
  // int onStart = 0;
  late DraggableScrollableController _draggableScrollableController;
  late LocationBloc locationBloc;
  late SocketService socketService;
  late NavigationBloc navigationBloc;
  late AppDataBloc appDataBloc;
  late MapBloc mapBloc;

  TileOverlay? _tileOverlay;
  // late Timer timer;
  bool waitingForResponse = false;
  bool nowIsInBack = false;

  // void setTimer(bool isBackground) {
  //   // int delaySeconds = isBackground ? 30 : 30;

  //   // Cancelling previous timer, if there was one, and creating a new one

  //   // if(timer != null){
  //   //   timer.cancel();
  //   // }
  //   int timeToCall =
  //       navigationBloc.state.navigationProfile == 'cycling' ? 17 : 17;
  //   // int timeToCall = navigationBloc.state.navigationProfile == 'cycling' ? navigationBloc.cyclingTime : navigationBloc.walkingTime;
  //   print('IS ONNNNNNNN $timeToCall');
  //   timer = Timer.periodic(Duration(seconds: timeToCall), (t) async {
  //     // Not sending a request, if waiting for response
  //     // if(onStart == 1){
  //     //   positionStreamX = Geolocator.getPositionStream().listen((event) {
  //     //     final position = event;
  //     //     locationBloc.add(OnNewUserLocationEvent(
  //     //         // LatLng(-12.047341, -77.031782)));
  //     //         LatLng(position.latitude, position.longitude))); // MUST DECOMMENT THIS
  //     //   });
  //     // }
  //     if (!waitingForResponse) {
  //       if (navigationBloc.state.isNavigating &&
  //           navigationBloc.state.navigationState == 2) {
  //         waitingForResponse = true;
  //         // await navigationBloc.postTrackingPosition();
  //         final position =  await Geolocator.getCurrentPosition();
  //         final List<Placemark>? placemarks = await locationBloc.getPlaceFromLatLng(position.latitude, position.longitude);
  //         String streetName = 'S/N';
  //         if(placemarks !=null && placemarks.isNotEmpty){
  //           streetName = placemarks[0].street ?? 'S/N';
  //         } 
  //         final stateT = await navigationBloc.postTrackingPositionMikel(position: LatLng(position.latitude, position.longitude), streetName: streetName);
  //         // final stateT = await navigationBloc.postTrackingPosition();
  //         print('IS ONNNNNNN the state is $stateT');
  //         waitingForResponse = false;
  //         if (isBackground && !nowIsInBack) {
  //           print('IS ONNNNNNN BACKGROUND $stateT');
  //           // _startForegroundTask();
  //           nowIsInBack = true;
  //         } else if (!isBackground && nowIsInBack) {
  //           print('IS ONNNNNNN , NOT IN BACK GROUND $stateT');
  //           // _stopForegroundTask();
  //           nowIsInBack = false;
  //         }
  //       } else {
  //         print('IS ONNNNNNNN $timeToCall');
  //       }

  //       print('IS ONNN BACKGROUND:      --->>> $isBackground');

  //       // // await post();
  //     }
  //   });
  // }

  @override
  void initState() {
    // When want to clean all when it finishes
    // TODO: implement initState
    super.initState();
    locationBloc = BlocProvider.of<LocationBloc>(context);
    mapBloc = BlocProvider.of<MapBloc>(context, listen: false);
    navigationBloc = BlocProvider.of<NavigationBloc>(context, listen: false);
    appDataBloc = BlocProvider.of<AppDataBloc>(context, listen: false);
    // locationBloc.getCurrentPosition();
    locationBloc.startFollowingUser();
    _addTileOverlay();

    socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('new_map_paint', (data) async {
      print('socket new map waswas $data');
      await appDataBloc.updatePredictionsGrid();
      // mapBloc.updateCameraPosition();
      // notifyListeners();
    });
    socketService.socket.on('join_room', (data) {
      print('socket new map waswas xxxxx$data');
      // notifyListeners();
    });

    WidgetsBinding.instance.addObserver(this); // Adding an observer
    // setTimer(false); // Setting a timer on init

    _draggableScrollableController = DraggableScrollableController();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   setTimer(state != AppLifecycleState.resumed);
  // }

  @override
  void dispose() {
    // positionStreamX?.cancel(); // TESTING X
    locationBloc.stopFollowingUser();
    socketService.socket.disconnect();

    /// TODO: EVALUATE THIS, ASK TO MIKEL
    // TODO: implement dispose
    // if (timer != null) {
    //   timer.cancel(); // Cancelling a timer on dispose
    // }
    WidgetsBinding.instance.removeObserver(this); // Removing an observer
    _draggableScrollableController.dispose();
    super.dispose();
    socketService.socket.on('leave_room', (data) {
      print('socket leave room $data');
      // _serverStatus = ServerStatus.Online;
      // notifyListeners();
    });
  }

  void _addTileOverlay() {
    final TileOverlay tileOverlay = TileOverlay(
      tileOverlayId: const TileOverlayId('tile_overlay_1'),
      tileProvider: _DebugTileProvider(),
    );
    setState(() {
      _tileOverlay = tileOverlay;
    });
  }

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final Set<TileOverlay> overlays = <TileOverlay>{
      if (_tileOverlay != null) _tileOverlay!,
    };
    // _addTileOverlay(); //  ADDING COMMENT TO IT,DID NOT REMENBER THE IMPORTANCE OF IT
    final Size areaScreen = MediaQuery.of(context).size;
    return Scaffold(
      key: _globalKey,
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, locationstate) {
          if (locationstate.lastKnownLocation == null) {
            return const Center(child: Text('Cargando el mapa...'));
          }
          return BlocBuilder<MapBloc, MapState>(
            builder: (context, mapState) {
              return SingleChildScrollView(
                child: Stack(
                  children: [
                    MapView(
                      inicialLocation: locationstate.lastKnownLocation!,
                      polylines: mapState.polylines.values.toSet(),
                      onverlay: overlays,
                      markers: mapState.markers.values.toSet(),
                    ),
                    // const SearchBar(),

                    const ManualMarker(),

                    BtnSettings(globalKey: _globalKey),

                    // BottomModalSheet(
                    //   areaScreen: areaScreen,
                    //   callbackStart: _startForegroundTask,
                    //   callbackEnd: _stopForegroundTask,
                    //   ),
                    _bottomModalSheet(areaScreen),
                    NavigationModeSheet(areaScreen: areaScreen),

                    mapState.isLoading
                        ? LoadingAlert(
                            screenSize: areaScreen,
                          )
                        : const SizedBox(),
                    RatingAlert(
                      screenSize: areaScreen,
                    ),
                    const AlertPollution(),
                    const AlertPlaces(),
                    const AlertOutOfArea(),
                    const AlertScreenOn(),
                    PlaceAlertInformation(screenSize: areaScreen)
                    // const AlertGoingToZone(),
                  ],
                ),
              );
            },
          );
        },
      ),
      drawer: const SideMenu(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          // TODO: GENERATE THE LOGIC TO SHIC THIS BTNs
          // BtnFollowUser(),
          // BtnCurrentLocation(),
        ],
      ),
    );
  }

  Widget _bottomModalSheet(Size areaScreen) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return state.displayManualMarker
            ? Container()
            : SizedBox(
                height: areaScreen.height,
                // child: _BottomModal(),
                child: _bottomModal());
      },
    );
  }

  Widget _bottomModal() {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          controller: _draggableScrollableController,
          initialChildSize: 0.4,
          minChildSize: 0.11,
          maxChildSize: 0.8,
          snap: true,
          snapSizes: const [0.4, 0.8],
          // maxChildSize: state.navigationMode == '' ? 0.1 : 0.6,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                  color: state.navigationState == 0
                      ? Colors.transparent
                      : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  )),
              child: SingleChildScrollView(
                controller: scrollController,
                child: SizedBox(
                  // height: 300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: state.navigationMode == 'monitoreo' &&
                            state.navigationState >= 1
                        ? _bottomModalMonitoreandoPrincipal()
                        : state.navigationMode == 'ruteo' &&
                                state.navigationState >= 1
                            ? _bottomModalRuteoPrincipal()
                            : Container(),
                    // child: BottomModalRuteo(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _bottomModalRuteoPrincipal() {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return state.isNavigating
            ? _bottomModalMonitoreando()
            : BottomModalRuteo(draggableScrollableController: _draggableScrollableController,);
      },
    );
  }
  Widget _bottomModalMonitoreandoPrincipal() {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return state.isNavigating
            ? _bottomModalMonitoreando()
            : _bottomModalMonitoreo();
      },
    );
  }

  Widget _bottomModalMonitoreando() {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    // final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 5,
            ),


            ToFollowWidget(
                mapBloc: mapBloc,
                draggableScrollableController: _draggableScrollableController,
                child: const HeaderAcompanhando()
            ),



            Row(
              children: [
                SizedBox(
                  width: 150,
                  // width: 205,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: state.navigationDataToShowTracking.isEmpty
                        ? [
                            FadeOut(
                              child: Container(
                                width: 80,
                                height: 16,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    gradient: LinearGradient(
                                        colors: [Colors.grey, Colors.white])),
                              ),
                            ),
                            const SizedBox(height: 5),
                            FadeOut(
                              child: Container(
                                width: 100,
                                height: 16,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    gradient: LinearGradient(
                                        colors: [Colors.grey, Colors.white])),
                              ),
                            ),
                            const SizedBox(height: 5),
                            FadeOut(
                              child: Container(
                                width: 80,
                                height: 16,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    gradient: LinearGradient(
                                        colors: [Colors.grey, Colors.white])),
                              ),
                            ),
                          ]
                        : [
                            BounceInLeft(
                              child: Text(
                                state.isOnArea ? 'Actualmente estas en:' : '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w300, fontSize: 12),
                              ),
                            ),
                            BounceInLeft(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  state.isOnArea
                                      ? (state.navigationDataToShowTracking
                                              .isNotEmpty
                                          ? state.navigationDataToShowTracking
                                              .last.streetName
                                          : '')
                                      : 'Estás fuera de área',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: state.isOnArea
                                          ? AppTheme.darkBlue
                                          : AppTheme.red,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                            BounceInLeft(
                              child: !state.isOnArea
                                  ? const Text('')
                                  : Row(
                                      children: [
                                        Text(
                                          // TODO: ASK WHAT TIME TO SHOWN
                                          state.navigationDataToShowTracking
                                                  .isNotEmpty
                                              ? DateTime.now()
                                                  .difference(DateTime.parse(state
                                                      .navigationDataToShowTracking
                                                      .first
                                                      .timestamp))
                                                  .inMinutes
                                                  .toString()
                                              : '',

                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.gray80,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          // TODO: ASK WHAT DISTANCE TO SHOWN
                                          state.navigationDataToShowTracking
                                                  .isNotEmpty
                                              ? 'min (${state.navigationDataToShowTracking.last.distance.toString()}km)'
                                              : '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.gray80,
                                              fontSize: 10),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                  ),
                ),
                const Expanded(
                  child: SizedBox(
                    width: 10,
                  ),
                ),
                BtnEndNavigation(
                  text: ' Finalizar',
                  btnColor: state.navLoading
                  ? AppTheme.gray50
                  : AppTheme.primaryOrange,
                  icon: Icons.navigation,
                  onPressed: state.navLoading
                  ?() {}
                  : () async {
                    mapBloc.add(OnStartLoading());
                    mapBloc.add(RemoveNavigationPolylinesAndMarkers());
                    await navigationBloc.postTrackingPositionMikel();
                    await navigationBloc.postTrackingPoints();
                    await navigationBloc.getInternalTrackingEnd().then((value) {
                      navigationBloc.add(StopNavigationEvent());
                    });
                    mapBloc.add(OnStopLoading());
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            state.navigationDataToShowTracking.length > 1
                ? BounceInRight(
                    child: ProfileAndModeAvatar(
                        profile: state.navigationProfile == 'walking'
                            ? 'Peatón'
                            : 'Ciclista',
                        profileIcon: state.navigationProfile == 'walking'
                            ? Icons.nordic_walking
                            : Icons.pedal_bike,
                        mode: state.navigationMode == 'monitoreo'
                            ? 'Acompañamiento'
                            : 'Ruteo',
                        modeIcon: Icons.pin_drop_rounded),
                  )
                : const SizedBox(),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 1,
              width: double.infinity,
              color: AppTheme.gray30,
            ),
            const SizedBox(
              height: 20,
            ),
            state.navigationDataToShowTracking.length > 1
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        // ignore: unnecessary_null_comparison
                        for (int i =
                                state.navigationDataToShowTracking.length - 1;
                            i >= 0;
                            i--)
                          FadeInUp(
                            child: HistoryTrackingPerPoint(
                              isHoleBoll: i ==
                                      state.navigationDataToShowTracking
                                              .length -
                                          1
                                  ? true
                                  : false,
                              areLines: i == 0 ? false : true,
                              titleHeader: i == 0 ? "Partida: " : "",
                              title: state
                                  .navigationDataToShowTracking[i].streetName,
                              time: DateTime.now()
                                  .difference(DateTime.parse(state
                                      .navigationDataToShowTracking[i]
                                      .timestamp))
                                  .inMinutes
                                  .toString(),
                              distance: state
                                  .navigationDataToShowTracking[i].distance
                                  .toString(),
                              exposure: state
                                  .navigationDataToShowTracking[i].exposure
                                  .toString(),
                              airQuality: state
                                  .navigationDataToShowTracking[i].airQuality,
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(),
            const SizedBox(
              height: 20,
            ),
            const BrandingLima(width: 200),
            const SizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }

  Widget _bottomModalMonitoreo() {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    final locationBloc = BlocProvider.of<LocationBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    // final navigationBloc = BlocProvider.of<NavigationBloc>(context);
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 5,
            ),
              // HeaderAcompanhamiento(navigationBloc: navigationBloc),
            ToFollowWidget(
                mapBloc: mapBloc,
                draggableScrollableController: _draggableScrollableController,
                child: const HeaderAcompanhando()),
            // ToFollowWidget(mapBloc: mapBloc, child: const HeaderAcompanhando()),
            // const SizedBox(
            //   height: 5,
            // ),
            state.navLoading ? const SizedBox() : Row(
              children: [
                IconButton(
                  onPressed: () {
                    navigationBloc.add(DeactivateNavigationModeEvent());
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                const Expanded(child: SizedBox()),
                const Text(
                  'Configurar acompañamiento',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 1,
              color: AppTheme.gray30,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person,
                  size: 40,
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Preferences.userName == ''
                          ? 'Hola'
                          : 'Hola ${Preferences.userName.split(' ')[0]}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 18),
                    ), // TODO: QUITAR ESTO, solo colocar el nomre
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'No es necesario que tengas un destino definido, te acompañaremos en el camino y te iremos mostrando la calidad de aire y exposición a contaminación que tengas durante tu recorrido.',
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
            const SizedBox(
              height: 25,
            ),
            const Text(
              'Elige un perfil para este viaje',
              style:
                  TextStyle(fontWeight: FontWeight.w700, color: AppTheme.darkBlue),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
                  children: [
                    Expanded(
                      child: BtnNavigationMode(
                        name: 'Peatón',
                        icon: Icons.nordic_walking,
                        isFocus: state.navigationProfile == 'walking',
                        callback: () {
                          navigationBloc.add(WalkingNavigationProfileEvent());
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: BtnNavigationMode(
                        name: 'Ciclista',
                        icon: Icons.pedal_bike,
                        isFocus: state.navigationProfile == 'cycling',
                        callback: () {
                          navigationBloc.add(CyclingNavigationProfileEvent());
                        },
                      ),
                    ),
                  ],
                ),
            const SizedBox(
              height: 30,
            ),
            BtnAllConfirmations(
                  btnWidth: double.infinity,
                  btnColor: 
                  state.navLoading 
                  // state.navLoading || locationBloc.state.modifyForTesting
                      ? AppTheme.gray50
                      : AppTheme.aqua,
                  text: ' Iniciar',
                  icon: Icons.navigation,
                  onPressed:
                   state.navLoading 
                  //  state.navLoading || locationBloc.state.modifyForTesting
                      ? null
                      : () async {
                        if(!state.navLoading){
                          mapBloc.add(OnStartLoading());
                          final bool willstart =
                              await navigationBloc.postTrackingStartMikel();
                              // await navigationBloc.postTrackingStart();
                          mapBloc.add(OnStopLoading());
                          if (willstart) {
                            print('navigation will xstart');
                            // _startForegroundTask();
                            // _startForegroundTask();
                            // locationBloc.stopFollowingUser();
                            await navigationBloc.postTrackingPositionMikel();
                            // await service.showNotificationForeground(id: 1, title: 'Ruteando', body: 'Regresar a la pagina de ruteo');
    
                            // NotificationApi.showNotification(
                            //   id: 0,
                            //   title: 'Ruteando',
                            //   body: 'Regresar a la pagina de ruteo',
                            //   payload: MapScreen.pageRoute,
                            //   );
                          }

                        }
                        },
                ),
    
            const SizedBox(
              height: 30,
            ),
    
    
            const BrandingLima(width: 200),
            const SizedBox(
              height: 50,
            ),
          ],
        );
      },
    );
  }
}

class ListaItems extends StatelessWidget {
  final ScrollController scrollController;

  final items = new List.filled(40, null, growable: false);

  ListaItems(this.scrollController);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: this.scrollController,
      itemCount: items.length,
      itemBuilder: (context, index) => ListTile(
        title: Text('Item: $index'),
      ),
    );
  }
}

class _DebugTileProvider implements TileProvider {
  _DebugTileProvider() {
    boxPaint.isAntiAlias = true;
    boxPaint.color = Colors.transparent;
    //boxPaint.strokeWidth = 2.0;
    boxPaint.style = PaintingStyle.stroke;
  }

  static const int width = 100;
  static const int height = 100;
  static final Paint boxPaint = Paint();
  static const TextStyle textStyle = TextStyle(
    color: Colors.red,
    fontSize: 20,
  );

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    // print("====Tile info zoom: $zoom - x: $x -y: $y");

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.red.withOpacity(0.3);

    //var int_zoom = zoom ?? 2;
    //int_zoom = int_zoom - 2;
    // ui.Image images = await getAssetImage('assets/logos/logoLimaWhite.png');
    // ui.Image images = await getAssetImage('assets/tiles/$zoom/$x/$y.png');
    paint.color = const Color.fromARGB(204, 160, 42, 42);
    // canvas.drawImage(images, Offset(0, 0), paint);
    //textPainter.paint(canvas, offset);
    canvas.drawRect(
        Rect.fromLTRB(0, 0, width.toDouble(), width.toDouble()), boxPaint);
    final ui.Picture picture = recorder.endRecording();
    final Uint8List byteData = await picture
        .toImage(width, height)
        .then((ui.Image image) =>
            image.toByteData(format: ui.ImageByteFormat.png))
        .then((ByteData? byteData) => byteData!.buffer.asUint8List());
    // print('====Tile info END TILESSSSSS 1..........');
    return Tile(width, height, byteData);
  }
}

// Future<ui.Image> getAssetImage(String asset, {width, height}) async {
//   ByteData data = await rootBundle.load(asset);
//   ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
//       targetWidth: width, targetHeight: height);
//   ui.FrameInfo fi = await codec.getNextFrame();
//   return fi.image;
// }


