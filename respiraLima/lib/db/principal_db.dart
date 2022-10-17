import 'dart:async';
import 'dart:io';

import 'package:app4/models/models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'package:path/path.dart';


class PrincipalDB {


  // dynamically typed store
  static final store = StoreRef.main();
  static late final String dbPath;
  static late final Directory appDocDirectory;
  static late final DatabaseFactory dbFactory;
  static late final Database _db;
  static const String pointsToSendStoreName = 'pointsToSend';
  static const String predictionsGridStoreName = 'predictionsGrid';
  static late final StoreRef<int, Map<String, Object?>> _pointsToSendStore;
  static late final StoreRef<int, Map<String, Object?>> _predictionsGridStore;


 static Future<String> createFolder(String cow) async {
 final dir = Directory('${(Platform.isAndroid
            ? await getExternalStorageDirectory() //FOR ANDROID
            : await getApplicationSupportDirectory() //FOR IOS
        )!
        .path}/$cow');
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await dir.exists())) {
      return dir.path;
    } else {
      dir.create();
      return dir.path;
    }
  }
  // To init the db
  static Future init() async{
    // print('iinit db 1');
    // appDocDirectory = await getApplicationSupportDirectory();
    // // appDocDirectory = await getApplicationDocumentsDirectory();
    // print('iinit db 2');
    //   // File path to a file in the current directory
    // dbPath = '${appDocDirectory.path}/dibAPP.db';
    // dbPath = await createFolder('dibAPP.db');
    final appDocDirectory = (Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory())!;

    // final appDocDirectory = await getApplicationDocumentsDirectory();
    // dbPath = '${appDocDirectory.path}/dibAPP.db';
    final dbPath = join(appDocDirectory.path, 'demo.db');
    print(dbPath);
    print('iinit db 3');
    dbFactory = databaseFactoryIo;
    print('iinit db 4');
    // We use the database factory to open the database
    _db = await dbFactory.openDatabase(dbPath);
    print('iinit db 5');
    _predictionsGridStore = intMapStoreFactory.store(predictionsGridStoreName);
    print('iinit db 6');
    _pointsToSendStore = intMapStoreFactory.store(pointsToSendStoreName);
    print('iinit db 7');
  }







  //1 ***** AUTH INFO  ->>> PRINCIPAL IDTOKE
  // static String _firebaseToken = '';
  static Future firebaseToken(String value) async{ // ALSO SAVE THE TIME
    await store.record('firebaseToken').put(_db, value);
    final timeSaved = DateTime.now().toString();
    await store.record('timeFirebaseTokenUpdated').put(_db, timeSaved);
    // _firebaseToken = value;
  }
  static Future<String> getFirebaseToken() async{
    final token = await store.record('firebaseToken').get(_db) as String?;
    if(token != null){
      return token;
    } else {
      return '';
    }
  }

  static Future<bool> clearUserInfo() async{
    try{
      await navigationID('');
      // await timeFirebaseTokenUpdated(''); 
      // await firebaseToken(''); 
      await store.record('firebaseToken').delete(_db); 
      await store.record('timeFirebaseTokenUpdated').delete(_db); 
      return true;
    } on Exception catch (e){
      return false;
    } 
    // await clearNavigationDetail();
  }
  
  // static String _timeFirebaseTokenUpdated = '';
  static Future timeFirebaseTokenUpdated(String value) async {
    await store.record('timeFirebaseTokenUpdated').put(_db, value);
    // _timeFirebaseTokenUpdated = value;
  }
  static Future<String?> getTimeFirebaseTokenUpdated() async{
    return await store.record('timeFirebaseTokenUpdated').get(_db) as String?;
  }
  
  
  





