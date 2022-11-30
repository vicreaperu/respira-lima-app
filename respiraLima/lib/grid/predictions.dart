import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'script/script_variables.dart';
import 'script/utils.dart';

double _min_latitude = double.parse(min_latitude);
double _min_longitude = double.parse(min_longitude);
double _latitude_offset = double.parse(latitude_offset);
double _longitude_offset = double.parse(longitude_offset);

class NavigationPredictions {
  bool is_ready = false;

  /** 
   * This allows update the internal data_grid used to return predictions
  */
  //TODO DB: SE DEBE GUARDAR EN DB
  void set data_grid(Map<String, dynamic> data_grid) {
  }

  //TODO DB: SE DEBE LEER LA GRILLA DESDE DB
  Map<String, dynamic> get data_grid {

    return {};
  }

  /** 
   * Allow to get the value of pm25 pollution in the given coordinates. In case
   * it is not possible calculate the value, and OutOfPredictionAreaError will
   * be thrown.
  */
  Future<Map<String, dynamic>> getCoordinatesPrediction(LatLng point) async {
    // if (!is_ready) throw NotLoadedPredictionsError();

    List<int> indexes = get_indexes_for_data_grid_with_predictions(point.latitude , point.longitude,
        _min_latitude, _min_longitude, _latitude_offset, _longitude_offset);

    int i = indexes[0], j = indexes[1];

    print("i: ${i} j: ${j}");

    Map<String, dynamic> data = await getDataGridPredictionsUsingIndexes(i, j,
        number_of_cells_for_latitude, number_of_cells_for_longitude, data_grid);

    if (data.isNotEmpty)
    {
      data['i'] = i;
      data['j'] = j;
      return data; 
      // return data['PM25']; 
    }
    else {
      return {'error': 'OUT OF AREA'};
    }
  }
}

class OutOfPredictonAreaError implements Exception {
  void default_message() => print(
      "OutOfPredictionAreaError: the passed coordinates area outside of prediction area.");
}

class NotLoadedPredictionsError implements Exception {
  void default_message() => print(
      "NotLoadedPredictionsError: the predictions object needs an object with grid file loaded using the set_data_grid method.");
}
