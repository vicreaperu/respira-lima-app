import 'package:app4/db/principal_db.dart';
import 'package:app4/models/models.dart';
import 'package:app4/services/services.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_data_event.dart';
part 'app_data_state.dart';

class AppDataBloc extends Bloc<AppDataEvent, AppDataState> {
  final PredictionsGridService predictionsGridService;
  final AppDataService appDataService;
  static int forResidualOperatorMin = 15;
  static int forResidualOperatorSec = 30;
  static int timesTryingMin = 5;
  static int timesTryingSec = 7;
  AppDataBloc({
      required this.predictionsGridService,
      required this.appDataService,
    }) : super(const AppDataState()) {
 

    on<IsLoadingAppDataEvent>((event, emit) async {
      emit(state.copyWith(isLoadingAppData: true));
    });
    on<StopLoadingAppDataEvent>((event, emit) async {
      emit(state.copyWith(isLoadingAppData: false));
    });
    on<IsAppData>((event, emit) async {
      emit(state.copyWith(isAppData: true));
    });
    on<IsNotAppData>((event, emit) async {
      emit(state.copyWith(isAppData: false));
    });

    on<SetAppData>((event, emit) async {
      emit(state.copyWith(
        placesAlerts: event.alertPlaces, 
        pollutionCategory: event.alertPollution,
        isAppData: true,
        ));
    });
    _init();
  }
  void _init() async{
    add(IsLoadingAppDataEvent());
    final bool hasAlertData = await getDataAlerts();
    print('ALERT UPDATED');
    if(hasAlertData){
      print('ALERT UPDATED ON');
      add(IsAppData());
    } else{
      print('ALERT UPDATED OF');
      add(IsNotAppData());
    }

    add(StopLoadingAppDataEvent());
  }
  Future<bool> checkAndUpdateAlertsData() async {
    bool returnVal = false;
    await getDataAlerts().then((isUpdated) {
      print('DB pred --------2>>>> WAS EMPTY AND UPDATED OK');
      returnVal = isUpdated;
    });
    // await countAllPredictionsGridValues().then((count) async{
    //   print('DB pred CANT DATA IS  $count');
    //   print('DB pred CANT DATA IS igual to 0? ${count==0}');
    //   if(count == null || count == 0){
    //     await getAllPredictionsGrid().then((isUpdated) {
    //     print('DB pred --------2>>>> WAS EMPTY AND UPDATED OK');
    //     returnVal = isUpdated;
    //   });
    //   }
    // });
    return returnVal;
  }

  Future<bool> getDataAlerts() async{
    bool response = false;
    final places = await PrincipalDB.getPlacesAlerts();
    final pollution = await PrincipalDB.getPollutionCategory();
    print('ALERT UPDATED ON $places');
    print('ALERT UPDATED ON $pollution');
    if(places.isEmpty || pollution.isEmpty){
      
      print('ALERT UPDATED ON INNNNNNNN');
      final String token = await PrincipalDB.getFirebaseToken();
      final resp = await appDataService.getDataAlerts( idToken: token );
      print('ALERT UPDATED ON $resp');
      if (resp['error'] == null){
        print('ALERT UPDATED ON w${resp.values}');
        print('ALERT UPDATED ON w${resp.keys}');
        List<Map<String,dynamic>> alertPlaces = resp['places_to_alert'].cast<Map<String,dynamic>>();
        List<String> alertPollution = resp['pollution_categories_to_alert'].cast<String>();
        // alertPollution.add('Moderada'); // ADDED FOR TESTING
        add(SetAppData(alertPlaces, alertPollution));
        await PrincipalDB.setPlacesAlerts(alertPlaces);
        await PrincipalDB.setPollutionCategory(alertPollution);
        response = true;
      }
    } else{
      add(SetAppData(places, pollution));
      response = true;
    }
    return response; 
  }
  Future<int> checkAndUpdatePredictionsGrid() async {
    int returnVal = 400;
    await PrincipalDB.getPredictionsGridDeadTime().then((timeSaved) async {
      print('Gridx----> TIME WILL DEAD ***** $timeSaved  ****');
      if(timeSaved != null && timeSaved != ''){
        print('Gridx----> TIME WILL DEAD ***** $timeSaved  ****');
        final Duration duration = DateTime.now().difference(DateTime.parse(timeSaved));
        
        print('Gridx----> DURARION IN MINUTES !!!${duration.inMinutes}!!! IN seconds !!!${duration.inSeconds}! and simbol ${duration.isNegative}????');
        print('Gridx----> DURARION IN MINUTES !!!${duration.inMinutes%forResidualOperatorMin}!!! !!!!!${duration.inSeconds%forResidualOperatorSec}!!?');
        if (duration.inSeconds%forResidualOperatorSec < timesTryingSec && duration.inMinutes%forResidualOperatorMin < timesTryingMin && !duration.isNegative){
        // if (duration.inMinutes < timePassedToUpdateGrid ){
          await getAllPredictionsGrid().then((isUpdated) {
              print('Gridx--- DB pred --------1>>>>>>>>>>>>>> DELETED AND UPDATED OK');
              returnVal =  isUpdated;
        });
        } else{
          returnVal = 200;
        }
      } else{
        await getAllPredictionsGrid().then((isUpdated) {
          print('DB pred --------3>>>> UPDATED OK');
          returnVal = isUpdated;

      });
      }
      print('DB pred LAST TIME SAVED is null .. $timeSaved');
    });
    print('socket new map  DB pred --------X0X>>>> xxxx NOT Updated');
    return returnVal;
  }
  Future<int> updatePredictionsGrid() async {
    int returnVal = 400;
    await deleteAllPredictionGrid().then((isDeleted) async {
      print('socket new map  DB pred DELETED DATA?  $isDeleted');
      if(isDeleted){
      await getAllPredictionsGrid().then((isUpdated) {
        print('socket new map  DB pred --------1>>>> DELETED AND UPDATED OK $isUpdated');
        returnVal =  isUpdated;

      });
      } else{
        await countAllPredictionsGridValues().then((count) async{
          print('socket new map  DB pred CANT DATA IS  $count');
          print('socket new map  DB pred CANT DATA IS igual to 0? ${count==0}');
          if(count == null || count == 0){
            await getAllPredictionsGrid().then((isUpdated) {
            print('socket new map  DB pred --------2>>>> WAS EMPTY AND UPDATED OK');
            returnVal = isUpdated;
          });
          }
        });
      }
    });
    return returnVal;
  }

