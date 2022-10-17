class LimitModel {
  final double maxLat;
  final double maxLng;
  final double minLat;
  final double minLng;

  LimitModel({
    required this.maxLat, 
    required this.maxLng, 
    required this.minLat, 
    required this.minLng
    });
  
  static LimitModel fromMap(Map<String,dynamic> map){
    return LimitModel(
      maxLat: map['max_latitude']!, 
      maxLng: map['max_longitude']!, 
      minLat: map['min_latitude']!, 
      minLng: map['min_longitude']!,
      );

  }
  Map<String,dynamic> toMap(){
    return{
      'max_latitude'  : maxLat,
      'max_longitude' : maxLng,
      'min_latitude'  : minLat,
      'min_longitude' : minLng,
    };
  }
}