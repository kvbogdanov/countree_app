import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:countree/widgets/drawer.dart';
import 'package:countree/data/cities.dart';
import 'package:countree/data/colors.dart';
import 'package:countree/data/maps.dart';
import 'package:countree/pages/treeform.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
//import 'package:proj4dart/proj4dart.dart' as proj4;
import 'package:progress_indicators/progress_indicators.dart';
import 'package:countree/pages/view.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:countree/model/user.dart';

import 'package:countree/model/tree.dart' as Dbtree;

const MAXZOOM = 20.0;

var uuid = Uuid();

Iterable parseTrees(String responseBody) {
  final parsed = json.decode(responseBody);

  if (parsed.containsKey('trees')) {
    return parsed['trees'];
  }
  return {};
}

Future<Iterable> fetchTrees(String uri) async {
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
    Options options1 = Options(
      followRedirects: true,
      contentType: 'application/json', //ContentType.parse('application/json')
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final onlymy = (prefs.getBool('onlymy') ?? true);

    final loggedUser = await loadCurrentUser();

    final Response response = await dio.post('/mobile/points',
        data: FormData.fromMap({
          'user_id': ((loggedUser != null) && (onlymy == true))
              ? loggedUser.id_system
              : -1
        }),
        options: options1);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return compute(parseTrees, response.data.toString());
    } else
      throw Exception('Authentication Error');
  } on DioError catch (exception) {
    if (exception == null || exception.toString().contains('SocketException')) {
      throw Exception("Network Error");
    } else if (exception.type == DioErrorType.RECEIVE_TIMEOUT ||
        exception.type == DioErrorType.CONNECT_TIMEOUT) {
      throw Exception(
          "Could'nt connect, please ensure you have a stable network.");
    } else {
      return {};
    }
  }
}

class HomePage extends StatefulWidget {
  static const String route = '/';

  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _getCurrentCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int idCity = (prefs.getInt('currentCity') ?? 0);

