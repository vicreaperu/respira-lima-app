
import 'package:app4/alerts/alerts_data.dart';
import 'package:app4/db/principal_db.dart';
import 'package:app4/helpers/helpers.dart';

import '../sensors_props/sensors.dart';

abstract class AlertsAbstractClass {
  //must be overrided
  Future<List<dynamic>> detect_alert_with_current_and_previous_data(
      Map<String, dynamic> current_point, Map<String, dynamic> previous_point) async{
    return [];
  }

  //must be overrided
  Future<List<dynamic>> detect_alert_with_current_data_only(
      Map<String, dynamic> current_point) async {
    return [];
  }

  Future<List<dynamic>> get_alerts(Map<String, dynamic> alert_data) async{
    bool valid_current_point = alert_data["current_point"] != null;
    bool valid_previous_point = alert_data["previous_point"] != null;

    if (valid_current_point && valid_previous_point)
      return await detect_alert_with_current_and_previous_data(
          alert_data["current_point"], alert_data["previous_point"]);
    else if (valid_current_point){
      return await detect_alert_with_current_data_only(alert_data["current_point"]);

    }
    return [];
  }
}

class PlaceAlerts extends AlertsAbstractClass {
  double max_distance = 0.15; // in km

  //TODO DB: SE DEBE GUARDAR EN LA DB
  void set places(List<dynamic> places) {
    this.places = places;
  }

  //TODO DB: SE DEBE LEER DE LA BD
  Future<List<Map<String, dynamic>>> getPlaces() async {
    //TODO: simulando la respuesta desde un archivo estatico
    // Map<String, dynamic> alerts_data = read_file('./alerts/alerts_data.json');
   
    return await PrincipalDB.getPlacesAlerts();
  }

  @override
  Future<List<dynamic>> detect_alert_with_current_data_only(
      Map<String, dynamic> current_point) async{
    List<dynamic> places_to_send_alert = [];
    double current_lat = current_point["latitude"],
        current_lon = current_point["longitude"];
    await getPlaces().then((places) {
      places.forEach((placeX) {
        final place = Map.of(placeX);
        double place_lat = place["lat"], place_lon = place["lon"];
        double distance = get_coordinates_distance(
            current_lat, current_lon, place_lat, place_lon);

        if (distance < this.max_distance) {
          place["distance"] = distance;
          places_to_send_alert.add(place);
        }
      });

    });

    return places_to_send_alert;
  }

  @override
  Future<List<dynamic>> detect_alert_with_current_and_previous_data(
      Map<String, dynamic> current_point, Map<String, dynamic> previous_point) async {

    List<dynamic> places_to_send_alert = [];

    double current_lat = current_point["latitude"],
        current_lon = current_point["longitude"];
    double previous_lat = previous_point["latitude"],
        previous_lon = previous_point["longitude"];
    await getPlaces().then((places) {
      places.forEach((placeX) {
        final place = Map.of(placeX);
        double place_lat = place["lat"], place_lon = place["lon"];

        double current_distance = get_coordinates_distance(
            current_lat, current_lon, place_lat, place_lon);
        double previous_distance = get_coordinates_distance(
            previous_lat, previous_lon, place_lat, place_lon);

        bool is_allert_trigger_current = current_distance <= this.max_distance;
        bool is_allert_trigger_previous = previous_distance <= this.max_distance;

        if (is_allert_trigger_current && !is_allert_trigger_previous) {
          place["distance"] = current_distance;
          places_to_send_alert.add(place);
        }
      });

    });

    return places_to_send_alert;
  }
}

class PollutionAlerts extends AlertsAbstractClass {
  late PM25 _pm25;

  PollutionAlerts(PM25 _pm25) {
    this._pm25 = _pm25;
  }

  //TODO DB: se debe setear a la base de datos
  void set pollution_categories_to_alert(
      Set<String> pollution_categories_to_alert) {}

  //TODO DB: se debe leer de la base de datos
  Future<List<String>> getPollution_categories_to_alert() async {
    //de momento solo se esta simulando con la lectura de un archivo estatico
    // Map<String, dynamic> alerts_data = read_file('./alerts/alerts_data.json');
    // return new Set<String>.from(AllertsData.pollutionCategory["pollution_categories_to_alert"]);
    return await PrincipalDB.getPollutionCategory();
  }

  @override
  Future<List<dynamic>> detect_alert_with_current_data_only(
      Map<String, dynamic> current_point) async {
    List<dynamic> pollution_alerts = [];

    double current_pollution = current_point["pm25"];
    List<String> current_category_and_color =
        _pm25.get_category_and_color_hex(current_pollution);
    String current_pollution_category = current_category_and_color[0],
        current_pollution_color = current_category_and_color[1];

    await getPollution_categories_to_alert().then((value){
      final pollution_categories_to_alert = value.toSet();
      print('ALERT UPDATED all xxxxx $pollution_categories_to_alert');
      print('ALERT UPDATED curretn xxxxx $current_pollution_category');
      if (pollution_categories_to_alert.contains(current_pollution_category)) {
        pollution_alerts.add({
          "color": current_pollution_color,
          "category": current_pollution_category
        });
      }
    });
    print('ALERT UPDATED response xxxx $pollution_alerts');
    return pollution_alerts;
  }

  @override
  Future<List<dynamic>> detect_alert_with_current_and_previous_data(
      Map<String, dynamic> current_point, Map<String, dynamic> previous_point) async{
    List<dynamic> pollution_alerts = [];

    double current_pollution = current_point["pm25"];
    List<String> current_category_and_color =
        _pm25.get_category_and_color_hex(current_pollution);
    String current_pollution_category = current_category_and_color[0],
        current_pollution_color = current_category_and_color[1];

    double previous_pollution = previous_point["pm25"];
    String previous_pollution_category = _pm25.get_category(previous_pollution);
    
    await getPollution_categories_to_alert().then((value){
      final pollution_categories_to_alert = value.toSet();
      print('ALERT UPDATED all $pollution_categories_to_alert');
      print('ALERT UPDATED curretn $current_pollution_category');
      bool is_current_category_alertable = pollution_categories_to_alert.contains(current_pollution_category);
      print('ALERT UPDATED response $is_current_category_alertable');

      if (is_current_category_alertable &&
          current_pollution_category != previous_pollution_category) {
        pollution_alerts.add({
          "color": current_pollution_color,
          "category": current_pollution_category
        });
      }
    });
    print('ALERT UPDATED response $pollution_alerts');
    

    return pollution_alerts;
  }
}

class NotLoadedPredictionsError implements Exception {
  void default_message() => print(
      "NotLoadedPredictionsError: the predictions object needs an object with grid file loaded using the set_data_grid method.");
}

Future<Map<String, dynamic>> get_alerts_to_send(Map<String, dynamic> alert_data) async{
  Map<String, dynamic> all_alerts = {};

  PM25 pm25 = PM25();

  PollutionAlerts pollutionAlerts = PollutionAlerts(pm25);
  List<dynamic> pollution_alert_list = await pollutionAlerts.get_alerts(alert_data);

  if (pollution_alert_list.isNotEmpty)
    all_alerts["pollution_alerts"] = pollution_alert_list;

  PlaceAlerts placeAlerts = PlaceAlerts();
  List<dynamic> place_alert_list = await placeAlerts.get_alerts(alert_data);

  if (place_alert_list.isNotEmpty)
    all_alerts["place_alerts"] = place_alert_list;

  return all_alerts;
}
