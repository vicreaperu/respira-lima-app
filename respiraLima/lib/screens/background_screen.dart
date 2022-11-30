import 'dart:isolate';
import 'package:app4/alerts/alets.dart';
import 'package:app4/db/db.dart';
import 'package:app4/grid/grid.dart';
import 'package:app4/models/models.dart';
import 'package:app4/screens/screens.dart';
import 'package:app4/sensors_props/sensors_props.dart';
import 'package:app4/share_preferences/share_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'dart:io';

import 'package:app4/global/enviroment.dart';
import 'package:http/http.dart' as http;

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallbackx() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandlerx());
}

class MyTaskHandlerx extends TaskHandler {
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
      notificationTitle: 'MyTaskHandlerx',
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



class BackgroundScreen extends StatefulWidget {
  const BackgroundScreen({Key? key}) : super(key: key);
  static String pageRoute = 'BackGround';

  @override
  State<StatefulWidget> createState() => _BackgroundScreenState();
}

class _BackgroundScreenState extends State<BackgroundScreen> {




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
        callback: startCallbackx,
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
            PrincipalDB.navigationCantPoints(pointCount + 1);
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
                    await PrincipalDB.insertUpdatePointsWithCustomID(point, pointCount);
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

                  await PrincipalDB.insertUpdatePointsWithCustomID(point, pointCount);
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

  @override
  void initState() {
    super.initState();
    
    _location = Location();
    // _location.enableBackgroundMode(enable: true);
    _initForegroundTask();
    _ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) async {
      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = await FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
  }

  @override
  void dispose() {
    _closeReceivePort();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A widget that prevents the app from closing when the foreground service is running.
    // This widget must be declared above the [Scaffold] widget.
    return WithForegroundTask(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Foreground Task'),
          centerTitle: true,
        ),
        body: _buildContentView(),
      ),
    );
  }

  Widget _buildContentView() {
    buttonBuilder(String text, {VoidCallback? onPressed}) {
      return ElevatedButton(
        child: Text(text),
        onPressed: onPressed,
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buttonBuilder('start', onPressed: () {
            Navigator.pushNamed(context, SettingsScreen.pageRoute);
          }),
          // buttonBuilder('start', onPressed: _startForegroundTask),
          buttonBuilder('stop', onPressed: _stopForegroundTask),
        ],
      ),
    );
  }
}




class ResumeRoutePage extends StatelessWidget {
  const ResumeRoutePage({Key? key}) : super(key: key);
  static String pageRoute = 'resumeRoute';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Route'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
            Navigator.of(context).pop();
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
