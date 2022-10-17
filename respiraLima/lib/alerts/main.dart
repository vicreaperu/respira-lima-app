import '../sensors_props/sensors.dart';
import 'alerts_Abstract_class.dart';

void main() {
  // test_place_alerts();
  // test_pollution_alerts();
  test_all_alerts();
}

void test_place_alerts() {
  PlaceAlerts placeAlerts = new PlaceAlerts();

  Map<String, dynamic> alert_data = {
    // "previous_point":{
    //   "lat":-12.040782
    //   "lon":-77.0405011
    // },
    "current_point": {"lat": -12.040782, "lon": -77.0405011},
  };
  dynamic alerts = placeAlerts.get_alerts(alert_data);
  print("alerts: ${alerts}");
}

//se tiene que añadir el tema de colocar
void test_pollution_alerts() {
  PM25 pm25 = new PM25();
  PollutionAlerts pollutionAlerts = new PollutionAlerts(pm25);

  Map<String, dynamic> alert_data = {
    "previous_point": {"lat": -12.050782, "lon": -77.0405011, "pm25": 9.5},
    "current_point": {"lat": -12.040782, "lon": -77.0405011, "pm25": 33.2},
  };

  dynamic alerts = pollutionAlerts.get_alerts(alert_data);

  print("alerts: ${alerts}");
}

void test_all_alerts() {
  Map<String, dynamic> alert_data = {
    "previous_point": {"lat": -12.050782, "lon": -77.0405011, "pm25": 9.5},
    "current_point": {"lat": -12.040782, "lon": -77.0405011, "pm25": 33.2},
  };

  final alerts = get_alerts_to_send(alert_data);
  print("alerts: ${alerts}");
}
