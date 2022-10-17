//permite obtener el valor del contaminante a partir de una grilla

import 'package:app4/db/db.dart';

int get_index_for_data_grid_with_predictions(
    double centroidValue, double minValue, double offsetValue) {
  int indexValue;
  if (centroidValue == minValue)
    indexValue = 1;
  else
    indexValue = (centroidValue - minValue) ~/ offsetValue;

  return indexValue;
}

//in python has data_grid_with_predictions but this is not used
List<int> get_indexes_for_data_grid_with_predictions(
    double latCentroid,
    double lonCentroid,
    double minLatitude,
    double minLongitude,
    double latitudeOffset,
    double longitudeOffset) {
  int i = get_index_for_data_grid_with_predictions(
      latCentroid, minLatitude, latitudeOffset);
  int j = get_index_for_data_grid_with_predictions(
      lonCentroid, minLongitude, longitudeOffset);

  return [i, j];
}

Future<Map<String, dynamic>> getDataGridPredictionsUsingIndexes(
    int i,
    int j,
    int numberOfCellsForLatitude,
    int numberOfCellsForLongitude,
    Map<String, dynamic> dataGridWithPredictions) 
 async{
  Map<String, dynamic> dataGridInformation = {};

  if ((i > 0) &&
      (j > 0) &&
      (i <= numberOfCellsForLatitude) &&
      (j <= numberOfCellsForLongitude)) {
    //NOTE: additional step, to use the json file, convert key into string
    String key = "($i, $j)";

    final predict = await PrincipalDB.findPredictionFromGridByGridId(key);
    print('mikel resp FROM KYE IS ------> $key');
    print('mikel resp FROM DB   ------> $predict');
    print('mikel resp FROM DB  is empty?? ------> ${predict.isEmpty}');
    if(predict.isNotEmpty){
      return predict[0].toMap() ;
    } 

      //   if (data_grid_with_predictions.containsKey(key))
      //     data_grid_information = data_grid_with_predictions[key];
      // }

      // return data_grid_information;

  } 
  dataGridInformation = {'error':666, 'type': 'OUT OF AREA'};
  return dataGridInformation;
  
}

