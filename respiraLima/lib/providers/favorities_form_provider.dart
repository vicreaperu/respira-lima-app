import 'package:flutter/material.dart';

class FavoritiesFormProvider extends ChangeNotifier{
  GlobalKey<FormState> formKeyFavorities = GlobalKey<FormState>();


  String tag = '';
  bool _isLoading = false;
  bool _isCompleted = false;


  
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

  bool isValidForm(){
    return formKeyFavorities.currentState?.validate() ?? false;
  }


}