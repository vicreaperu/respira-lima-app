class FavoritePlacesModel {
  late int id;
  final String idF;
  final String streetName;
  final double lat;
  final double lng;
  final String tag;

  FavoritePlacesModel({
    required this.streetName, 
    required this.idF, 
    required this.lat, 
    required this.lng, 
    required this.tag
    });
  
  static FavoritePlacesModel fromMap(Map<String,dynamic> map){
    return FavoritePlacesModel(
      streetName: map['address']!, 
      lng       : map['coordinates'][1], 
      lat       : map['coordinates'][0], 
      tag       : map['name']!,
      idF       : map['id']!,
      );

  }
  Map<String,dynamic> toMap(){
    return{
      'address'    : streetName,
      'coordinates': [lat,lng],
      'name'       : tag,
      'id'         : idF,
    };
  }
}