///////   RELATED WITH ---->>> GENERAL NAVIGATION INFO
///////   RELATED WITH ---->>> GENERAL NAVIGATION INFO
  //3 ***** NAVIGATION INFO ->>> All related with a navigation

  // static String _navigationID = '';
  static Future navigationID(String value) async {
    await store.record('navigationID').put(_db, value);
    // _navigationID = value;
  }
  static Future<String> getNavigationID() async{
    final id = await store.record('navigationID').get(_db) as String?;
    if(id != null){
      return id;
    } else{
      return '';
    }
  }
  

  // static int    _navigationCountPoint = 0; // Will be used ass ID for the prediction
  
  static Future navigationCantPoints(int value) async {
    await store.record('navigationCountPoint').put(_db, value);
    // _navigationCountPoint = value;
  }
  static Future<int> getNavigationCantPoint() async{
    final count = await store.record('navigationCountPoint').get(_db) as int?;
    if(count != null){
      print('DB Pred ---- NAV CANT POINT COUNT points: $count');
      return count;
    } else{
      return 0;
    }
  }
  static Future navigationLastTimeSent(String value) async {
    await store.record('LatTimeSent').put(_db, value);
    // _navigationLatTimeSent = value;
  }
  static Future<String?> getNavigationLastTimeSent() async{
    final count = await store.record('LatTimeSent').get(_db) as String?;
    if(count != null){
      print('DB Pred ---- NAV CANT POINT COUNT points: $count');
      return count;
    } else{
      return null;
    }
  }
  static Future navigationNumPointToSent(int value) async {
    await store.record('NumPointSent').put(_db, value);
    // _navigationLatTimeSent = value;
  }
  static Future<int?> getNavigationNumPointToSent() async{
    final count = await store.record('NumPointSent').get(_db) as int?;
    if(count != null){
      print('DB Pred ---- NAV CANT POINT COUNT points: $count');
      return count;
    } else{
      return null;
    }
  }


  static Future navigationAcumulatedPM25(double value) async {
    await store.record('navigationAcumulatedPM25').put(_db, value);
    // _navigationCountPoint = value;
  }
  static Future<double> getNavigationAcumulatedPM25() async{
    final count = await store.record('navigationAcumulatedPM25').get(_db) as double?;
    if(count != null){
      return count;
    } else{
      return 0;
    }
  }
  static Future navigationAcumulatedDistance(double value) async {
    await store.record('navigationAcumulatedDistance').put(_db, value);
    // _navigationCountPoint = value;
  }
  static Future<double> getNavigationAcumulatedDistance() async{
    final count = await store.record('navigationAcumulatedDistance').get(_db) as double?;
    if(count != null){
      return count;
    } else{
      return 0;
    }
  }

  




  // static StartNavigationModel _initialNavigationData = StartNavigationModel(
  //   profile: '', mode: '', startTime: '', startLatLng: LatLng(0,0), startStreetName: '');
  static Future startNavigationDetails(StartNavigationModel value) async{
    await store.record('startNavigationDetails').put(_db, value.toMap());
    // _startNavigationDetails = value;
  }
  static Future<StartNavigationModel?> getStartNavigationDetails() async{
    final val = await store.record('startNavigationDetails').get(_db) as Map<String,dynamic>?;
    if(val != null){
      return StartNavigationModel.fromMap(val);
    } else{
      return null;
    }
  }

