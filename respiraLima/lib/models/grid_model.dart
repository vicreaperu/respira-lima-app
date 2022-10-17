class GridModel{
  late int id;
  final String gridId;
  // final Map<String, dynamic> predictions;

  final double pm10;
  final double pm25;

  GridModel({
    required this.gridId, 
    // required this.predictions,
    required this.pm10, 
    required this.pm25
    });

    static GridModel fromMap(Map<String, dynamic>map){
      return GridModel(
        gridId     : map['grid_id'], 
        pm10       : map['pm_10'],
        pm25       : map['pm_25'],
        // predictions: map['prediction'],
        );
    }

  Map<String, dynamic> toMap() {
    return {
      'grid_id'  : gridId,
      'pm_10'     : pm10,
      'pm_25'     : pm25,
    };
  }
  // Map<String, dynamic> toMap() {
  //   return {
  //     'pm10'  : pm10,
  //     'pm25'  : pm25
  //   };
  // }

}