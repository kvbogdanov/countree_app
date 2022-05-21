//import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class CountreeCity {
  final String name;
  final LatLng center;
  final String uri;

  CountreeCity(name, center, uri)
      : name = name,
        center = center,
        uri = uri;
}

class CountreeCities {
  static List<CountreeCity> cities = <CountreeCity>[CountreeCity("Архангельск", LatLng(64.5399, 40.5159), "https://29.countree.ru")];

  static List<String> get getNames {
    return cities.map((city) => city.name).toList();
  }
}
