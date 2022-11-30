import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences _prefer;
  static String _userName           = '';
  static String _userBirthday       = '';
  static int    _userGender         = 0;
  static String _userPassword       = '';
  static String _userEmail          = '';
  static String _userPhoneNumber    = '';
  static int    _userCiclistPeaton  = 0; // Peaton = 1, ciclista = 2 
  static int    _userAirQualityPref = 0; // Baja contaminacion = 1, menor distancias = 2
  static bool   _isDark             = false;
  static bool   _isEmailVerified    = false;
  static bool   _isAguest           = true;
  static bool   _speakRoute         = true;
  static bool   _oldAndroid         = false;

  // //// TODO: DELETE
  // static String _firebaseToken = '';
  // static String _timeFirebaseTokenUpdated = '';



  static bool _isFirstTime      = true;
  static bool _areTermsAccepted = false;
  static bool _willRemenberData = false;
  // related with a navigation event

  // // TODO: DELETE
  // static String _routeId = '';
  // static int _countPointSend = 0;

  // static String _navigationProfile = '';
  // static String _navigationMode = '';


  // static String _navigationLastKnowTime = '';
  // static String _navigationInitialInformation = '';
  // static String _navigationLastKnownInformation = '';

  static Future init() async {
    _prefer = await SharedPreferences.getInstance();
  }
  // static void clearNavigationPreferences(){
  //   navigationProfile               = '';
  //   navigationMode                  = '';
  //   navigationLastKnowTime          = '';
  //   countPointSend                  = 0;
  //   routeId                         = '';
  //   navigationInitialInformation    = '';
  //   navigationLastKnownInformation  = '';
  // }

  static cleanLitePreferences() async {
    userName = '';
    userBirthday = '';
    userGender = 0;
    userPassword = '';
    userEmail = '';
    userPhoneNumber = '';
    isEmailVerified = false;
    isFirstTime = true;
    await setIsAguest(true);
  }
  static cleanTotalPreferences() async{
    userName = '';
    userBirthday = '';
    userGender = 0;
    userPassword = '';
    userEmail = '';
    userPhoneNumber = '';
    await setUserCiclistPeaton(0);
    await setUserAirQualityPref(0);
    // isDark = false;
    isEmailVerified = false;
    // firebaseToken = '';
    // timeFirebaseTokenUpdated = '';
    isFirstTime = true; // TODO: analize this condition
    await setIsAguest(true);
    // areTermsAccepted = false;
    // willRemenberData = false;
  }

  // static String get navigationLastKnownInformation {
  //   return _prefer.getString('navigationLastKnownInformation') ?? _navigationLastKnownInformation;
  // }

  // static set navigationLastKnownInformation(String value) {
  //   _prefer.setString('navigationLastKnownInformation', value);
  //   _navigationLastKnownInformation = value;
  // }
  // static String get navigationInitialInformation {
  //   return _prefer.getString('navigationInitialInformation') ?? _navigationInitialInformation;
  // }

  // static set navigationInitialInformation(String value) {
  //   _prefer.setString('navigationInitialInformation', value);
  //   _navigationInitialInformation = value;
  // }
  // static String get navigationLastKnowTime {
  //   return _prefer.getString('navigationLastKnowTime') ?? _navigationLastKnowTime;
  // }

  // static set navigationLastKnowTime(String value) {
  //   _prefer.setString('navigationLastKnowTime', value);
  //   _navigationLastKnowTime = value;
  // }

  // static String get navigationMode {
  //   return _prefer.getString('navigationMode') ?? _navigationMode;
  // }

  // static set navigationMode(String value) {
  //   _prefer.setString('navigationMode', value);
  //   _navigationMode = value;
  // }


  // static String get navigationProfile {
  //   return _prefer.getString('navigationProfile') ?? _navigationProfile;
  // }

  // static set navigationProfile(String value) {
  //   _prefer.setString('navigationProfile', value);
  //   _navigationProfile = value;
  // }



  //   static int get countPointSend {
  //   return _prefer.getInt('countPointSend') ?? _countPointSend;
  // }

  // static set countPointSend(int value) {
  //   _prefer.setInt('countPointSend', value);
  //   _countPointSend = value;
  // }

  //   static String get routeId {
  //   return _prefer.getString('routeId') ?? _routeId;
  // }

  // static set routeId(String value) {
  //   _prefer.setString('routeId', value);
  //   _routeId = value;
  // }


  static bool get oldAndroid {
    return _prefer.getBool('oldAndroid') ?? _oldAndroid;
  }

  static setoldAndroid(bool value) async{
    await _prefer.setBool('oldAndroid', value);
    _oldAndroid = value;
  }




  static bool get speakRoute {
    return _prefer.getBool('speakRoute') ?? _speakRoute;
  }

  static set speakRoute(bool value) {
    _prefer.setBool('speakRoute', value);
    _speakRoute = value;
  }
  static bool get isAguest {
    return _prefer.getBool('isAguest') ?? _isAguest;
  }

  static set isAguest(bool value) {
    _prefer.setBool('isAguest', value);
    _isAguest = value;
  }
  static setIsAguest(bool value) async{
    await _prefer.setBool('isAguest', value);
    _isAguest = value;
  }

  static bool get areTermsAccepted {
    return _prefer.getBool('areTermsAccepted') ?? _areTermsAccepted;
  }

  static set areTermsAccepted(bool value) {
    _prefer.setBool('areTermsAccepted', value);
    _areTermsAccepted = value;
  }

  static bool get isFirstTime {
    return _prefer.getBool('isFirstTime') ?? _isFirstTime;
  }

  static set isFirstTime(bool value) {
    _prefer.setBool('isFirstTime', value);
    _isFirstTime = value;
  }

  static bool get willRemenberData {
    return _prefer.getBool('willRemenberData') ?? _willRemenberData;
  }

  static set willRemenberData(bool value) {
    _prefer.setBool('willRemenberData', value);
    _willRemenberData = value;
  }

  static int getGenderNumber(String genderString) {
    genderString.toLowerCase();
    if (genderString == 'masculino') {
      return 1;
    } else if (genderString == 'femenino') {
      return 2;
    } else if (genderString == 'otros') {
      return 3;
    }
    return 0;
  }

  static String getGenderString() {
    if (_userGender == 1) {
      return 'masculino';
    } else if (_userGender == 2) {
      return 'femenino';
    } else if (_userGender == 3) {
      return 'otros';
    }
    return '';
  }

  static String getGenderStringPassingValue(int gender) {
    if (gender == 1) {
      return 'masculino';
    } else if (gender == 2) {
      return 'femenino';
    } else if (gender == 3) {
      return 'otros';
    }
    return '';
  }


  // static String get timeFirebaseTokenUpdated {
  //   return _prefer.getString('timeFirebaseTokenUpdated') ?? _timeFirebaseTokenUpdated;
  // }

  // static set timeFirebaseTokenUpdated(String value) {
  //   _prefer.setString('timeFirebaseTokenUpdated', value);
  //   _timeFirebaseTokenUpdated = value;
  // }
  // static String get firebaseToken {
  //   return _prefer.getString('firebaseToken') ?? _firebaseToken;
  // }

  // static set firebaseToken(String value) {
  //   _prefer.setString('firebaseToken', value);
  //   _firebaseToken = value;
  // }

  static bool get isEmailVerified {
    return _prefer.getBool('isEmailVerified') ?? _isEmailVerified;
  }

  static set isEmailVerified(bool value) {
    _prefer.setBool('isEmailVerified', value);
    _isEmailVerified = value;
  }

  static bool get isDark {
    return _prefer.getBool('isDark') ?? _isDark;
  }

  static set isDark(bool value) {
    _prefer.setBool('isDark', value);
    _isDark = value;
  }

  static int get userAirQualityPref {
    return _prefer.getInt('userAirQualityPref') ?? _userAirQualityPref;
  }

  static setUserAirQualityPref(int value) async {
    await _prefer.setInt('userAirQualityPref', value);
    _userAirQualityPref = value;
  }

  static int get userCiclistPeaton {
    return _prefer.getInt('userCiclistPeaton') ?? _userCiclistPeaton;
  }

  static setUserCiclistPeaton(int value) async{
    await _prefer.setInt('userCiclistPeaton', value);
    _userCiclistPeaton = value;
  }






  static String get userEmail {
    return _prefer.getString('userEmail') ?? _userEmail;
  }

  static set userEmail(String value) {
    _prefer.setString('userEmail', value);
    _userEmail = value;
  }

  static String get userPhoneNumber {
    return _prefer.getString('userPhoneNumber') ?? _userPhoneNumber;
  }

  static set userPhoneNumber(String value) {
    _prefer.setString('userPhoneNumber', value);
    _userPhoneNumber = value;
  }

  static String get userPassword {
    return _prefer.getString('userPassword') ?? _userPassword;
  }

  static set userPassword(String value) {
    _prefer.setString('userPassword', value);
    _userPassword = value;
  }

  static int get userGender {
    return _prefer.getInt('userGender') ?? _userGender;
  }

  static set userGender(int value) {
    _prefer.setInt('userGender', value);
    _userGender = value;
  }

  static String get userBirthday {
    return _prefer.getString('userBirthday') ?? _userBirthday;
  }

  static set userBirthday(String value) {
    _prefer.setString('userBirthday', value);
    _userBirthday = value;
  }

  static String get userName {
    return _prefer.getString('userName') ?? _userName;
  }

  static set userName(String value) {
    _prefer.setString('userName', value);
    _userName = value;
  }
}
