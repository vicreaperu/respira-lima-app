import 'dart:convert';
import 'dart:io';

import 'package:app4/global/enviroment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AppDataService extends ChangeNotifier {

  
  Future<Map<String, dynamic>> getDataAlerts({required String idToken}) async {
    Map<String, dynamic> response = {'error': 0};
    final Map<String, String> head = {
      HttpHeaders.authorizationHeader: idToken,
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    final url = Uri.https(Environment.baseUrlAuth, '${Environment.unEncodedPathAppData}/alerts_data');
    try {
      final resp = await http.get(url, headers: head);
      final Map<String, dynamic> decodeResp = json.decode(resp.body);
      print('ALERT UPDATED ON $decodeResp');
      print('ALERT UPDATED ON ${decodeResp.keys}');
      print('ALERT UPDATED ON ${decodeResp.values}');
      if (decodeResp['status'] == 200) {
        response = decodeResp["response"];
      }
        
    } on Exception catch (e) {
      response = {'error': 1};
      
    }
    return response;
  }

}