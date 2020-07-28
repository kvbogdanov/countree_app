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
  static List<CountreeCity> cities = <CountreeCity>[
    CountreeCity("Красноярск", LatLng(56.01115, 92.85290), "https://24.countree.ru"),
    CountreeCity("Минусинск", LatLng(53.7166, 91.6995), "https://24.countree.ru"),
    CountreeCity("Назарово", LatLng(56.0138, 90.4124), "https://24.countree.ru"),
    CountreeCity("Дивногорск", LatLng(55.966507, 92.380403), "https://24.countree.ru"),
    CountreeCity("Сосновоборск", LatLng(56.119619, 93.335448), "https://24.countree.ru"),
    CountreeCity("Енисейск", LatLng(58.454698, 92.174961), "https://24.countree.ru")
  ];

  static List<String> get getNames{
    return cities.map((city) => city.name).toList();
  }

}