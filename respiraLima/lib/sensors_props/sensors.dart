import 'package:app4/helpers/helpers.dart';
import 'package:app4/sensors_props/sensors_props.dart';
import 'package:bisection/bisection.dart';


class PM25 {
  bool is_ready = false;

  late Map<String, dynamic> _category_limit_lookup;
  late Map<String, dynamic> _category_color_lookup;
  late Map<String, dynamic> _color_hex_lookup;

  late List<num> _category_limits_values;
  late List<String> _category_names;

  late String _default_color_hex;

  PM25() {
    this._initialize_params();
    is_ready = true;
  }

  //TODO DB: SE DEBE HACER LA ESCRITURA A DB CADA VEZ QUE SE QUIERA HACER UNA ACTUALIZACION
  void set data_dict(Map<String, dynamic> data_dict) {}

  //TODO DB: SE DEBE HACER LA LECTURA A DB
  Map<String, dynamic> get data_dict {
    //DE MOMENTO ESTA SIMULANDO LECTURA A ARCHIVO
    // Map<String, dynamic> sensors_props =
    //     read_file('./sensors_props/sensors_data.json');
    Map<String, dynamic> pm25_props = SensorsData.sensorPM25;
    return pm25_props;
  }

  void _initialize_params() {
    _category_limit_lookup = this.data_dict["category_limit_lookup"];
    _category_color_lookup = this.data_dict["category_color_lookup"];
    _color_hex_lookup = this.data_dict["color_hex_lookup"];
    _default_color_hex = this.data_dict["default_color_hex"];
    _category_limits_values = new List.from(_category_limit_lookup.values);
    _category_names = new List.from(_category_limit_lookup.keys);
  }

  String get_category(num value) {
    if (!is_ready) throw NotLoadedSensorPropsError();
    int idx = 0; //by default return the first category for negative numbers
    if (value >= this._category_limits_values[0])
      idx = bisect_right(this._category_limits_values, value) - 1;
    return this._category_names[idx];
  }

  String _get_color_hex_from_category(String category) =>
      _color_hex_lookup[_category_color_lookup[category]] ?? _default_color_hex;

  List<String> get_category_and_color_hex(num value) {
    if (!is_ready) throw NotLoadedSensorPropsError();
    String category = this.get_category(value);
    String color = _get_color_hex_from_category(category);
    return [category, color];
  }
}

class NotLoadedSensorPropsError implements Exception {
  void default_message() => print(
      "NotLoadedSensorPropsError: the sensor colors object needs an object with a file loaded using the set_props method.");
}