    return CountreeCities.cities[idCity];
  }

  _getLoggedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final res = (prefs.getBool('logged') ?? false);
    if (res == true) return await loadCurrentUser();
    return res;
  }

  _getMapLayer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var newMapLayerName = prefs.getString('mapsrc');

    if (newMapLayerName != '' && newMapLayerName != mapSourcesNames[0]) {
      // antipattern! to remove
      switch (newMapLayerName) {
        case "Mapbox (карта)":
          mainLayers[0] = mapSources[1];
          break;
        case "Mapbox (спутниковый снимок)":
          mainLayers[0] = mapSources[2];
          break;
        case "OSM":
          mainLayers[0] = mapSources[3];
          break;
        case "Яндекс (тест)":
          mainLayers[0] = mapSources[4];
          break;
        default:
          mainLayers[0] = mapSources[0];
      }

      return true;
    }

    return false;
  }

  _setCurrentCity(String cityname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int ccounter = 0;

    for (var city in CountreeCities.cities) {
      if (city.name == cityname) {
        await prefs.setInt('currentCity', ccounter);
        mapController.move(city.center, 16.0);
        await _loadPointsFast(city.uri);
        break;
      }
      ccounter++;
    }
  }

  Future<dynamic> _loadPointsFast(String uri) async {
    var responseTrees = await fetchTrees(uri);
    markers = <Marker>[];
    for (var tree in responseTrees) {
      Color mInnerColor = Color(0xff225D9C);
      Color mBorderColor = Colors.green;
      double mSize = 16;

      switch (tree['layout']) {
        case 'small':
          {
            mInnerColor = Color(0xff7EE043);
            mSize = 12;
          }
          break;
        case 'dead':
          {
            mInnerColor = Color(0xff222222);
          }
          break;
        case 'leaf':
          {
            mInnerColor = Color(0xffe0c143);
          }
          break;
        case 'needle':
          {
            mInnerColor = Color(0xff7ee043);
          }
          break;
        case 'cutdown':
          {
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
          child: GestureDetector(
            onTap: () {
              _scaffoldKey.currentState.hideCurrentSnackBar();
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Row(
                children: <Widget>[
                  //Text('#24-'+tree['id'].toString()+" "),
                  Text(tree['name']),
                  SizedBox(width: 15),
                  RaisedButton(
                      child: Text("Детально"),
                      color: Colors.grey,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          ViewPage.route,
                          arguments: tree['id'] ?? 0,
                        );
                      })
                ],
              )));
            },
            child: Container(
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

  Future<dynamic> _loadMyTrees(String uri) async {
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

      final loggedUser = await loadCurrentUser();

      if ((loggedUser == null)) return null;

      Response response = await dio.post('/mobile/mytrees',
          data: FormData.fromMap({'user_id': loggedUser.id_system}),
          options: options);
      //debugPrint(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.data);
        //print(responseJson['data']);

        if (responseJson['data'].containsKey('trees')) {
          for (var tree in responseJson['data']['trees']) {
            this.saveTreeLocal(tree);
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

  Future<Dbtree.Tree> _getTreeBySystemId(int id) async {
    if (id == null) return null;
    final tree = await Dbtree.Tree().select().where('id_system=$id').toSingle();
    return tree;
  }

  Future<Dbtree.Tree> saveTreeLocal(remoteTree) async {
    Dbtree.Tree localTree =
        await this._getTreeBySystemId(remoteTree['id_tree']);

    print(remoteTree);
    //return localTree;

    /*
      {
        id_tree: 25615, 
        name: другой вид, 
        lat: 56.003313000229, 
        lon: 92.849908862446, 
        created: 1596483345, 
        id_user: 1, 
        treetype: 35, 
        custom_treetype: null, 
        is_alive: 0, 
        is_seedling: 0, 
        multibarrel: 0, 
        firstthread: 2, 
        overall: 1, 
        notsure: , 
        pics: [https://24.countree.ru/assets/preview/fd/d8/fdd8ac5ef4056bc6cab1a3f32460253b.jpg], 
        cutdown: null, 
        state: null, 
        diameter: 21.00, 
        height: 7, 
        surround: 2}
    */

    var notsure = [];

    if (remoteTree['notsure'] != null)
      notsure = remoteTree['notsure'].split(";");

    print(notsure);

    if (localTree == null) {
      if (remoteTree['is_alive'] == 1) {
        localTree = Dbtree.Tree(
          id_system: remoteTree['id_tree'],
          created: int.parse(remoteTree['created']),
          uploaded: int.parse(remoteTree['created']),
          id_treetype: remoteTree['treetype'],
          custom_treetype: remoteTree['custom_treetype'],
          notsure_treetype: notsure.contains('id_treetype') == true ? 1 : 0,
          longitude: double.parse(remoteTree['lon']),
          latitude: double.parse(remoteTree['lat']),
          is_alive: remoteTree['is_alive'],
          notsure_is_alive: notsure.contains('is_alive') == true ? 1 : 0,
        );
      } else if (remoteTree['isseedling'] == true) {
        localTree = Dbtree.Tree(
          id_system: remoteTree['id_tree'],
          created: int.parse(remoteTree['created']),
          uploaded: int.parse(remoteTree['created']),
          id_user: remoteTree['id_user'],
          id_treetype: remoteTree['treetype'],
          custom_treetype: remoteTree['custom_treetype'],
          notsure_treetype: notsure.contains('id_treetype') == true ? 1 : 0,
          longitude: double.parse(remoteTree['lon']),
          latitude: double.parse(remoteTree['lat']),
          is_alive: remoteTree['is_alive'],
          notsure_is_alive: notsure.contains('is_alive') == true ? 1 : 0,
          is_seedling: remoteTree['is_seedling'],
          notsure_is_seedling: notsure.contains('is_seedling') == true ? 1 : 0,
        );
      } else {
        var imagePaths = List<String>();
        for (var ti in remoteTree['pics']) {
          imagePaths.add(ti);
        }

        localTree = Dbtree.Tree(
            id_system: remoteTree['id_tree'],
            created: int.parse(remoteTree['created']),
            uploaded: int.parse(remoteTree['created']),
            id_user: remoteTree['id_user'],
            id_treetype: remoteTree['treetype'],
            custom_treetype: remoteTree['custom_treetype'],
            notsure_treetype: notsure.contains('id_treetype') == true ? 1 : 0,
            longitude: double.parse(remoteTree['lon']),
            latitude: double.parse(remoteTree['lat']),
            is_alive: remoteTree['is_alive'],
            notsure_is_alive: notsure.contains('is_alive') == true ? 1 : 0,
            is_seedling: remoteTree['is_seedling'],
            notsure_is_seedling:
                notsure.contains('is_seedling') == true ? 1 : 0,
            diameter: double.parse(remoteTree['diameter']).round(),
            notsure_diameter: notsure.contains('diameter') == true ? 1 : 0,
            multibarrel: remoteTree['multibarrel'],
            notsure_multibarrel:
                notsure.contains('multibarrel') == true ? 1 : 0,
            id_state: remoteTree['state'],
            notsure_id_state: notsure.contains('state') == true ? 1 : 0,
            firstthread: remoteTree['firstthread'] == null
                ? 0
                : remoteTree['firstthread'],
            notsure_firstthread:
                notsure.contains('firstthread') == true ? 1 : 0,
            ids_condition: remoteTree['conditions'] == null
                ? ''
                : remoteTree['conditions'].map((i) => i.toString()).join(","),
            custom_condition: remoteTree['custom_condition'],
            notsure_ids_condition:
                notsure.contains('conditions') == true ? 1 : 0,
            id_surroundings: remoteTree['surround'],
            notsure_id_surroundings:
                notsure.contains('surround') == true ? 1 : 0,
            ids_neighbours: remoteTree['neighbours'] == null
                ? ''
                : remoteTree['neighbours'].map((i) => i.toString()).join(","),
            notsure_ids_neighbours:
                notsure.contains('neighbours') == true ? 1 : 0,
            id_overall:
                remoteTree['overall'] == null ? 0 : remoteTree['overall'],
            height: remoteTree['height'].toDouble(),
            images: imagePaths.join(";")); //.save();

      }
    } else {
      if (remoteTree['is_alive'] == 1) {
        localTree.id_system = remoteTree['id_tree'];
        localTree.id_treetype = remoteTree['treetype'];
        localTree.custom_treetype = remoteTree['custom_treetype'];
        localTree.notsure_treetype =
            notsure.contains('id_treetype') == true ? 1 : 0;
        localTree.longitude = double.parse(remoteTree['lon']);
        localTree.latitude = double.parse(remoteTree['lat']);
        localTree.is_alive = remoteTree['is_alive'];
        localTree.notsure_is_alive =
            notsure.contains('is_alive') == true ? 1 : 0;
      } else if (remoteTree['isseedling'] == true) {
        localTree.id_system = remoteTree['id_tree'];
        localTree.id_treetype = remoteTree['treetype'];
        localTree.custom_treetype = remoteTree['custom_treetype'];
        localTree.notsure_treetype =
            notsure.contains('id_treetype') == true ? 1 : 0;
        localTree.longitude = double.parse(remoteTree['lon']);
        localTree.latitude = double.parse(remoteTree['lat']);
        localTree.is_alive = remoteTree['is_alive'];
        localTree.notsure_is_alive =
            notsure.contains('is_alive') == true ? 1 : 0;
        localTree.is_seedling = remoteTree['is_seedling'];
        localTree.notsure_is_seedling =
            notsure.contains('is_seedling') == true ? 1 : 0;
      } else {
        var imagePaths = List<String>();
        for (var ti in remoteTree['pics']) {
          imagePaths.add(ti);
        }

        localTree.id_system = remoteTree['id_tree'];
        localTree.id_treetype = remoteTree['treetype'];
        localTree.custom_treetype = remoteTree['custom_treetype'];
        localTree.notsure_treetype =
            notsure.contains('id_treetype') == true ? 1 : 0;
        localTree.longitude = double.parse(remoteTree['lon']);
        localTree.latitude = double.parse(remoteTree['lat']);
        localTree.is_alive = remoteTree['is_alive'];
        localTree.notsure_is_alive =
            notsure.contains('is_alive') == true ? 1 : 0;
        localTree.is_seedling = remoteTree['is_seedling'];
        localTree.notsure_is_seedling =
            notsure.contains('is_seedling') == true ? 1 : 0;
        localTree.is_seedling = remoteTree['is_seedling'];
        localTree.notsure_is_seedling =
            notsure.contains('is_seedling') == true ? 1 : 0;
        localTree.diameter = double.parse(remoteTree['diameter']).round();
        localTree.notsure_diameter =
            notsure.contains('diameter') == true ? 1 : 0;
        localTree.multibarrel = remoteTree['multibarrel'];
        localTree.notsure_multibarrel =
            notsure.contains('multibarrel') == true ? 1 : 0;
        localTree.id_state = int.parse(remoteTree['state']);
        localTree.notsure_id_state = notsure.contains('state') == true ? 1 : 0;
        localTree.firstthread =
            remoteTree['firstthread'] == null ? 0 : remoteTree['firstthread'];
        localTree.notsure_firstthread =
            notsure.contains('firstthread') == true ? 1 : 0;
        localTree.ids_condition = remoteTree['conditions'] == null
            ? ''
            : remoteTree['conditions'].map((i) => i.toString()).join(",");
        localTree.custom_condition = remoteTree['custom_condition'];
        localTree.notsure_ids_condition =
            notsure.contains('conditions') == true ? 1 : 0;
        localTree.id_surroundings = remoteTree['surround'];
        localTree.notsure_id_surroundings =
            notsure.contains('surround') == true ? 1 : 0;
        localTree.ids_neighbours = remoteTree['neighbours'] == null
            ? ''
            : remoteTree['neighbours'].map((i) => i.toString()).join(",");
        localTree.notsure_ids_neighbours =
            notsure.contains('neighbours') == true ? 1 : 0;
        localTree.id_overall =
            remoteTree['overall'] == null ? 0 : remoteTree['overall'];
        localTree.height = remoteTree['height'].toDouble();
        localTree.images = imagePaths.join(";");
      }
    }

    //print(localTree);
    await localTree.save();
    return localTree;
  }

  MapController mapController;

  CountreeCity currentCity;
  String dropdownValue;
  bool signed = false;
  List<Marker> markers = <Marker>[];
  double zoomLevel = 16.0;
  int maxClusterRadius = 100;
  int totalTrees = 0;
  List<LayerOptions> mainLayers = [mapSources[0]];
  LayerOptions clusteredLO;
  LayerOptions nonClusteredLO;
  User currentUser;

  @override
  void initState() {
    super.initState();

    mapController = MapController();
    currentCity = CountreeCities.cities[0];

    _getCurrentCity().then((result) {
      setState(() {
        currentCity = result;
        mapController.move(currentCity.center, 16.0);
        dropdownValue = currentCity.name;

        if (markers.length == 0)
          _loadPointsFast(currentCity.uri).then((result) {
            setState(() {
              totalTrees = markers.length;
              clusteredLO = MarkerClusterLayerOptions(
                maxClusterRadius: 100,
                animationsOptions: AnimationsOptions(
                    zoom: const Duration(milliseconds: 0),
                    fitBound: const Duration(milliseconds: 500),
                    centerMarker: const Duration(milliseconds: 500),
                    spiderfy: const Duration(milliseconds: 500),
                    centerMarkerCurves: Curves.fastOutSlowIn),
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
                    heroTag: uuid.v1(),
                    child: Text(markers.length.toString()),
                    onPressed: null,
                  );
                },
              );
              nonClusteredLO = MarkerLayerOptions(markers: markers);
              mainLayers.add(clusteredLO);
            });
          });
      });
    });
    dropdownValue = currentCity.name;

    _getLoggedState().then((result) {
      setState(() {
        if (result is User) {
          currentUser = result;
          signed = true;
        } else
          signed = false;
      });
    });

    _getMapLayer().then((result) {
      setState(() {});
    });

    _loadMyTrees(currentCity.uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text('Countree')),
        endDrawer: buildDrawer(context, HomePage.route,
            signed: signed, cu: currentUser),
        body: Padding(
          padding: EdgeInsets.all(0.0),
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 6.0, bottom: 6.0, left: 16.0),
                  child: Row(children: <Widget>[
                    Expanded(
                        flex: 4,
                        child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                          value: dropdownValue,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.black87, fontSize: 16),
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownValue = newValue;
                              _setCurrentCity(newValue);
                              zoomLevel = 16;
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
                        ))),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: (totalTrees == 0)
                            ? Container(
                                width: 40,
                                height: 40,
                                child: JumpingDotsProgressIndicator(
                                    fontSize: 20.0))
                            : Text(
                                '(' + totalTrees.toString() + ')',
                                style: TextStyle(fontSize: 10),
                              ),
                      ),
                    ),
                    Expanded(
                        flex: 4,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  if (mapController.zoom > 5)
                                    mapController.move(mapController.center,
                                        mapController.zoom - 1);
                                  setState(() {
                                    var prevZl = zoomLevel.round();
                                    zoomLevel = mapController.zoom;
                                    if (zoomLevel.round() == 17 &&
                                        prevZl > zoomLevel) {
                                      mainLayers.removeLast();
                                      mainLayers.add(clusteredLO);
                                    }
                                  });
                                },
                                child: ClipOval(
                                  child: Container(
                                      color: countreeTheme.shade400,
                                      height: 40.0,
                                      width: 40.0,
                                      child: Icon(Icons
                                          .remove) //Center(child: Text('-', style: TextStyle(color: Colors.white, fontSize: 20),)),
                                      ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: Text(
                                  'x' + zoomLevel.round().toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (mapController.zoom < MAXZOOM)
                                    mapController.move(mapController.center,
                                        mapController.zoom + 1);
                                  setState(() {
                                    var prevZl = zoomLevel.round();
                                    zoomLevel = mapController.zoom;
                                    if (zoomLevel.round() == 18 &&
                                        prevZl < zoomLevel) {
                                      mainLayers.removeLast();
                                      mainLayers.add(nonClusteredLO);
                                    }
                                  });
                                },
                                child: ClipOval(
                                  child: Container(
                                      color: countreeTheme.shade400,
                                      height: 40.0,
                                      width: 40.0,
                                      child: Icon(Icons
                                          .add) //Center(child: Text('+', style: TextStyle(color: Colors.white, fontSize: 20),)),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ))
                  ])),
              Flexible(
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: currentCity.center, //LatLng(56.01115, 92.85290),
                    zoom: 16.0,
                    maxZoom: MAXZOOM,
                    onTap: (point) {
                      setState(() {
                        zoomLevel = mapController.zoom;
                      });
                    },
                    onPositionChanged: (p1, p2) {
                      if (markers.length > 0)
                        setState(() {
                          //var prevZl = zoomLevel.round();
                          zoomLevel = mapController.zoom;

                          if (zoomLevel.round() > 17.99 &&
                              mainLayers.last == clusteredLO) {
                            mainLayers.removeLast();
                            mainLayers.add(nonClusteredLO);
                          } else if (zoomLevel.round() < 17.99 &&
                              mainLayers.last == nonClusteredLO) {
                            mainLayers.removeLast();
                            mainLayers.add(clusteredLO);
                          }
                        });
                    },
                    plugins: [
                      //ZoomButtonsPlugin(),
                      MarkerClusterPlugin(),
                    ],
                  ),
                  layers: mainLayers,

                  /*
                [
                  TileLayerOptions(
                    urlTemplate:
                        'http://tiles.maps.sputnik.ru/{z}/{x}/{y}.png',
                        //'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        //"https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia29zeWFnIiwiYSI6ImNrYWp6OWdnOTBmb3kycW1pemU1NTE3a3UifQ.IJglSz8JQcOYKfkntYdCwA",
                        //-"https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}@2x.png?access_token=pk.eyJ1Ijoia29zeWFnIiwiYSI6ImNrYWp6OWdnOTBmb3kycW1pemU1NTE3a3UifQ.IJglSz8JQcOYKfkntYdCwA",
                    additionalOptions: {
                      'accessToken': 'pk.eyJ1Ijoia29zeWFnIiwiYSI6ImNrYWp6OWdnOTBmb3kycW1pemU1NTE3a3UifQ.IJglSz8JQcOYKfkntYdCwA',
                      'id': 'mapbox/streets-v11',
                    },    
                    subdomains: ['a', 'b', 'c'],
                    //tileProvider: NonCachingNetworkTileProvider(),
                  ),
                  /*
                  TileLayerOptions(
                    urlTemplate:'http://vec{s}.maps.yandex.net/tiles?l=map&v=4.55.2&z={z}&x={x}&y={y}&scale=2&lang=ru_RU',
                    subdomains: ['01', '02', '03', '04'],
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
                  */
                  MarkerClusterLayerOptions(
                    maxClusterRadius: 0,
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
                        heroTag: uuid.v1(),
                        child: Text(markers.length.toString()),
                        onPressed: null,
                      );
                    },
                  ),
                             
                  //MarkerLayerOptions(markers: markers),
                ],*/
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: signed
            ? SpeedDial(
                animatedIcon: AnimatedIcons.add_event,
                animatedIconTheme: IconThemeData(size: 32),
                backgroundColor: Colors.deepOrangeAccent,
                visible: true,
                curve: Curves.bounceIn,
                children: [
                  // FAB 1
                  SpeedDialChild(
                      child: Icon(Icons.add),
                      backgroundColor: countreeTheme.shade600,
                      onTap: () {
                        Navigator.pushNamed(context, TreeformPage.route);
                      },
                      label: 'Добавить дерево',
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontSize: 16.0),
                      labelBackgroundColor: countreeTheme.shade600),
                  // FAB 2
                  SpeedDialChild(
                      child: Icon(Icons.new_releases),
                      backgroundColor: countreeTheme.shade600,
                      onTap: () {
                        Navigator.pushNamed(context, TreeformPage.route);
                      },
                      label: 'Добавить дерево при посадке',
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontSize: 16.0),
                      labelBackgroundColor: countreeTheme.shade600)
                ],
              )
            : null

        /*
        FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, TreeformPage.route);
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.deepOrangeAccent ,
        ):null*/

        );
  }
}
