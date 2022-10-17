import 'dart:convert';
import 'dart:io';

import 'package:app4/global/enviroment.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapService extends ChangeNotifier {





  Future<Map<String, dynamic>> getGridLimits({  // Limits for painting polilines
    required String idToken, 
    }) async {

    final Map<String, String> head = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: idToken,
      }; 
    final url = Uri.https(Environment.baseUrlMap, '${Environment.unEncodedPathMap}/grid-limits'); 
    try{
      final resp = await http.get(url, headers: head);
      final decodedResp = json.decode(resp.body);
      print('Grid limit body ${resp.body}');
      print('Grid limit decoded $decodedResp');
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
  Future<Map<String, dynamic>> getAllPolylines4Coordinates({ 
    required String idToken,
    required String type, 
    required String format, 
    LatLng? upLeft, 
    LatLng? downRight, 
    LatLng? upRight, 
    LatLng? downLeft, 
    }) async {
    final Map<String, dynamic> mapParams = {
      'type': type,
      'format': format,
      'up_left': upLeft != null ? '${upLeft.latitude}_${upLeft.longitude}' : '0.0_0.0',
      'down_right': downRight != null ? '${downRight.latitude}_${downRight.longitude}' : '0.0_0.0',
      'up_right': upRight != null ? '${upRight.latitude}_${upRight.longitude}' : '0.0_0.0',
      'down_left': downLeft != null ? '${downLeft.latitude}_${downLeft.longitude}' : '0.0_0.0',

      
    };
    final Map<String, String> head = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: idToken,
      }; 
    final url = Uri.https(Environment.baseUrlMap, '${Environment.unEncodedPathMap}/predictions', mapParams); 
    print('This is the value url $url');

    try{
      final resp = await http.get(url, headers: head);

      // final Map<String, dynamic> decodeResp = json.decode(resp.body);
      print('This is the value -----------SINCE HERE --------');
      print('URL IS-------');
      print(resp);
      print(resp.body);
      print('This is the value ----------------------== BOSY TYPE==-----------------');
      print(resp.body.runtimeType);
      final decodedResp = json.decode(resp.body);
      print(resp.body);
      try{
        // final Map<String,dynamic> finalDecoded = decodedResp?.castMap<String,dynamic>() ?? {'error':0};

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
        print('This is the value The error is 1111:______$e __________');
        print(e);
        return {'error':2};
    }
      
 
    } on Exception catch (e){
        print('This is the value The error is 2222:________$e ________');
        print(e);
        return {'error':3};
    }
  }

}

