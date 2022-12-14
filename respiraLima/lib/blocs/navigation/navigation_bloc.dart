import 'dart:async';
import 'package:app4/api/api.dart';
import 'package:app4/blocs/blocs.dart';
import 'package:app4/db/db.dart';
import 'package:app4/helpers/helpers.dart';
import 'package:app4/models/models.dart';
import 'package:app4/services/services.dart';
import 'package:app4/share_preferences/preferences.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:location/location.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  static int limitPoints = 1440;
  final format = DateFormat('yyyy-MM-dd HH:mm:ss');
  final LocationBloc locationBloc;
  final AppDataBloc appDataBloc;
  final RouteService routeService;
  final PlacesPreferencesService placesPreferencesService;
  final Location locationPlugin;
  // final BackgroundLocationRepository backgroundLocationRepository;
  // final AppDataBloc AppDataBloc;
  final int cyclingTime = 5;
  final int walkingTime = 5;
  final int minToUpdateGrid = 29;
  late final NotificationApi service;
  late final TtsApi tts;
  NavigationService navigationService;
  AuthService authService;
  NavigationBloc( {
    required this.locationPlugin, 
    // required this.AppDataBloc,
    // required this.backgroundLocationRepository,
    required this.locationBloc,
    required this.appDataBloc,
    required this.navigationService,
    required this.authService,
    required this.routeService,
    required this.placesPreferencesService,
  }) : super(const NavigationState()) {
    on<AddUpdateFavoritePlacesDataEvent>((event, emit) {
        emit(state.copyWith(favoritePlacesData: event.favoritePlacesData));
      });


    on<OffSelectingFavoriteRoute>((event, emit) {
        emit(state.copyWith(isFavoriteRouteSelected: false));
      });
    on<OnSelectingFavoriteRoute>((event, emit) {
      // locationBloc.add(OnStartFollowingUserXX());
      emit(state.copyWith(isFavoriteRouteSelected: true, startAndFinalDestination: [event.destination]));
    });

    on<OffSelectingRoute>((event, emit) {
        emit(state.copyWith(isRouteSelected: false));
      });
    on<OnSelectingRoute>((event, emit) {
      // locationBloc.add(OnStartFollowingUserXX());
      emit(state.copyWith(isRouteSelected: true, startAndFinalDestination: [event.destination]));
    });

    on<OffOutOfAreaAlertEvent>((event, emit) {
        emit(state.copyWith(outOffAreaAlert: false));
      });
    on<OnOutOfAreaAlertEvent>((event, emit) {
        emit(state.copyWith(outOffAreaAlert: true));
      });
    on<OffAlertScreenOnEvent>((event, emit) {
        emit(state.copyWith(alertScreenON: false));
      });
    on<OnAlertScreenOnEvent>((event, emit) {
        emit(state.copyWith(alertScreenON: true));
        Timer(const Duration(seconds: 15), () {
          add(OffAlertScreenOnEvent());
        });
      });


    on<OnPlaceAlertShowDetailsEvent>((event, emit) {
        emit(state.copyWith(placeAlertShowDetails: true));
      });
    on<OffPlaceAlertShowDetailsEvent>((event, emit) {
        emit(state.copyWith(placeAlertShowDetails: false));
      });

    on<OutOfAreaEvent>((event, emit) {
        emit(state.copyWith(isOnArea: false));
      });
    on<IsOnAreaEvent>((event, emit) {
        emit(state.copyWith(isOnArea: true));
      });

    on<OnSpeakRouteEvent>((event, emit) {
        emit(state.copyWith(speakRoute: true));
      });


    on<OffSpeakRouteEvent>((event, emit) {
        emit(state.copyWith(speakRoute: false));
      });
    on<OnNavLoadingEvent>((event, emit) {
        emit(state.copyWith(navLoading: true));
      });

      
    on<UpdateDataPercentEvent>((event, emit) {
        emit(state.copyWith(dataPercent: event.percent));
      });




    on<OffNavLoadingEvent>((event, emit) {
        emit(state.copyWith(navLoading: false));
      });

    on<OnLoadingEvent>((event, emit) {
        emit(state.copyWith(loading: true));
      });
    on<OffLoadingEvent>((event, emit) {
        emit(state.copyWith(loading: false));
      });

    on<LikedEvent>((event, emit) {
        emit(state.copyWith(locationLiked: true, locationScored: true));
      });
    on<UnLikedEvent>((event, emit) {
        emit(state.copyWith(locationLiked: false, locationScored: true));
      });

    on<SetStartsEvent>((event, emit) {
        emit(state.copyWith(locationStars: event.score, locationScored: true));
      });


    on<PlaceVotesEvent>((event, emit) {
        emit(state.copyWith(locationStars: event.score, locationLiked: event.liked, totalStars: event.votes));
      });
    on<AddNavigationInstructions>((event, emit) {
        emit(state.copyWith(navigationInstruction: event.instructions));
      });

    on<UpdateAndReadNavigationInstructions>((event, emit) {
        emit(state.copyWith(navigationInstruction: event.instructions));
        if(event.textInstruction != null){
          print('Min distanceX ON EVENT, WILL READ ${event.textInstruction}');
          tts.speakTts(event.textInstruction!);
        }
      });



    on<AddHistoryData>((event, emit) {
      final List<HistoryModel> historyList = event.historyData.map((historyData) =>
          HistoryModel.fromMap(historyData)
        ).toList();
        emit(state.copyWith(historyData: historyList));
      });


    on<OnPlacesAlertEvent>((event, emit) {
      final List<PlaceAlertModel> placesList = event.pollutionAletData.map((pollution) =>
          PlaceAlertModel.fromMap(pollution)
        ).toList();
        emit(state.copyWith(placesAlert: true, placeAlerData: placesList));
        Timer(const Duration(seconds: 10), () {
          // Future.whenComplete(() => emit(state.copyWith(placesAlert: false)));
          add(OffPlacesAlertEvent());
        });
      });



    on<OffPlacesAlertEvent>((event, emit) {
        emit(state.copyWith(placesAlert: false));
        // emit(state.copyWith(placesAlert: false, placeAlerData: []));
      });

    on<OnPollutionAlertEvent>((event, emit) {
        
        emit(state.copyWith(pollutionAlert: true));
        Timer(const Duration(seconds: 10), () {
          add(OffPollutionAlertEvent());
        });
      });
    on<OffPollutionAlertEvent>((event, emit) {
        emit(state.copyWith(pollutionAlert: false));
      });




    on<EndingEvent>((event, emit) {
        emit(state.copyWith(navigationDataToShowEnding: event.mapEndingData));
      });
    on<TrackingEvent>((event, emit) async {
      print('This is the Navagation track data........///////');
      List<PositionReport> navigationDataToShow = [...state.navigationDataToShowTracking];
        if(navigationDataToShow.length < 5){
            navigationDataToShow.add(event.reportMap);
            final initialNavInfo = await PrincipalDB.getNavigationInitialInformation();
            if(initialNavInfo == null){
              PrincipalDB.navigationInitialInformation(event.reportMap.toMap());
              // Preferences.navigationInitialInformation = json.encode(event.mapTackingData);
            } 
          } else{
            if(event.reportMap.streetName == navigationDataToShow.last.streetName){
              navigationDataToShow = [...navigationDataToShow.take(1).toList(), ...navigationDataToShow.sublist(1,4).toList() ,event.reportMap ];
            } else{
              navigationDataToShow = [...navigationDataToShow.take(1).toList(), ...navigationDataToShow.skip(2).toList() ,event.reportMap ];
            }
          }
        PrincipalDB.navigationLastKnownInformation(event.reportMap.toMap());
        PrincipalDB.navigationLastKnowTime(DateTime.now().toString());
        // Preferences.navigationLastKnownInformation = json.encode(event.mapTackingData);
        // Preferences.navigationLastKnowTime = DateTime.now().toString();
        print('This is the Navagation track data........///////');
        print("BACKDATA---->${navigationDataToShow.last.distance}");
        print("BACKDATA---->${navigationDataToShow.last.streetName}");
        emit(state.copyWith(navigationDataToShowTracking: navigationDataToShow, isOnArea: true));
      });
    
    on<ClearAllDataToshow>((event, emit) {
        emit(state.copyWith(navigationDataToShowEnding: {}, navigationDataToShowTracking: [], isOnArea: true));
      });

    on<MonitoreoNavigationModeEvent>((event, emit) {
        emit(state.copyWith(navigationMode: 'monitoreo', navigationState: 1));
      });
    on<RuteoNavigationModeEvent>((event, emit) {
        emit(state.copyWith(navigationMode: 'ruteo', navigationState: 1));
      });
    on<SelectNavigationModeEvent>((event, emit) {
        emit(state.copyWith(navigationState: 1));
      });





    on<OffChangedEvent>((event, emit) {
        emit(state.copyWith(changed: false));
      });



    on<WalkingNavigationProfileEvent>((event, emit) {
        emit(state.copyWith(navigationProfile: 'walking', changed: true));
      });
    on<CyclingNavigationProfileEvent>((event, emit) {
        emit(state.copyWith(navigationProfile: 'cycling', changed: true));
      });


    on<TimeNavigationAirQualityPreferencesEvent>((event, emit) {
        emit(state.copyWith(navigationAirQualityPref: 'time', changed: true));
      });
    on<PollutantNavigationAirQualityPreferencesEvent>((event, emit) {
        emit(state.copyWith(navigationAirQualityPref: 'pollutant', changed: true));
      });


    on<DeactivateNavigationModeEvent>((event, emit) {
      locationBloc.add(OffSavingLocationHistory());
      emit(state.copyWith(navigationState: 0, isNavigating: false));
      });
    on<LiteStartNavigationEvent>((event, emit) {
      locationBloc.add(OnStartSavingLocationHistory());
      emit(state.copyWith(navigationState: 2, isNavigating: true));

      });
    // on<BackgroundStartNavigationEvent>((event, emit) {
    //   locationBloc.add(OnStartSavingLocationHistory());
    //   emit(state.copyWith(navigationState: 2, isNavigating: true));
    //   final int timeToCall = state.navigationProfile == 'cycling' ? cyclingTime : walkingTime;
    //   Timer.periodic(Duration(seconds: timeToCall), ((timer) async {
    //     // print('${format2.format(timer.)}');
    //       print(format.format(DateTime.now()).toString() );
    //       if(!state.isNavigating){
    //         print('BACKX Will cancel -------');
    //         timer.cancel();
    //       } else{
    //         print('BACKX asckingg -------');
    //         final stateT = await postTrackingPositionMikel();
    //          await PrincipalDB.getAllPoints().then((value) async {
    //             add(TrackingEvent(PositionReport.fromMap({
    //               'exposure'    : 10.3,
    //               'air_quality' : 'Bueno',
    //               'color'       : '',
    //               'timestamp'   : '12/12/12',
    //               'distance'    : '12',
    //               'street_name' : 'caramandunga',
    //             })));
             
    //          });
    //         print(state.navigationDataToShowTracking);
    //       }
    //   }));
    //   });
    on<StartNavigationEvent>((event, emit) {
        locationBloc.add(OnStartSavingLocationHistory());
        emit(state.copyWith(navigationState: 2, isNavigating: true));
        
        
        final int timeToCall = state.navigationProfile == 'cycling' ? cyclingTime : walkingTime;
        Timer.periodic(Duration(seconds: timeToCall), ((timer) async {
        // print('${format2.format(timer.)}');
          print(format.format(DateTime.now()).toString() );
          if(!state.isNavigating){
            print('BACKX Will cancel -------');
            timer.cancel();
          } 
          else if(!locationBloc.state.isInBackground || isIOS){
            print('BACKX asckingg -------');
            final stateT = await postTrackingPositionMikel();
            print(state.navigationDataToShowTracking);
            print('the state is $stateT');
          } else{
            print('POINTCANT--->       es in BACK ${locationBloc.state.isInBackground}');
          }
      }));
      });
    on<StopNavigationEvent>((event, emit) async {
        // final bool response = await postTrackingEnd(); 
        // if (response){
        emit(state.copyWith(navigationState: 3, isNavigating: false, isRouteSelected: false, navigationInstruction: []));
        // }
      });
    on<OnFavoritiesSpecialEvent>((event, emit) async {
        emit(state.copyWith(navigationState: state.navigationState + 100));
      });
    on<OffFavoritiesSpecialEvent>((event, emit) async {
      if(state.navigationState >= 100){
        emit(state.copyWith(navigationState: state.navigationState - 100));
      } else if(state.navigationState < 0 || state.navigationState >= 4) {
        emit(state.copyWith(navigationState: 0));
      }
      });

    on<OnlyStopNavigationEvent>((event, emit) async {
        // final bool response = await postTrackingEnd(); 
        // if (response){
        emit(state.copyWith(isNavigating: false, navigationInstruction: []));
        // }
      });
    on<EndNavigationEvent>((event, emit) async {
      emit(state.copyWith(navigationState: 0));
      await postTrackingScore(event.rating);
      });
    on<NoRatingEvent>((event, emit) async {
      await PrincipalDB.navigationID('');
      // Preferences.routeId = '';
      emit(state.copyWith(navigationState: 0));
      });
    
    on<ReturnToNavigationTrackingRuteo>((event, emit) async {
      List<PositionReport> navigationDataToShow = [];
      if(event.initialReport != null){
        navigationDataToShow.add(event.initialReport!);
      }
      if(event.lastKnowReport != null){
        navigationDataToShow.add(event.lastKnowReport!);
      }
      print('To init --- navigation list data.. $navigationDataToShow');
      emit(state.copyWith(
        navigationProfile: event.profile, 
        navigationMode: event.mode, 
        navigationDataToShowTracking: navigationDataToShow,
        startAndFinalDestination: [event.startDestination, event.finalDestination]
        ));
      // backgroundLocationRepository.startForegroundService();
      // await service.showNotification(
      //             id: 0,
      //             title: 'Ruteando',
      //             body: 'Regresar a la pagina de ruteo');
      KeepScreenOn.turnOn();
    },
    );
    
    on<ReturnToNavigationTrackingMonitoreo>((event, emit) async {
      List<PositionReport> navigationDataToShow = [];
      if(event.initialReport != null){
        navigationDataToShow.add(event.initialReport!);
      }
      if(event.lastKnowReport != null){
        navigationDataToShow.add(event.lastKnowReport!);
      }
      print('To init --- navigation list data.. $navigationDataToShow');
      emit(state.copyWith(
        navigationProfile: event.profile, 
        navigationMode: event.mode, 
        navigationDataToShowTracking: navigationDataToShow
        ));
      // await service.showNotification(
      //             id: 0,
      //             title: 'Ruteando',
      //             body: 'Regresar a la pagina de ruteo');
      // backgroundLocationRepository.startForegroundService();
      KeepScreenOn.turnOn();
    },
    );
    
    _init();  
  }
  void _init() async{
    service = NotificationApi();
    service.initialize();
    tts = TtsApi();
    tts.initTts();
    if(Preferences.speakRoute){
      
    }
    await PrincipalDB.getAllFavoritePlace().then((listPlaces) {
      add(AddUpdateFavoritePlacesDataEvent(listPlaces));
    },);
    print('aaaa---> To init navigation----');
    final navID = await PrincipalDB.getNavigationID();
    // if(Preferences.routeId != ''){
    if(navID != '' ){
      final navState = await PrincipalDB.getNavigationState();
      if(navState < 22){
        print('To init --ONN-- $navID');
        // print('To init --navigationInitialInformation-- ${Preferences.navigationInitialInformation}');
        // print('To init --navigationLastKnownInformation-- ${Preferences.navigationLastKnownInformation}');
        final navDetails = await PrincipalDB.getStartNavigationDetails();
        final initialInfo = await PrincipalDB.getNavigationInitialInformation();
        final lastKnowInfo = await PrincipalDB.getNavigationLastKnownInformation();

        if(navDetails != null){
        final isGridUpdated = await appDataBloc.checkAndUpdatePredictionsGrid();
        print('Gridx---->>  gaaaa IS GRID UPDATED??? $isGridUpdated');
          add(StartNavigationEvent());
          // add(LiteStartNavigationEvent());
          if(navDetails.mode == 'monitoreo'){
            add(ReturnToNavigationTrackingMonitoreo(
              navDetails.mode, 
              navDetails.profile, 
              initialInfo, 
              lastKnowInfo,
              ));
          } else{
            add(ReturnToNavigationTrackingRuteo(
              mode            : navDetails.mode, 
              profile         : navDetails.profile, 
              initialReport   : initialInfo, 
              lastKnowReport  : lastKnowInfo,
              finalDestination: LatLng(navDetails.destinationLat, navDetails.destinationLng),
              startDestination: LatLng(navDetails.lat, navDetails.lng),
              
              ));
              await Future.delayed(const Duration(milliseconds: 10));
              await setRouteWithPrediction();
          }
        }

      } else{
        await PrincipalDB.clearNavigationDetail();
      }
    }
    if(Preferences.userCiclistPeaton == 1){
      add(WalkingNavigationProfileEvent());
    } else if(Preferences.userCiclistPeaton == 2){
      add(CyclingNavigationProfileEvent());
    }
    if(Preferences.userAirQualityPref == 1){
      add(PollutantNavigationAirQualityPreferencesEvent());
    } else if(Preferences.userAirQualityPref == 2){
      add(TimeNavigationAirQualityPreferencesEvent());
    }
    print('aaaa---> To end navigation----');
  }


  Future onlyStopNavigation() async{
    add(OnlyStopNavigationEvent());
    await PrincipalDB.navigationState(22);
  }

  Future stopNavigation() async{
    add(StopNavigationEvent());
    await PrincipalDB.navigationState(33);
  }

