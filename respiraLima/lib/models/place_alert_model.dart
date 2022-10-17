
class PlaceAlertModel {
  // Id will be gotten from the database.
  // It's automatically generated & unique for every stored position report.
  final double lat;
  final double lon;
  final String name;
  final String description;
  final double distance;
  final String id;
  final String imgUrl;
  final String type;



  PlaceAlertModel({
    required this.id,
    required this.imgUrl,
    required this.type,
    required this.lat,
    required this.lon,
    required this.name,
    required this.description,
    required this.distance,

  });

  Map<String, dynamic> toMap() {
    return {
      'id'          : id,
      'img_url'     : imgUrl,
      'type'        : type,
      'lat'         : lat,
      'lon'         : lon,
      'name'        : name,
      'distance'    : distance,
      'description' : description,
    };
  }

  static PlaceAlertModel fromMap(Map<String, dynamic> map) {
    return PlaceAlertModel(
      id          : map['id'],
      imgUrl      : map['img_url'],
      type        : map['type'],
      lat         : map['lat'],
      lon         : map['lon'],
      name        : map['name'],
      distance    : map['distance'],
      description : map['description'] ?? '',

    );
  }
}