///////   RELATED WITH ---->>> INTERNAL REPORT TO SHOW
///////   RELATED WITH ---->>> INTERNAL REPORT TO SHOW

  // static String _navigationLastKnowTime = '';
  static Future navigationLastKnowTime(String value) async{
    await store.record('navigationLastKnowTime').put(_db, value);
    // _navigationLastKnowTime = value;
  }
  static Future<String?> getNavigationLastKnowTime() async{
    return await store.record('navigationLastKnowTime').get(_db) as String?;
  }

  // static String _navigationInitialInformation = '';
  static Future navigationInitialInformation(Map<String,dynamic> reportMap) async{
    await store.record('navigationInitialInformation').put(_db, reportMap);
    // _navigationInitialInformation = value;
  }
  static Future<PositionReport?> getNavigationInitialInformation() async{
    final map = await store.record('navigationInitialInformation').get(_db) as Map<String, dynamic>?;
    if(map != null){
      return PositionReport.fromMap(map);
    } else{
      return null;
    }
  }

  // static String _navigationLastKnownInformation = '';
  static Future navigationLastKnownInformation(Map<String,dynamic> reportMap) async{
    await  store.record('navigationLastKnownInformation').put(_db, reportMap);
    // _navigationLastKnownInformation = value;
  }
  static Future<PositionReport?> getNavigationLastKnownInformation() async{
    final map = await store.record('navigationLastKnownInformation').get(_db) as Map<String,dynamic>?;
    if(map != null){
      return PositionReport.fromMap(map);
    } else{
      return null;
    }
  }


  static Future clearNavigationDetail()async {
    await store.record('navigationLastKnowTime').put(_db, ''); 
    await store.record('navigationCountPoint').delete(_db); 
    await store.record('navigationInitialInformation').delete(_db); 
    await store.record('navigationLastKnownInformation').delete(_db); 


    await store.record('navigationAcumulatedPM25').delete(_db); 
    await store.record('navigationAcumulatedDistance').delete(_db); 


    await store.record('startNavigationDetails').delete(_db);
    await store.record('navigationID').delete(_db);
    await deleteAllPoints();
  }










///////   RELATED WITH ---->>> POINTS  TO SEND
///////   RELATED WITH ---->>> POINTS  TO SEND

  static Future insertPoint(PointModel pointModel) async {
    await _pointsToSendStore.add(_db, pointModel.toMap());
  }
  static Future insertUpdatePointsWithCustomID(PointModel pointModel, int id) async {
    await _pointsToSendStore.record(id).put(_db, pointModel.toMap());
  }

  static Future<int?> countAllPoints() async {
    final value = await _pointsToSendStore.count(_db);
    return value;
  }

   
  static Future<List<PointModel>> findPointById(int pointNum) async {
    final finder = Finder(filter: Filter.byKey(pointNum));
    final recordSnapshots = await _pointsToSendStore.find(
      _db,
      finder: finder,
    );
    return recordSnapshots.map((snapshot) {
    final gridModel = PointModel.fromMap(snapshot.value);
    // An ID is a key of a record from the database.
    gridModel.id = snapshot.key;
    return gridModel;
  }).toList();
}
  static Future<List<Map<String,dynamic>>> getPointsToSend(int lastPointId) async {
    final finder = Finder(filter: Filter.greaterThanOrEquals('point_number',lastPointId));
    final recordSnapshots = await _pointsToSendStore.find(
      _db,
      finder: finder,
    );
    return recordSnapshots.map((snapshot) {
    final gridModel = PointModel.fromMap(snapshot.value);
    // An ID is a key of a record from the database.
    gridModel.id = snapshot.key;
    return gridModel.toMapToSend();
  }).toList();
}




  static Future deleteAllPoints() async {
    final finder = Finder(sortOrders: [SortOrder('point_number'),]);
      await _pointsToSendStore.delete(
      _db,
      finder: finder,
    ).then((value) => print('DB ON Deleting all cant $value'));
  }

  static Future<List<PointModel>> getAllPoints() async {
    // Finder object can also sort data.
    final finder = Finder(sortOrders: [
      SortOrder('point_number'),
    ]);

    final recordSnapshots = await _pointsToSendStore.find(
      _db,
      finder: finder,
    );

    // Making a List<positionReport> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final pointModel = PointModel.fromMap(snapshot.value);
      // An ID is a key of a record from the database.
      pointModel.id = snapshot.key;
      return pointModel;
    }).toList();
  }



 ////////////// ALERTS DATAS --------------->>>>>>>>>>
 ////////////// ALERTS DATAS --------------->>>>>>>>>>
 ////////////// ALERTS DATAS --------------->>>>>>>>>>
 ////////////// ALERTS DATAS --------------->>>>>>>>>>
  static Future setPlacesAlerts(List<Map<String, dynamic>> value) async  {
    await store.record('placesAlert').put(_db, value);
    // _predictionsGridTimeUpdated = value;
  }
  static Future<List<Map<String, dynamic>>> getPlacesAlerts() async{
    final list = await store.record('placesAlert').get(_db);
    // List<Map<String, dynamic>>? list = await store.record('placesAlert').get(_db) as List<Map<String, dynamic>>?;
    if(list != null){
      // final listToReturn = list.cast<Map<String, dynamic>>();
      return list.cast<Map<String, dynamic>>();
    } else{
      return [];
    }
  }
  static Future setPollutionCategory(List<String> value) async  {
    await store.record('pollutionCategory').put(_db, value);
    // _predictionsGridTimeUpdated = value;
  }
  static Future<List<String>> getPollutionCategory() async{
    final list = await store.record('pollutionCategory').get(_db);
    if(list != null){
      return list.cast<String>();
    } else{
      return [];
    }
  }