/// ********************1 START NAVIGATION **************************
/// ********************1 START NAVIGATION **************************

  Future<bool> isOnTheArea() async{
    bool response = false;
    final token = await PrincipalDB.getFirebaseToken();
    final resp = await navigationService.isOnTheArea(
        idToken: token,
        coordinates: locationBloc.state.lastKnownLocation!,
      );   
      print('resp is $resp');
      // TODO: THE LOADING 
      if(resp['status'] != null){
        if ( resp['status'] == 200) {
          if(resp['response']['valid'])
            {
              add(IsOnAreaEvent());  
              response = true;
            }
          else if(!resp['response']['valid']){
            add(OutOfAreaEvent());
          }
        } else if(resp['status'] == 401){
          await authService.askForTokenUpdating();
        }
      } else if(resp['error'] != null){
          print('THE ERROR ISSS  ---${resp["error"]}');
      }

    return response;
  }
/// ********************1 START NAVIGATION **************************
/// ********************1 START NAVIGATION **************************
Future<bool> postTrackingStartMikelSpeach() async{
    bool returnAnswer = false;
    await tts.speakTts('Iniciando recorrido');
    return returnAnswer;
  }

  Future<bool> postTrackingStartMikel() async{
    bool returnAnswer = false;
    //TODO VEFIRY GRID STATUS
    // await PrincipalDB.countAllPredictionsGridValues().then((cantVal) async {
    //   print('grid cant val is $cantVal');
    //   if(cantVal > 0){
    //     print('grid IN, MUST UPDATE: ${cantVal > 0}');    
    print('Following---2> ${DateTime.now().toString()}');
    await appDataBloc.checkAndUpdatePredictionsGrid().then((isUpdated) async {
      if(isUpdated == 200){
        returnAnswer = true;
      } else{
        await authService.askForTokenUpdating().then((value) {
          print('TOKEN IS UPDATED XXXXXXX? $value');
        });
        returnAnswer = false;
      }
    });
    print('Following---3> ${DateTime.now().toString()}');
    //   }
    // });
    if(returnAnswer){
      final token = await PrincipalDB.getFirebaseToken();
    print('Following---4> ${DateTime.now().toString()}');
      final resp = await navigationService.postTrackingStartMikel(
          idToken: token,
          // idToken: Preferences.firebaseToken,
          navigationMode: state.navigationMode,
          navigationWay: state.navigationProfile,
          startTime: format.format(DateTime.now()).toString(),
          coordinates: locationBloc.state.lastKnownLocation!,
          streetName: locationBloc.state.lastKnownLocationStreetName!,
        );
        add(ClearAllDataToshow());
      print('Following---5> ${DateTime.now().toString()}');
        await PrincipalDB.clearNavigationDetail();
        // Preferences.clearNavigationPreferences();
        print('resp is $resp');
        // TODO: THE LOADING 
        if (resp['status'] != null ) {
          if(resp['status'] == 200){
            print('routeid is ${resp['response']['route_id']}');
            await PrincipalDB.navigationID(resp['response']['route_id']);
            await PrincipalDB.navigationCantPoints(0);
            await PrincipalDB.navigationNumPointToSent(0);
            await PrincipalDB.navigationLastTimeSent(DateTime.now().toString());
            await PrincipalDB.navigationLastKnowTime(DateTime.now().toString());
            await PrincipalDB.navigationInitTime(DateTime.now().toString());
            await PrincipalDB.startNavigationDetails(StartNavigationModel(
              profile: state.navigationProfile, 
              mode: state.navigationMode, 
              startTime: DateTime.now().toString(), 
              lat: locationBloc.state.lastKnownLocation!.latitude, 
              lng: locationBloc.state.lastKnownLocation!.longitude, 
              startStreetName: locationBloc.state.lastKnownLocationStreetName!,
              destinationLat: state.startAndFinalDestination.isNotEmpty ? state.startAndFinalDestination.last.latitude : 0,
              destinationLng: state.startAndFinalDestination.isNotEmpty ? state.startAndFinalDestination.last.longitude : 0,
            ));


            // Preferences.routeId = resp['response']['route_id'];
            // Preferences.countPointSend = 0;
            // Preferences.navigationLastKnowTime = DateTime.now().toString();
            // Preferences.navigationProfile = state.navigationProfile;
            // Preferences.navigationMode = state.navigationMode;
            // print('To init preference is ${Preferences.routeId}');
            // await service.showNotification(
            //         id: 0,
            //         title: 'Ruteando',
            //         body: 'Regresar a la pagin a de ruteo');
            // backgroundLocationRepository.startForegroundService();
            KeepScreenOn.turnOn();
            // add(BackgroundStartNavigationEvent());
            // add(LiteStartNavigationEvent());
            add(StartNavigationEvent()); // COMMENTED BEACUSE WE DO THIS ON FOREGROUND
            add(OnAlertScreenOnEvent());
            tts.speakTts('Iniciando Recorrido');
            returnAnswer = true;
          } else if (resp['status'] == 401){
              await authService.askForTokenUpdating();
            }
        } else if(resp['error'] != null){
          print('THE ERROR ISSS  ---${resp["error"]}');
        }
    }
    print('Following---10> FIN${DateTime.now().toString()}');
    return returnAnswer;
  }
