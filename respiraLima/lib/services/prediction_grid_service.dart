import 'dart:convert';
import 'dart:io';

import 'package:app4/global/enviroment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PredictionsGridService extends ChangeNotifier {

  Future<Map<String, dynamic>> getAllPredictionsGrid({  // Limits for painting polilines
    required String idToken, 
    }) async {

    final Map<String, String> head = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: idToken,
      }; 
    final url = Uri.https(Environment.baseUrl, '${Environment.unEncodedPathGrid}/grid_data'); 
    try{
      print('Grid Pred. url $url');
      final resp = await http.get(url, headers: head);
      final decodedResp = json.decode(resp.body);
      print('Grid Pred. body ${resp.body}');
      print('Grid pred. decoded $decodedResp');
      try{
        if(decodedResp['status'] != null){
          if(decodedResp['status'] == 200){
            final Map<String,dynamic> finalDecoded = decodedResp["response"] ?? {'error':0};
            print('Grid Pred. $finalDecoded');
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

