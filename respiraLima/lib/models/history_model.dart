
class HistoryModel {
//  {
//distance: 0.0, 
//end_street_name: Calle Santiago Acuña 180, 
//exposure: 6.77, 
//profile: walking, 
//start_street_name: Calle Santiago Acuña 180, 
//start_timestamp: 2022-10-03 12:46:09, 
//total_time: 9.0
//}
  late int id;
  final double distance;
  final double exposure;
  final double totalTime;
  final String startStreetName;
  final String endStreetName;
  final String profile;
  final String startTimestamp;


  HistoryModel({
    required this.distance,
    required this.exposure,
    required this.profile,


    required this.startStreetName,
    required this.endStreetName,
    required this.totalTime,
    required this.startTimestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'exposure'          : exposure,
      'profile'           : profile,
      'distance'          : distance,
      'start_street_name' : startStreetName,
      'end_street_name'   : endStreetName,
      'total_time'        : totalTime,
      'start_timestamp'   : startTimestamp,
    };
  }

  static HistoryModel fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      exposure        : map['exposure'],
      profile         : map['profile'],
      distance        : map['distance'],
      startStreetName : map['start_street_name'],
      endStreetName   : map['end_street_name'],
      totalTime       : map['total_time'],
      startTimestamp  : map['start_timestamp'],
    );
  }
}