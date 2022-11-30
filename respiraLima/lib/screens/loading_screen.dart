import 'package:app4/blocs/blocs.dart';
import 'package:app4/helpers/helpers.dart';
import 'package:app4/screens/screens.dart';
// import 'package:app4/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:provider/provider.dart';

class LoadingScreen extends StatelessWidget {
  static const String pageRoute = 'LoadingMap';
  const LoadingScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // final socketService = Provider.of<SocketService>(context, listen: false);
    // socketService.connect();
    return Scaffold(body: BlocBuilder<GpsBloc, GpsState>(
      builder: (context, state) {
        // return state.isAllGranted ? const BackgroundScreen2() : const GpsAccessScreen();
        // return state.isAllGranted ? const MapScreen() : const GpsAccessScreen();
        // return state.isAllGranted ? (isAndroid ? const MapScreenAndroid() : const MapScreen()) : const GpsAccessScreen();
        return state.isAllGranted ? (isAndroid ? const MapScreenAndroid() : const MapScreeniOS()) : const GpsAccessScreen();
      },
    ));
  }
}
