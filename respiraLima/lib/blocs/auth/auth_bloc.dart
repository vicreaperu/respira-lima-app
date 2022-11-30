import 'dart:async';

import 'package:app4/db/db.dart';
import 'package:app4/services/services.dart';
import 'package:app4/share_preferences/preferences.dart';
import 'package:app4/share_preferences/share_preferences.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  DateTime initTime;
  final int timeToCallInMinute = 5;  // minutes
  final int timeToUpdateInMinute = 50; // mi
  final int timeToKillRoute = 30; // min
  final format = DateFormat('yyyy-MM-dd HH:mm:ss');


  AuthBloc({
    required this.initTime,
    required this.authService,

    }) : super(AuthState(initialDate: initTime)) {

      on<StartUpdatingAccountEvent>((event, emit) {
        Timer.periodic(Duration(minutes: timeToCallInMinute), ((timer) async {
        // print('${format2.format(timer.)}');
          // print("The time now is${format.format(DateTime.now()).toString() }");
          // print("The time saved is is${format.format(DateTime.parse(Preferences.timeFirebaseTokenUpdated)).toString() }");

          if(!state.startUpdating){
            print('Will cancel UPDATING THE AUTH TOKEN-------');
            timer.cancel();
          } else{

            _init();
          }
      }));
      });

    
    on<SetIsUpdating>((event, emit)  => emit(state.copyWith(startUpdating: true)));
    on<StopUpdatingAccountEvent>((event, emit)  => emit(state.copyWith(startUpdating: false)));
    


    on<HasAccountEvent>((event, emit)  {
      print('ISSSS A NOT GUEST EVENT<<<<<<----');
      emit(state.copyWith(hasAccount: true, isAGuest: false));
    } );
    on<HasSimpleAccountEvent>((event, emit)  {
      print('ISSSS A NOT SAYING IF IS A GUEST GUEST EVENT<<<<<<----');
      emit(state.copyWith(hasAccount: true));
    } );
    on<HasAccountAsGuestEvent>((event, emit)  {
      print('ISSSS A GUEST EVENT<<<<<<----');
      emit(state.copyWith(hasAccount: true, isAGuest: true));
    });
    on<NotHasAccountEvent>((event, emit)  {
      emit(state.copyWith(hasAccount: false));
      // authService.signOutFirebase();
    });
    
    on<IsAguestEvent>((event, emit) => emit(state.copyWith(isAGuest: true)),);
    on<IsNotAguestEvent>((event, emit) => emit(state.copyWith(isAGuest: false)),);

    on<HasValidAccountEvent>((event, emit)  {
      emit(state.copyWith(hasValidAccound: true, hasAccount: true));  
    });
    on<NotHasValidAccountEvent>((event, emit)  => emit(state.copyWith(hasValidAccound: false, hasAccount: false)));
    print('BEFORE OF INIT');
    _init();
    print('ouT OF INIT');
  }


  void _init() async {
    final String navID = await PrincipalDB.getNavigationID();
    bool response = false;
    print('aaaa---> To init auth----');
    if(navID != '') {
      final int navState = await PrincipalDB.getNavigationState(); 
      if(navState < 22) {
        print('To init --0');
        final String? lastKnowTimeNav = await PrincipalDB.getNavigationLastKnowTime();
        print('Last know time is $lastKnowTimeNav');

        if(lastKnowTimeNav != null && lastKnowTimeNav != ''){
          final Duration duration = DateTime.now().difference(DateTime.parse(lastKnowTimeNav));
          print('Time pased is ${duration.inMinutes}');       
          if (duration.inMinutes < timeToKillRoute){
            if(Preferences.userEmail != '' && Preferences.userPassword != ''){
              print('.....NOT A GUEST 1');
              add(HasAccountEvent());
            } else{
              add(HasAccountAsGuestEvent());
            }
            await updateTokenEvent();
            print('To init --1');
            response = true;
          } else{
            await PrincipalDB.clearNavigationDetail();   
            // Preferences.clearNavigationPreferences();   
          } 
        }
      } else{
        await PrincipalDB.clearNavigationDetail();
      }
    }
    print('To init --3');
    final String token = await PrincipalDB.getFirebaseToken();
    if(token != ''){
      final String? lastTimeTokenUpdated = await PrincipalDB.getTimeFirebaseTokenUpdated();
      if (lastTimeTokenUpdated != null && lastTimeTokenUpdated != ''){
        final Duration duration = DateTime.now().difference(DateTime.parse(lastTimeTokenUpdated));
        if(Preferences.userEmail != '' && Preferences.userPassword != ''){
          print('.....NOT A GUEST 2');
          add(HasAccountEvent());
          response = true;
        } else if(duration.inMinutes < timeToUpdateInMinute){
          print('..... A GUEST 3');
          add(HasAccountAsGuestEvent());
          response = true;
        }
        if(response){
          await updateTokenEvent();
          print('To init --4 has account');
        }
      } 
    }
    if(!response){
      print('To init --5');
      await Preferences.cleanLitePreferences();
      await PrincipalDB.clearUserInfo();
      add(NotHasAccountEvent());
    }
    print('aaaa---> To end auth----');
  }

  Future updateTokenEvent() async {
      // if(state.hasAccount){
        // final String? token = await authService.updateToken(Preferences.firebaseToken);
        // FirebaseAuth.instance.signInAnonymously();

        // final String? token = await authService.loginUser(Preferences.userEmail, Preferences.userPassword);
        print('to init update toke is init');
        final bool isUpdated = await authService.askForTokenUpdating();
        // final String? token = await authService.loginUser(Preferences.userEmail, Preferences.userPassword);
        // print('TOKEN is $token');
        print('to init update toke is init $isUpdated');
        if(isUpdated) {
          // Preferences.isFirstTime = false;
          // Preferences.firebaseToken = token;
          // Preferences.timeFirebaseTokenUpdated = DateTime.now().toString();
          print('GUEST----> HasValidAccountEvent ');
          add(HasValidAccountEvent());
          print('GUEST----> HasValidAccountEvent x2');
          // if(!state.startUpdating){
          //   print('will start updating');
          //   add(SetIsUpdating());
          //   add(StartUpdatingAccountEvent());
          // }
        }else {
            print('GUEST----> NotHasAccountEvent ');
            add(NotHasAccountEvent());
            await Preferences.cleanLitePreferences();
            print('GUEST----> will not start updating');
            print('GUEST----> NotHasAccountEvent x2');
          // TODO: with if the token is nos updating // implement IT
        }
      // } else{
      //   print('fffff');
      // }
      // TODO: implement event handler
    }
    
  

}
