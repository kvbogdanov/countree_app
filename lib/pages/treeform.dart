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
  bool visRegular = true;
  bool visSeedling = true;

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
  LatLng currentPoint;

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  double zoomLevel = 18.0;

  List<Marker> markers = <Marker>[];
  int maxClusterRadius = 100;
  int totalTrees = 0;
  List<LayerOptions> mainLayers = [
        mapSources[0],
    ];
  LayerOptions clusteredLO;
  LayerOptions nonClusteredLO;

  Map<String, bool> notSure = {
    'treetype' : false,
    'isalive': false,
    'isseedling' : false,
    'diameter' : false,
    'multibarrel' : false,
    'state' : false,
    'firstthread' : false,
    'condition' : false,
    'neighbours' : false,
    'surroundings' : false,
    'overall' : false,
    'height' : false,
  };

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

    //print(_locationData.latitude.toString() + ' ' + _locationData.longitude.toString());

    return new LatLng(56.003313,92.8486668);

    //return new LatLng(_locationData.latitude, _locationData.longitude); 
  }

  void _handleTap(LatLng latlng) {
    setState(() {
      currentPoint = latlng;
    });
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
          mapController.move(currentCity.center, 18.0);     
        });
    });
    
    _getCurrentLocation().then((result){
      mapController.move(result, zoomLevel);
      currentPoint = result;
      _handleTap(currentPoint);
    });

  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Завершить редактирование?'),
        content: new Text('Информация в форме редактирования НЕ БУДЕТ сохранена'),
        actions: <Widget>[
          new FlatButton(
            child: new Text('Остаться', style: TextStyle(fontSize: 20)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Выйти', style: TextStyle(fontSize: 20, color: Colors.red)),
          ),
        ],
      ),
    )) ?? false;
  }  

  @override
  Widget build(BuildContext context) {
    var markers = [currentPoint].map((latlng) {
      return Marker(
        width: 50.0,
        height: 50.0,
        point: latlng,
        builder: (ctx) => Container(
          child: Icon(Icons.filter_tilt_shift, color: Colors.red, size: 50), // FlutterLogo(),
        ),
      );
    }).toList();

    if(mainLayers.length > 1)
      mainLayers.removeLast();

    mainLayers.add(MarkerLayerOptions(markers: markers));
      

    return new WillPopScope(
      onWillPop: _onWillPop,
      child: 
        Scaffold(
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
                          zoom: 18.0,
                          maxZoom: MAXZOOM,
                          onTap: (point) {
                            //print('tap');
                            _handleTap(point);
                            setState((){
                              zoomLevel =  mapController.zoom;
                            });
                          },
                          onPositionChanged: (p1, p2) {
                            //print(p1.center.toString());
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
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                        Text('Биологический вид', style: TextStyle(fontSize: 20)),
                                                        Tooltip(
                                                          message: 'Не уверен',
                                                          child:
                                                            Checkbox(
                                                              value: notSure['treetype'],
                                                              activeColor: Colors.red,
                                                              onChanged: (val) {
                                                                notSure['treetype'] = val;
                                                                setState(() {});
                                                              }
                                                            )
                                                        )
                                                    ],
                                                  )
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
                                          onPressed: () {
                                            setState(() {
                                               _fbKey.currentState.fields['treetype'].currentState.didChange(TreeTypeList.getById(10).name);
                                            });
                                          },
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
                                          onPressed: () {
                                            setState(() {
                                               _fbKey.currentState.fields['treetype'].currentState.didChange(TreeTypeList.getById(1).name);
                                            });
                                          },
                                          color: countreeTheme.shade400,
                                          textColor: Colors.white,
                                          child: Text(TreeTypeList.getById(1).name.toUpperCase(),
                                            style: TextStyle(fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        RaisedButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18.0),
                                            side: BorderSide(color: countreeTheme.shade800)),
                                          onPressed: () {
                                            setState(() {
                                               _fbKey.currentState.fields['treetype'].currentState.didChange(TreeTypeList.getById(17).name);
                                            });
                                          },
                                          color: countreeTheme.shade400,
                                          textColor: Colors.white,
                                          child: Text(TreeTypeList.getById(17).name.toUpperCase(),
                                            style: TextStyle(fontSize: 12)),
                                        ),
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
                                    SizedBox(height: 25),
    // Сухое дерево                                
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
                                                  Row(
                                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Text('Сухое дерево', style: TextStyle(fontSize: 20)),
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
                                                      Spacer(),
                                                      Checkbox(
                                                        value: notSure['isalive'],
                                                        activeColor: Colors.red,
                                                        onChanged: (val) {
                                                          notSure['isalive'] = val;
                                                          setState(() {});
                                                        }
                                                      )
                                                    ],
                                                  )
                                              )
                                          )
                                        )
                                      ]
                                    ), 
                                    FormBuilderSwitch(
                                      attribute: "isalive",
                                      label: Text("Сухое дерево ", style: TextStyle(color: Colors.black87, fontSize: 16)),
                                      onChanged: (value) {
                                        setState(() {
                                          visRegular = !value;
                                          visSeedling = !value;
                                        });
                                      },
                                    ), 
    // Малое насаждение                                
                                    Visibility(
                                      visible: visSeedling,
                                      child: Column(
                                        children: <Widget>[
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
                                                        Row(
                                                          children: <Widget>[
                                                            Text('Малое насаждение', style: TextStyle(fontSize: 20)),
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
                                                                            Text('Лиственное зеленое насаждение ниже 2 метров или хвойное зеленое насаждение ниже 1 метра.'),
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
                                                            Spacer(),
                                                            Checkbox(
                                                              value: notSure['isseedling'],
                                                              activeColor: Colors.red,
                                                              onChanged: (val) {
                                                                notSure['isseedling'] = val;
                                                                setState(() {});
                                                              }
                                                            )
                                                          ],
                                                        )
                                                    )
                                                )
                                              )
                                            ]
                                          ), 
                                          FormBuilderSwitch(
                                            attribute: "isseedling",
                                            label: Text("Малое насаждение", style: TextStyle(color: Colors.black87, fontSize: 16)),
                                            onChanged: (value) {
                                              setState(() {
                                                visRegular = !value;
                                              });
                                            },                                            
                                          ),
                                        ]
                                      )
                                    ),
    // Обхват ствола                              
                                    Visibility(
                                      visible: visRegular,
                                      child:
                                        Column(
                                          children: <Widget>[
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
                                                          Row(
                                                            children: <Widget>[
                                                              Text('Обхват ствола (см)', style: TextStyle(fontSize: 20)),
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
                                                                              Text('Обхват самого толстого ствола дерева, измеренный на высоте 1.3 метра (на уровне груди взрослого человека). Измеряется при помощи портновского метра. В случае, если толщина стволов одинакова - измеряется тот ствол, который измерить удобнее. Если доступ к стволу затруднен, следует оставить поле пустым и нажать кнопку “не уверен“.'),
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
                                                              Spacer(),
                                                              Checkbox(
                                                                value: notSure['diameter'],
                                                                activeColor: Colors.red,
                                                                onChanged: (val) {
                                                                  notSure['diameter'] = val;
                                                                  setState(() {});
                                                                }
                                                              )
                                                            ],
                                                          )
                                                      )
                                                  )
                                                )
                                              ]
                                            ),
                                            FormBuilderTextField(
                                              attribute: "diameter",
                                              keyboardType: TextInputType.number,
                                              initialValue: '10',
                                              validators: [
                                                FormBuilderValidators.numeric(),
                                                FormBuilderValidators.max(1000),
                                              ],
                                            ),
                                          ]
                                        )
                                    ),
    // многоствольное                                
                                    Visibility(
                                      visible: visRegular,
                                      child: Column(
                                        children: <Widget>[
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
                                                        Row(
                                                          children: <Widget>[
                                                            Text('Многоствольное', style: TextStyle(fontSize: 20)),
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
                                                                            Text('Признак указывается, если из земли выходят несколько стволов одного вида и между стволами у земли нельзя поместить ладонь в длину. Если ладонь поместить можно, то следует описывать такие насаждения как отдельные деревья. Если из земли выходит 1 ствол, и уже после ветвится - признак указывать не нужно - это 1 дерево.'),
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
                                                            Spacer(),
                                                            Checkbox(
                                                              value: notSure['multibarrel'],
                                                              activeColor: Colors.red,
                                                              onChanged: (val) {
                                                                notSure['multibarrel'] = val;
                                                                setState(() {});
                                                              }
                                                            )
                                                          ],
                                                        )
                                                    )
                                                )
                                              )
                                            ]
                                          ), 
                                          FormBuilderSwitch(
                                            attribute: "multibarrel",
                                            label: Text("Многоствольное", style: TextStyle(color: Colors.black87, fontSize: 16))
                                          ),
                                        ]
                                      )
                                    ),
    // крона у дерева
                                    Visibility(
                                      visible: visRegular,
                                      child: Column(
                                        children: <Widget>[
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
                                                        Row(
                                                          children: <Widget>[
                                                            Text('Крона у дерева', style: TextStyle(fontSize: 20)),
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
                                                                            Text('Полноценная, естественная - дерево не подвергалось обрезке.'),
                                                                            Image.network("https://24.countree.ru/img/type1.jpg"),
                                                                            SizedBox(height: 25),
                                                                            Text('Искусственно сформированная - имеется 3-5 и более обрезанных ветвей или хотя бы 1 обрезанный ствол более 10 см в диаметре, при этом крона у дерева имеется и выглядит функционально.'),
                                                                            Image.network("https://24.countree.ru/img/type2.jpg"),
                                                                            SizedBox(height: 25),
                                                                            Text('Глубоко обрезанная - Имеется толстый ствол при небольшой высоте, крона представлена тонкими ветвями в возрасте 1-3 лет.'),
                                                                            Image.network("https://24.countree.ru/img/type3.jpg"),
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
                                                            Spacer(),
                                                            Checkbox(
                                                              value: notSure['state'],
                                                              activeColor: Colors.red,
                                                              onChanged: (val) {
                                                                notSure['state'] = val;
                                                                setState(() {});
                                                              }
                                                            )
                                                          ],
                                                        )
                                                    )
                                                )
                                              )
                                            ]
                                          ), 
                                          FormBuilderChoiceChip(
                                            attribute: "state",
                                            options: [
                                              FormBuilderFieldOption(
                                                child: Text("Полноценная, естественная"),
                                                value: 1
                                              ),
                                              FormBuilderFieldOption(
                                                child: Text("Искусственно сформированная"),
                                                value: 2
                                              ),
                                              FormBuilderFieldOption(
                                                child: Text("Глубоко обрезанная"),
                                                value: 3
                                              ),
                                            ],
                                          ),
                                        ]
                                      )
                                    ),
    // высота первой ветви
                                    Visibility(
                                      visible: visRegular,
                                      child: Column(
                                        children: <Widget>[
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
                                                        Row(
                                                          children: <Widget>[
                                                            Text('Крона начинается на высоте', style: TextStyle(fontSize: 16)),
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
                                                                            Text('Высота от земли до нижней ветви дерева, точного измерения не требуется - достаточно сравнения с собственным ростом.'),
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
                                                            Spacer(),
                                                            Checkbox(
                                                              value: notSure['firstthread'],
                                                              activeColor: Colors.red,
                                                              onChanged: (val) {
                                                                notSure['firstthread'] = val;
                                                                setState(() {});
                                                              }
                                                            )
                                                          ],
                                                        )
                                                    )
                                                )
                                              )
                                            ]
                                          ), 
                                          FormBuilderChoiceChip(
                                            attribute: "firstthread",
                                            options: [
                                              FormBuilderFieldOption(
                                                child: 
                                                  Container(
                                                    margin: EdgeInsets.only(left: 10, right: 10),
                                                    child:
                                                      Text("0 м")
                                                  ),
                                                value: 0
                                              ),
                                              FormBuilderFieldOption(
                                                child: 
                                                  Container(
                                                    margin: EdgeInsets.only(left: 10, right: 10),
                                                    child:
                                                      Text("1 м")
                                                  ),
                                                value: 1
                                              ),
                                              FormBuilderFieldOption(
                                                child: 
                                                  Container(
                                                    margin: EdgeInsets.only(left: 10, right: 10),
                                                    child:
                                                      Text("2 м")
                                                  ),
                                                value: 2
                                              ),
                                              FormBuilderFieldOption(
                                                child: 
                                                  Container(
                                                    margin: EdgeInsets.only(left: 10, right: 10),
                                                    child:
                                                      Text("3 м")
                                                  ),
                                                value: 3
                                              ),
                                              FormBuilderFieldOption(
                                                child: 
                                                  Container(
                                                    margin: EdgeInsets.only(left: 10, right: 10),
                                                    child:
                                                      Text("5 м")
                                                  ),
                                                value: 5
                                              ),
                                            ],
                                          ),
                                        ]
                                      )
                                    ),
    // Состояние дерева                                      
                                    Visibility(
                                      visible: visRegular,
                                      child: Column(
                                        children: <Widget>[
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
                                                        Row(
                                                          children: <Widget>[
                                                            Text('Состояние дерева', style: TextStyle(fontSize: 20)),
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
                                                                            Text('Наросты, грибы и другие образования на стволе - ставится даже при единичном плодовом теле гриба или наросте. Кора на стволе облазит или повреждена - ставится при размере повреждения площадью превышающем ладонь (если повреждений несколько, то их суммарная площадь превышает ладонь). Ветви сухие или сломанные и Листья/хвоя потемневшие, с пятнами - устанавливается если повреждения затронули 25% кроны и более. Дефекты, для которых в данном пункте установлена галочка, стоит включить в прикрепляемые фото - либо сделать общий вид дерева, где будут видны указанные недостатки, либо сделать отдельные фото.'),
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
                                                            Spacer(),
                                                            Checkbox(
                                                              value: notSure['condition'],
                                                              activeColor: Colors.red,
                                                              onChanged: (val) {
                                                                notSure['condition'] = val;
                                                                setState(() {});
                                                              }
                                                            )
                                                          ],
                                                        )
                                                    )
                                                )
                                              )
                                            ]
                                          ), 
                                          FormBuilderCheckboxList(
                                            attribute: "condition",
                                            initialValue: [],
                                            options: [
                                              FormBuilderFieldOption(
                                                child: Text("Наросты, грибы и другие образования на стволе"),
                                                value: "1"
                                              ),
                                              FormBuilderFieldOption(
                                                child: Text("Кора на стволе облазит или повреждена"),
                                                value: "2"
                                              ),
                                              FormBuilderFieldOption(
                                                child: Text("Ветви сухие или сломанные"),
                                                value: "3"
                                              ),
                                              FormBuilderFieldOption(
                                                child: Text("Листья/хвоя потемневшие, с пятнами"),
                                                value: "4"
                                              ),
                                            ],
                                          ),
                                        ]
                                      )
                                    ),

    // условия роста дерева
                                    Visibility(
                                      visible: visRegular,
                                      child: Column(
                                        children: <Widget>[
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
                                                        Row(
                                                          children: <Widget>[
                                                            Text('Условия роста', style: TextStyle(fontSize: 20)),
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
                                                                            Text('В случае, если в 0,5 метров от ствола нет ничего кроме почвы и растительности, устанавливается значение “Только почва, газон”, в противном случае устанавливается одна из 3-х подходящих галочек. В случае наличия нескольких подходящих вариантов (есть и асфальт и брусчатка) - указывается преобладающий по занимаемой площади вариант.'),
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
                                                            Spacer(),
                                                            Checkbox(
                                                              value: notSure['surroundings'],
                                                              activeColor: Colors.red,
                                                              onChanged: (val) {
                                                                notSure['surroundings'] = val;
                                                                setState(() {});
                                                              }
                                                            )
                                                          ],
                                                        )
                                                    )
                                                )
                                              )
                                            ]
                                          ), 
                                          FormBuilderChoiceChip(
                                            attribute: "surroundings",
                                            options: [
                                              FormBuilderFieldOption(
                                                child:Text("Брусчатка"),
                                                value: 1
                                              ),
                                              FormBuilderFieldOption(
                                                child:Text("Асфальт"),
                                                value: 2
                                              ),
                                              FormBuilderFieldOption(
                                                child:Text("Только почва, газон"),
                                                value: 4
                                              ),
                                              FormBuilderFieldOption(
                                                child:Text("Другое (бетон, керамогранит, доски, пластик)"),
                                                value: 3
                                              ),
                                            ],
                                          ),
                                        ]
                                      )
                                    ),
    // Окружение дерева                                      
                                    Visibility(
                                      visible: visRegular,
                                      child: Column(
                                        children: <Widget>[
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
                                                        Row(
                                                          children: <Widget>[
                                                            Text('Окружение дерева', style: TextStyle(fontSize: 20)),
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
                                                                            Text('Галочку “Провода над кроной дерева” - стоит указывать так же если провода В кроне или ПОД кроной дерева. В случае, если провода высоко над кроной дерева и дерево не способно дорасти до такой высоты, то галочку указывать не стоит. Объекты, для которых в данном пункте установлена галочка, стоит включить в прикрепляемые фото - либо сделать общий вид дерева, где будут видны указанные объекты, либо сделать отдельные фото.'),
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
                                                            Spacer(),
                                                            Checkbox(
                                                              value: notSure['neighbours'],
                                                              activeColor: Colors.red,
                                                              onChanged: (val) {
                                                                notSure['neighbours'] = val;
                                                                setState(() {});
                                                              }
                                                            ) 
                                                          ],
                                                        )
                                                    )
                                                )
                                              )
                                            ]
                                          ), 
                                          FormBuilderCheckboxList(
                                            attribute: "neighbours",
                                            initialValue: [],
                                            options: [
                                              FormBuilderFieldOption(
                                                child: Text("Здание в 5 метрах от ствола"),
                                                value: "1"
                                              ),
                                              FormBuilderFieldOption(
                                                child: Text("Рекламная или другая конструкция, столб, павильон в 1 метре от кроны"),
                                                value: "2"
                                              ),
                                              FormBuilderFieldOption(
                                                child: Text("Провода над кроной дерева"),
                                                value: "3"
                                              ),
                                              FormBuilderFieldOption(
                                                child: Text("Искусственные объекты намотаны, привязаны, прибиты к стволу или кроне дерева"),
                                                value: "4"
                                              ),
                                            ],
                                          ),
                                        ]
                                      )
                                    ),
    // интегральное состоение дерева (общая оценка)
                                    Visibility(
                                      visible: visRegular,
                                      child: Column(
                                        children: <Widget>[
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
                                                        Row(
                                                          children: <Widget>[
                                                            Text('Общая оценка', style: TextStyle(fontSize: 20)),
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
                                                                            Text('Общая оценка дерева - показатель “здоровья” дерева. Хорошее - если дерево выглядит здоровым и не имеет никаких признаков болезней (повреждения коры, наросты, потемневшая листва, сухие ветви, грибы и тд), Удовлетворительное - у дерева есть проблемы, но не угрожающие его жизнеспособности. Неудовлетворительное - существенные повреждения дерева, возможна его гибель из-за повреждений.'),
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
                                                            Spacer(),
                                                            Checkbox(
                                                              value: notSure['overall'],
                                                              activeColor: Colors.red,
                                                              onChanged: (val) {
                                                                notSure['overall'] = val;
                                                                setState(() {});
                                                              }
                                                            ) 
                                                          ],
                                                        )
                                                    )
                                                )
                                              )
                                            ]
                                          ), 
                                          FormBuilderChoiceChip(
                                            attribute: "overall",
                                            options: [
                                              FormBuilderFieldOption(
                                                child: 
                                                  Container(
                                                    margin: EdgeInsets.only(left: 10, right: 10),
                                                    child:
                                                      Text("хорошее")
                                                  ),
                                                value: 1
                                              ),
                                              FormBuilderFieldOption(
                                                child: 
                                                  Container(
                                                    margin: EdgeInsets.only(left: 10, right: 10),
                                                    child:
                                                      Text("удовл")
                                                  ),
                                                value: 2
                                              ),
                                              FormBuilderFieldOption(
                                                child: 
                                                  Container(
                                                    margin: EdgeInsets.only(left: 10, right: 10),
                                                    child:
                                                      Text("неудовл", style: TextStyle(color: Colors.red))
                                                  ),
                                                value: 3
                                              ),
                                            ],
                                          ),
                                        ]
                                      )
                                    ),                                    
    // фотографии                                
                                    Visibility(
                                      visible: visRegular,
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(height: 25),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 10,
                                                child: Container(
                                                  color: countreeTheme.shade100,
                                                  child: 
                                                    Padding(
                                                      padding: EdgeInsets.all(20.0),
                                                      child:
                                                        Row(
                                                          children: <Widget>[
                                                            Text('Фотографии', style: TextStyle(fontSize: 20)),
                                                          ],
                                                        )
                                                    )
                                                )
                                              )
                                            ]
                                          ), 
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 10,
                                                child:
                                                  FormBuilderImagePicker(
                                                    attribute: "treeimages",
                                                  )
                                              )
                                            ]
                                          )
                                        ]
                                      )
                                    ),
    // высота дерева                    
                                    Visibility(
                                      visible: visRegular,
                                      child:
                                        Column(
                                          children: <Widget>[
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
                                                          Row(
                                                            children: <Widget>[
                                                              Text('Высота дерева', style: TextStyle(fontSize: 20)),
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
                                                                              Text('Высоту можно определить или по ориентирам (этаж здания - около 3 метров), или с помощью бумажного прямоугольного треугольника с углами 45 градусов. Для этого поднесите его к глазу так, чтобы катеты были горизонтально и вертикально, а Вы смотрели на гипотенузу. Наведите верхнюю вершину треугольника на вершину дерева и отмерьте расстояние до дерева из этой точке. Добавив Ваш рост, Вы получите примерную высоту дерева.\n'),
                                                                              Image.network("https://24.countree.ru/img/tree-height.jpg"),
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
                                                              Spacer(),
                                                              Checkbox(
                                                                value: notSure['height'],
                                                                activeColor: Colors.red,
                                                                onChanged: (val) {
                                                                  notSure['height'] = val;
                                                                  setState(() {});
                                                                }
                                                              ) 
                                                            ],
                                                          )
                                                      )
                                                  )
                                                )
                                              ]
                                            ),
                                            /*
                                            FormBuilderTextField(
                                              attribute: "height",
                                              keyboardType: TextInputType.number,                                          
                                              validators: [
                                                FormBuilderValidators.numeric(),
                                                FormBuilderValidators.max(70),
                                                FormBuilderValidators.min(0),
                                              ],
                                            ), 
                                            */
                                            FormBuilderSlider(
                                              attribute: "height",
                                              validators: [FormBuilderValidators.min(0.1)],
                                              min: 0.0,
                                              max: 30.0,
                                              initialValue: 1.0,
                                              divisions: 200,
                                            ),
                                          ]
                                        )
                                    ),
                                  ],
                                )
                            )
                          )
                        ]
                      )
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container()
                        ),
                        Expanded(                      
                          flex: 8,
                          child:
                            RaisedButton(
                              color: Colors.deepOrangeAccent,
                              child: Text("Сохранить и отправить", style: TextStyle(fontSize: 16, color: Colors.white)),
                              onPressed: () {
                                if (_fbKey.currentState.saveAndValidate()) {
                                  print(_fbKey.currentState.value);

                                  showDialog(
                                    context: context,
                                    builder: (context) => new AlertDialog(
                                      title: new Text('Информация о дереве сохранена'),
                                      content: new Text('Вы можете добавить ещё одно дерево или вернуться к карте'),
                                      actions: <Widget>[
                                        new FlatButton(
                                          child: new Text('На карту', style: TextStyle(fontSize: 20)),
                                          onPressed: () => {
                                            Navigator.of(context).pop(true),
                                            Navigator.of(context).pop(true),
                                          }
                                        ),
                                        new FlatButton(
                                          child: new Text('Ещё дерево', style: TextStyle(fontSize: 20, color: Colors.red)),
                                          onPressed: () => {
                                            Navigator.of(context).pop(true),
                                            Navigator.of(context).pop(true),
                                            Navigator.pushNamed(context, TreeformPage.route), //Navigator.pushNamedAndRemoveUntil(context, "treeform", (r) => false),
                                          }
                                        ),
                                      ],
                                    ),
                                  );                                

                                }
                              },
                            ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container()
                        ),
                      ],
                    ),
                    SizedBox(height: 50), 
                  ],
                )
            )
        )
      );
  }

}