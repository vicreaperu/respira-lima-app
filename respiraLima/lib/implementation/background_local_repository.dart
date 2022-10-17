import 'package:app4/native_code/native_code.dart';
import 'package:app4/repositories/repositories.dart';

class BackgroundLocationRepositoryImpl implements BackgroundLocationRepository {
  final BackgroundLocation _backgroundLocation;

  BackgroundLocationRepositoryImpl(this._backgroundLocation);

  @override
  Future<void> startForegroundService() {
    return _backgroundLocation.startForegroundService();
  }

  @override
  Future<void> stopForegroundService() {
   return _backgroundLocation.stopForegroundService();
  }
}