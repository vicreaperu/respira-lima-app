import 'package:app4/blocs/blocs.dart';
import 'package:app4/screens/gps_access_screen.dart';
import 'package:app4/screens/map_screen.dart';
import 'package:app4/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class LoadingScreenC extends StatefulWidget {
  static const String pageRoute = 'LoadingMapcopy';
  const LoadingScreenC({Key? key}) : super(key: key);

  @override
  State<LoadingScreenC> createState() => _LoadingScreenCState();
}




class _LoadingScreenCState extends State<LoadingScreenC> {

  late final SocketService socketService;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    socketService = Provider.of<SocketService>(context, listen: false);
    socketService.connect();
    socketService.socket.on('new_map_paint', (data) {
      print('socket new map $data');
      final mapBloc = BlocProvider.of<MapBloc>(context, listen: false);
      mapBloc.updateCameraPosition();
    // notifyListeners();
  } );
    socketService.socket.on('join_room', (data) {
    print('socket join room xxxxx$data');
    // notifyListeners();
  } );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<GpsBloc, GpsState>(
      builder: (context, state) {
        return state.isAllGranted ? const MapScreen() : const GpsAccessScreen();
      },
    ));
  }
}
