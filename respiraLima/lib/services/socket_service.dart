
import 'dart:convert';

import 'package:app4/blocs/blocs.dart';
import 'package:app4/db/principal_db.dart';
import 'package:app4/global/enviroment.dart';
import 'package:app4/share_preferences/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;


enum ServerStatus {
  Online,
  Offline,
  Connecting
}
class SocketService with ChangeNotifier {

  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  
  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;

  void connect() async {

    // final token = Preferences.firebaseToken;
    final String token = await PrincipalDB.getFirebaseToken();
    
    // Dart client
    
    print('socket Will try to connect 1');
    _socket = IO.io( Environment.socketUrl , {
      'transports'    : ['websocket'],
      'autoConnect'   : true,
      'forceNew'      : true,
      'extraHeaders'  : {'Authorization' : token}
    });
  //   _socket = IO.io(Environment.socketUrl, 
  //   IO.OptionBuilder()
  //     .setTransports(['websocket']) // for Flutter or Dart VM
  //     .disableAutoConnect()  // disable auto-connection
  //     .setExtraHeaders({'Authorization': token}) // optional
  //     .build()
      
  // );
  _socket.onConnect((_) {
    print('socket join room');
    socket.emit('join_room', {'room':'paint-map'});
   });
    _socket.on('leave_room', (data) {
      print('socket leave room $data');
      _serverStatus = ServerStatus.Online;
      // notifyListeners();
    });
  _socket.onDisconnect((_) {
    print('socket Disconnect 0--0000-------0000000');
    
  });

  // _socket.on('join_room', (data) {
  //   print('socket join room $data');
  //   // notifyListeners();
  // } );



  }

}


