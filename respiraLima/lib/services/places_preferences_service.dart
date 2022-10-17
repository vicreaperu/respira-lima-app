import 'dart:convert';
import 'dart:io';

import 'package:app4/global/enviroment.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
class PlacesPreferencesService extends ChangeNotifier {


  Future<Map<String, dynamic>> postPlacePreferencesLikeScore(
    {
      required String idToken,
      required String placeId,
      required bool like,
      required double score,

    }
  ) async {
      final Map<String, dynamic> navStartParams = {
        "place_id": placeId,
        "like":like ,
        "score":score,
      };

      final Map<String, String> head = {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: idToken,
      }; 
      final url = Uri.https(Environment.baseUrlNav, '${Environment.unEncodedPathPlaces}/preferences');    
try{
      final resp = await http.post(url, headers: head, body: json.encode(navStartParams));

      print('postPlacesPreferencesLikeScore   ${resp.body}');
      final decodedResp = json.decode(resp.body);
      try{
        // {"response":{"route_id":"8G5UBBBpiA84YrNbuBhO"},"status":200}
        return decodedResp;
      }on Exception catch (e){
        print('postPlacesPreferencesLikeScore   The error is 1111:______$e __________');
        return {'error':1};
    }
      
 
    } on Exception catch (e){
        print('postPlacesPreferencesLikeScore  The error is 2222:_________$e _______');
        return {'error':2};
    }
  }
  Future<Map<String, dynamic>> getPlacePreferencesLikeScore(
    {
      required String idToken,
      required String placeID,
    }
  ) async {
      final Map<String, String> head = {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: idToken,
      }; 
      final Map<String,dynamic> moduleInfo = {
        'place_id': placeID,
      };
      final url = Uri.https(Environment.baseUrlNav, '${Environment.unEncodedPathPlaces}/preferences', moduleInfo);    
  try{
      final resp = await http.get(url, headers: head);

      print('getPlacePreferencesLikeScore  ${resp.body}');
      final decodedResp = json.decode(resp.body);
      print('getPlacePreferencesLikeScore deCODED ${decodedResp.values}');
      print('getPlacePreferencesLikeScore deCODED ${decodedResp.keys}');
      try{
        return decodedResp;
      }on Exception catch (e){
        print('getPlacePreferencesLikeScore 0 NavigationService The error is 1111:______$e __________');
        return {'error':1};
    }
      
 
    } on Exception catch (e){
        print('getPlacePreferencesLikeScore 0 NavigationService The error is 2222:_________$e _______');
        return {'error':2};
    }
  }
}