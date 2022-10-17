import 'package:app4/route_tracking/route_tracking.dart';
import 'package:intl/intl.dart';

import '../sensors_props/sensors.dart';
import 'segment.dart';

//TODO: se podria implementar una lista de puntos dentro de route, y un metodo para enviarlos al api, y cuando ello se de de forma exitosa, se borren los puntos de la lista
class NavigationRoute {
  late String route_id, start_timestamp, end_timestamp;

  NavigationRoute(String route_id) {
    this.route_id = route_id;
  }

  //TODO DB: implementar getters and setter usando la db

  void set current_point(PointMi? current_point) {
    //TODO DB: query to save current point in db
  }

  PointMi? get current_point {
    //TODO DB: query to get current point in db
    return null;
  }

  void set previous_point(PointMi? current_point) {
    //TODO DB: query to save previous point in db
  }

  PointMi? get previous_point {
    //TODO DB: query to get current point in db
    return null;
  }

  void set accumulated_pm25(double accumulated_pm25) {
    //TODO DB: query to update accumulated pm25
  }

  double get accumulated_pm25 {
    //TODO DB: query to update accumulated pm25
    return 1.0;
  }

  void set accumulated_distance(double accumulated_pm25) {
    //TODO DB: query to update accumulated distance
  }

  double get accumulated_distance {
    //TODO DB: query to update accumulated distance
    return 1.0;
  }

  void set valid_points(int valid_points) {
    //TODO DB: query to set valid_points number
  }

  int get valid_points {
    //TODO DB: query to get valid_points
    return 1;
  }

  void set calculated_segments(int valid_points) {
    //TODO DB: query to set valid_segments
  }

  int get calculated_segments {
    //TODO DB: query to get valid_segments
    return 1;
  }

  void set not_calculated_segments(int valid_points) {
    //TODO DB: query to set not_valid_segments
  }

  int get not_calculated_segments {
    //TODO DB: query to get not_valid_segments
    return 1;
  }

  void set start_street_name(String start_street_name) {
    //TODO DB: query to set start_street_name
  }

  String get start_street_name {
    //TODO DB: query to get start_street_name
    return "Calle start";
  }

  void set end_street_name(String start_street_name) {
    //TODO DB: query to set end_street_name
  }

  String get end_street_name {
    //TODO DB: query to get end_street_name
    return "Calle end";
  }

  bool _is_valid_point(PointMi? p) => p != null;

  void start(String start_timestamp, String start_street_name) {
    this.start_timestamp = start_timestamp;
    this.start_street_name = start_street_name;
  }

  /** 
   * Allow add a new point to the current route
  */
  void add_point(PointMi current_point) {
    //will be the same as using /tracking/point

    this.previous_point = this.current_point;

    this.current_point = current_point;
    this.valid_points += 1;

    //verify that previous and current point mus be valid
    if (_is_valid_point(this.current_point) &&
        _is_valid_point(this.previous_point)) {
      Segment current_segment =
          new Segment(this.previous_point!, this.current_point!); 
      this.calculated_segments += 1;
      _update_route_accummulated_params(current_segment);
    } else
      this.not_calculated_segments += 1;
  }

  void end(String end_timestamp, String end_street_name) {
    //POST to end_route
    this.end_timestamp = end_timestamp;
    this.end_street_name = end_street_name;
  }

  /** 
   * Allow update route metrics with data obtained from current point
  */
  void _update_route_accummulated_params(Segment segment_data) {
    this.accumulated_distance += segment_data.distance();
    this.accumulated_pm25 += segment_data.pm25();
  }

  double get _average_pm25 {
    //0 will be the default value
    if (this.calculated_segments == 0) return 0;
    return double.parse(
        (this.accumulated_pm25 / this.calculated_segments).toStringAsFixed(1));
  }

  int get _total_time {
    //calculating the passed time
    DateFormat fmt = DateFormat("yyyy-MM-dd H:m:s");
    DateTime start_date = fmt.parse(this.start_timestamp);
    DateTime end_date = fmt.parse(end_timestamp);
    Duration duration = end_date.difference(start_date);
    return duration.inMinutes;
  }
}

class RouteReporter {
  late String route_id;
  late NavigationRoute route;
  late PM25 _pm25;

  RouteReporter(String route_id, PM25 _pm25) {
    this.route_id = route_id;
    this.route =
        new NavigationRoute(route_id); //permite hacer consultas de parametros hacia db
    this._pm25 = _pm25;
  }

  Map<String, dynamic> get_temporary_report() {
    if (!this.route._is_valid_point(this.route.current_point)) return {};

    double current_pm25 = this.route.current_point!.pm25;

    List<String> air_quality_and_color =
        _pm25.get_category_and_color_hex(current_pm25);
    String air_quality = air_quality_and_color[0];
    String color = air_quality_and_color[1];

    Map<String, dynamic> temporary_report = {
      "exposure": current_pm25,
      "air_quality": air_quality,
      "color": color,
      "timestamp": this.route.current_point!.timestamp,
      "distance": this.route.accumulated_distance,
      "street_name": this.route.current_point!.streetName
    };

    return temporary_report;
  }

  Map<String, dynamic> get_final_report() {
    if (this.route.valid_points == 0) return {};

    double average_pm25 = this.route._average_pm25;

    String air_quality = _pm25.get_category(average_pm25);

    Map<String, dynamic> final_report = {
      "exposure": average_pm25,
      "air_quality": air_quality,
      "total_time": this.route._total_time,
      "distance": this.route.accumulated_distance,
      "start_street_name": this.route.start_street_name,
      "end_street_name": this.route.end_street_name
    };

    return final_report;
  }
}
