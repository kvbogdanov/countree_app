import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:countree/widgets/drawer.dart';
import 'package:countree/data/cities.dart';
import 'package:countree/data/maps.dart';
import 'package:countree/data/tree.dart';
import 'package:countree/data/colors.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';

import 'package:location/location.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:countree/model/user.dart';
import 'package:countree/model/tree.dart' as Dbtree;

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image/image.dart' as LocalImage;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;

const MAXZOOM = 20.0;

class SeedingformPage extends StatefulWidget {
  static const String route = 'seedingform';

  @override
  SeedingformPageState createState() {
    return SeedingformPageState();
  }
}

class SeedingformPageState extends State<SeedingformPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  final _nameController = TextEditingController();

  bool signed = false;
  bool visRegular = true;
  bool visSeedling = true;
  bool visCustomType = false;
  bool visCustomCondition = false;

  int args;

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

  void _handleTap(LatLng latlng) {
    setState(() {
      currentPoint = latlng;
    });
  }

  Future<String> _localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Location location = new Location();
  MapController mapController;
  CountreeCity currentCity;
  LatLng currentPoint;

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  double zoomLevel = 18.0;

  List<Marker> markers = <Marker>[];
  List<Marker> prevMarkers = <Marker>[];
  int maxClusterRadius = 100;
  int totalTrees = 0;
  List<LayerOptions> mainLayers = [
    mapSources[0],
  ];
  LayerOptions clusteredLO;
  LayerOptions nonClusteredLO;

  User currentUser;
  String localDocPath;

  _getCurrentLocation({bool useStored: true}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final curLat = (prefs.getDouble('latitude') ?? 0);
    final curLon = (prefs.getDouble('longitude') ?? 0);
    final curZoom = (prefs.getDouble('zoom') ?? 0);

    //print(curLat.toString() + ' ' + curLon.toString());
    if (useStored == false || curLat == 0) {
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.DENIED) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.GRANTED) {
          return;
        }
      }
      _locationData = await location.getLocation();
      //print(_locationData.latitude.toString() + ' ' + _locationData.longitude.toString());
      //return new LatLng(56.003313,92.8486668);
      return new LatLng(_locationData.latitude, _locationData.longitude);
    } else {
      zoomLevel = curZoom;
      return new LatLng(curLat, curLon);
    }
  }

  Future<bool> _rememberMapPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', mapController.center.latitude);
    await prefs.setDouble('longitude', mapController.center.longitude);
    await prefs.setDouble('zoom', mapController.zoom);
    return true;
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Завершить редактирование?'),
            content: new Text(
                'Информация в форме редактирования НЕ БУДЕТ сохранена'),
            actions: <Widget>[
              new FlatButton(
                  child: new Text('Остаться', style: TextStyle(fontSize: 20)),
                  onPressed: () => Navigator.of(context).pop(false)),
              new FlatButton(
                onPressed: () async {
                  await _rememberMapPosition();
                  Navigator.of(context).pop(true);
                },
                child: new Text('Выйти',
                    style: TextStyle(fontSize: 20, color: Colors.red)),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  void initState() {
    super.initState();

    _localPath().then((result) {
      localDocPath = result;
    });

    _getLoggedState().then((result) {
      setState(() {
        if (result is User) {
          currentUser = result;
          signed = true;
        } else
          signed = false;
      });
    });

    mapController = MapController();
    currentCity = CountreeCities.cities[0];
    _getCurrentCity().then((result) {
      setState(() {
        currentCity = result;
        mapController.move(currentCity.center, 18.0);
      });
    });

    _getMapLayer().then((result) {
      setState(() {});
    });

    _getCurrentLocation().then((result) {
      mapController.move(result, zoomLevel);
      currentPoint = result;
      _handleTap(currentPoint);
    });

    /*
    WidgetsBinding.instance.addPostFrameCallback((_) => {
          _getTreeByTime(args).then((result) {
            if (result != null) _loadFormWithTree(result, setpos: true);
          })
        });
    */
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;

    var markers = [currentPoint].map((latlng) {
      return Marker(
        width: 50.0,
        height: 50.0,
        point: latlng,
        builder: (ctx) => Container(
          child: Icon(Icons.filter_tilt_shift,
              color: Colors.red, size: 50), // FlutterLogo(),
        ),
      );
    }).toList();

    if (mainLayers.length > 1) {
      mainLayers.removeLast();

      if (prevMarkers.length > 0 && mainLayers.length > 1)
        mainLayers.removeLast();
    }
    mainLayers.add(MarkerLayerOptions(markers: prevMarkers));
    mainLayers.add(MarkerLayerOptions(markers: markers));

    return new WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(title: Text('Countree')),
            endDrawer: buildDrawer(context, SeedingformPage.route,
                signed: signed, cu: currentUser),
            body: SingleChildScrollView(
                child: Column(
              children: <Widget>[
                Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                  child:
                      Text('Посадка деревьев', style: TextStyle(fontSize: 20)),
                ),
                Container(
                    height: 400,
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                          center:
                              currentCity.center, //LatLng(56.01115, 92.85290),
                          zoom: 18.0,
                          maxZoom: MAXZOOM,
                          onTap: (point) {
                            //print('tap');
                            _handleTap(point);
                            setState(() {
                              zoomLevel = mapController.zoom;
                            });
                          },
                          onPositionChanged: (p1, p2) {
                            //print(p1.center.toString());
                            //print(p2);
                          }),
                      layers: mainLayers,
                    )),
                Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 2),
                  child: Row(
                    children: <Widget>[
                      Text(
                          'Lon: ${currentPoint == null ? '0' : currentPoint.longitude.toString()}\nLat: ${currentPoint == null ? '0' : currentPoint.latitude.toString()}'),
                      Spacer(),
                      GestureDetector(
                        onTap: () async {
                          _getCurrentLocation(useStored: false).then((result) {
                            setState(() {
                              mapController.move(result, zoomLevel);
                              currentPoint = result;
                              _handleTap(currentPoint);
                            });
                          });
                        },
                        child: Icon(Icons.gps_fixed,
                            color: countreeTheme.shade400, size: 40),
                      ),
                      //Text(' Lat: ${currentPoint==null?'0':currentPoint.latitude.toString()}')
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: FormBuilder(
                              key: _fbKey,
                              child: Column(children: <Widget>[
                                Row(children: <Widget>[
                                  Expanded(
                                      flex: 10,
                                      child: Container(
                                          color: countreeTheme.shade100,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  top: 8,
                                                  bottom: 8),
                                              child: Row(
                                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text('Дата посадки',
                                                      style: TextStyle(
                                                          fontSize: 18)),
                                                ],
                                              ))))
                                ]),
                                //SizedBox(height: 10),
                                FormBuilderDateTimePicker(
                                  name: 'date',
                                  // onChanged: _onChanged,
                                  inputType: InputType.date,
                                  initialValue: DateTime.now(),
                                  // enabled: true,
                                ),
                                Row(children: <Widget>[
                                  Expanded(
                                      flex: 10,
                                      child: Container(
                                          color: countreeTheme.shade100,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  top: 8,
                                                  bottom: 8),
                                              child: Row(
                                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text('Посадку проводит',
                                                      style: TextStyle(
                                                          fontSize: 20)),
                                                ],
                                              ))))
                                ]),
                                Row(children: [
                                  RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side: BorderSide(
                                            color: countreeTheme.shade800)),
                                    onPressed: () {},
                                    color: countreeTheme.shade400,
                                    textColor: Colors.white,
                                    child: Text('Организация',
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                  SizedBox(width: 10),
                                  RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side: BorderSide(
                                            color: countreeTheme.shade800)),
                                    onPressed: () {},
                                    color: countreeTheme.shade400,
                                    textColor: Colors.white,
                                    child: Text('Частное лицо',
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                ]),
                                SizedBox(height: 10),
                                Row(children: <Widget>[
                                  Expanded(
                                      flex: 10,
                                      child: Container(
                                          color: countreeTheme.shade100,
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  top: 8,
                                                  bottom: 8),
                                              child: Row(
                                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text('Наименование / ФИО',
                                                      style: TextStyle(
                                                          fontSize: 20)),
                                                ],
                                              ))))
                                ]),
                                TextFormField(
                                  controller: _nameController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: UnderlineInputBorder()),
                                ),
                              ])))
                    ]))
              ],
            ))));
  }
}
