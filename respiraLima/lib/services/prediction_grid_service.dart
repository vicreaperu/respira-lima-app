import 'dart:convert';
import 'dart:io';

import 'package:app4/global/enviroment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PredictionsGridService extends ChangeNotifier {

  Future<Map<String, dynamic>> getAllPredictionsGridV2({  // Limits for painting polilines
    required String idToken, 
    String? gridName,
    }) async {
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
  Future<Map<String, dynamic>> getAllPredictionsGrid({  // Limits for painting polilines
    required String idToken, 
    }) async {

    final Map<String, String> head = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: idToken,
      }; 
    final url = Uri.https(Environment.baseUrl, '${Environment.unEncodedPathGrid}/grid_data'); 
    try{
      final resp = await http.get(url, headers: head);
      final decodedResp = json.decode(resp.body);

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
  

}

