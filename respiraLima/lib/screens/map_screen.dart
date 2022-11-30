import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:animate_do/animate_do.dart';
import 'package:app4/alerts/alets.dart';
import 'package:app4/blocs/blocs.dart';
import 'package:app4/db/db.dart';
import 'package:app4/grid/grid.dart';
import 'package:app4/helpers/helpers.dart';
import 'package:app4/models/models.dart';
import 'package:app4/screens_alerts/alert_screen_on.dart';
import 'package:app4/screens_alerts/screens_alerts.dart';
import 'package:app4/sensors_props/sensors_props.dart';
// import 'package:app4/services/services.dart';
import 'package:app4/share_preferences/share_preferences.dart';
import 'package:app4/themes/themes.dart';
import 'package:app4/views/views.dart';
import 'package:app4/widgets/navigation_mode_sheet.dart';
import 'package:app4/widgets/place_alert_information.dart';
import 'package:app4/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;


import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:app4/global/enviroment.dart';
import 'package:http/http.dart' as http;
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;



  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final customData = await FlutterForegroundTask.getData<String>(key: 'customData');
    
    print('customData: $customData --> ${DateTime.now().toString()}');
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'MyTaskHandler',
      notificationText: 'eventCount: $_eventCount',
    );

    // Send data to the main isolate.
    sendPort?.send(_eventCount);

    _eventCount++;
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    print('onButtonPressed >> $id');
  }

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}


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
  // late SocketService socketService;
  late NavigationBloc navigationBloc;
  late AppDataBloc appDataBloc;
  late MapBloc mapBloc;

  TileOverlay? _tileOverlay;
  // late Timer timer;
  bool waitingForResponse = false;
  bool nowIsInBack = false;



  /// 1...........................
  /// 1...........................
  final format = DateFormat('yyyy-MM-dd HH:mm:ss');
  final FirebaseAuth auth = FirebaseAuth.instance;
  ReceivePort? _receivePort;
  static int forResidualOperatorMin = 15;
  static int forResidualOperatorSec = 30;
  static int timesTryingMin = 5;
  static int timesTryingSec = 7;
  
  late Location _location;

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Colors.orange,
        ),
        buttons: [
          const NotificationButton(id: 'sendButton', text: 'Send'),
          const NotificationButton(id: 'testButton', text: 'Test'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: false,
        allowWakeLock: false,
        allowWifiLock: true,
      ),
    );
    
  }

  Future<bool> _startForegroundTask() async {
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted =
          await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        print('SYSTEM_ALERT_WINDOW permission denied!');
        return false;
      }
    }

    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    bool reqResult;
    if (await FlutterForegroundTask.isRunningService) {
      reqResult = await FlutterForegroundTask.restartService();
    } else {
      reqResult = await FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }

    ReceivePort? receivePort;
    if (reqResult) {
      receivePort = await FlutterForegroundTask.receivePort;
    }

    return _registerReceivePort(receivePort);
  }

  Future<bool> _stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? receivePort){
    _closeReceivePort();

    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) async{
        if (message is int) {
          
          final location = await _location.getLocation();
          
          // final location = await Geolocator.getCurrentPosition();
          String streetName = 'S/N';
          if (location.latitude != null && location.longitude != null){
            final timestamp = format.format(DateTime.now()).toString();
            final double latitude = location.latitude!;
            final double longitude = location.longitude!;
            List<geocoding.Placemark>? placemarks = await geocoding.placemarkFromCoordinates(latitude, longitude);
            if(placemarks.isNotEmpty){
              streetName = placemarks[0].street ?? 'S/N';
            } 


            final int pointCount = await PrincipalDB.getNavigationCantPoint();
            await PrincipalDB.navigationCantPoints(pointCount + 1);
            final routeID = await PrincipalDB.getNavigationID();






            await PrincipalDB.getPredictionsGridDeadTime().then((timeSaved) async {
            
            if(timeSaved != null && timeSaved != ''){
              final Duration duration = DateTime.now().difference(DateTime.parse(timeSaved));
              
              print('Gridx---->  ***** $timeSaved  **** DURARION IN MINUTES !!!${duration.inMinutes}!!! IN seconds !!!${duration.inSeconds}! and simbol ${duration.isNegative}????');
              print('Gridx----> DURARION IN MINUTES !!!${duration.inMinutes%forResidualOperatorMin}!!! !!!!!${duration.inSeconds%forResidualOperatorSec}!!?');
              if (duration.inSeconds%forResidualOperatorSec < timesTryingSec && duration.inMinutes%forResidualOperatorMin < timesTryingMin && !duration.isNegative){
              // if (duration.inMinutes < timePassedToUpdateGrid ){
                await _gridUpdating();
                
              } 
            } else{
              await _gridUpdating();
            
            }
            print('DB pred LAST TIME SAVED is null .. $timeSaved');
          });


              
            Map<String, dynamic>? prediction;
            NavigationPredictions predictions = NavigationPredictions();
            Map<String, dynamic> respondese = {'error': 0, 'detail': 'No data'};
            await predictions.getCoordinatesPrediction(LatLng(latitude, longitude)).then((value) {
              if(value['error'] == null){
                prediction = value;
                print('Gridx----> PREDICTION DATA -------OK------> $prediction');
              } else{
                respondese = {'error': 1, 'detail': 'out of area'};
                print('Gridx----> PREDICTION DATA ------ERROR-------> $respondese');
              }
            });







            if(prediction != null){

              final PM25 _pm25 = PM25();
              if(pointCount > 0){

                // await PrincipalDB.findPointById(pointCount-1).then((value) async {
                await PrincipalDB.getAllPoints().then((value) async {
                  
                  if(value.isNotEmpty){
                    final Map<String,dynamic> start =  {
                        'latitude' : value.last.lat,
                        'longitude': value.last.lon,
                        'pm25'     : value.last.pm25,
                      };
                    
                    final Map<String,dynamic> end =  {
                        'latitude' : location.latitude,
                        'longitude': location.longitude,
                        'pm25'     : prediction!['pm_25'],
                      };
                    
                    final segment = SegmentModel(
                      startPoint: start,
                      endPoint: end
                    );


                    final List<String> airQualityAndColor = _pm25.get_category_and_color_hex(prediction!['pm_25']);
                    final double pm25 = segment.pm25();
                    
                    final point = PointModel(
                      lat: latitude, 
                      lon: longitude, 
                      timestamp: timestamp, 
                      streetName: streetName, 
                      pointNumber: pointCount,
                      // pm25: 100,
                      pm25: pm25,
                    );
                    
                    await PrincipalDB.insertPoint(point);
                    // await PrincipalDB.insertUpdatePointsWithCustomID(point, pointCount);
                    await PrincipalDB.getNavigationAcumulatedPM25().then((accumulatedPM25) async {
                      accumulatedPM25 += pm25;
                      await PrincipalDB.navigationAcumulatedPM25(accumulatedPM25);
                    });
                    await PrincipalDB.getNavigationAcumulatedDistance().then((accumulatedDistance) async {
                      accumulatedDistance += segment.distance_km();
                      await PrincipalDB.navigationAcumulatedDistance(accumulatedDistance);
                      final double distanceRound = double.parse(accumulatedDistance.toStringAsFixed(1));
                      final report = PositionReport(
                        // exposure  : 10, 
                        exposure  : pm25, 
                        airQuality: airQualityAndColor[0], 
                        timestamp : timestamp, 
                        // distance  : 10, 
                        distance  : distanceRound, 
                        streetName: streetName,
                        color     : airQualityAndColor[1]
                      );
                      respondese = report.toMap();
                    });
                    





                    final Map<String, dynamic> alertsData = {
                      "current_point": end,
                      "previous_point": start
                    };

                    final alerts = await get_alerts_to_send(alertsData);






                      // List<dynamic> placesToSendAlert = [];

                      // double currentLat = end["latitude"],
                      //     currentLon = end["longitude"];
                      // double previousLat = start["latitude"],
                      //     previousLon = start["longitude"];
                      // await PrincipalDB.getPlacesAlerts().then((places) {
                      //   // print('alert $places');
                      //   for (var placeX in places) {
                      //     final place = Map.of(placeX);
                      //     double placeLat = place["lat"], placeLon = place["lon"];

                      //     final double currentDistance = Geolocator.distanceBetween(currentLat, currentLon, placeLat, placeLon);
                      //     final double previousDistance = Geolocator.distanceBetween(
                      //         previousLat, previousLon, placeLat, placeLon);
                      //     // print("alert current distance $currentDistance");
                      //     // print("alert previous distance $previousDistance");
                      //     bool isAlertTriggerCurrent = currentDistance <= 100;
                      //     bool isAlertTriggerPrevious = previousDistance <= 100;

                      //     if (isAlertTriggerCurrent && !isAlertTriggerPrevious) {
                      //       place["distance"] = currentDistance;
                      //       placesToSendAlert.add(place);
                      //     }
                      //   }

                      // });


                      // print('THE ALERTS ARE ......1: $placesToSendAlert');





                    print('THE ALLERTS ARE: $alerts');
                    if(alerts.isNotEmpty){
                      if(alerts['place_alerts'] != null){
                        respondese['place_alerts'] = alerts['place_alerts'];
                      }
                      if(alerts['pollution_alerts'] != null){
                        respondese['pollution_alerts'] = alerts['pollution_alerts'];
                      }
                    }



                  } else{
                    respondese = {'error': 2, 'detail': 'No grid on db'};
                    // TODO: THE SAME AS THE NEXT ELSE
                  }
                });




              } else {
                  List<String> airQualityAndColor = _pm25.get_category_and_color_hex(prediction!['pm_25']);
                  final point = PointModel(
                    lat: latitude, 
                    lon: longitude, 
                    timestamp: timestamp, 
                    streetName: streetName, 
                    pointNumber: pointCount,
                    pm25: prediction!['pm_25'],
                  );
                  
                  final report = PositionReport(
                    exposure  : prediction!['pm_25'], 
                    airQuality: airQualityAndColor[0], 
                    timestamp : timestamp, 
                    distance  : 0, 
                    streetName: streetName,
                    color     : airQualityAndColor[1]
                    );

                  final Map<String,dynamic> end =  {
                    'latitude' : latitude,
                    'longitude': longitude,
                    'pm25'     : prediction!['pm_25'],
                  };

                  await PrincipalDB.insertPoint(point);
                  // await PrincipalDB.insertUpdatePointsWithCustomID(point, pointCount);
                  await PrincipalDB.getNavigationAcumulatedPM25().then((accumulatedPM25) async {
                      accumulatedPM25 += prediction!['pm_25'];
                      await PrincipalDB.navigationAcumulatedPM25(accumulatedPM25);
                    });
                  respondese = report.toMap();






                  final Map<String, dynamic> alertsData = {
                      "current_point": end,
                    };

                  final alerts = await get_alerts_to_send(alertsData);

                  print('THE ALLERTS ARE: $alerts');
                    if(alerts.isNotEmpty){
                    if(alerts['place_alerts'] != null){
                      respondese['place_alerts'] = alerts['place_alerts'];
                    }
                    if(alerts['pollution_alerts'] != null){
                      respondese['pollution_alerts'] = alerts['pollution_alerts'];
                    }
                  }
                  

                  }
                }

              print('Gridx----> : FINAL RESPONSE ISSSSS:   $respondese');
              print('Gridx----> : $message ${DateTime.now().toString()} lat: ${location.latitude} lon: ${location.longitude} streetName $streetName, routeID: $routeID, CantPoint $pointCount');
          }





         // TODO: GET THE PREVIOUS PM25




          
            
     
        //////  get time  
        //////  get lat lon  
        //////  actualizar grilla  
        /////   refrescar token
        /////   sincronizar con fornt
          
          
          
          
          
          
          
          
          


        } else if (message is String) {
          if (message == 'onNotificationPressed') {
            Navigator.of(context).pushNamed('/resume-route');
          }
        } else if (message is DateTime) {
          print('timestamp: ${message.toString()}');
        }
      });

      return true;
    }

    return false;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }
  
  Future<bool> askForTokenUpdating() async {
    bool response = false;
    try {
      print('Gridx----> to init BEFORE FIRABASE INSTANCE');
      final String? token = await auth.currentUser?.getIdToken();
      // To change it after initialization, use `setPersistence()`:
      print('Gridx----> to init ACTUAL TOKEN ${token ?? 'NO TOK'}');
      if(token != null){
        
        final String? lastTimeTokenUpdated = await PrincipalDB.getTimeFirebaseTokenUpdated();
        if (lastTimeTokenUpdated != null && lastTimeTokenUpdated != ''){
          final Duration duration = DateTime.now().difference(DateTime.parse(lastTimeTokenUpdated));
          final String previousToken =  await PrincipalDB.getFirebaseToken(); 
          print('Gridx----> to init PREVIOUS TOKEN IS 1 zz IS $previousToken'); 
          print('Gridx----> to init  TIME PASED ${duration.inMinutes}'); 
          // if(duration.inMinutes > 59){
            if(token != previousToken){
              print('Gridx----> to UPDATING TOKENNNNNNNN----***************'); 
              await PrincipalDB.firebaseToken(token);
              // PrincipalDB.firebaseToken = token;
              Preferences.isFirstTime = false;
              // Preferences.timeFirebaseTokenUpdated = DateTime.now().toString();
              response = true;
            } else if(duration.inMinutes > 59){
              print('Gridx----> to NOTTT UPDATED, TIME PASES IS ${duration.inMinutes}----***************'); 
              response = false;

            } else{
              print('Gridx----> to SAME TOKEN AS BEFORE AND TIME PASES IS ${duration.inMinutes}----***************'); 

              Preferences.isFirstTime = false;
              response = true;
            }
        } else{
          print('Gridx----> to UPDATING  NEWWWW TOKENNNNNNNN----***************'); 
          await PrincipalDB.firebaseToken(token);
          // PrincipalDB.firebaseToken = token;
          Preferences.isFirstTime = false;
          // Preferences.timeFirebaseTokenUpdated = DateTime.now().toString();
          response = true;
      } 
        
      } 
    } catch (e) {
      print('Gridx----> to init TOKENQQ ERROR IS $e');
      response = false;
    }
    return response;
  }

  Future<int> _gridUpdating() async{
    int returnVal = 400;
    final isTokenUpdated = await askForTokenUpdating();
    final String token = await PrincipalDB.getFirebaseToken();
    final String? gridName = await PrincipalDB.getPredictionsGridName();
    print('Gridx---> grid init name $gridName');
    final resp = await _getAllPredictionsGridV2(
      idToken: token,
      gridName: gridName,
    );
    if (resp['error'] == null){
    // int countID = 1;
    await PrincipalDB.deleteAllPredictionGrid();
    resp["data"].forEach((key, value) async {
      final GridModel gridMod = GridModel(gridId: key, pm10: value['PM10']??0, pm25: value['PM25']??0);
      await PrincipalDB.insertPredictionValueFromGrid( gridMod);
      // await PrincipalDB.insertPredictionValueFromGridWithCustomID( gridMod, countID);
      // countID += 1;
    });
    await PrincipalDB.predictionsGridName(resp["name"] ?? '');
    await PrincipalDB.predictionsGridDeadTime(resp["expiration_date"] ?? '');
    final DateTime timeNow = DateTime.now();
    await PrincipalDB.predictionsGridTimeUpdated(timeNow.toString());
    print('Gridx---> grid data ${resp["data"]}');
    print('Gridx---> grid name ${resp["name"]}');
    print('Gridx---> expiration date ${resp["expiration_date"]}');
  
    returnVal =  200;
  } else if(resp['error'] == 401) {
    await PrincipalDB.timeFirebaseTokenUpdated('');
    // final isTokenUpdated = await askForTokenUpdating();
    print('Gridx---> to init ----------------TOKEN UPDATED ????????? $isTokenUpdated !!!!!!!!');
  }
  return returnVal;
}


  Future<Map<String, dynamic>> _getAllPredictionsGridV2({  // Limits for painting polilines
    required String idToken, 
    String? gridName,
    }) async
    {
      final Map<String, String> gridData = gridName != null && gridName != '' ? {
        'grid_name': gridName,
      } : {};
      final Map<String, String> head = {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: idToken,
        }; 
      final url = Uri.https(Environment.baseUrl, '${Environment.unEncodedPathGrid}/grid_data/v2', gridData); 
      try{
        final resp = await http.get(url, headers: head);
        final decodedResp = json.decode(resp.body);
        print('Gridx---> SINCE HERE IS THE RESPONSE --------------------');
        print('Gridx---> $decodedResp');
        print('Gridx---> HERE ENDS THE RESPONSE --------------------');
        try{
          if(decodedResp['status'] != null){
            if(decodedResp['status'] == 200){
              final Map<String,dynamic> finalDecoded = decodedResp["response"] ?? {'error':0};
              return finalDecoded;
            } else if (decodedResp['status'] == 401){
              return {'error':401};
            }
          }
          return {'error':1};
        }on Exception catch (e){
          return {'error':2};
      }
      } on Exception catch (e){
          return {'error':3};
      }
  }



  T? _ambiguate<T>(T? value) => value;

  /// 1...........................
  /// 1...........................


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
    print('location start Following FROM MAP_SCREEN');
    locationBloc.startFollowingUser();
    _addTileOverlay();

    // socketService = Provider.of<SocketService>(context, listen: false);
    // socketService.connect();
    // socketService.socket.on('new_map_paint', (data) async {
    //   print('socket new map waswas $data');
    //   await appDataBloc.updatePredictionsGrid();
    //   // mapBloc.updateCameraPosition();
    //   // notifyListeners();
    // });
    // socketService.socket.on('join_room', (data) {
    //   print('socket new map waswas xxxxx$data');
    //   // notifyListeners();
    // });

    WidgetsBinding.instance.addObserver(this); // Adding an observer
    // setTimer(false); // Setting a timer on init

    _draggableScrollableController = DraggableScrollableController();
    /// 1...........................
    /// 1...........................
    _location = Location();
    // _location.enableBackgroundMode(enable: true); // RECENT COMMENT 
    _initForegroundTask();
    _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) async {
      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = await FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
    /// 1...........................
    /// 1...........................
    
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('STATE IS $state !!!!');
    // setTimer(state != AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    // positionStreamX?.cancel(); // TESTING X
    locationBloc.stopFollowingUser();


    // socketService.socket.on('leave_room', (data) {
    //   print('socket leave room $data !!');
    //   // _serverStatus = ServerStatus.Online;
    //   // notifyListeners();
    // });
    // socketService.socket.disconnect();




    /// TODO: EVALUATE THIS, ASK TO MIKEL
    // TODO: implement dispose
    // if (timer != null) {
    //   timer.cancel(); // Cancelling a timer on dispose
    // }
    WidgetsBinding.instance.removeObserver(this); // Removing an observer
    _draggableScrollableController.dispose();
    super.dispose();
    /// 1..........................
    /// 1..........................
    _closeReceivePort();
    /// 1..........................
    /// 1..........................
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
            return  Center(child: 
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Cargando el mapa...'),
                const SizedBox(height: 30,),
                MaterialButton(
                onPressed: () {
                  if (isIOS) {
                    Phoenix.rebirth(context); 
                  }
                },
                splashColor: Colors.transparent,
                color: AppTheme.blue,
                elevation: 0,
                shape: const StadiumBorder(),
                child: const Text('Reiniciar app',
                    style: TextStyle(color: Colors.white)),
              ),
              ],
            )
            );
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

                    const ManualMarkerLite(),
                    // const ManualMarker(),

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
      drawer: SideMenu(scaffoldKey: _globalKey,),
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

          
            // const HeaderSpeacker(),
            
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                //  const HeaderSpeacker(),
                            //  const SizedBox(width: 5,),
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
                navigationBloc.state.navigationMode == 'ruteo' ? const HeaderSpeacker() : const SizedBox(),
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
                  icon: Icons.near_me_rounded ,
                  onPressed: state.navLoading
                  ?() {}
                  : () async {
                    mapBloc.add(OnStartLoading());
                    await navigationBloc.onlyStopNavigation();
                    mapBloc.add(RemoveNavigationPolylinesAndMarkers());
                    // _stopForegroundTask();
                    print('END---->>> 1 BEFORE  postTrackingPositionMikel ');
                    await navigationBloc.postTrackingPositionMikel();
                    print('END---->>> 2 BEFORE  postTrackingPoints ');
                    await navigationBloc.postTrackingPoints();
                    print('END---->>> 3 BEFORE  getInternalTrackingEnd ');
                    await navigationBloc.getPostInternalTrackingEnd().then((value) async {
                      print('END---->>> 44444 innn  getInternalTrackingEnd ');
                      await navigationBloc.stopNavigation();
                    });
                    print('END---->>> 5 ENDDDDDD');
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
                            ? Icons.directions_run
                            : Icons.directions_bike_outlined ,
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
                        icon: Icons.directions_run,
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
                        icon: Icons.directions_bike_outlined ,
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
                  icon: Icons.near_me_rounded ,
                  onPressed:
                   state.navLoading 
                  //  state.navLoading || locationBloc.state.modifyForTesting
                      ? null
                      : () async {
                        if(!state.navLoading){
                          mapBloc.add(OnStartLoading());
                          print('Following---0> init${DateTime.now().toString()}');
                          final bool willstart = await navigationBloc.postTrackingStartMikel();
                              // await navigationBloc.postTrackingStartMikelSpeach();
                              
                              // await navigationBloc.postTrackingStart();
                          mapBloc.add(OnStopLoading());
                          if (willstart) {
                            print('navigation will xstart');
                      
                            await navigationBloc.postTrackingPositionMikel();
                            // _startForegroundTask();
                           
                          }
                          print('Following---11> ENDD${DateTime.now().toString()}');

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


