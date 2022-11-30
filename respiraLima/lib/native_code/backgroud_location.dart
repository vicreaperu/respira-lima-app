import 'package:app4/helpers/helpers.dart';
import 'package:flutter/services.dart';

class BackgroundLocation {
  final _channel = const MethodChannel('app.respira.lima/background-location');

  Future<void> startForegroundService() async {
    if (isAndroid) {
      await _channel.invokeMethod('start');
    }
  }

  Future<void> stopForegroundService() async {
    if (isAndroid) {
      await _channel.invokeMethod('stop');
    }
  }
}