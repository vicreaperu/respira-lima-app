import 'package:flutter/material.dart';

class AuthFormProvider extends ChangeNotifier{
  GlobalKey<FormState> formKeyLogin = new GlobalKey<FormState>();
  GlobalKey<FormState> formKeyRegister = new GlobalKey<FormState>();
  GlobalKey<FormState> formKeyRestorPass = new GlobalKey<FormState>();
  String userName = '';
  String userEmail = '';
  // TODO, EVALUATE THIS
  String userPhoneNumber = '';
  String userPassword = '';
  String userBirthday = '';
  String gender = '';
  int userGender = 0;
  bool isDark = false;
  bool _isLoading = false;
  bool _isCompleted = false;
  bool _isDataOk = true;

  bool get isDataOk => _isDataOk;
  set isDataOk(bool value) {
    _isDataOk = value;
    notifyListeners();
  }
  
  bool get isCompleted => _isCompleted;
  set isCompleted(bool value) {
    _isCompleted = value;
    notifyListeners();
  }
  
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool isValidLogin(){
    return formKeyLogin.currentState?.validate() ?? false;
  }
  bool isValidRegister(){
    return formKeyRegister.currentState?.validate() ?? false;
  }
  bool isValidRestorPass(){
    return formKeyRestorPass.currentState?.validate() ?? false;
  }

}