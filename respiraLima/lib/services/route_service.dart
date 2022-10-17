
import 'dart:convert';
import 'dart:io';

import 'package:app4/global/enviroment.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
class RouteService extends ChangeNotifier {



  Future<Map<String, dynamic>> getRouteWithPredictionPRO({
    required String idToken,
    required String profile,
    required LatLng initCoor,
    required LatLng lastCoor,
  }) async {
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
    final url = Uri.https(Environment.baseUrl, '${Environment.unEncodedPathRoute}/compute');
    try{
      final resp = await http.post(url, headers: head, body: json.encode(authData));

      print('-----------SINCE HERE --------');
      
      final Map<String, dynamic> decodedResp = json.decode(resp.body);
      print('Routing data, xxxxPRO body: ${resp.body} ');
      print('Routing data, XXXX PRO body: $decodedResp');
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
  Future<Map<String, dynamic>> getRouteWithPrediction({
    required String idToken,
    required String profile,
    required LatLng initCoor,
    required LatLng lastCoor,
  }) async {
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
    final url = Uri.https(Environment.baseUrl, '${Environment.unEncodedPathRoute}/compute');
    try{
      final resp = await http.post(url, headers: head, body: json.encode(authData));

      print('-----------SINCE HERE --------');
      
      final Map<String, dynamic> decodedResp = json.decode(resp.body);
      print('Routing data, body: ${resp.body} ');
      print('Routing data, body: $decodedResp');
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
}