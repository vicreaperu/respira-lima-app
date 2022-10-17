
class SensorsData {
  static Map<String,dynamic> sensorPM25 = {
    "color_hex_lookup": {
                          "green": "0xFFA0CE63",
                          "yellow": "0xFFFDFD54",
                          "orange": "0xFFF6C244",
                          "red": "0xFFEA3423"
                          },
    "category_color_lookup": {
                              "Buena": "green",
                              "Moderada": "yellow",
                              "Mala": "orange",
                              "Cuidado": "red"
                              },
    "category_limit_lookup": {
                              "Buena": 0,
                              "Moderada": 12.5,
                              "Mala": 25,
                              "Cuidado": 125
                              },
    "default_color_hex":   "0xFFA0CE63" 
};
}