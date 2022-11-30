import 'dart:convert';
import 'dart:io';

import 'package:app4/global/enviroment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserAppInformationService extends ChangeNotifier {

  Future<Map<String, dynamic>> getPoliticsAndQuestions(
    // {  // Limits for painting polilines
    // required String idToken, 
    // }
    ) async {

    final Map<String, String> head = {
      HttpHeaders.contentTypeHeader: 'application/json',
      // HttpHeaders.authorizationHeader: idToken,
      }; 
    final url = Uri.https(Environment.baseUrl, '${Environment.unEncodedPathAppData}/settings'); 
    try{
      final resp = await http.get(url, headers: head);
      final decodedResp = json.decode(resp.body);
      print('appData---> SINCE HERE IS THE RESPONSE --------------------');
      print('appData---> $decodedResp');
      print('appData---> HERE ENDS THE RESPONSE --------------------');
      try{
        if(decodedResp['status'] != null){
          if(decodedResp['status'] == 200){
            final Map<String,dynamic> finalDecoded = decodedResp["response"] ?? {'error':0};
            print('appData---> ${finalDecoded.keys}');
            print('appData---> ${finalDecoded.values}');
            print('appData---> interest link ${finalDecoded['interest_links']}');
            print('appData---> learn more ${finalDecoded['learn_more']}');

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