/// ********************2 TRACKING POSITION **************************
/// ********************2 TRACKING POSITION **************************
// [{air_quality: Buena, distance: 0, exposure: 0, 
//street_name: Calle nn, timestamp: 2022-08-27 08:40:07},
//{air_quality: Mala, distance: 0, exposure: 25.2, 
//street_name: Calle nn, timestamp: 2022-08-27 08:54:37}, 
//{air_quality: Mala, distance: 0, exposure: 25.2,
// street_name: Calle nn, timestamp: 2022-08-27 08:54:47},
//{air_quality: Mala, distance: 0, exposure: 25.2, 
//street_name: Calle nn, timestamp: 2022-08-27 08:54:57}, 
//{air_quality: Mala, distance: 0, exposure: 25.2, 
//street_name: Calle nn, timestamp: 2022-08-27 08:55:07}]


  Future<bool> postTrackingPoints() async{
    int pointCount = await PrincipalDB.getNavigationCantPoint();
    // pointCount += 1;
    // Preferences.countPointSend += 1;
    bool response = false;
    final token = await PrincipalDB.getFirebaseToken();
    final routeID = await PrincipalDB.getNavigationID();
    final lastPointSend = await PrincipalDB.getNavigationNumPointToSent();
    if(lastPointSend != null){
      final listTosend = await PrincipalDB.getPointsToSend(lastPointSend);
      print('3error--------------->>>>> POINTS$listTosend');
      if(listTosend.isNotEmpty){
        await navigationService.postTrackingPoints(
            routeId:  routeID,
            idToken:  token,
            points: listTosend,
            calculatedSegments: pointCount,
            notCalculatedSegments: 0 // TODO: FIX TO REAL DATA
            // pointCount: Preferences.countPointSend,
          ).then((value) async {
            if(value['status'] != null ){
              if(value['status'] == 200){
                await PrincipalDB.navigationNumPointToSent(pointCount);
                await PrincipalDB.navigationLastTimeSent(DateTime.now().toString());
                response=true;
              } else if (value['status'] == 401){
                await authService.askForTokenUpdating();
              } else if (value['status'] == 403){
                // add(OutOfAreaEvent());
              }
            } else if(value['error'] != null){
            print('THE ERROR ISSS  ---${value["error"]}');
          }
          },);
        
      }
    }
    
    return response;
  }
