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

const MAXZOOM = 20.0;


class TreeformPage extends StatefulWidget {
  static const String route = 'treeform';

  @override
TreeformPageState createState() {
    return TreeformPageState();
  }
}

class TreeformPageState extends State<TreeformPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  bool signed = false;

  _getCurrentCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int idCity = (prefs.getInt('currentCity') ?? 0);

    return CountreeCities.cities[idCity];
  }

  _getLoggedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('logged') ?? false);
  }  

  Location location = new Location();
  MapController mapController;
  CountreeCity currentCity;

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  double zoomLevel = 16.0;

  List<Marker> markers = <Marker>[];
  int maxClusterRadius = 100;
  int totalTrees = 0;
  List<LayerOptions> mainLayers = [
        mapSources[0]
    ];
  LayerOptions clusteredLO;
  LayerOptions nonClusteredLO;

  _getCurrentLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();   

    print(_locationData.latitude.toString() + ' ' + _locationData.longitude.toString());

    return new LatLng(56.003313,92.8486668);

    //return new LatLng(_locationData.latitude, _locationData.longitude); 
  }

  @override
  void initState() {
    super.initState();

    _getLoggedState().then((result){
        setState(() {
          signed = result;
        });
    });

    mapController = MapController();
    currentCity = CountreeCities.cities[0];
    _getCurrentCity().then((result){
        setState(() {
          currentCity = result;
          mapController.move(currentCity.center, 16.0);     
        });
    });
    
    _getCurrentLocation().then((result){
      mapController.move(result, zoomLevel);
    });

  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Countree')),
      endDrawer: buildDrawer(context, TreeformPage.route, signed:signed),
      body: 
        SingleChildScrollView(
          child:
            Column(          
              children: <Widget>[
                Container(
                  height: 400,
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      center: currentCity.center, //LatLng(56.01115, 92.85290),
                      zoom: 16.0,
                      maxZoom: MAXZOOM,
                      onTap: (point) {
                        print('tap');
                        setState((){
                          zoomLevel =  mapController.zoom;
                        });
                      },
                      onPositionChanged: (p1, p2) {
                        print(p1.center.toString());
                        //print(p2);
                      }
                    ),
                    layers: mainLayers,
                  ) 
                ),
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FormBuilder(
                          key: _fbKey,
                          child: 
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 10,
                                      child: Container(
                                        color: countreeTheme.shade100,
                                        child: 
                                          Padding(
                                            padding: EdgeInsets.all(15.0),
                                            child:
                                              Text('Биологический вид', style: TextStyle(fontSize: 20))
                                          )
                                      )
                                    )
                                  ]
                                ), 
                                SizedBox(height: 10),
                                Row(
                                  children: <Widget>[
                                    RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                        side: BorderSide(color: countreeTheme.shade800)),
                                      onPressed: () {},
                                      color: countreeTheme.shade400,
                                      textColor: Colors.white,
                                      child: Text(TreeTypeList.getById(10).name.toUpperCase(),
                                        style: TextStyle(fontSize: 12)),
                                    ),
                                    SizedBox(width: 10),
                                    RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                        side: BorderSide(color: countreeTheme.shade800)),
                                      onPressed: () {},
                                      color: countreeTheme.shade400,
                                      textColor: Colors.white,
                                      child: Text(TreeTypeList.getById(1).name.toUpperCase(),
                                        style: TextStyle(fontSize: 12)),
                                    ),
                                    /*
                                    SizedBox(width: 10),
                                    RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                        side: BorderSide(color: Colors.red)),
                                      onPressed: () {},
                                      color: Colors.red,
                                      textColor: Colors.white,
                                      child: Text(TreeTypeList.getById(17).name.toUpperCase(),
                                        style: TextStyle(fontSize: 10)),
                                    ),
                                    */
                                  ],
                                ),
                                FormBuilderDropdown(
                                  attribute: "treetype",
                                  initialValue: TreeTypeList.types[0].name,
                                  items: TreeTypeList.getNames()
                                    .map((ttype) => DropdownMenuItem(
                                      value: ttype.toString(),
                                      child: Text(ttype)
                                  )).toList(),
                                ),
                                FormBuilderSwitch(
                                  attribute: "treetype_notsure",
                                  label: Text("Не уверен", style: TextStyle(color: Colors.black87, fontSize: 16))
                                ), 
                                SizedBox(height: 25),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 10,
                                      child: Container(
                                        color: countreeTheme.shade100,
                                        child: 
                                          Padding(
                                            padding: EdgeInsets.all(15.0),
                                            child:
                                              Text('Сухое дерево', style: TextStyle(fontSize: 20))
                                          )
                                      )
                                    )
                                  ]
                                ), 
                                FormBuilderSwitch(
                                  attribute: "isalive",
                                  label: Row(
                                    children: <Widget>[
                                      Text("Сухое дерево ", style: TextStyle(color: Colors.black87, fontSize: 16)),
                                      GestureDetector(
                                        onTap: () {
                                          return showDialog<void>(
                                            context: context,
                                            barrierDismissible: false, // user must tap button!
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                //title: Text('Внимание'),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: <Widget>[
                                                      Text('Галочка устанавливается, если дерево в вегетационный период не имеет ни одного живого листа/хвои - когда есть уверенность, что дерево умерло и не вернется.'),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Text('Понятно'),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );                                          
                                        },
                                        child: Icon(Icons.help, color: countreeTheme.shade400,),
                                      ),
                                    ],
                                  )
                                ), 
                                FormBuilderSwitch(
                                  attribute: "isalive_notsure",
                                  label: Text("Не уверен, что дерево сухое", style: TextStyle(color: Colors.black87, fontSize: 16))
                                ),
                                FormBuilderImagePicker(
                                  attribute: "treeimages",
                                )
                              ],
                            )
                        )
                      )
                    ]
                  )
                )            
              ],
            )
        )
    );
  }

}