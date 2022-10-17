import 'dart:io';

import 'package:app4/db/db.dart';
import 'package:app4/models/models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';

class PositionReportDao {

  
  static late Directory appDocDirectory;

  
  static const String pOSITION_REPORT_STORE_NAME = 'positionReports';
  // A Store with int keys and Map<String, dynamic> values.
  // This Store acts like a persistent map, values of which are positionReport objects converted to Map
  static late final StoreRef<int, Map<String, Object?>> _positionReportStore;

  static Future init() async{
    appDocDirectory = await getApplicationDocumentsDirectory();
      // File path to a file in the current directory
    String dbPath = appDocDirectory.path+'/'+'sample.db';
    _positionReportStore = intMapStoreFactory.store(pOSITION_REPORT_STORE_NAME);
  }
  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insert(PositionReport positionReport) async {
    await _positionReportStore.add(await _db, positionReport.toMap());
  }

  Future update(PositionReport positionReport) async {
    // For filtering by key (ID), RegEx, greater than, and many other criteria,
    // we use a Finder.
    final finder = Finder(filter: Filter.byKey(positionReport.id));
    await _positionReportStore.update(
      await _db,
      positionReport.toMap(),
      finder: finder,
    );
  }

  Future delete(PositionReport positionReport) async {
    final finder = Finder(filter: Filter.byKey(positionReport.id));
    await _positionReportStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future<List<PositionReport>> getAllSortedByName() async {
    // Finder object can also sort data.
    final finder = Finder(sortOrders: [
      SortOrder('street_name'),
    ]);

    final recordSnapshots = await _positionReportStore.find(
      await _db,
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