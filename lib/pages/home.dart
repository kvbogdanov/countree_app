import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong/latlong.dart';
import 'zoombuttons_plugin_option.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:countree/widgets/drawer.dart';
import 'package:countree/data/cities.dart';
import 'package:countree/data/colors.dart';

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

class HomePage extends StatefulWidget {
  static const String route = '/';

  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _getCurrentCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int idCity = (prefs.getInt('currentCity') ?? 0);

    return CountreeCities.cities[idCity];
  }

  _getLoggedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('logged') ?? false);
  }  

  _setCurrentCity(String cityname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int ccounter = 0;

    for(var city in CountreeCities.cities){
      if(city.name == cityname)
      {
        await prefs.setInt('currentCity', ccounter);
        mapController.move(city.center, 16.0);
        _loadPoints(city.uri);    
        break;
      }
      ccounter++;
    }
  }

  Future<dynamic> _loadPoints(String uri) async {

    BaseOptions options = BaseOptions(
      baseUrl: uri,
      responseType: ResponseType.plain,
      connectTimeout: 30000,
      receiveTimeout: 30000,
      validateStatus: (code) {
        if (code >= 200) {
          return true;
        }

        return false;
      });

    Dio dio = Dio(options);
    try {
      Options options = Options(
        followRedirects: true,
        contentType: 'application/json', //ContentType.parse('application/json')
      );

      Response response = await dio.post('/mobile/points', data: FormData.fromMap({}), options: options);

      if (response.statusCode == 200 || response.statusCode == 201) {

        var responseJson = json.decode(response.data);

        if(responseJson.containsKey('trees'))
        {
          markers = <Marker>[];
          for(var tree in responseJson['trees'])
          {
            Color mInnerColor = Color(0xff225D9C);
            Color mBorderColor = Colors.green;
            double mSize = 16;

            switch(tree['layout'])
            {
                case 'small': {
                    mInnerColor = Color(0xff7EE043);
                    mSize = 12;
                }
                break;
                case 'dead': {
                    mInnerColor = Color(0xff222222);
                }
                break;
                case 'leaf': {
                    mInnerColor = Color(0xffe0c143);
                }
                break;
                case 'needle': {
                    mInnerColor = Color(0xff7ee043);
                }
                break;
                case 'cutdown': {
                    mInnerColor = Colors.red;
                    mBorderColor = Colors.red;
                    mSize = 14;
                }
                break;
            }

            Marker tempMarker = Marker(
                width: mSize + 4,
                height: mSize + 4,
                point: LatLng(double.parse(tree['lat']), double.parse(tree['lon'])),
                builder: (ctx) => Container(
                  child: 
                  GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState.hideCurrentSnackBar();
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text(tree['name']),
                      ));
                    },
                    child:
                      Container(
                        width: mSize,
                        height: mSize,
                        decoration: new BoxDecoration(
                          color: mInnerColor,
                          borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                          border: new Border.all(
                            color: mBorderColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                  ),
                ),
              );
            markers.add(tempMarker);
            
          }
        }

        return responseJson;
      } else
        throw Exception('Authentication Error');
    } on DioError catch (exception) {
      if (exception == null ||
          exception.toString().contains('SocketException')) {
        throw Exception("Network Error");
      } else if (exception.type == DioErrorType.RECEIVE_TIMEOUT ||
          exception.type == DioErrorType.CONNECT_TIMEOUT) {
        throw Exception(
            "Could'nt connect, please ensure you have a stable network.");
      } else {
        return null;
      }
    }
  }

  MapController mapController;

  CountreeCity currentCity;
  String dropdownValue;
  bool signed = false;
  List<Marker> markers = <Marker>[];
  double zoomLevel = 16.0;
  int totalTrees = 0;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    currentCity = CountreeCities.cities[0];
    _getCurrentCity().then((result){
        setState(() {
          currentCity = result;
          mapController.move(currentCity.center, 16.0); 
          dropdownValue = currentCity.name;

          _loadPoints(currentCity.uri).then((result){
            setState(() {
              totalTrees = markers.length;
            });
          });
        });
    });
    dropdownValue = currentCity.name;

    _getLoggedState().then((result){
        setState(() {
          signed = result;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Countree')),
      endDrawer: buildDrawer(context, HomePage.route, signed:signed),
      body: Padding(
        padding: EdgeInsets.all(0.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 6.0, bottom: 6.0, left: 16.0),
              child: Row(                
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child:
                      DropdownButtonHideUnderline(
                        child:
                          DropdownButton<String>(
                            value: dropdownValue,
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Colors.black87, fontSize: 18),
                            onChanged: (String newValue) {
                              setState(() {
                                dropdownValue = newValue;
                                _setCurrentCity(newValue);
                                zoomLevel =  16;
                                totalTrees = markers.length;
                              });
                            },
                            items: CountreeCities.getNames 
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          )
                      )
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child:
                          Text(
                            '(' + totalTrees.toString() + ')',
                            style: TextStyle(fontSize: 10),
                          ),
                      ),
                  ),
                  Expanded(
                    flex: 4,
                    child: 
                      Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                if(mapController.zoom > 5)
                                  mapController.move(mapController.center, mapController.zoom-1);
                                setState(() { 
                                  zoomLevel =  mapController.zoom;
                                });
                              },
                              child: ClipOval(
                                child: Container(
                                  color: countreeTheme.shade400,
                                  height: 40.0, 
                                  width: 40.0,
                                  child: Center(child: Text('-', style: TextStyle(color: Colors.white, fontSize: 20),)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child:
                                Text(
                                  'x' + zoomLevel.round().toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if(mapController.zoom < 22)
                                  mapController.move(mapController.center, mapController.zoom+1);
                                setState(() { 
                                  zoomLevel =  mapController.zoom;
                                });
                              },
                              child: ClipOval(
                                child: Container(
                                  color: countreeTheme.shade400,
                                  height: 40.0, 
                                  width: 40.0,
                                  child: Center(child: Text('+', style: TextStyle(color: Colors.white, fontSize: 20),)),
                                ),
                              ),
                            ), 
                          ],
                        ),
                      )
                  )
                ]
              )
            ),
            Flexible(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  center: currentCity.center, //LatLng(56.01115, 92.85290),
                  zoom: 16.0,
                  maxZoom: 22.0,
                  plugins: [
                    ZoomButtonsPlugin(),
                    MarkerClusterPlugin(),
                  ],                  
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        //'http://tiles.maps.sputnik.ru/{z}/{x}/{y}.png',
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        //"https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia29zeWFnIiwiYSI6ImNrYWp6OWdnOTBmb3kycW1pemU1NTE3a3UifQ.IJglSz8JQcOYKfkntYdCwA",
                        //-"https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}@2x.png?access_token=pk.eyJ1Ijoia29zeWFnIiwiYSI6ImNrYWp6OWdnOTBmb3kycW1pemU1NTE3a3UifQ.IJglSz8JQcOYKfkntYdCwA",
                    additionalOptions: {
                      'accessToken': 'pk.eyJ1Ijoia29zeWFnIiwiYSI6ImNrYWp6OWdnOTBmb3kycW1pemU1NTE3a3UifQ.IJglSz8JQcOYKfkntYdCwA',
                      'id': 'mapbox/streets-v11',
                    },    
                    subdomains: ['a', 'b', 'c'],
                    //tileProvider: NonCachingNetworkTileProvider(),
                  ),                  
                  TileLayerOptions(
                    urlTemplate:
                        //'http://tiles.maps.sputnik.ru/{z}/{x}/{y}.png',
                        //'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia29zeWFnIiwiYSI6ImNrYWp6OWdnOTBmb3kycW1pemU1NTE3a3UifQ.IJglSz8JQcOYKfkntYdCwA",
                        //"https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}@2x.png?access_token=pk.eyJ1Ijoia29zeWFnIiwiYSI6ImNrYWp6OWdnOTBmb3kycW1pemU1NTE3a3UifQ.IJglSz8JQcOYKfkntYdCwA",
                    additionalOptions: {
                      'accessToken': 'pk.eyJ1Ijoia29zeWFnIiwiYSI6ImNrYWp6OWdnOTBmb3kycW1pemU1NTE3a3UifQ.IJglSz8JQcOYKfkntYdCwA',
                      'id': 'mapbox/satellite-v9',
                      //'id': 'mapbox/streets-v11',
                    },
                    opacity: 0.3,    
                    //subdomains: ['a', 'b', 'c'],
                    //tileProvider: NonCachingNetworkTileProvider(),
                  ),
                  
                  MarkerClusterLayerOptions(
                    maxClusterRadius: 100,
                    animationsOptions: AnimationsOptions(zoom: const Duration(milliseconds: 0), fitBound: const Duration(milliseconds: 500), centerMarker: const Duration(milliseconds: 500), spiderfy: const Duration(milliseconds: 500), centerMarkerCurves: Curves.fastOutSlowIn),
                    zoomToBoundsOnClick: true,
                    size: Size(60, 60),
                    fitBoundsOptions: FitBoundsOptions(
                      padding: EdgeInsets.all(50),
                    ),
                    markers: markers,
                    polygonOptions: PolygonOptions(
                        borderColor: countreeTheme.shade400,
                        color: Colors.black12,
                        borderStrokeWidth: 3),
                    builder: (context, markers) {
                      return FloatingActionButton(
                        child: Text(markers.length.toString()),
                        onPressed: null,
                      );
                    },
                  ),
                             
                  //MarkerLayerOptions(markers: markers),
                  /*
                  ZoomButtonsPluginOption(
                      minZoom: 4,
                      maxZoom: 30,
                      mini: true,
                      padding: 10,
                      alignment: Alignment.bottomLeft),
                  */
                ],
              ),
            ),
          ],
        ),
      ),
    );  


  }

}