/////////////////// -------------- POST TRACKING POSITON MIKEL --------------
  Future<bool> postTrackingPositionMikel({LatLng? position, String? streetName}) async{
    bool dataToSend = false;
    
    final int pointCount = await PrincipalDB.getNavigationCantPoint();
    print('POINTCANT--->       FOREGROUND $pointCount  cant at ${DateTime.now().toString()}');
    await PrincipalDB.navigationCantPoints(pointCount + 1);
    // await locationPlugin.getLocation().then((posit) {
    //   print('BACKX --------locationPlugin${posit.latitude}');
    //   print('BACKX --------locationPlugin${posit.longitude}');

    // });
    // Geolocator.getCurrentPosition().then((posit){
    //   print('BACKX GEOCODING${posit.latitude}');
    //   print('BACKX GEOCODING${posit.longitude}');
    // });
    final LatLng actualPosition = position ?? locationBloc.state.lastKnownLocation!;
    final String actualstreetName = streetName ?? locationBloc.state.lastKnownLocationStreetName!;
    // isOnAreaFastQuestionWithPoint();
    print('POINTCANT--->       FOREGROUND    ${locationBloc.state.lastKnownLocation?.latitude}');
    print('POINTCANT--->       FOREGROUND    ${locationBloc.state.lastKnownLocation?.longitude}');
    final routeID = await PrincipalDB.getNavigationID();



    //////// FOR TESTING, IMPLEMENT MORE VALIDATIONS HERE
    await appDataBloc.checkAndUpdatePredictionsGrid().then((isUpdated) async {
      if(isUpdated == 200){
        // returnAnswer = true;
      } else{
        await authService.askForTokenUpdating().then((value) {
          print('TOKEN IS UPDATED XXXXXXX? $value');
        });
        // returnAnswer = false;
      }
    });




    await navigationService.postTrackingPositionMikelV2(
        routeId:  routeID,
        // routeId:  Preferences.routeId,
        timestamp: format.format(DateTime.now()).toString(),
        coordinates: actualPosition,
        pointCount: pointCount,
        // pointCount: Preferences.countPointSend,
        streetName: actualstreetName, 
      ).then((value) async {
        // print('mikel resp ..............Will update Date .............');

        print("4error----> resp  ss${value.keys}");
        print("3error----> resp ss${value.values}");
        // print("mikel resp ss${value.runtimeType}");
      
        if(value['error'] == null ){
          add(TrackingEvent(PositionReport.fromMap(value))); 
          if(value['place_alerts'] != null){
            final List<Map<String,dynamic>> pollutionAlertData = value['place_alerts'].cast<Map<String,dynamic>>();
            add(OnPlacesAlertEvent(pollutionAlertData));
            await service.showNotification(
                id: 1,
                title: 'Lugar interesante',
                ongoin: false,
                autoCancel: true,
                indeterminate: false,
                body: value['place_alerts'].first['name']);
                
          }
          if(value['pollution_alerts'] != null){
            add(OnPollutionAlertEvent());
            await service.showNotification(
                id: 2,
                ongoin: false,
                autoCancel: true,
                indeterminate: false,
                title: 'Alerta de contaminacion',
                body: 'Cuidado, lugar altamente contaminado');
          }
          dataToSend = true;
          
        } else if(value['error'] != null){
          // await authService.askForTokenUpdating(); //value['status'] == 401
          // add(OutOfAreaEvent());  // value['status'] == 403
          print('THE ERROR ISSS  ---${value["error"]}');
       }
      },);
    final dataToshow = await PrincipalDB.countAllPoints();
    final lastTimeSend = await PrincipalDB.getNavigationLastTimeSent();
    final initTime = await PrincipalDB.getNavigationInitTime();

    
    if(initTime != null && dataToshow != null){
      final Duration duration = DateTime.now().difference(DateTime.parse(initTime));
      final double idealCantPoint = duration.inSeconds/5;
      final double percentPoint = (pointCount) / idealCantPoint;
      // final double percentPoint = dataToshow / idealCantPoint;
      final String? finaName = await PrincipalDB.getPredictionsGridName();
      print('3error---->---> $finaName');
      print('PERCENT---->>> Percent: $percentPoint idealCantPoint: $idealCantPoint actual cantPoint $pointCount DataToSHOW $dataToshow');
      if(percentPoint <= 1 && percentPoint >= 0){
        add(UpdateDataPercentEvent(percent: percentPoint));
        
      }
      if(idealCantPoint > limitPoints){
        await postTrackingPoints();
        print('END---->>> 3 BEFORE  getInternalTrackingEnd ');
        await getPostInternalTrackingEnd().then((value) async {
          print('END---->>> 44444 innn  getInternalTrackingEnd ');
          await stopNavigation();
          if(locationBloc.state.isInBackground){
            getOutOfApp();
          }
        });
      }
      // else{

      // }
    }
    if(lastTimeSend != null){
      final Duration duration = DateTime.now().difference(DateTime.parse(lastTimeSend));
      if(duration.inMinutes > 1){
        print('PERCENT--------------SEND DATA------------------------');
        postTrackingPoints();
      }
    }

    print('BACKX navigation data to send cant data is ${dataToshow ?? 'NO DATA'}');
    return dataToSend;
  }
