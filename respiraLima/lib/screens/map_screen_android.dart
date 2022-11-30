import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:animate_do/animate_do.dart';
import 'package:app4/alerts/alets.dart';
import 'package:app4/api/api.dart';
import 'package:app4/blocs/blocs.dart';
import 'package:app4/db/db.dart';
import 'package:app4/grid/grid.dart';
import 'package:app4/helpers/helpers.dart';
import 'package:app4/models/models.dart';
import 'package:app4/route_tracking/route_tracking.dart';
import 'package:app4/screens_alerts/screens_alerts.dart';
import 'package:app4/sensors_props/sensors_props.dart';
import 'package:app4/share_preferences/share_preferences.dart';
import 'package:app4/themes/themes.dart';
import 'package:app4/views/views.dart';
import 'package:app4/widgets/navigation_mode_sheet.dart';
import 'package:app4/widgets/place_alert_information.dart';
import 'package:app4/widgets/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;


import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:app4/global/enviroment.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:restart_app/restart_app.dart';
@pragma('vm:entry-point')
void startCallbackAndroid() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandlerAndroid());
}

class MyTaskHandlerAndroid extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;


  final format = DateFormat('yyyy-MM-dd HH:mm:ss');
  
  late FirebaseAuth auth;
  static int forResidualOperatorMin = 15;
  static int forResidualOperatorSec = 30;
  static int timesTryingMin = 5;
  static int timesTryingSec = 7;
  static const int limitPoints = 1440;
  
  // late Location _location;
  late bool runOnback;
  late final StartNavigationModel? navigatingData;
  List<InstructionsModel> navigationInstruction = [];
  List<LatLng> myRoute = [];
  TrackingRoute? plannedRoute;
  // Position? location;
  late final TtsApi tts;
  late final NotificationApi service;
  Future<double> _navigationDataSaver() async{
         
    print('GRIDXY---->  ***** -----INIT ');
    // final location = await _location.getLocation();
    final location = await Geolocator.getCurrentPosition();
    // final double latitude = location?.latitude ?? 0;
    // final double longitude = location?.longitude ?? 0;
    String streetName = 'S/N';
    print('GRIDXY---->  ***** ${location.latitude} /// ${location.longitude}');
    double pm25 = 0;
    // if (location.latitude != null && location.longitude != null){
    if(runOnback && navigatingData !=null) {

      final timestamp = format.format(DateTime.now()).toString();
      final double latitude = location.latitude ;
      final double longitude = location.longitude ;

    ///  FOR GETTING THE ROUTE
      // if(navigationInstruction.isEmpty && navigatingData!.mode == "ruteo" ){
      //   print('Routing---->X      BEFORE $navigationInstruction');
      //   await setRouteWithPrediction(actualLatLng: LatLng(latitude, longitude));
      //   print('Routing---->X      AFTER $navigationInstruction');
      // }



      List<geocoding.Placemark>? placemarks = await geocoding.placemarkFromCoordinates(latitude, longitude);
      if(placemarks.isNotEmpty){
        streetName = placemarks[0].street ?? 'S/N';
      } 


      final int pointCount = await PrincipalDB.getNavigationCantPoint();
      print('POINTCANT---> BACK $pointCount  cant at ${DateTime.now().toString()}');
      await PrincipalDB.navigationCantPoints(pointCount + 1);
      final routeID = await PrincipalDB.getNavigationID();






      await PrincipalDB.getPredictionsGridDeadTime().then((timeSaved) async {
      
        if(timeSaved != null && timeSaved != ''){
          final Duration duration = DateTime.now().difference(DateTime.parse(timeSaved));
          
          print('GRIDXY---->  ***** $timeSaved  **** DURARION IN MINUTES !!!${duration.inMinutes}!!! IN seconds !!!${duration.inSeconds}! and simbol ${duration.isNegative}????');
          print('GRIDXY----> DURARION IN MINUTES !!!${duration.inMinutes%forResidualOperatorMin}!!! !!!!!${duration.inSeconds%forResidualOperatorSec}!!?');
          if (duration.inSeconds%forResidualOperatorSec < timesTryingSec && duration.inMinutes%forResidualOperatorMin < timesTryingMin && !duration.isNegative){
          // if (duration.inMinutes < timePassedToUpdateGrid ){AS
            await _gridUpdating();
            
          } 
        } 
        else{
          await _gridUpdating();
        }
        print('DB pred LAST TIME SAVED is null .. $timeSaved');
      });


        
      Map<String, dynamic>? prediction;
      NavigationPredictions predictions = NavigationPredictions();
      Map<String, dynamic> respondese = {'error': 0, 'detail': 'No data'};
      await predictions.getCoordinatesPrediction(LatLng(latitude, longitude)).then((value) async {
        if(value['error'] == null){
          await PrincipalDB.getPredictionsGridTimeName().then((gridName) {
          prediction = Map<String,dynamic>.from(value);
          prediction!['gridTimeId'] = gridName;
          });
          print('GRIDXY----> PREDICTION DATA -------OK------> $prediction');
        } else{
          respondese = {'error': 1, 'detail': 'out of area'};
          print('GRIDXY----> PREDICTION DATA ------ERROR-------> $respondese');
        }
      });



      if(prediction != null){

        final PM25 _pm25 = PM25();
        final int pointCountSaved = await PrincipalDB.countAllPoints();
        if(pointCountSaved > 0){
        // if(pointCount > 0){

          // await PrincipalDB.findPointById(pointCount-1).then((value) async {
          await PrincipalDB.getAllPoints().then((value) async {
            print('POINTCANT--->      BACK ${value.length}');
            if(value.isNotEmpty){
              final Map<String,dynamic> start =  {
                  'latitude' : value.last.lat,
                  'longitude': value.last.lon,
                  'pm25'     : value.last.pm25,
                };
              
              final Map<String,dynamic> end =  {
                  'latitude' : latitude,
                  'longitude': longitude,
                  'pm25'     : prediction!['pm_25'],
                };
              
              final segment = SegmentModel(
                startPoint: start,
                endPoint: end
              );


              final List<String> airQualityAndColor = _pm25.get_category_and_color_hex(prediction!['pm_25']);
              pm25 = segment.pm25();
              
              final point = PointModel(
                lat: latitude, 
                lon: longitude, 
                timestamp: timestamp, 
                streetName: streetName, 
                pointNumber: pointCount,
                // pm25: 100,
                pm25: pm25,
                j: prediction!['j'] ?? 0,
                i: prediction!['i'] ?? 0,
                gridTimeId: prediction!['gridTimeId'] ?? '2022-04-04-04-04-04',
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




              print('THE ALERTS ARE .......2: $alerts');
              if(alerts.isNotEmpty){
                if(alerts['place_alerts'] != null){
                  respondese['place_alerts'] = alerts['place_alerts'];
                  print('4tts ${respondese['place_alerts'].first["name"]}');
                  tts.speakTts('Estás cerca a ${respondese['place_alerts'].first["name"] ?? 'un lugar interesante'}');
                }
                if(alerts['pollution_alerts'] != null){
                  respondese['pollution_alerts'] = alerts['pollution_alerts'];
                  print('4tts ${respondese['pollution_alerts']}');
                  tts.speakTts('Nivel alto de contaminacion');
                }
              }



            } else{
              respondese = {'error': 2, 'detail': 'No grid on db'};
              // TODO: THE SAME AS THE NEXT ELSE
            }
          });




        } else {
            pm25 = prediction!['pm_25'];
            List<String> airQualityAndColor = _pm25.get_category_and_color_hex(pm25);
            final point = PointModel(
              lat: latitude, 
              lon: longitude, 
              timestamp: timestamp, 
              streetName: streetName, 
              pointNumber: pointCount,
              pm25: pm25,
              j: prediction!['j'] ?? 0,
              i: prediction!['i'] ?? 0,
              gridTimeId: prediction!['gridTimeId'] ?? '2022-04-04-04-04-04',
            );
            
            final report = PositionReport(
              exposure  : pm25, 
              airQuality: airQualityAndColor[0], 
              timestamp : timestamp, 
              distance  : 0, 
              streetName: streetName,
              color     : airQualityAndColor[1]
              );

            final Map<String,dynamic> end =  {
              'latitude' : latitude,
              'longitude': longitude,
              'pm25'     : pm25,
            };

            await PrincipalDB.insertPoint(point);
            // await PrincipalDB.insertUpdatePointsWithCustomID(point, pointCount);
            await PrincipalDB.getNavigationAcumulatedPM25().then((accumulatedPM25) async {
                accumulatedPM25 += pm25;
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

      print('GRIDXY----> : FINAL RESPONSE ISSSSS:   $respondese');
      print('GRIDXY----> :  ${DateTime.now().toString()} lat: $latitude lon: $longitude streetName $streetName, routeID: $routeID, CantPoint $pointCount');

      if(respondese['error'] == null ){
        if(respondese['place_alerts'] != null){
          final List<Map<String,dynamic>> pollutionAlertData = respondese['place_alerts'].cast<Map<String,dynamic>>();
          await service.showNotification(
              id: 1,
              title: 'Lugar interesante',
              ongoin: false,
              autoCancel: true,
              indeterminate: false,
              body: respondese['place_alerts'].first['name']);
        }
        if(respondese['pollution_alerts'] != null){
          await service.showNotification(
              id: 2,
              ongoin: false,
              autoCancel: true,
              indeterminate: false,
              title: 'Alerta de contaminacion',
              body: 'Cuidado, lugar altamente contaminado');
        }
        
      } else if(respondese['error'] != null){
        // await authService.askForTokenUpdating(); //value['status'] == 401
        // add(OutOfAreaEvent());  // value['status'] == 403
        print('THE ERROR ISSS  ---${respondese["error"]}');
      }

      final lastTimeSend = await PrincipalDB.getNavigationLastTimeSent();
      final initTime = await PrincipalDB.getNavigationInitTime();

      if(initTime != null){
        final Duration duration = DateTime.now().difference(DateTime.parse(initTime));
        final double idealCantPoint = duration.inSeconds/5;
        print('killer--- $idealCantPoint');
        print('killer--- ${idealCantPoint > limitPoints}');
        if(idealCantPoint > limitPoints){
          await _postTrackingPoints();
          await PrincipalDB.clearNavigationDetail();
          // getOutOfApp();
          _stopForegroundTask();
        // print('END---->>> 3 BEFORE  getInternalTrackingEnd ');
        // await getPostInternalTrackingEnd().then((value) async {
        //   print('END---->>> 44444 innn  getInternalTrackingEnd ');
        //   await stopNavigation();
          
        //     getOutOfApp();
        
        // });
      }
      }

      if(lastTimeSend != null){
        final Duration duration = DateTime.now().difference(DateTime.parse(lastTimeSend));
        if(duration.inMinutes > 1){
          _postTrackingPoints();
        }
      }




    }

    return pm25;


  }


  // Future<void> _startLocator() async{
  //   Map<String, dynamic> data = {'countInit': 1};
  //   return await BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
  //       initCallback: LocationCallbackHandler.initCallback,
  //       initDataCallback: data,
  //       disposeCallback: LocationCallbackHandler.disposeCallback,
  //       iosSettings: IOSSettings(
  //           accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
  //       autoStop: false,
  //       androidSettings: AndroidSettings(
  //           accuracy: LocationAccuracy.NAVIGATION,
  //           interval: 5,
  //           distanceFilter: 0,
  //           client: LocationClient.google,
  //           androidNotificationSettings: AndroidNotificationSettings(
  //               notificationChannelName: 'Location tracking',
  //               notificationTitle: 'Start Location Tracking',
  //               notificationMsg: 'Track location in background',
  //               notificationBigMsg:
  //                   'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
  //               notificationIconColor: Colors.grey,
  //               notificationTapCallback:
  //                   LocationCallbackHandler.notificationCallback)));
  // }
  Future _routing({
    required double latitude, 
    required double longitude
    }) 
    async
    {
        final double startLatitude = latitude;
        final double startLongitude = longitude;

        final TrackingPoint actualPoint = TrackingPoint(startLatitude, startLongitude);
        final Map<String, dynamic> minDistanc = plannedRoute!.getMinDistances(actualPoint);
        final initInterval = minDistanc['segment'][0];
        final endInterval = minDistanc['segment'][1];
        final double endLatitude = navigatingData!.destinationLat; 
        final double endLongitude = navigatingData!.destinationLng;
        print('Min distance is endLatitude $endLatitude');
        print('Min distance is endLongitude $endLongitude');
        if(true){ // ALWAYS WILL SPEACK
        // if(navigationBloc.state.speakRoute){
          for (InstructionsModel instruction in navigationInstruction){
            if( initInterval >= instruction.initInterval && endInterval <= instruction.endInterval){
              print('Min distanceX actualInterval/InstructionInterval $initInterval/${instruction.initInterval} - $endInterval/${instruction.endInterval}  ');
              final double endLatitudeX =  myRoute[instruction.endInterval].latitude;
              final double endLongitudeX = myRoute[instruction.endInterval].longitude;
              final distance = Geolocator.distanceBetween(startLatitude,startLongitude,endLatitude,endLongitude);
              final distanceX = Geolocator.distanceBetween(startLatitude,startLongitude,endLatitudeX,endLongitudeX);
              final i = navigationInstruction.indexOf(instruction);
              final newInstructions = [...navigationInstruction];
              
              if(distanceX < 120 && distanceX > 80 && instruction.state == 0){
                print('Min distanceX MUST SPEAK 2222');
                final newInstruction = instruction.copyWith(state: 1);
                newInstructions[i] = newInstruction;
                navigationInstruction = [...newInstructions];
                final String newTextToSpeak = "En 100 metros, ${newInstructions[i+1].description}";
                tts.speakTts(newTextToSpeak);
                // instruction.state = 1;
              }
              if(distanceX < 40 && instruction.state != 2){
                print('Min distanceX MUST SPEAK 22222');
                final newInstruction = instruction.copyWith(state: 2);
                newInstructions[i] = newInstruction;
                navigationInstruction = [...newInstructions];
                tts.speakTts(newInstructions[i+1].description);

              }
              print('Min distanceX is minDistance $distance');
              print('Min distanceXXXX is minDistance $distanceX');
              break;
            }
          }
              
        }
        // ax >= bx
        // ay <= by

        print('Min distanceX is minDistance $minDistanc');
        
        print('Min distance is actualPointX ${actualPoint.x}');
        print('Min distance is actualPointY ${actualPoint.y}');
        print('Min distancex   ------- is min distance ${minDistanc['global_min_distance']*100000}');
        if(minDistanc['global_min_distance']*100000>30){
          print('Min distance OUT OF ROUTE');
          await setRouteWithPrediction(actualLatLng: LatLng(latitude, longitude));
          print('Min distance  WAITING');
        }
      
  }
  
  Future<bool> _askForTokenUpdating() async {
    bool response = false;
    try {
      print('GRIDXY----> to init BEFORE FIRABASE INSTANCE');
      final String? token = await auth.currentUser?.getIdToken();
      // To change it after initialization, use `setPersistence()`:
      print('GRIDXY----> to init ACTUAL TOKEN ${token ?? 'NO TOK'}');
      if(token != null){
        
        final String? lastTimeTokenUpdated = await PrincipalDB.getTimeFirebaseTokenUpdated();
        if (lastTimeTokenUpdated != null && lastTimeTokenUpdated != ''){
          final Duration duration = DateTime.now().difference(DateTime.parse(lastTimeTokenUpdated));
          final String previousToken =  await PrincipalDB.getFirebaseToken(); 
          print('GRIDXY----> to init PREVIOUS TOKEN IS 1 zz IS $previousToken'); 
          print('GRIDXY----> to init  TIME PASED ${duration.inMinutes}'); 
          // if(duration.inMinutes > 59){
            if(token != previousToken){
              print('GRIDXY----> to UPDATING TOKENNNNNNNN----***************'); 
              await PrincipalDB.firebaseToken(token);
              // PrincipalDB.firebaseToken = token;
              Preferences.isFirstTime = false;
              // Preferences.timeFirebaseTokenUpdated = DateTime.now().toString();
              response = true;
            } else if(duration.inMinutes > 59){
              print('GRIDXY----> to NOTTT UPDATED, TIME PASES IS ${duration.inMinutes}----***************'); 
              response = false;

            } else{
              print('GRIDXY----> to SAME TOKEN AS BEFORE AND TIME PASES IS ${duration.inMinutes}----***************'); 

              Preferences.isFirstTime = false;
              response = true;
            }
        } else{
          print('GRIDXY----> to UPDATING  NEWWWW TOKENNNNNNNN----***************'); 
          await PrincipalDB.firebaseToken(token);
          // PrincipalDB.firebaseToken = token;
          Preferences.isFirstTime = false;
          // Preferences.timeFirebaseTokenUpdated = DateTime.now().toString();
          response = true;
      } 
        
      } 
    } catch (e) {
      print('GRIDXY----> to init TOKENQQ ERROR IS $e');
      response = false;
    }
    return response;
  }




  Future<bool> _postTrackingPoints() async {
    int pointCount = await PrincipalDB.getNavigationCantPoint();
      // pointCount += 1;
      // Preferences.countPointSend += 1;
      bool response = false;
      final token = await PrincipalDB.getFirebaseToken();
      final routeID = await PrincipalDB.getNavigationID();
      final lastPointSend = await PrincipalDB.getNavigationNumPointToSent();
      if(lastPointSend != null){
        final listTosend = await PrincipalDB.getPointsToSend(lastPointSend);
        print('3error--------------->>>>> $listTosend');
        if(listTosend.isNotEmpty){
          await postTrackingPoints(
              routeId:  routeID,
              idToken:  token,
              points: listTosend,
              calculatedSegments: pointCount,
              notCalculatedSegments: 0 // TODO: FIX TO REAL DATA
              // pointCount: Preferences.countPointSend,
            ).then((value) async {
              if(value['status'] != null ){
                if(value['status'] == 200){
                  await PrincipalDB.navigationNumPointToSent(pointCount);
                  await PrincipalDB.navigationLastTimeSent(DateTime.now().toString());
                  response=true;
                } else if (value['status'] == 401){
                  await _askForTokenUpdating();
                } else if (value['status'] == 403){
                  // add(OutOfAreaEvent());
                }
              } else if(value['error'] != null){
              print('THE ERROR ISSS  ---${value["error"]}');
            }
            },);
          
        }
      }
    return response;

  }

    Future<Map<String, dynamic>> postTrackingPoints(
    {
      required String idToken,
      required String routeId,
      required List<Map<String,dynamic>> points,
      required int calculatedSegments,
      required int notCalculatedSegments,
    }
  ) async 
  {
      final Map<String, dynamic> navTracParams = {
        "route_id": routeId,
        "calculated_segments": calculatedSegments,
        "not_calculated_segments": notCalculatedSegments,
        "points" : points,
      };
      final Map<String, String> head = {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: idToken,
      }; 
      final url = Uri.https(Environment.baseUrlNav, '${Environment.unEncodedPathNav}/position/v2');    
    try{
      final resp = await http.post(url, headers: head, body: json.encode(navTracParams) );
      print('postTrackingPoints  Poinst send  $points');
      print('postTrackingPoints  Responde ${resp.body}');
      final decodedResp = json.decode(resp.body);
      try{
        
        return decodedResp;
      }on Exception catch (e){
        print('postTrackingPosition  NavigationService The error is 1111:______$e __________');
        return {'error':1};
    }
      
 
    } on Exception catch (e){
        print('postTrackingPosition NavigationService The error is 2222:_________$e _______');
        return {'error':2};
    }
  }



  Future<int> _gridUpdating() async{
    int returnVal = 400;
    final isTokenUpdated = await _askForTokenUpdating();
    final String token = await PrincipalDB.getFirebaseToken();
    final String? gridName = await PrincipalDB.getPredictionsGridName();
    print('GRIDXY---> grid init name $gridName');
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
    print('GRIDXY---> grid data ${resp["data"]}');
    print('GRIDXY---> grid name ${resp["name"]}');
    print('GRIDXY---> expiration date ${resp["expiration_date"]}');
  
    returnVal =  200;
  } else if(resp['error'] == 401) {
    await PrincipalDB.timeFirebaseTokenUpdated('');
    // final isTokenUpdated = await _askForTokenUpdating();
    print('GRIDXY---> to init ----------------TOKEN UPDATED ????????? $isTokenUpdated !!!!!!!!');
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
      try
      {
        final resp = await http.get(url, headers: head);
        final decodedResp = json.decode(resp.body);
        print('GRIDXY---> SINCE HERE IS THE RESPONSE --------------------');
        print('GRIDXY---> $decodedResp');
        print('GRIDXY---> HERE ENDS THE RESPONSE --------------------');
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
  Future<Map<String, dynamic>> getRouteWithPrediction({
    required String idToken,
    required String profile,
    required LatLng initCoor,
    required LatLng lastCoor,
  }) async 
  {
    final Map<String, String> head = {
      HttpHeaders.contentTypeHeader  : 'application/json',
      HttpHeaders.authorizationHeader: idToken,
    }; 
    final Map<String, dynamic> authData = {
      'profile'     : profile,
      'origin'      : "${initCoor.latitude}_${initCoor.longitude}",
      "end"         : "${lastCoor.latitude}_${lastCoor.longitude}",
      "instructions": true,

    };
    print('getRouteWithPrediction $authData');
    final url = Uri.https(Environment.baseUrl, Environment.unEncodedPathRoute);
    try{
      final resp = await http.post(url, headers: head, body: json.encode(authData));

      print('-----------SINCE HERE --------');
      
      final Map<String, dynamic> decodedResp = json.decode(resp.body);
      print('Routing----> data, body: ${resp.body} ');
      if (decodedResp['status'] == 200) {
        return decodedResp['response'];
      }
      else{
        return {'error': 0};
      }
    } on Exception catch (e){
      return {'error': 1};
    }

  }
  
  Future<bool> setRouteWithPrediction({
    required LatLng actualLatLng
  }) async
  {
    // Future<bool> setRouteWithPrediction({required LatLng start, required LatLng end}) async{
    bool response = false;
    final token = await PrincipalDB.getFirebaseToken();
    final resp6 =  await getRouteWithPrediction(
      initCoor: actualLatLng,
      lastCoor: LatLng(navigatingData!.destinationLat, navigatingData!.destinationLng), 
      profile: navigatingData!.profile,
      idToken: token,
      ); 


    if(resp6['error'] == null){
        final latLngList = resp6['points'].map((coors) => LatLng(coors[1], coors[0])).toList();
        myRoute = latLngList.cast<LatLng>();
        List<TrackingPoint> plannedRoutePoints = [];
        for (var point in myRoute) {plannedRoutePoints.add(TrackingPoint(point.latitude,point.longitude));}
        plannedRoute = TrackingRoute(plannedRoutePoints);
        final instructionsList = resp6['instructions'].map((instructions) => InstructionsModel.fromMap(instructions)).toList();
        final List<InstructionsModel> instructions = instructionsList.cast<InstructionsModel>();
        print('Routing----> destiny is points: ${myRoute.length}');
        print('Routing----> destiny is points: $myRoute');
        print('Routing----> destiny instructions: $instructions');
      navigationInstruction = [...instructions];
      // locationBloc.add(AddMyRoute(points));  
      response = true;
    } else if(resp6['error'] != null){
      print('THE ERROR ISSS  ---${resp6["error"]}');
    } 
    print('Routing----> destiny ALL OKKKKKK-------->>>>>>');
    return response;
  }

 

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    await PrincipalDB.init();

    final navID = await PrincipalDB.getNavigationID();
    final navState = await PrincipalDB.getNavigationState();
    // if(Preferences.routeId != ''){
    if(navID != '' && navState < 22){
      print('POINTCANT---> BACK GRIDXY----> Will runn on BACK, THE navID is: $navID');
      await Firebase.initializeApp();
      await Preferences.init();
      auth = FirebaseAuth.instance;
      _sendPort = sendPort;
      navigatingData = await PrincipalDB.getStartNavigationDetails();
      print('POINTCANT--->    Routing----> destiny ---${navigatingData?.profile ?? "NO PROFILE"}----->>>>>>');
      print('POINTCANT--->    Routing----> destiny ---${navigatingData?.mode ?? "NO PROFILE"}----->>>>>>');
      
      // You can use the getData function to get the stored data.
      final customData = await FlutterForegroundTask.getData<String>(key: 'customData');
      
      print('customData: $customData --> ${DateTime.now().toString()}');
      // _location = Location();
      // _location.enableBackgroundMode(enable: true); // recent commented

      /// TTS 
      tts = TtsApi();
      tts.initTts();
      service = NotificationApi();
      service.initialize();
      
      runOnback = true;
    } else{
      print('POINTCANT---> BACK GRIDXY----> Will NOOOOOTT   runn on BACK, THE navID is: $navID');
      runOnback = false;
    }
    // Geolocator.getPositionStream().listen((event) {
    //   location = event;

    // });

  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    final double pm25 = await _navigationDataSaver();
    FlutterForegroundTask.updateService(
      notificationTitle: 'Respira Lima',
      notificationText: 'Tu exposición PM2.5: $pm25',
    );
    // Send data to the main isolate.
    sendPort?.send(pm25);

    _eventCount++;
    print('Count:  $_eventCount,   $pm25');
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




Future<bool> _stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
}


class MapScreenAndroid extends StatefulWidget {
  // To use it life cycle
  static String pageRoute = 'MapScreenAndroid';
  const MapScreenAndroid({Key? key}) : super(key: key);
  @override
  State<MapScreenAndroid> createState() => _MapScreenAndroidState();
}

class _MapScreenAndroidState extends State<MapScreenAndroid> with WidgetsBindingObserver {
  // StreamSubscription<Position>? positionStreamX;
  // int onStart = 0;
  late DraggableScrollableController _draggableScrollableController;
  late LocationBloc locationBloc;
  // late SocketService socketService;
  late NavigationBloc navigationBloc;
  late AppDataBloc appDataBloc;
  late UserAppDataBloc userAppDataBloc;
  late MapBloc mapBloc;

  TileOverlay? _tileOverlay;
  // late Timer timer;
  bool waitingForResponse = false;
  bool nowIsInBack = false;
  bool _restartApp = false;
  late Timer timerForRestartUpp;



  /// 1...........................
  /// 1...........................
  ReceivePort? _receivePort;

  
  // late Location _location;

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }


  @override
  void initState() {
    super.initState();
    locationBloc = BlocProvider.of<LocationBloc>(context);
    mapBloc = BlocProvider.of<MapBloc>(context, listen: false);
    navigationBloc = BlocProvider.of<NavigationBloc>(context, listen: false);
    appDataBloc = BlocProvider.of<AppDataBloc>(context, listen: false);
    userAppDataBloc = BlocProvider.of<UserAppDataBloc>(context, listen: false);
    // locationBloc.getCurrentPosition();
    print('location start Following FROM MAP_SCREEN_ANDROID');
    locationBloc.startFollowingUser();
    
    _addTileOverlay();

    WidgetsBinding.instance.addObserver(this); // Adding an observer

    _draggableScrollableController = DraggableScrollableController();

    _stopForegroundTask();


    timerForRestartUpp = Timer(const Duration(seconds: 6), (() {
      setState(() {
        _restartApp = true;
      });
    }));
    
    
  }
  void _restartDB()async{
    print('POINTCANT--->      DB 1');
    await PrincipalDB.getNavigationID().then((token)async{
      print('POINTCANT--->      DB 2');
      if(token != ''){
        print('POINTCANT--->      DB 3');
        await PrincipalDB.reopenDB();
        print('POINTCANT--->      DB 4');
      }
      print('POINTCANT--->      DB 5');
      
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('STATE IS $state !!!!');
    print('STATE IS ${state.name} !!!!');
    // setTimer(state != AppLifecycleState.resumed);
    if(state.name == 'resumed'){
      
      WidgetsFlutterBinding.ensureInitialized();
      _restartDB();
      locationBloc.add(OnForegroundEvent());
    } else if(state.name == 'paused'){
      if(navigationBloc.state.isNavigating || navigationBloc.state.navigationState == 2){
        print('2error--->> BACK NATIVIGATION');
        locationBloc.add(OnBackgroundEvent());
      } else{
        print('2error--->> BACK NOOOOO NATIVIGATION    STATE:${navigationBloc.state.navigationState}');
        if(userAppDataBloc.state.selectingPic){
          locationBloc.add(const OnBackgroundNoNavigationEvent(timeWait: 300));
        } else{
          locationBloc.add(OnBackgroundNoNavigationEvent(timeWait: navigationBloc.state.navigationState == 3 ? 30 : 5));
        }
      }
      print('POINTCANT--->       STATE IS MINIMIZED');
    } else if(state.name == 'detached'){
      print('POINTCANT--->       STATE IS CLOSED');
    } else{
      print('POINTCANT--->       STATE IS FFF');
    }
  }

  @override
  void dispose() {
    locationBloc.stopFollowingUser();
    timerForRestartUpp.cancel();
    WidgetsBinding.instance.removeObserver(this); // Removing an observer
    _draggableScrollableController.dispose();
    super.dispose();
    /// 1..........................
    /// 1..........................
    _closeReceivePort();
    /// 1..........................
    /// 1..........................
    print('POINTCANT---> DISPOSEEEEEEEE');
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
    locationBloc.add(OnForegroundEvent());

    return MaterialApp(
    // A widget to start the foreground service when the app is minimized or closed.
    // This widget must be declared above the [Scaffold] widget.
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightThem,
    home: WillStartForegroundTask(
      onWillStart: () async
      //  {return true;},
      {
        // Return whether to start the foreground service.
        final String navID = await PrincipalDB.getNavigationID();
        final int navState = await PrincipalDB.getNavigationState();
        if(navID != '' && navState < 22){
          // locationBloc.add(OnBackgroundEvent());
          return true;
        } else {
          return false;
        } 
        // return true;
      },
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription: 'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'stat_bid_app',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        autoRunOnBoot: false,
        allowWifiLock: false,
      ),
      notificationTitle: 'Foreground Service is running',
      notificationText: 'Tap to return to the app',
      callback: startCallbackAndroid,
      child: Scaffold(
      // resizeToAvoidBottomInset: false,
      key: _globalKey,
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, locationstate) {
          if (locationstate.lastKnownLocation == null) {
            return Center(child: 
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Cargando el mapa...'),
                const SizedBox(height: 30,),
                _restartApp ? MaterialButton(
                onPressed: () {
                  if (isAndroid) {
                    Restart.restartApp();
                  } else {
                    Phoenix.rebirth(context); 
                  }
                },
                splashColor: Colors.transparent,
                color: AppTheme.blue,
                elevation: 0,
                shape: const StadiumBorder(),
                child: const Text('Reiniciar app',
                    style: TextStyle(color: Colors.white)),
              ) :
              const SizedBox(),
              ],
            ));
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


                    // BottomModalSheet(
                    //   areaScreen: areaScreen,
                    //   callbackStart: _startForegroundTask,
                    //   callbackEnd: _stopForegroundTask,
                    //   ),
                    BtnCompass(globalKey: _globalKey),
                    _bottomModalSheet(areaScreen),
                    NavigationModeSheet(areaScreen: areaScreen),

                    mapState.isLoading
                        ? LoadingAlert(
                            screenSize: areaScreen,
                          )
                        : const SizedBox(),
                    const AlertOutOfArea(),
                    const AlertPollution(),
                    const AlertPlaces(),
                    // const AlertScreenOn(),
                    BtnSettings(globalKey: _globalKey),
                    PlaceAlertInformation(screenSize: areaScreen),
                    RatingAlert(
                      screenSize: areaScreen,
                    ),
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
    ),
      
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
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    //  const HeaderSpeacker(),
                                //  const SizedBox(width: 5,),
                    SizedBox(
                      width: 160,
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
                                                  // ? 'min (${state.navigationDataToShowTracking.last.distance.toString()}km) al ${(state.dataPercent*100).round()}%'
                                                  : '',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: AppTheme.gray80,
                                                  fontSize: 10),
                                            ),
                                          ],
                                        ),
                                ),
                                // Text(
                                //   // TODO: ASK WHAT DISTANCE TO SHOWN
                                //   state.navigationDataToShowTracking
                                //           .isNotEmpty
                                //       ? 'Data al ${(state.dataPercent*100).round()}%'
                                //       : '',
                                //   style: const TextStyle(
                                //       fontWeight: FontWeight.w500,
                                //       color: AppTheme.gray80,
                                //       fontSize: 10),
                                // ),
                              ],
                      ),
                    ),
                    navigationBloc.state.navigationMode == 'ruteo' ? const HeaderSpeacker() : const SizedBox(),
                    // const Expanded(
                    //   child: SizedBox(
                    //     width: 10,
                    //   ),
                    // ),
                    BtnEndNavigation(
                      text: ' Finalizar',
                      btnColor: state.navLoading
                      ? AppTheme.gray50
                      : AppTheme.primaryOrange,
                      icon: Icons.near_me_rounded ,
                      onPressed: state.navLoading
                      ?() {}
                      : () async {
                        await _stopForegroundTask();
                        mapBloc.add(OnStartLoading());
                        await navigationBloc.onlyStopNavigation();
                        mapBloc.add(RemoveNavigationPolylinesAndMarkers());
                        // _stopForegroundTask();
                        print('END---->>> 1 BEFORE  postTrackingPositionMikel ');
                        await navigationBloc.postTrackingPositionMikel();
                        print('END---->>> 2 BEFORE  postTrackingPoints ');
                        await navigationBloc.postTrackingPoints();
                        print('END---->>> 3 BEFORE  getInternalTrackingEnd ');
                        await navigationBloc.getPostInternalTrackingEnd().then((value) async{
                          print('END---->>> 44444 innn  getInternalTrackingEnd ');
                          await navigationBloc.stopNavigation();
                        });
                        print('END---->>> 5 ENDDDDDD');
                        mapBloc.add(OnStopLoading());
                      },
                    ),
                  ],
                ),
              ),
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
            
            // Container(
            //   height: 1,
            //   width: double.infinity,
            //   color: AppTheme.gray30,
            // ),
            LinearPercentIndicator(
              lineHeight: 1,
              animation: true,
              animationDuration: 1000,
              // lineHeight: 20.0,
      
              percent: navigationBloc.state.dataPercent,
              // center: Text("20.0%"),
              progressColor: AppTheme.primaryBlue,
              backgroundColor: AppTheme.lightRed,
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

class ListaItemsAndroid extends StatelessWidget {
  final ScrollController scrollController;

  final items = List.filled(40, null, growable: false);

  ListaItemsAndroid(this.scrollController, {super.key});

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

