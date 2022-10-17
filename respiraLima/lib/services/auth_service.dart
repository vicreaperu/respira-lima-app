import 'dart:convert';
import 'dart:io';

import 'package:app4/db/principal_db.dart';
import 'package:app4/global/enviroment.dart';
import 'package:app4/share_preferences/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class AuthService extends ChangeNotifier {
  late final UserCredential credentials;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> signOutFirebase() async{
    try{
      await auth.signOut();
      print('SingOut OK');
    } catch(e){
      print('SingOut error $e');
    }
  }

  Future<bool> askForTokenUpdating() async {
    bool response = false;
    try {
      print('to init BEFORE FIRABASE INSTANCE');
      final String? token = await auth.currentUser?.getIdToken();
      // To change it after initialization, use `setPersistence()`:
      print('to init TOKENQQ 1 xx IS ${token ?? 'NO TOK'}');
      if(token != null){
        print('to init TOKENQQ 1 yy IS $token'); 
        final String? lastTimeTokenUpdated = await PrincipalDB.getTimeFirebaseTokenUpdated();
        if (lastTimeTokenUpdated != null && lastTimeTokenUpdated != ''){
          final Duration duration = DateTime.now().difference(DateTime.parse(lastTimeTokenUpdated));
          final String previousToken =  await PrincipalDB.getFirebaseToken(); 
          print('to init TOKENQQ 1 zz IS $previousToken'); 
          if(duration.inMinutes > 59){
            if(token != previousToken){
              await PrincipalDB.firebaseToken(token);
              // PrincipalDB.firebaseToken = token;
              Preferences.isFirstTime = false;
              // Preferences.timeFirebaseTokenUpdated = DateTime.now().toString();
              response = true;
            } 
            else{
              print('xxxxxx AUTHHHH ERRORRR.... RETURNING THE SAME TOKEN');
            }
          } else{
            Preferences.isFirstTime = false;
            response = true;
          }
        } 
        
        
      }
    } catch (e) {
      print('to init TOKENQQ ERROR IS $e');
      response = false;
    }
    return response;
  }
  Future<String> loginFirebaseEmailPassword(String email, String password) async {
    String response = '';
    try {  
        credentials = await auth.signInWithEmailAndPassword(
          email: email,
          password: password
        );
        
        print('TOKENQQ 11 IS  ${credentials.user?.isAnonymous ?? "NULL"}');  
        final token = await credentials.user?.getIdTokenResult() ;
        print('TOKENQQ 22 IS $token');  
        print('TOKENQQ 33 IS ${token?.token ?? 'NO TOK'}');
        response = token?.token ?? '';
    } catch (e) {
      print('TOKENQQ logInEmailPass ERROR IS $e');
    }
    return response;
  }
  Future<String> loginFirebaseAnonymous() async {
    try {     
        credentials = await auth.signInAnonymously();       
        print('TOKENQQ 1 anonymous IS ANONYMOUS ${credentials.user?.isAnonymous ?? "NULL"}');  
        final token = await credentials.user?.getIdTokenResult() ;
        print('TOKENQQ 2 anonymous IS $token');  
        print('TOKENQQ 3 anonymous IS ${token?.token ?? 'NO TOK'}');  
        return token?.token ?? '';

    } catch (e) {
      print('TOKENQQ ERROR anonymous IS $e');
    }
    return '';
  }


  Future<String> lookUpUserF(String idTok) async {
    final Map<String, dynamic> authData = {'idToken': idTok};
    final url = Uri.https(
        Environment.baseUrlFireBase, '/v1/accounts:lookup', {'key': Environment.firebaseToken});
    final resp = await http.post(url, body: json.encode(authData));
    print(resp);
    print(resp.body);
    return '';
  }
  
  Future<String?> updateToken(String token) async {
    final Map<String, dynamic> authData = {
      'token': token,
      'returnSecureToken': true,
    };
    final url = Uri.https(Environment.baseUrlFireBase, '/v1/accounts:signInWithCustomToken',
        {'key': Environment.firebaseToken});
    try {
      final resp = await http.post(url, body: json.encode(authData));
      print('-----------SINCE HERE GET TOKEN----------------');
   
      print(resp.body);
      
      final Map<String, dynamic> decodeResp = json.decode(resp.body);
      print(decodeResp.keys);
      print(decodeResp.values);
      if (decodeResp.containsKey('idToken')) {
        print(decodeResp['idToken']);
        return decodeResp['idToken'];
      } else {
        print(decodeResp);
      }
    } on Exception catch (e) {
      print(e);
    }
    return null;
  }

  Future<String?> loginUser(String email, String password) async {
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };
    final url = Uri.https(Environment.baseUrlFireBase, '/v1/accounts:signInWithPassword',
        {'key': Environment.firebaseToken});
    try {
      final resp = await http.post(url, body: json.encode(authData));
      print('-----------SINCE HERE----------------');
   
      print(resp.body);
      
      final Map<String, dynamic> decodeResp = json.decode(resp.body);
      print(decodeResp.keys);
      print(decodeResp.values);
      if (decodeResp.containsKey('idToken')) {
        print(decodeResp['idToken']);
        return decodeResp['idToken'];
      } else {
        print(decodeResp);
      }
    } on Exception catch (e) {
      print(e);
    }
    return null;
  }
  
  Future<String?> createUser({ 
      required String email, 
      required String name, 
      // required String phone, 
      required String password, 
      required String birthday, 
      required String gender
    }) async {
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      "name": name,
      // "phone_number": '+51900000001',
      "birthdate": birthday,
      "gender": gender,
    };
    final Map<String, String> head = {
      HttpHeaders.contentTypeHeader: 'application/json'
      }; 
    final url = Uri.https(Environment.baseUrlAuth, '${Environment.unEncodedPathAuth}/register');
    try{
      final resp = await http.post(url, headers: head, body: json.encode(authData));

      print('-----------SINCE HERE --------');
      
      final Map<String, dynamic> decodedResp = json.decode(resp.body);
      print('REGISTER DATA $decodedResp');
      if (decodedResp['status'] == 200) {
      // if(decodedResp.containsKey('success')){
        // TODO: save values to storage
        return null;
      }
      else{
        return decodedResp['error'];
      }
    } on Exception catch (e){
      return e.toString();
    }
  }

  Future<Map<String, dynamic>> lookUpUser(String idToken) async {
    final Map<String, String> head = {
      HttpHeaders.authorizationHeader: idToken,
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    final url = Uri.https(Environment.baseUrlAuth, '${Environment.unEncodedPathAuth}/user');
    try {
      final resp = await http.get(url, headers: head);

      print('LookUp User-------');
      print(resp);
      print(resp.body);

    
      final Map<String, dynamic> decodeResp = json.decode(resp.body);
      if (decodeResp['status'] == 200) {
      // if (decodeResp.containsKey('email') || decodeResp.containsKey('phone_number')) {
        return decodeResp["response"];
      } else {
        print(decodeResp);
      }
    } on Exception catch (e) {
      print(e);
    }
    return {};
  }





  Future<bool?> isEmailVerified(String idToken) async {
    final Map<String, String> head = {
      HttpHeaders.authorizationHeader: idToken,
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    final url = Uri.https(Environment.baseUrlAuth, '${Environment.unEncodedPathAuth}/user/email-verified');
    try {
      final resp = await http.get(url, headers: head);
      print('Verified EMAIL-------');
      // {"email_verified":false}
      print(resp);
      print(resp.body);

    
      final Map<String, dynamic> decodeResp = json.decode(resp.body);
      if (decodeResp['status'] == 200) { // TODO: VERIFY THIS
      // if (decodeResp.containsKey('email_verified')) {
        return decodeResp['email_verified'];
      } else {
        print(decodeResp);
      }
    } on Exception catch (e) {
      print(e);
    }
    return null;
  }

  Future<bool> deleteUserAccount(String idToken) async {
    final Map<String, String> head = {
      HttpHeaders.authorizationHeader: idToken,
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    final url = Uri.https(Environment.baseUrlAuth, '${Environment.unEncodedPathAuth}/user');
    try {
      final resp = await http.delete(url, headers: head);
      print('Delete Account-------');
      // {"email_verified":false}
      print(resp);
      print(resp.body);

    
      final Map<String, dynamic> decodeResp = json.decode(resp.body);
      if (decodeResp['status'] == 200) {
        return true;
      } else {
        print(decodeResp);
      }
    } on Exception catch (e) {
      print(e);
    }
    return false;
  }



  Future<bool> changeUserData({
    required String email, 
    required String name, 
    required String phone, 
    required String birthday, 
    required String gender, 
    required String idToken
    }) async {
    final Map<String, dynamic> authData = {
      'email': email,
      "name": name,
      // "phone_number": '+51$phone',
      "birthdate": birthday,
      "gender": gender,
    };
    final Map<String, String> head = {
      HttpHeaders.authorizationHeader: idToken,
      HttpHeaders.contentTypeHeader: 'application/json'
      }; 
    final url = Uri.https(Environment.baseUrlAuth, '${Environment.unEncodedPathAuth}/user');
    try {
      final resp = await http.put(url, headers: head, body: json.encode(authData));
      final Map<String, dynamic> decodeResp = json.decode(resp.body);
      print(decodeResp);
      if (decodeResp['status'] == 200) {
        return true;
      } else {
        print(decodeResp);
      }
    } on Exception catch (e) {
      print(e);
    }
    return false;
    
  }

  Future<bool> verifyEmail(String idToken) async {
    final Map<String, String> head = {
      HttpHeaders.authorizationHeader: idToken,
      HttpHeaders.contentTypeHeader: 'application/json'
      }; 

    final url = Uri.https(Environment.baseUrlAuth, '${Environment.unEncodedPathAuth}/user/verify-email');
    try {
      final resp = await http.put(url,headers: head);
    // {"success":"A verification link will be sent to the email"}
      final Map<String, dynamic> decodeResp = json.decode(resp.body);
      if (decodeResp['status'] == 200) {
        return true;
      } else {
        print(decodeResp);
      }
    } on Exception catch (e) {
      print(e);
    }
    return false;
  }
  Future<String?> resetPassword(String email) async {
    final Map<String, dynamic> authData = {'email': email};
    final Map<String, String> head = {HttpHeaders.contentTypeHeader: 'application/json'}; 

    final url = Uri.https(Environment.baseUrlAuth, '${Environment.unEncodedPathAuth}/user/reset-password');
    try{

      final resp = await http.put(url,headers: head, body: json.encode(authData));
      print('resetPassword-------');
      print(resp);
      print(resp.body);
    }on Exception catch (e) {
      print(e);
    }

    return null;
  }
  Future<bool> changePassword(String idToken, String password) async {
    final Map<String, String> head = {
      HttpHeaders.authorizationHeader: idToken,
      HttpHeaders.contentTypeHeader: 'application/json'
      }; 
    final Map<String, dynamic> authData = {'password': password};

    final url = Uri.https(Environment.baseUrlAuth, '${Environment.unEncodedPathAuth}/user/change-password');
    try {
      final resp = await http.put(url,headers: head, body: json.encode(authData));
      final Map<String, dynamic> decodeResp = json.decode(resp.body);
      if (decodeResp['status'] == 200) {
      // if (decodeResp.containsKey('success')) {
        return true;
      } else {
        print(decodeResp);
      }
    } on Exception catch (e) {
      print(e);
    }
    return false;
  }


}