/// ********************3 END NAVIGATION **************************
/// ********************3 END NAVIGATION **************************
// [{air_quality: Mala, color: 0xFFF6C244, distance: 0, end_street_name: Calle end, 
//exposure: 25.2, start_street_name: Calle start, total_time: 0}]

    Future<bool> getPostInternalTrackingEnd() async{
      bool response = false;
      final token = await PrincipalDB.getFirebaseToken();
      final routeID = await PrincipalDB.getNavigationID();
      final resp3 = await navigationService.getInternalTrackingEnd(
        routeId:  routeID,
        idToken: token,
        // routeId:  Preferences.routeId,
        // idToken: Preferences.firebaseToken,
        endTimestamp:format.format(DateTime.now()).toString(),
        endCoordinates: locationBloc.state.lastKnownLocation!, 
        streetName: locationBloc.state.lastKnownLocationStreetName!,
      );
      print('resp3 is values ${resp3.values}');
      if(resp3['error'] == null){
        // if(resp3['status'] == 200){
          add(EndingEvent(resp3));
          print('..................Will show.....................');
          print(state.navigationDataToShowTracking);
          // add(StopNavigationEvent());
          // backgroundLocationRepository.stopForegroundService();
          KeepScreenOn.turnOff();
          service.closeNotification();
          await postTrackingReportEnd(
            exposure   : resp3['exposure'] ?? 0, 
            airQuality : resp3['air_quality'] ?? '', 
            color      : resp3['color']  ?? '', 
            distance   : resp3['distance'], 
            totalTime  : resp3['total_time'],
          ).then((itWasSent) {
            if(itWasSent) {
              response =  true;
            }
          });

        // }else if (resp3['status'] == 401){
        //   await authService.askForTokenUpdating();
        // }
        
      } else if(resp3['error'] != null){
        print('THE ERROR ISSS  ---${resp3["error"]}');
      } 
    return response;
  }
    Future<bool> postTrackingReportEnd(
      {
        required double exposure,
        required String airQuality,
        required String color,
        required double distance,
        required int totalTime, 
      }
    ) async{
      bool response = false;
      final token = await PrincipalDB.getFirebaseToken();
      final routeID = await PrincipalDB.getNavigationID();
      final resp3 = await navigationService.postTrackingReportEnd(
        routeId:  routeID,
        idToken: token,
        endTimestamp:format.format(DateTime.now()).toString(),
        endCoordinates: locationBloc.state.lastKnownLocation!,
        endStreetName: locationBloc.state.lastKnownLocationStreetName!,
        exposure: exposure,
        airQuality: airQuality,
        color: color,
        distance: distance,
        totalTime: totalTime,
      );
      print('resp3 is values ${resp3.values}');
      if(resp3['status'] != null){
        if(resp3['status'] == 200){
          print('postTrackingReportEnd  RESPONSE IS $resp3');
          response = true;
        }else if (resp3['status'] == 401){
          await authService.askForTokenUpdating();
        }
        
      } else if(resp3['error'] != null){
        print('THE ERROR ISSS  ---${resp3["error"]}');
      } 
    return response;
  }

