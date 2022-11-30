
class LinkModel {
  late int id;
  final String linkName;
  final String linkUrl;
 
  LinkModel({
    required this.linkName,
    required this.linkUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name'          : linkName,
      'url'           : linkUrl,
    };
  }

  static LinkModel fromMap(Map<String, dynamic> map) {
    return LinkModel(
      linkName        : map['name'],
      linkUrl         : map['url'],
    );
  }
}