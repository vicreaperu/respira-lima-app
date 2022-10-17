// To parse this JSON data, do
//
//     final places = placesFromMap(jsonString);

import 'dart:convert';

class Places {
    Places({
        required this.type,
        required this.query,
        required this.features,
        required this.attribution,
    });

    final String type;
    final List<String> query;
    final List<Feature> features;
    final String attribution;

    factory Places.fromJson(String str) => Places.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Places.fromMap(Map<String, dynamic> json) => Places(
        type: json["type"],
        query: List<String>.from(json["query"].map((x) => x)),
        features: List<Feature>.from(json["features"].map((x) => Feature.fromMap(x))),
        attribution: json["attribution"],
    );

    Map<String, dynamic> toMap() => {
        "type": type,
        "query": List<dynamic>.from(query.map((x) => x)),
        "features": List<dynamic>.from(features.map((x) => x.toMap())),
        "attribution": attribution,
    };
}

class Feature {
    Feature({
       required this.id,
       required this.type,
       required this.properties,
       required this.textEs,
       required this.placeNameEs,
       required this.text,
       required this.placeName,
       required this.center,
       required this.geometry,
       required this.context,
    });

    final String id;
    final FeatureType? type;
    final Properties properties;
    final String textEs;
    final String placeNameEs;
    final String text;
    final String placeName;
    final List<double> center;
    final Geometry geometry;
    final List<Context> context;

    factory Feature.fromJson(String str) => Feature.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Feature.fromMap(Map<String, dynamic> json) => Feature(
        id: json["id"],
        type: featureTypeValues.map[json["type"]],
        properties: Properties.fromMap(json["properties"]),
        textEs: json["text_es"],
        placeNameEs: json["place_name_es"],
        text: json["text"],
        placeName: json["place_name"],
        center: List<double>.from(json["center"].map((x) => x.toDouble())),
        geometry: Geometry.fromMap(json["geometry"]),
        context: List<Context>.from(json["context"].map((x) => Context.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "type": featureTypeValues.reverse[type],
        "properties": properties.toMap(),
        "text_es": textEs,
        "place_name_es": placeNameEs,
        "text": text,
        "place_name": placeName,
        "center": List<dynamic>.from(center.map((x) => x)),
        "geometry": geometry.toMap(),
        "context": List<dynamic>.from(context.map((x) => x.toMap())),
    };
    @override
  String toString() {
    // TODO: implement toString
    return 'Feature $text';
  }
}

class Context {
    Context({
       required this.id,
       required this.textEs,
       required this.text,
       required this.wikidata,
       required this.languageEs,
       required this.language,
       required this.shortCode,
    });

    final String    id;
    final String    textEs;
    final String    text;
    final String   ?wikidata;
    final String   ?languageEs;
    final String   ?language;
    final String   ?shortCode;

    factory Context.fromJson(String str) => Context.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Context.fromMap(Map<String, dynamic> json) => Context(
        id: json["id"],
        textEs: json["text_es"],
        text: json["text"],
        wikidata: json["wikidata"],
        languageEs: json["language_es"] ,
        language: json["language"] ,
        shortCode: json["short_code"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "text_es": textEs,
        "text": text,
        "wikidata": wikidata,
        "language_es": languageEs ,
        "language": language ,
        "short_code": shortCode,
    };
}



class Geometry {
    Geometry({
       required this.type,
       required this.coordinates,
    });

    final GeometryType? type;
    final List<double> coordinates;

    factory Geometry.fromJson(String str) => Geometry.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Geometry.fromMap(Map<String, dynamic> json) => Geometry(
        type: geometryTypeValues.map[json["type"]],
        coordinates: List<double>.from(json["coordinates"].map((x) => x.toDouble())),
    );

    Map<String, dynamic> toMap() => {
        "type": geometryTypeValues.reverse[type],
        "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
    };
}

enum GeometryType { POINT }

final geometryTypeValues = EnumValues({
    "Point": GeometryType.POINT
});

enum PlaceType { ADDRESS }

final placeTypeValues = EnumValues({
    "address": PlaceType.ADDRESS
});

class Properties {
    Properties({
        required this.accuracy,
    });

    final Accuracy? accuracy;

    factory Properties.fromJson(String str) => Properties.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Properties.fromMap(Map<String, dynamic> json) => Properties(
        accuracy: accuracyValues.map[json["accuracy"]],
    );

    Map<String, dynamic> toMap() => {
        "accuracy": accuracyValues.reverse[accuracy],
    };
}

enum Accuracy { STREET }

final accuracyValues = EnumValues({
    "street": Accuracy.STREET
});

enum FeatureType { FEATURE }

final featureTypeValues = EnumValues({
    "Feature": FeatureType.FEATURE
});

class EnumValues<T> {
    Map<String, T> map;
    Map<T, String>? reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        reverseMap ??= map.map((k, v) => MapEntry(v, k));
        return reverseMap!;
    }
}