/// ********************4 RATE - SCORE THE NAVIGATION **************************
/// ********************4 RATE - SCORE THE NAVIGATION **************************
/// 
  Future<bool> postTrackingScore(double rateVal) async{
    final token = await PrincipalDB.getFirebaseToken();
    final routeID = await PrincipalDB.getNavigationID();
    final resp4 = await navigationService.postTrackingScore(
      routeId:  routeID,
      idToken: token,
      // routeId:  Preferences.routeId,
      // idToken: Preferences.firebaseToken,
      score: rateVal,
    );
    print('resp4 is values ${resp4.values}');
    print('resp4 is keys ${resp4.keys}');
    if(resp4['status'] != null){
      if(resp4['status'] == 200){
        print('THE SCORE Is SUCCCES saved');
        await PrincipalDB.navigationID('');
        // Preferences.routeId = '';
        return true;
      }
    } else if(resp4['error'] != null){
      print('THE ERROR ISSS  ---${resp4["error"]}');
    } 
    return false;
  }

/// ********************4 HISTORY - GET THE NAVIGATION HISTORY**************************
/// ********************4 HISTORY - GET THE NAVIGATION HISTORY**************************
/// 
  Future<bool> getTrackingHistory() async{
    add(OnLoadingEvent());
    bool response = false;
    final token = await PrincipalDB.getFirebaseToken();
    final resp5 = await navigationService.getTrackingHistory(
      idToken: token,
    );
    print('getTrackingHistory is values ${resp5.values}');
    print('getTrackingHistory is keys ${resp5.keys}');
    if(resp5['status'] != null){
      if(resp5['status'] == 200){
        final List<Map<String,dynamic>> histData = resp5['response'].cast<Map<String,dynamic>>();
        add(AddHistoryData(histData));
        response = true;
      }
    } else if(resp5['error'] != null){
      print('THE ERROR ISSS  ---${resp5["error"]}');
    } 
    add(OffLoadingEvent());
    return response;
  }