///////   RELATED WITH ---->>> GRID
///////   RELATED WITH ---->>> GRID

//2 ***** PREDICTION GRID INFO  ->>> TO KNOW WHEN TO UPDATE THE DATA
  // static String _predictionsGridTimeUpdated = '';

  static Future predictionsGridTimeUpdated(String value) async  {
    await store.record('predictionsGridTimeUpdated').put(_db, value);
    // _predictionsGridTimeUpdated = value;
  }
  static Future<String?> getPredictionsGridTimeUpdated() async{
    return await store.record('predictionsGridTimeUpdated').get(_db) as String?;
  }

  static Future insertPredictionValueFromGrid(GridModel gridModel) async {
    await _predictionsGridStore.add(_db, gridModel.toMap());
  }
  static Future insertUpdatePredictionValueFromGridWithCustomID(GridModel gridModel, int id) async {
    await _predictionsGridStore.record(id).put(_db, gridModel.toMap());
  }

  static Future<int> countAllPredictionsGridValues() async {
    final val = await _predictionsGridStore.count(_db);
    return val;
  }


  static Future<int?> deleteAllPredictionGrid() async {
    final finder = Finder(sortOrders: [SortOrder('grid_id'),]);
      await _predictionsGridStore.delete(
      _db,
      finder: finder,
    ).then((value) {
      print('DB Pred ---- DELETED CANT $value');
      return value;
    });
    return null;
  }


 
  static Future<List<GridModel>> findPredictionFromGridByGridId(String gridID) async {
    final finder = Finder(filter: Filter.equals('grid_id',gridID));
        final recordSnapshots = await _predictionsGridStore.find(
      _db,
      finder: finder,
    );
    return recordSnapshots.map((snapshot) {
    final gridModel = GridModel.fromMap(snapshot.value);
    // An ID is a key of a record from the database.
    gridModel.id = snapshot.key;
    return gridModel;
  }).toList();
  }


  static Future<List<GridModel>> getAllPredictionsGrid() async {
    // Finder object can also sort data.
    final finder = Finder(sortOrders: [
      SortOrder('grid_id'),
    ]);

    final recordSnapshots = await _predictionsGridStore.find(
      _db,
      finder: finder,
    );

    // Making a List<positionReport> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final gridModel = GridModel.fromMap(snapshot.value);
      // An ID is a key of a record from the database.
      gridModel.id = snapshot.key;
      return gridModel;
    }).toList();
  }








///////   RELATED WITH ---->>> GRID
///////   RELATED WITH ---->>> GRID

  // static String _navigationID = '';
  static Future minMaxLatLng(Map<String, dynamic> map) async {
    await store.record('minMaxLatLng').put(_db, map);
    // _navigationID = value;
  }
  static Future<Map<String, dynamic>> getMinMaxLatLng() async{
    final minMax = await store.record('minMaxLatLng').get(_db) as Map<String, dynamic>?;
    if(minMax != null){
      return minMax;
    } else{
      return {
        'max_latitude' : -12.0303907000975, 
        'max_longitude': -77.0148487754054, 
        'min_latitude' : -12.07985338842309, 
        'min_longitude': -77.0884236816076,
        'updateForActualLimit': true,
        };
    }
  }
  




}