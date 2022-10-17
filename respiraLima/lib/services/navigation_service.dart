import 'dart:convert';
import 'dart:io';

import 'package:app4/alerts/alets.dart';
import 'package:app4/db/db.dart';
import 'package:app4/global/enviroment.dart';
import 'package:app4/grid/grid.dart';
import 'package:app4/models/models.dart';
import 'package:app4/sensors_props/sensors_props.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:http/http.dart' as http;
import 'package:app4/route_tracking/route_tracking.dart';


class NavigationService extends ChangeNotifier {

  Future<Map<String, dynamic>> isOnTheArea(
    {
      required String idToken,
      required LatLng coordinates,
    }
    ) async {
    final Map<String, dynamic> isValidParams = {
      "coordinates": '${coordinates.latitude}_${coordinates.longitude}',
    };
    final Map<String, String> head = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: idToken,
    }; 
    final url = Uri.https(Environment.baseUrlNav, '${Environment.unEncodedPathNav}/valid_coordinates', isValidParams);    
    try{
        final resp = await http.get(url, headers: head);

        print('postTrackingStart  NavigationService ${resp.body}');
        final decodedResp = json.decode(resp.body);
        try{
          // {"response":{"valid":true},"status":200}

          return decodedResp;
        }on Exception catch (e){
          print('postTrackingStart  NavigationService The error is 1111:______$e __________');
          return {'error':1};
      }
        
  
      } on Exception catch (e){
          print('postTrackingStart NavigationService The error is 2222:_________$e _______');
          return {'error':2};
      }
  }

  Future<Map<String, dynamic>> postTrackingStartMikel({
    required String idToken,
    required String streetName, //TODO: NUEVO PARAMETRO
    required String navigationMode,
    required String navigationWay,
    required String startTime,
    required LatLng coordinates,
    String destination = '',
  }) async {
    final Map<String, dynamic> navStartParams = {
      "profile": navigationWay,
      "mode": navigationMode,
      "start_timestamp": startTime,
      "start_street_name": streetName,
      "start_coordinates": '${coordinates.latitude}_${coordinates.longitude}',
      "destination_label": destination == '' ? null : destination,
    };
    final Map<String, String> head = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: idToken,
    };
    final url = Uri.https(
        Environment.baseUrlNav, '${Environment.unEncodedPathNav}/start/v2');
    print('settingStreetName  postTrackingStart NavigationService $navStartParams');
    print('settingStreetName  postTrackingStart  NavigationService $url');
    try {
      final resp =
          await http.post(url, headers: head, body: json.encode(navStartParams));
      print('settingStreetName postTrackingStart  NavigationService ${resp.body}');
      final decodedResp = json.decode(resp.body);
      try {
        // {"response":{"route_id":"8G5UBBBpiA84YrNbuBhO"},"status":200}

        // TODO: se debe guardar en db local el timestamp de inicion de la ruta
        if(decodedResp["status"] == 200){
          String routeId = decodedResp["response"]["route_id"];
          RouteMi currentRoute = RouteMi(routeId);
          currentRoute.start(startTime, streetName);
          return decodedResp;

        } else{
          return {'error': 0};
        }

      } on Exception catch (e) {
        print('settingStreetName postTrackingStart  NavigationService The error is 1111:__$e ____');
        return {'error': 1};
      }
    } on Exception catch (e) {
      print('settingStreetName postTrackingStart NavigationService The error is 2222:___$e ___');
      return {'error': 2};
    }
}



