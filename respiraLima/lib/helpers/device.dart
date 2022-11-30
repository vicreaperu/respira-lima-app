

import 'package:device_info_plus/device_info_plus.dart';


Future<bool?> isAndroidDeviceIgualUpper10() async{
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  print('MODE----> DEVICE-ANDROID REALEASE IS on ${androidInfo.version.release}'); 
  final double? releaseVal = double.tryParse(androidInfo.version.release);
  if(releaseVal !=null){
    print('MODE----> DEVICE is $releaseVal < 10 ?? ${releaseVal < 10}');
    return releaseVal >= 10;
  } else{
    print('MODE----> DEVICE FINAL RESP. $releaseVal');
  }
  
}

Future<String> getAndroidDeviceReleaseType() async{
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  print('MODE----> DEVICE-ANDROID Running on ${androidInfo.model}'); 
  print('MODE----> DEVICE-ANDROID REALEASE IS on ${androidInfo.version.release}'); 
  
  return androidInfo.version.release;
}

Future<String> getIOsDeviceTyoe() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  print('MODE----> DEVICE-IOS  Running on ${iosInfo.utsname.machine}');
  return iosInfo.utsname.machine ?? '';
}