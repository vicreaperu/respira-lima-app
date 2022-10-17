import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:intl/intl.dart';

Map<String, dynamic> read_file(String file_name) {
  var input = File(file_name).readAsStringSync();
  var content = jsonDecode(input);
  return content;
}

List<dynamic> read_list(String file_name) {
  var input = File(file_name).readAsStringSync();
  var content = jsonDecode(input);
  return content;
}

String get_timestamp() {
  DateTime d = DateTime.now();
  DateFormat fmt = DateFormat("yyyy-MM-dd H:m:s");
  String d_str = fmt.format(d);
  return d_str;
}

double get_coordinates_distance(
  double lat_1, double lon_1, double lat_2, double lon_2) {
  //lambda function to get radians
  double to_radians(deg) => deg * pi / 180.0;

  double lat_1_r = to_radians(lat_1), lon_1_r = to_radians(lon_1);
  double lat_2_r = to_radians(lat_2), lon_2_r = to_radians(lon_2);

  double earth_radius = 6371.0; //in km
  double d_lat = lat_2_r - lat_1_r;
  double d_lon = lon_2_r - lon_1_r;

  num a = pow(sin(d_lat / 2), 2) +
      cos(lat_1_r) * cos(lat_2_r) * pow(sin(d_lon / 2), 2);

  return 2 * earth_radius * asin(sqrt(a));
}
double get_coordinates_distance_meters(
  double lat_1, double lon_1, double lat_2, double lon_2) {
  //lambda function to get radians
  double to_radians(deg) => deg * pi / 180.0;

  double lat_1_r = to_radians(lat_1), lon_1_r = to_radians(lon_1);
  double lat_2_r = to_radians(lat_2), lon_2_r = to_radians(lon_2);

  double earth_radius = 6371.0; //in km
  double d_lat = lat_2_r - lat_1_r;
  double d_lon = lon_2_r - lon_1_r;

  num a = pow(sin(d_lat / 2), 2) +
      cos(lat_1_r) * cos(lat_2_r) * pow(sin(d_lon / 2), 2);

  return 2000 * earth_radius * asin(sqrt(a));
}