  Future<bool> deleteAllPredictionGrid() async{
    bool valToReturn = false;
    await PrincipalDB.deleteAllPredictionGrid().then((value){
      if(value != null){
        valToReturn = true;
      }
    });
    return valToReturn;
  }



  Future readPredictionsGridFromDB() async{
    print('DB pred before asking all');
    await PrincipalDB.getAllPredictionsGrid().then((value) {
      if(value.length > 0){
        print('DB pred lenght ${value.length}');
        print('DB pred first ${value.first.gridId}');
        print('DB pred first ID - ${value.first.id}');
        print('DB pred last ${value.last.gridId}');
        print('DB pred last ID - ${value.last.id}');
      }
    });
    print('DB pred after asking all');
  }

  Future<int?> countAllPredictionsGridValues()async{
    await PrincipalDB.countAllPredictionsGridValues().then((count) {
      return count;
    });
    return null;
  }

  Future findPredictionFromGridByGridId(String gridID) async{
    await PrincipalDB.findPredictionFromGridByGridId(gridID).then((value) {
      if(value.length > 0){
        print('DB pred bygridID lenght ${value.length}');
        print('DB pred bygridID last ${value.last.gridId}');
        print('DB pred bygridID last ID- ${value.last.id}');
        print('DB pred bygridID first ${value.first.gridId}');
        print('DB pred bygridID first ${value.first.gridId}');
        print('DB pred bygridID first ID - ${value.first.id}');
      }
    });

  }



  Future<int> getAllPredictionsGrid() async{
    int response = 400;
    final String token = await PrincipalDB.getFirebaseToken();
    final String? gridName = await PrincipalDB.getPredictionsGridName();
      print('Gridx---> grid init name $gridName');
    final resp = await predictionsGridService.getAllPredictionsGridV2(
      idToken: token,
      gridName: gridName,

    );
    // final resp = await predictionsGridService.getAllPredictionsGrid(
    //   idToken: token,
    // );
    if (resp['error'] == null){
      // int countID = 1;
      await deleteAllPredictionGrid();
      resp["data"].forEach((key, value) async {
        final GridModel gridMod = GridModel(gridId: key, pm10: value['PM10']??0, pm25: value['PM25']??0);
        await PrincipalDB.insertPredictionValueFromGrid( gridMod);
        // await PrincipalDB.insertPredictionValueFromGridWithCustomID( gridMod, countID);
        // countID += 1;
      });
      await PrincipalDB.predictionsGridName(resp["name"] ?? '');
      await PrincipalDB.predictionsGridDeadTime(resp["expiration_date"] ?? '');
      final DateTime timeNow = DateTime.now();
      await PrincipalDB.predictionsGridTimeUpdated(timeNow.toString());
      print('Gridx---> grid data ${resp["data"]}');
      print('Gridx---> grid name ${resp["name"]}');
      print('Gridx---> expiration date ${resp["expiration_date"]}');
    
      response =  200;
    } else if(resp['error'] == 401) {
      response = 401;
    }
    return response; 
  }
}
