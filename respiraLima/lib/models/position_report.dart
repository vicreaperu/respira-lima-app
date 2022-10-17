
class PositionReport {
  // Id will be gotten from the database.
  // It's automatically generated & unique for every stored position report.
  late int id;
  final double exposure;
  final String airQuality;
  final String? color;
  final String timestamp;
  final String streetName;
  final double distance;


  PositionReport({
    required this.exposure,
    required this.airQuality,
    required this.color,
    required this.timestamp,
    required this.distance,
    required this.streetName,
  });

  Map<String, dynamic> toMap() {
    return {
      'exposure'    : exposure,
      'air_quality' : airQuality,
      'color'       : color,
      'timestamp'   : timestamp,
      'distance'    : distance,
      'street_name' : streetName,
    };
  }

  static PositionReport fromMap(Map<String, dynamic> map) {
    return PositionReport(
      exposure   : map['exposure'],
      airQuality : map['air_quality'],
      color      : map['color'],
      timestamp  : map['timestamp'],
      distance   : map['distance'],
      streetName : map['street_name'],
    );
  }
}