import 'dart:async';
import 'dart:io';

import 'package:app4/models/position_report.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';


class PositionReportDB {


  // dynamically typed store
  static final store = StoreRef.main();
  static late final String dbPath;
  static late final Directory appDocDirectory;
  static late final DatabaseFactory dbFactory;
  static late final Database _db;
  static const String positionReportStoreName = 'positionReports';
  static const String gridPredictionStoreName = 'positionReports';
  static late final StoreRef<int, Map<String, Object?>> _positionReportStore;


  static String _navigationIdToken = '';


  // To init the db
  static Future init() async{
    appDocDirectory = await getApplicationDocumentsDirectory();
      // File path to a file in the current directory
    dbPath = appDocDirectory.path+'/'+'dibAPP.db';
    dbFactory = databaseFactoryIo;
    // We use the database factory to open the database
    _db = await dbFactory.openDatabase(dbPath);
    _positionReportStore = intMapStoreFactory.store(positionReportStoreName);
  }

  static set navigationIdToken(String value) {
    store.record('navigationIdToken').put(_db, value);
    _navigationIdToken = value;
  }
  static Future<String> getNavigationIdToken() async{
    
    await store.record('navigationIdToken').get(_db).then((value) => {
      if(value != null){
        value.toString()
      }
    });
    return '';
  }
  static Future insert(PositionReport positionReport) async {
    await _positionReportStore.add(_db, positionReport.toMap());
  }

  static Future delete(PositionReport positionReport) async {
    final finder = Finder(filter: Filter.byKey(positionReport.id));
    await _positionReportStore.delete(
      await _db,
      finder: finder,
    );
  }




  static Future deleteAll(PositionReport positionReport) async {
    final finder = Finder(sortOrders: [SortOrder('timestamp'),]);
      await _positionReportStore.delete(
      _db,
      finder: finder,
    ).then((value) => print('DB ON Deleting all cant $value'));
  }



  static Future<List<PositionReport>> getAllSortedByName() async {
    // Finder object can also sort data.
    final finder = Finder(sortOrders: [
      SortOrder('timestamp'),
    ]);

    final recordSnapshots = await _positionReportStore.find(
      _db,
      finder: finder,
    );

    // Making a List<positionReport> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final positionReport = PositionReport.fromMap(snapshot.value);
      // An ID is a key of a record from the database.
      positionReport.id = snapshot.key;
      return positionReport;
    }).toList();
  }

}