Future<Map<String, dynamic>> postTrackingPositionMikelV2({
  required String routeId,
  required String streetName, //TODO: NUEVO PARAMETRO
  required LatLng coordinates,
  required String timestamp,
  required int pointCount,
}) async {
  try {
    print('mikel res -- pointCount $pointCount');
    Map<String, dynamic> respondese = {'error': 0, 'detail': 'No data'};
    Map<String, dynamic>? previousPrediction = null;
    Map<String, dynamic>? prediction = null;
    NavigationPredictions predictions = NavigationPredictions();
    // I have the currente pm25
    await predictions.getCoordinatesPrediction(coordinates).then((value) {
      if(value['error'] == null){
        prediction = value;
      } else{
        respondese = {'error': 1, 'detail': 'out of area'};
      }
    });
    // TODO: GET THE PREVIOUS PM25
    if(prediction != null){
      if(pointCount > 0){
        // await PrincipalDB.findPointById(pointCount-1).then((value) async {
        await PrincipalDB.getAllPoints().then((value) async {
          if(value != null && value.isNotEmpty){
            final Map<String,dynamic> start =  {
                'latitude' : value.last.lat,
                'longitude': value.last.lon,
                'pm25'     : value.last.pm25,
              };
            
            final Map<String,dynamic> end =  {
                'latitude' : coordinates.latitude,
                'longitude': coordinates.longitude,
                'pm25'     : prediction!['pm_25'],
              };
            
            final segment = SegmentModel(
              startPoint: start,
              endPoint: end
              );


            final PM25 _pm25 = PM25();

            final List<String> airQualityAndColor =
              _pm25.get_category_and_color_hex(prediction!['pm_25']);
            final String airQuality = airQualityAndColor[0];
            final String color = airQualityAndColor[1];
            final double pm25 = segment.pm25();
            final double distanceKm = segment.distance_km();
            
            final point = PointModel(
              lat: coordinates.latitude, 
              lon: coordinates.longitude, 
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
              accumulatedDistance += distanceKm;
              await PrincipalDB.navigationAcumulatedDistance(accumulatedDistance);
              final double distanceRound = double.parse(accumulatedDistance.toStringAsFixed(1));
              final report = PositionReport(
                // exposure  : 10, 
                exposure  : segment.pm25(), 
                airQuality: airQuality, 
                timestamp : timestamp, 
                // distance  : 10, 
                distance  : distanceRound, 
                streetName: streetName,
                color     : color
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
            respondese = {'error': 2, 'detail': 'out of area'};
            // TODO: THE SAME AS THE NEXT ELSE
          }
        });
      } else {
          final PM25 _pm25 = PM25();
          List<String> airQualityAndColor =
            _pm25.get_category_and_color_hex(prediction!['pm_25']);
          String airQuality = airQualityAndColor[0];
          String color = airQualityAndColor[1];
          final point = PointModel(
            lat: coordinates.latitude, 
            lon: coordinates.longitude, 
            timestamp: timestamp, 
            streetName: streetName, 
            pointNumber: pointCount,
            pm25: prediction!['pm_25'],
          );
          final report = PositionReport(
            exposure  : prediction!['pm_25'], 
            airQuality: airQuality, 
            timestamp : timestamp, 
            distance  : 0, 
            streetName: streetName,
            color     : color
            );
          final Map<String,dynamic> end =  {
            'latitude' : coordinates.latitude,
            'longitude': coordinates.longitude,
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
    return respondese;

  } on Exception catch (e) {
    print(
        'postTrackingPosition  NavigationService The error is 1111:__$e ____');
    return {'error': 1};
  }
}


Future<Map<String, dynamic>> getInternalTrackingEnd({
  required String idToken,
  required String routeId,
  required String streetName, //TODO: NUEVO PARAMETRO
  required LatLng endCoordinates,
  required String endTimestamp,
}) async {
    try {
      // TODO: SEND THE REPORT TO THE BACKEND

      final numPoint = await PrincipalDB.getNavigationCantPoint();
      final accumPM25 = await PrincipalDB.getNavigationAcumulatedPM25();
      print('numpoint Removing -----$numPoint');
      print('accumPM25 Removing -----$accumPM25');
      double? accumDistance;
      //TODO: CORRECT THE DISTANCE CALC
      await PrincipalDB.getNavigationAcumulatedDistance().then((value) {
        accumDistance = double.tryParse((value).toStringAsFixed(2));
      });

      Duration? duration;
      final initialInfo = await PrincipalDB.getNavigationInitialInformation();
      if(initialInfo != null){
        duration = DateTime.now().difference(DateTime.parse(initialInfo.timestamp));
      }
      
      final averagePM25 = double.parse((accumPM25/numPoint).toStringAsFixed(2));
      final PM25 _pm25 = PM25();
          List<String> airQualityAndColor =
            _pm25.get_category_and_color_hex(averagePM25);
          String airQuality = airQualityAndColor[0];
          String color = airQualityAndColor[1];

      final Map<String,dynamic> report = {
        "exposure"          : averagePM25,
        "air_quality"       : airQuality,
        "color"             : color,
        "total_time"        : duration?.inMinutes ?? 0,
        "distance"          : accumDistance ?? 0,
        "start_street_name" : initialInfo?.streetName ?? 'SN',
        "end_street_name"   : streetName
      };
      print('Final report is ---->>>> $report');
      return report;

    } on Exception catch (e) {
      print(
          'postTrackingEnd NavigationService The error is 2222:_________$e _______');
      return {'error': 2};
    }
}





  Future<Map<String, dynamic>> postTrackingStart(
    {
      required String idToken,
      required String navigationMode,
      required String navigationWay,
      required String startTime,
      required LatLng coordinates,
      String destination = '',
    }
  ) async {
      final Map<String, dynamic> navStartParams = {
        "profile": navigationWay,
        "mode":navigationMode ,
        "start_timestamp":startTime,
        "start_coordinates": '${coordinates.latitude}_${coordinates.longitude}',
        "destination_label": destination == '' ? null : destination,
      };
      print('The starttime is: $startTime');
      print(startTime.runtimeType);
      final Map<String, String> head = {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: idToken,
      }; 
      final url = Uri.https(Environment.baseUrlNav, '${Environment.unEncodedPathNav}/start');    
try{
      final resp = await http.post(url, headers: head, body: json.encode(navStartParams));

      print('postTrackingStart  NavigationService ${resp.body}');
      final decodedResp = json.decode(resp.body);
      try{
        // {"response":{"route_id":"8G5UBBBpiA84YrNbuBhO"},"status":200}
        return decodedResp;
      }on Exception catch (e){
        print('postTrackingStart  NavigationService The error is 1111:______$e __________');
        return {'error':1};
    }
      
 
    } on Exception catch (e){
        print('postTrackingStart NavigationService The error is 2222:_________$e _______');
        return {'error':2};
    }
  }





  Future<Map<String, dynamic>> postTrackingPoints(
    {
      required String idToken,
      required String routeId,
      required List<Map<String,dynamic>> points,
      required int calculatedSegments,
      required int notCalculatedSegments,
    }
  ) async {
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

  

  Future<Map<String, dynamic>> postTrackingReportEnd(
    {
      required String idToken,
      required String routeId,
      required LatLng endCoordinates,
      required String endTimestamp,
      required String endStreetName,
      required double exposure,
      required String airQuality,
      required String color,
      required double distance,
      required int totalTime,
    }
  ) async {
      final Map<String, dynamic> navEndParams = {
        "route_id": routeId,
        "end_coordinates": '${endCoordinates.latitude}_${endCoordinates.longitude}',
        "end_timestamp": endTimestamp,
        "end_street_name": endStreetName,
        "exposure" : exposure,
        "air_quality" : airQuality,
        "color" : color,
        "distance" : distance,
        "total_time" : totalTime,
      };
      final Map<String, String> head = {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: idToken,
      }; 
      final url = Uri.https(Environment.baseUrlNav, '${Environment.unEncodedPathNav}/end/v2');  
      print('settingStreetName  postTrackingEnd NavigationService $navEndParams');
      print('settingStreetName postTrackingEnd  NavigationService $url');

    try{
      final resp = await http.post(url, headers: head, body: json.encode(navEndParams));

      print('settingStreetName postTrackingEnd  responde ${resp.body}');
      final decodedResp = json.decode(resp.body);
      print('settingStreetName postTrackingEnd  decorde $decodedResp');
      try{
        return decodedResp;
      }on Exception catch (e){
        print('settingStreetName postTrackingEnd  NavigationService The error is 1111:______$e __________');
        return {'error':1};
    }
      
 
    } on Exception catch (e){
        print('settingStreetName  postTrackingEnd NavigationService The error is 2222:_________$e _______');
        return {'error':2};
    }
  }




  Future<Map<String, dynamic>> postTrackingScore(
    {
      required String idToken,
      required String routeId,
      required double score,
    }
  ) async {
      final Map<String, dynamic> navEndParams = {
        "route_id": routeId,
        "score": score,
      };
      final Map<String, String> head = {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: idToken,
      }; 
      final url = Uri.https(Environment.baseUrlNav, '${Environment.unEncodedPathNav}/score');    
  try{
      final resp = await http.post(url, headers: head, body: json.encode(navEndParams));

      print('postTrackingScore  NavigationService ${resp.body}');
      print('postTrackingScore  NavigationService ${resp.body}');
      final decodedResp = json.decode(resp.body);
      try{
        return decodedResp;
      }on Exception catch (e){
        print('postTrackingScore  NavigationService The error is 1111:______$e __________');
        return {'error':1};
    }
      
 
    } on Exception catch (e){
        print('postTrackingScore NavigationService The error is 2222:_________$e _______');
        return {'error':2};
    }
  }
  Future<Map<String, dynamic>> getTrackingHistory(
    {
      required String idToken,
    }
  ) async {
      final Map<String, String> head = {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: idToken,
      }; 
      final url = Uri.https(Environment.baseUrlNav, '${Environment.unEncodedPathNav}/history');    
  try{
      final resp = await http.get(url, headers: head);

      print('getTrackingHistory 0 NavigationService ${resp.body}');
      print('getTrackingHistory 0 NavigationService ${resp.body}');
      final decodedResp = json.decode(resp.body);
      try{
        return decodedResp;
      }on Exception catch (e){
        print('getTrackingHistory 0 NavigationService The error is 1111:______$e __________');
        return {'error':1};
    }
      
 
    } on Exception catch (e){
        print('getTrackingHistory 0 NavigationService The error is 2222:_________$e _______');
        return {'error':2};
    }
  }
}