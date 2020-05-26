import 'package:flutter_map/flutter_map.dart';

const Map<int, String> mapSourcesNames ={
  0: "\"Спутник\"",
  1: "Mapbox (карта)",
  2: "Mapbox (спутниковый снимок)",
  3: "OSM",
  4: "Яндекс (тест)"
};

Map<int, LayerOptions> mapSources ={
  0: TileLayerOptions(
      urlTemplate:
          'http://tiles.maps.sputnik.ru/{z}/{x}/{y}.png',
    ),  
  1: TileLayerOptions(
      urlTemplate:
          "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia29zeWFnIiwiYSI6ImNrYWp6OWdnOTBmb3kycW1pemU1NTE3a3UifQ.IJglSz8JQcOYKfkntYdCwA",
      additionalOptions: {
        'accessToken': 'pk.eyJ1Ijoia29zeWFnIiwiYSI6ImNrYWp6OWdnOTBmb3kycW1pemU1NTE3a3UifQ.IJglSz8JQcOYKfkntYdCwA',
        'id': 'mapbox/streets-v11',
      },    
      subdomains: ['a', 'b', 'c'],
    ),
  2: TileLayerOptions(
      urlTemplate:
          "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia29zeWFnIiwiYSI6ImNrYWp6OWdnOTBmb3kycW1pemU1NTE3a3UifQ.IJglSz8JQcOYKfkntYdCwA",
      additionalOptions: {
        'accessToken': 'pk.eyJ1Ijoia29zeWFnIiwiYSI6ImNrYWp6OWdnOTBmb3kycW1pemU1NTE3a3UifQ.IJglSz8JQcOYKfkntYdCwA',
        'id': 'mapbox/satellite-v9',
      },    
      subdomains: ['a', 'b', 'c'],
    ),
  3: TileLayerOptions(
      urlTemplate:
          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      subdomains: ['a', 'b', 'c'],
    ),
  4: TileLayerOptions(
      urlTemplate:'http://vec{s}.maps.yandex.net/tiles?l=map&v=4.55.2&z={z}&x={x}&y={y}&scale=2&lang=ru_RU',
      subdomains: ['01', '02', '03', '04'],
    ),    

};