/// ********************4 NAVIGATION ROUTE  - GET THE NAVIGATION NAVIGATION ROUTE**************************
/// 
  Future<bool> setRouteWithPrediction() async{
  // Future<bool> setRouteWithPrediction({required LatLng start, required LatLng end}) async{
    bool response = false;
    final token = await PrincipalDB.getFirebaseToken();
    final resp6 =  await routeService.getRouteWithPrediction(
      initCoor: locationBloc.state.lastKnownLocation ?? state.startAndFinalDestination.first,
      lastCoor: state.startAndFinalDestination.last, 
      profile: state.navigationProfile,
      idToken: token,
      ); 

    print('Min distanceX getRouteWithPrediction is values ${resp6.values}');
    print('getRouteWithPrediction is keys ${resp6.keys}');
    if(resp6['error'] == null){
        final latLngList = resp6['points'].map((coors) => LatLng(coors[1], coors[0])).toList();
        final List<LatLng> points = latLngList.cast<LatLng>();
        final instructionsList = resp6['instructions'].map((instructions) => InstructionsModel.fromMap(instructions)).toList();
        final List<InstructionsModel> instructions = instructionsList.cast<InstructionsModel>();
        print('Routing destiny is points: ${points.length}');
        print('Routing destiny is points: $points');
        print('Routing destiny instructions: $instructions');
      add(AddNavigationInstructions(instructions));
      locationBloc.add(AddMyRoute(points));  
      response = true;
    } else if(resp6['error'] != null){
      print('THE ERROR ISSS  ---${resp6["error"]}');
    } 
    return response;
  }


  Future<bool> getPlacePreferencesLikeScore() async{
  // Future<bool> setRouteWithPrediction({required LatLng start, required LatLng end}) async{
    bool response = false;
    final token = await PrincipalDB.getFirebaseToken();
    final String placeId = state.placeAlerData.isNotEmpty ? state.placeAlerData.first.id : '';
    if(placeId != ''){
      final resp6 =  await placesPreferencesService.getPlacePreferencesLikeScore(
        placeID: placeId,
        idToken: token,
        ); 

      if(resp6['error'] == null && resp6['status'] == 200){ 
        final Map<String, dynamic> scoredVal = resp6['response'].cast<String,dynamic>();
        print('getPlacePreferencesLikeScore Routing destiny is points:ww ${scoredVal.keys}');
        print('getPlacePreferencesLikeScore Routing destiny is points:ww ${scoredVal.values}');
        add(PlaceVotesEvent(scoredVal['average_score'] ?? 0, scoredVal['number_of_votes'], scoredVal['like'] ?? false));
        response = true;
      } else if(resp6['error'] != null){
        print('getPlacePreferencesLikeScore THE ERROR ISSS  ---${resp6["error"]}');
      } 

    }
    return response;
  }

  Future<bool> postPlacePreferencesLikeScore() async{
  // Future<bool> setRouteWithPrediction({required LatLng start, required LatLng end}) async{
    bool response = false;
    final token = await PrincipalDB.getFirebaseToken();
    final String placeId = state.placeAlerData.isNotEmpty ? state.placeAlerData.first.id : '';
    if(placeId != ''){
      final resp6 =  await placesPreferencesService.postPlacePreferencesLikeScore(
        placeId: placeId,
        idToken: token,
        like: state.locationLiked,
        score: state.locationStars
        ); 

      if(resp6['error'] == null && resp6['status'] == 200){ 
        response = true;
      } else if(resp6['error'] != null){
        print('getPlacePreferencesLikeScore THE ERROR ISSS  ---${resp6["error"]}');
      } 

    }
    return response;
  }



  Future<bool> putNavigationPreferences() async{
    bool response = false;
    final token = await PrincipalDB.getFirebaseToken(); 
    print('preferences--->> state.navigationAirQualityPref ${state.navigationAirQualityPref}');
    print('preferences--->> state.navigationProfile ${state.navigationProfile}');
    final resp6 =  await navigationService.putNavigationPreferences(
      idToken: token,
      navigationAirQualityPref: state.navigationAirQualityPref,
      profile: state.navigationProfile
      ); 

    if(resp6['error'] == null && resp6['status'] == 200){ 
      response = true;
    } else if(resp6['error'] != null){
      print('getPlacePreferencesLikeScore THE ERROR ISSS  ---${resp6["error"]}');
    } 
    return response;
  }


  Future<Map<String,dynamic>> getNavigationPreferencesAndFavoriteDestinations() async{
    final navPrefer = await getNavigationPreferences();
    final favDestini = await getFavoriteDestinations();
    return {
      'pref' : navPrefer,
      'fav' : favDestini,
    };
  }



  Future<bool> getNavigationPreferences() async{
    bool response = false;
    final token = await PrincipalDB.getFirebaseToken(); 

    final resp6 =  await navigationService.getNavigationPreferences(
      idToken: token,
      ); 

    if(resp6['error'] == null){ 
      print('preference----> yyyy ${resp6.keys}');
      print('preference----> yyyy ${resp6.values}');
      final String profile = resp6['preferred_profile'];
      final String param = resp6['route_calculation_parameter'];
      if(param == 'time'){
        add(TimeNavigationAirQualityPreferencesEvent());
        await Preferences.setUserAirQualityPref(2);
      } else if (param == 'pollutant') {
        add(PollutantNavigationAirQualityPreferencesEvent());
        await Preferences.setUserAirQualityPref(1);
      }
      if(profile == 'walking'){
        add(WalkingNavigationProfileEvent());
        await Preferences.setUserCiclistPeaton(1);
      } else if (profile == 'cycling') {
        add(CyclingNavigationProfileEvent());
        await Preferences.setUserCiclistPeaton(2);
      }

      response = true;
    } else if(resp6['error'] != null){
      print('preference----> getNavigationPreferences THE ERROR ISSS  ---${resp6["error"]}');
    } 
    return response;
  }
  Future<bool> getFavoriteDestinations() async{
    bool response = false;
    final token = await PrincipalDB.getFirebaseToken(); 

    final resp6 =  await navigationService.getFavoriteDestinations(
      idToken: token,
      ); 

    if(resp6['error'] == null){ 
      print('preference----> xxxx${resp6.keys}');
      print('preference----> xxxx${resp6.values}');
      final List<Map<String, dynamic>> favoriteRoutes = resp6['response'].cast<Map<String,dynamic>>();
      final List<FavoritePlacesModel> favPlacesNew = [];
      favoriteRoutes.forEach((element) async {
        final FavoritePlacesModel favPlace = FavoritePlacesModel.fromMap(element);
        favPlacesNew.add(favPlace);
        await PrincipalDB.insertFavoritePlace(favPlace);
      },);
      add(AddUpdateFavoritePlacesDataEvent(favPlacesNew));
      print('preference----> ....... $favoriteRoutes');
      response = true;
    } else if(resp6['error'] != null){
      print('preference--->> getFavoriteDestinations THE ERROR ISSS  ---${resp6["error"]}');
    } 
    return response;
  }
  Future<String> postFavoriteDestinations({
    required String tag,
    required String streetName,
    required LatLng coordinates
  }) async{
    String response = '';
    
    final token = await PrincipalDB.getFirebaseToken(); 

    final resp6 =  await navigationService.postFavoriteDestinations(
      idToken: token,
      streetName: streetName,
      coordinates: coordinates,
      tag: tag,
      ); 

    if(resp6['error'] == null){ 
      print('preference----> xxxx${resp6.keys}');
      print('preference----> yyyyy${resp6.values}');
      response = resp6['response']['id'] ?? ''; // must be the token
    } else if(resp6['error'] != null){
      print('getPlacePreferencesLikeScore THE ERROR ISSS  ---${resp6["error"]}');
    } 
    return response;
  }


  Future<String> deleteFavoriteDestination({
    required String favoriteDestinyID,
  }) async{
    String response = '';
    
    final token = await PrincipalDB.getFirebaseToken(); 

    final resp6 =  await navigationService.deleteFavoriteDestination(
      idToken: token,
      favoriteDestinyID: favoriteDestinyID
      ); 

    if(resp6['error'] == null){ 
      print('preference----> xxxx${resp6.keys}');
      print('preference----> yyyyy${resp6.values}');
      await PrincipalDB.deleteAllFavoritePlace();
      await getFavoriteDestinations();
    } else if(resp6['error'] != null){
      print('getPlacePreferencesLikeScore THE ERROR ISSS  ---${resp6["error"]}');
    } 
    return response;
  }











  @override
  Future<void> close() {
    // TODO: implement close
    // backgroundLocationRepository.stopForegroundService();
    return super.close();
  }

  


}
