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
    if(res == true)
      return await loadCurrentUser();
    return res;
  } 

  _getMapLayer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var newMapLayerName = prefs.getString('mapsrc');

    if(newMapLayerName != '' && newMapLayerName != mapSourcesNames[0])
    {
      // antipattern! to remove
      switch (newMapLayerName) {
        case "Mapbox (карта)": mainLayers[0] = mapSources[1]; break;
        case "Mapbox (спутниковый снимок)": mainLayers[0] = mapSources[2]; break;
        case "OSM": mainLayers[0] = mapSources[3]; break;
        case "Яндекс (тест)": mainLayers[0] = mapSources[4]; break;
        default: mainLayers[0] = mapSources[0];
      }

      return true;
    }

    return false;
  }

  _getPrevTrees() async {
    final localTrees = await Dbtree.Tree().select().orderByDesc('created').toList();

    prevMarkers = <Marker>[];
    for(var tree in localTrees)
    {
      Color mInnerColor = Color(0xff225D9C);
      Color mBorderColor = Colors.green;
      double mSize = 16;

      if(tree.is_seedling == 1)
      {
        mInnerColor = Color(0xff7EE043);
        mSize = 12;
      }
      else if(tree.is_alive == 1)
      {
          mInnerColor = Color(0xff222222);
      }
      else if(TreeTypeList.getById(tree.id_treetype).decidious==true)
      {
        mInnerColor = Color(0xffe0c143);
      }
      else
      {
        mInnerColor = Color(0xff7ee043);
      }

      Marker tempMarker = Marker(
          width: mSize + 4,
          height: mSize + 4,
          point: LatLng(tree.latitude, tree.longitude),
          builder: (ctx) => Container(
            child: 
            GestureDetector(
              onTap: () {
                _scaffoldKey.currentState.hideCurrentSnackBar();
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content:
                    Row(
                      children: <Widget>[                              
                        Text(TreeTypeList.getById(tree.id_treetype).name)
                      ],
                    )
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
      prevMarkers.add(tempMarker);
    }    
  }

  Future<String>  _localPath() async {
    final directory = await  getApplicationDocumentsDirectory();
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

  _getCurrentLocation({bool useStored: true}) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final curLat = (prefs.getDouble('latitude') ?? 0);
    final curLon = (prefs.getDouble('longitude') ?? 0);
    final curZoom = (prefs.getDouble('zoom') ?? 0);

    print(curLat.toString() + ' ' + curLon.toString());

    if(useStored==false || curLat==0)
    {
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
      //return new LatLng(56.003313,92.8486668);
      return new LatLng(_locationData.latitude, _locationData.longitude);
    }
    else
    {
      zoomLevel = curZoom;
      return new LatLng(curLat, curLon);
    }
  }

  void _handleTap(LatLng latlng) {
    setState(() {
      currentPoint = latlng;
    });
  }

  @override
  void initState() {
    super.initState();

    _localPath().then((result){
      localDocPath = result;
    });

    _getLoggedState().then((result){
        setState(() {
          if(result is User)
          {
            currentUser = result;
            signed = true;
          }
          else
            signed = false;
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
    
    _getMapLayer().then((result){
        setState(() {});
    });
  
    _getPrevTrees().then((result){
      setState(() {});
    });

    _getCurrentLocation().then((result){
      mapController.move(result, zoomLevel);
      currentPoint = result;
      _handleTap(currentPoint);
    });


    WidgetsBinding.instance.addPostFrameCallback((_) => { 
        _getTreeByTime(args).then((result){
          if(result != null)
            _loadFormWithTree(result, setpos: true);
        })
    });

  }

  Future<Dbtree.Tree> _getTreeByTime(int timestamp) async
  {
    if(timestamp==null)
      return null;
    final tree = await Dbtree.Tree().select().where('created=$timestamp').toSingle();
    return tree;
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
            onPressed: () =>
              Navigator.of(context).pop(false)
          ),
          new FlatButton(
            onPressed: () async { 
              await _rememberMapPosition();
              Navigator.of(context).pop(true);
            },
            child: new Text('Выйти', style: TextStyle(fontSize: 20, color: Colors.red)),
          ),
        ],
      ),
    )) ?? false;
  }  

  List<String> validateTree(){
    final treeInfo = _fbKey.currentState.value;
    var errors = List<String>();

    if(treeInfo['isalive']==true || treeInfo['isseedling']==true)
      return [];

    if(treeInfo['diameter'] == 0 && notSure['diameter'] == false)
      errors.add("Обхват ствола должен быть больше нуля");

    if(treeInfo['state']==null && notSure['state'] == false)
      errors.add("Необходимо указать крону у дерева");

    if(treeInfo['surroundings']==null && notSure['surroundings'] == false)
      errors.add("Необходимо указать условия роста");

    if(treeInfo['treeimages']==null || treeInfo['treeimages'].length == 0)
      errors.add("Необходимо добавить хотя бы одно фото");

    if(treeInfo['height'] == 0 && notSure['height'] == false)
      errors.add("Высота дерева должна быть больше нуля");

    return errors;
  }

  Future<Dbtree.Tree> saveTreeLocal() async
  {
    final treeInfo = _fbKey.currentState.value;
    var res = 0;

    if(treeInfo['isalive']==true)
    {
      var ctree = Dbtree.Tree(
        created: new DateTime.now().millisecondsSinceEpoch,
        id_user: currentUser.id_system,
        id_treetype: TreeTypeList.getByName(treeInfo['treetype']).id,
        custom_treetype: treeInfo['custom_treetype'],
        notsure_treetype: notSure['treetype']==true?1:0,
        longitude: currentPoint.longitude,
        latitude: currentPoint.latitude,
        is_alive: treeInfo['isalive']==true?1:0,
        notsure_is_alive: notSure['isalive']==true?1:0,
      );

      if(args!=null)
      {
        var targetTree = await _getTreeByTime(args);
        if(targetTree!=null)
        {
          targetTree.uploaded = 0;
          targetTree.id_user = ctree.id_user;
          targetTree.id_treetype = ctree.id_treetype;
          targetTree.custom_treetype = ctree.custom_treetype;
          targetTree.notsure_treetype = ctree.notsure_treetype;
          targetTree.longitude = ctree.longitude;
          targetTree.latitude = ctree.latitude;
          targetTree.is_alive = ctree.is_alive;
          targetTree.notsure_is_alive = ctree.notsure_is_alive;

          var res = await targetTree.save();

          return targetTree;
          //return res>0?ctree:targetTree;
        }
      }
      else
      {
        var res = await ctree.save();
        return res>0?ctree:null;
      }   


      //var res = await ctree.save();
      //return res>0?ctree:null;
    }
    else if(treeInfo['isseedling']==true)
    {
      var ctree = Dbtree.Tree(
        created: new DateTime.now().millisecondsSinceEpoch,
        id_user: currentUser.id_system,
        id_treetype: TreeTypeList.getByName(treeInfo['treetype']).id,
        custom_treetype: treeInfo['custom_treetype'],
        notsure_treetype: notSure['treetype']==true?1:0,
        longitude: currentPoint.longitude,
        latitude: currentPoint.latitude,
        is_alive: treeInfo['isalive']==true?1:0,
        notsure_is_alive: notSure['isalive']==true?1:0,
        is_seedling: treeInfo['isseedling']==true?1:0,
        notsure_is_seedling: notSure['isseedling']==true?1:0,
      );


      if(args!=null)
      {
        var targetTree = await _getTreeByTime(args);
        if(targetTree!=null)
        {
          targetTree.uploaded = 0;
          targetTree.id_user = ctree.id_user;
          targetTree.id_treetype = ctree.id_treetype;
          targetTree.custom_treetype = ctree.custom_treetype;
          targetTree.notsure_treetype = ctree.notsure_treetype;
          targetTree.longitude = ctree.longitude;
          targetTree.latitude = ctree.latitude;
          targetTree.is_alive = ctree.is_alive;
          targetTree.notsure_is_alive = ctree.notsure_is_alive;
          targetTree.is_seedling = ctree.is_seedling;
          targetTree.notsure_is_seedling = ctree.notsure_is_seedling;

          var res = await targetTree.save();

          return targetTree;
          //return res>0?ctree:targetTree;
        }
      }
      else
      {
        var res = await ctree.save();
        return res>0?ctree:null;
      }      

      //var res = await ctree.save();
      //return res>0?ctree:null;           
    }
    else
    {

      var imagePaths = List<String>();
      for(var ti in treeInfo['treeimages'])
      {
        imagePaths.add(ti.path);
      }      
      var ctree = Dbtree.Tree(
        created: new DateTime.now().millisecondsSinceEpoch,
        id_user: currentUser.id_system,
        id_treetype: TreeTypeList.getByName(treeInfo['treetype']).id,
        custom_treetype: treeInfo['custom_treetype'],
        notsure_treetype: notSure['treetype']==true?1:0,
        longitude: currentPoint.longitude,
        latitude: currentPoint.latitude,
        is_alive: treeInfo['isalive']==true?1:0,
        notsure_is_alive: notSure['isalive']==true?1:0,
        is_seedling: treeInfo['isseedling']==true?1:0,
        notsure_is_seedling: notSure['isseedling']==true?1:0,
        diameter: int.parse(treeInfo['diameter']),
        notsure_diameter: notSure['diameter']==true?1:0,
        multibarrel: treeInfo['multibarrel']==true?1:0,
        notsure_multibarrel: notSure['multibarrel']==true?1:0,
        id_state: treeInfo['state'],
        notsure_id_state: notSure['state']==true?1:0,
        firstthread: treeInfo['firstthread']==null?0:treeInfo['firstthread'],
        notsure_firstthread: notSure['firstthread']==true?1:0,
        ids_condition: treeInfo['condition'].map((i) => i.toString()).join(","),
        custom_condition: treeInfo['custom_condition'],
        notsure_ids_condition: notSure['condition']==true?1:0,
        id_surroundings: treeInfo['surroundings'],
        notsure_id_surroundings: notSure['surroundings']==true?1:0,
        ids_neighbours: treeInfo['neighbours'].map((i) => i.toString()).join(","),
        notsure_ids_neighbours: notSure['neighbours']==true?1:0, 
        id_overall: treeInfo['overall']==null?0:treeInfo['overall'],
        height: treeInfo['height'], //double.parse(treeInfo['height']),
        images: imagePaths.join(";")
      ); //.save();

      
      if(args!=null)
      {
        var targetTree = await _getTreeByTime(args);
        if(targetTree!=null)
        {
          targetTree.uploaded = 0;
          targetTree.id_user = ctree.id_user;
          targetTree.id_treetype = ctree.id_treetype;
          targetTree.custom_treetype = ctree.custom_treetype;
          targetTree.notsure_treetype = ctree.notsure_treetype;
          targetTree.longitude = ctree.longitude;
          targetTree.latitude = ctree.latitude;
          targetTree.is_alive = ctree.is_alive;
          targetTree.notsure_is_alive = ctree.notsure_is_alive;
          targetTree.is_seedling = ctree.is_seedling;
          targetTree.notsure_is_seedling = ctree.notsure_is_seedling;
          targetTree.diameter = ctree.diameter;
          targetTree.notsure_diameter = ctree.notsure_diameter;
          targetTree.multibarrel = ctree.multibarrel;
          targetTree.notsure_multibarrel = ctree.notsure_multibarrel;
          targetTree.id_state = ctree.id_state;
          targetTree.notsure_id_state = ctree.notsure_id_state;
          targetTree.firstthread = ctree.firstthread;
          targetTree.notsure_firstthread = ctree.notsure_firstthread;
          targetTree.ids_condition = ctree.ids_condition;
          targetTree.custom_condition = ctree.custom_condition;
          targetTree.notsure_ids_condition = ctree.notsure_ids_condition;
          targetTree.id_surroundings = ctree.id_surroundings;
          targetTree.notsure_id_surroundings = ctree.notsure_id_surroundings;
          targetTree.ids_neighbours = ctree.ids_neighbours;
          targetTree.notsure_ids_neighbours = ctree.notsure_ids_neighbours;
          targetTree.id_overall = ctree.id_overall;
          targetTree.height = ctree.height;
          targetTree.images = ctree.images;

          //targetTree.created = ctree.created;
          var res = await targetTree.save();

          return targetTree;
          //return res>0?ctree:targetTree;
        }
      }
      else
      {
        var res = await ctree.save();
        return res>0?ctree:null;
      }

    }
    //return false;
  }

  Future<bool> _rememberMapPosition() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', mapController.center.latitude);
    await prefs.setDouble('longitude', mapController.center.longitude);
    await prefs.setDouble('zoom', mapController.zoom);
    return true;
  }

  Future<bool> _copyPervTree() async
  {
    final lastTree = await Dbtree.Tree().select().orderByDesc('created').toSingle();

    if(lastTree != null)
      _loadFormWithTree(lastTree, noimg:true);
    else
      return false;
    
    return true;
  }

  _loadFormWithTree(Dbtree.Tree tree, {setpos: false, noimg: false})
  {
    setState(() {
        if(setpos==true)
        {
          currentPoint = new LatLng(tree.latitude, tree.longitude);
          mapController.move(currentPoint, zoomLevel);
        }

        // биологический вид
        final idTreetype = tree.id_treetype;
        _fbKey.currentState.fields['treetype'].currentState.didChange(TreeTypeList.getById(idTreetype).name);
        visCustomType = (idTreetype == 99);
        notSure['treetype'] = (tree.notsure_treetype==1);

        // сухое дерево
        _fbKey.currentState.fields['isalive'].currentState.didChange(tree.is_alive==1);
        visRegular = (tree.is_alive==0);
        visSeedling = (tree.is_seedling==0);
        notSure['isalive'] = (tree.notsure_is_alive==1);

        if(visRegular == false)
        {
          visSeedling = false;
          return;
        }

        // малое насаждение
        _fbKey.currentState.fields['isseedling'].currentState.didChange(tree.is_seedling==1);
        visRegular = (tree.is_seedling==0);
        notSure['isseedling'] = (tree.notsure_is_seedling==1);

        if(visSeedling == false)
          return;

        // обхват ствола
        _fbKey.currentState.fields['diameter'].currentState.didChange(tree.diameter.toString());
        notSure['diameter'] = (tree.notsure_diameter==1);

        // крона у дерева
        _fbKey.currentState.fields['state'].currentState.didChange(tree.id_state);
        notSure['state'] = (tree.notsure_id_state==1);

        // высота первой ветви
        _fbKey.currentState.fields['firstthread'].currentState.didChange(tree.firstthread);
        notSure['firstthread'] = (tree.notsure_firstthread==1);

        // состояние  дерева
        if(tree.ids_condition != null)
        {
          var condList = tree.ids_condition.split(','); //.map(int.parse).toList();
          if(condList.isEmpty!=true)
          {
            final condListIds = tree.ids_condition.split(',').toList();
            _fbKey.currentState.fields['condition'].currentState.didChange(condListIds);
          }
        }
        notSure['condition'] = (tree.notsure_ids_condition==1);

        // условия роста
        _fbKey.currentState.fields['surroundings'].currentState.didChange(tree.id_surroundings);
        notSure['surroundings'] = (tree.notsure_id_surroundings==1);

        // окружение  дерева
        if(tree.ids_neighbours != null)
        {
          var neibList = tree.ids_neighbours.split(','); //.map(int.parse).toList();
          if(neibList.isEmpty!=true)
          {
            final neibListIds = tree.ids_neighbours.split(',').toList();
            _fbKey.currentState.fields['neighbours'].currentState.didChange(neibListIds);
          }
        }
        notSure['neighbours'] = (tree.notsure_ids_neighbours==1);
        
        // общая оценка
        _fbKey.currentState.fields['overall'].currentState.didChange(tree.id_overall);
        notSure['overall'] = (tree.notsure_id_overall==1);        

        // высота первой ветви
        _fbKey.currentState.fields['height'].currentState.didChange(tree.height);
        notSure['height'] = (tree.notsure_firstthread==1);

        if(noimg == false && tree.is_alive==0 && tree.is_seedling==0)
        {
          // изображения
          final imagePathList = tree.images.split(";");
          List<File> imagesList = [];        
          for(var imgpath in imagePathList)
          {
            imagesList.add(new File(imgpath));
          }
          _fbKey.currentState.fields['treeimages'].currentState.didChange(imagesList);
        }
    });
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
          child: Icon(Icons.filter_tilt_shift, color: Colors.red, size: 50), // FlutterLogo(),
        ),
      );
    }).toList();


    if(mainLayers.length > 1)
    {
      mainLayers.removeLast();

      if(prevMarkers.length>0 && mainLayers.length>1)
        mainLayers.removeLast();
    }
    mainLayers.add(MarkerLayerOptions(markers: prevMarkers));
    mainLayers.add(MarkerLayerOptions(markers: markers));
      

    return new WillPopScope(
      onWillPop: _onWillPop,
      child: 
        Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: Text('Countree')),
          endDrawer: buildDrawer(context, TreeformPage.route, signed:signed, cu: currentUser),
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
                      padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 2),
                      child:
                        Row(
                          children: <Widget>[
                            Text('Lon: ${currentPoint==null?'0':currentPoint.longitude.toString()}\nLat: ${currentPoint==null?'0':currentPoint.latitude.toString()}'), 
                            Spacer(),
                            GestureDetector(
                              onTap: () async {
                                _getCurrentLocation(useStored: false).then((result){
                                  setState(() {
                                    mapController.move(result, zoomLevel);
                                    currentPoint = result;
                                    _handleTap(currentPoint);                                    
                                  });
                                });  
                              },
                              child: Icon(Icons.gps_fixed , color: countreeTheme.shade400, size: 40),
                            ),
                            //Text(' Lat: ${currentPoint==null?'0':currentPoint.latitude.toString()}')
                          ],
                        ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
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
                                                padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
                                                child:
                                                  Row(
                                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                        Text('Биологический вид', style: TextStyle(fontSize: 20)),
                                                        Spacer(),
                                                        Tooltip(
                                                          message: 'Не уверен',
                                                          child:
                                                            SizedBox(
                                                              width: 28.0,
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
                                                        ),
                                                        Text('н/у', style: TextStyle(fontSize: 14)),
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
                                               visCustomType = false;
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
                                               visCustomType = false;
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
                                               visCustomType = false;
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
                                      onChanged: (el){
                                        if(el == 'другой вид' && visCustomType == false)
                                          setState(() {visCustomType = true;});
                                        else if(el != 'другой вид' && visCustomType == true)
                                          setState(() {visCustomType = false;});
                                      },
                                    ),
                                    Visibility(
                                      visible: visCustomType,
                                      child:           
                                        FormBuilderTextField(
                                          attribute: "custom_treetype",
                                          decoration: InputDecoration(labelText: "Введите вид"),
                                          validators: [
                                            FormBuilderValidators.max(100),
                                          ],
                                        ),
                                    ),
                                    /*
                                    SizedBox(height: 15),
                                    RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4.0),
                                        side: BorderSide(color: countreeTheme.shade800)),
                                      onPressed: () {
                                        setState(() {
                                            //_fbKey.currentState.fields['treetype'].currentState.didChange(TreeTypeList.getById(1).name);
                                        });
                                      },
                                      color: countreeTheme.shade100,
                                      textColor: countreeTheme.shade800,
                                      child: Text('Определитель',
                                        style: TextStyle(fontSize: 14)),
                                    ), 
                                    */
                                    SizedBox(height: 15),
    // Сухое дерево                                
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 10,
                                          child: Container(
                                            color: countreeTheme.shade100,
                                            child: 
                                              Padding(
                                                padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
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
                                                      Tooltip(
                                                        message: 'Не уверен',
                                                        child:
                                                          SizedBox(
                                                            width: 28.0,
                                                            child: 
                                                              Checkbox(
                                                                value: notSure['isalive'],
                                                                activeColor: Colors.red,
                                                                onChanged: (val) {
                                                                  notSure['isalive'] = val;
                                                                  setState(() {});
                                                                }
                                                              )
                                                          )
                                                      ),
                                                      Text('н/у', style: TextStyle(fontSize: 14)),
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
                                                      padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
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
                                                            Tooltip(
                                                              message: 'Не уверен',
                                                              child:
                                                                SizedBox(
                                                                  width: 28.0,
                                                                  child: 
                                                                    Checkbox(
                                                                      value: notSure['isseedling'],
                                                                      activeColor: Colors.red,
                                                                      onChanged: (val) {
                                                                        notSure['isseedling'] = val;
                                                                        setState(() {});
                                                                      }
                                                                    )
                                                                )
                                                            ),
                                                            Text('н/у', style: TextStyle(fontSize: 14)),
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
                                                        padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
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
                                                              Tooltip(
                                                                message: 'Не уверен',
                                                                child:
                                                                  SizedBox(
                                                                    width: 28.0,
                                                                    child: 
                                                                      Checkbox(
                                                                        value: notSure['diameter'],
                                                                        activeColor: Colors.red,
                                                                        onChanged: (val) {
                                                                          notSure['diameter'] = val;
                                                                          setState(() {});
                                                                        }
                                                                      )
                                                                  )
                                                              ),
                                                              Text('н/у', style: TextStyle(fontSize: 14)),
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
                                                      padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
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
                                                            Tooltip(
                                                              message: 'Не уверен',
                                                              child:
                                                                SizedBox(
                                                                    width: 28.0,
                                                                    child:
                                                                      Checkbox(
                                                                        value: notSure['multibarrel'],
                                                                        activeColor: Colors.red,
                                                                        onChanged: (val) {
                                                                          notSure['multibarrel'] = val;
                                                                          setState(() {});
                                                                        }
                                                                      )
                                                                )
                                                            ),
                                                            Text('н/у', style: TextStyle(fontSize: 14)),
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
                                                      padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
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
                                                            Tooltip(
                                                              message: 'Не уверен',
                                                              child:
                                                                SizedBox(
                                                                  width: 28.0,
                                                                  child:
                                                                    Checkbox(
                                                                      value: notSure['state'],
                                                                      activeColor: Colors.red,
                                                                      onChanged: (val) {
                                                                        notSure['state'] = val;
                                                                        setState(() {});
                                                                      }
                                                                    )
                                                                )
                                                            ),
                                                            Text('н/у', style: TextStyle(fontSize: 14)),
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
                                                      padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
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
                                                            Tooltip(
                                                              message: 'Не уверен',
                                                              child:
                                                                SizedBox(
                                                                  width: 28.0,
                                                                  child:
                                                                    Checkbox(
                                                                      value: notSure['firstthread'],
                                                                      activeColor: Colors.red,
                                                                      onChanged: (val) {
                                                                        notSure['firstthread'] = val;
                                                                        setState(() {});
                                                                      }
                                                                    )
                                                                )
                                                            ),
                                                            Text('н/у', style: TextStyle(fontSize: 14)),
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
                                                      padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
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
                                                            Tooltip(
                                                              message: 'Не уверен',
                                                              child:
                                                                SizedBox(
                                                                  width: 28.0,
                                                                  child:
                                                                    Checkbox(
                                                                      value: notSure['condition'],
                                                                      activeColor: Colors.red,
                                                                      onChanged: (val) {
                                                                        notSure['condition'] = val;
                                                                        setState(() {});
                                                                      }
                                                                    )
                                                                )
                                                            ),
                                                            Text('н/у', style: TextStyle(fontSize: 14)),
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
                                            onChanged: (el){
                                              if(visCustomCondition == false && el.contains("99"))
                                                setState(() {visCustomCondition = true;});
                                              else if(visCustomCondition == true && !el.contains("99"))
                                                setState(() {visCustomCondition = false;});
                                            },
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
                                              FormBuilderFieldOption(
                                                child: Text("Иные особенности (напр., дупло, опасный наклон ствола)"),
                                                value: "99"
                                              ),
                                            ],
                                          ),
                                          Visibility(
                                            visible: visCustomCondition,
                                            child:           
                                              FormBuilderTextField(
                                                attribute: "custom_condition",
                                                decoration: InputDecoration(labelText: "Введите особености состояния"),
                                                validators: [
                                                  FormBuilderValidators.max(200),
                                                ],
                                              ),
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
                                                      padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
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
                                                            Tooltip(
                                                              message: 'Не уверен',
                                                              child:
                                                                Checkbox(
                                                                  value: notSure['surroundings'],
                                                                  activeColor: Colors.red,
                                                                  onChanged: (val) {
                                                                    notSure['surroundings'] = val;
                                                                    setState(() {});
                                                                  }
                                                                )
                                                            ),
                                                            Text('н/у', style: TextStyle(fontSize: 14)),
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
                                                      padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
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
                                                            Tooltip(
                                                              message: 'Не уверен',
                                                              child:
                                                                SizedBox(
                                                                  width: 28.0,
                                                                  child:
                                                                    Checkbox(
                                                                      value: notSure['neighbours'],
                                                                      activeColor: Colors.red,
                                                                      onChanged: (val) {
                                                                        notSure['neighbours'] = val;
                                                                        setState(() {});
                                                                      }
                                                                    )
                                                                )
                                                            ),
                                                            Text('н/у', style: TextStyle(fontSize: 14)),
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
                                                      padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
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
                                                            Tooltip(
                                                              message: 'Не уверен',
                                                              child:
                                                                SizedBox(
                                                                  width: 28.0,
                                                                  child:
                                                                    Checkbox(
                                                                      value: notSure['overall'],
                                                                      activeColor: Colors.red,
                                                                      onChanged: (val) {
                                                                        notSure['overall'] = val;
                                                                        setState(() {});
                                                                      }
                                                                    )
                                                                )
                                                            ),
                                                            Text('н/у', style: TextStyle(fontSize: 14)),
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
                                                      padding: EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
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
                                                    //initialValue: ['https://24.countree.ru/assets/preview/88/75/887592c95b458d783e2f661723185e94.jpg'],
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
                                                        padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
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
                                                              Tooltip(
                                                                message: 'Не уверен',
                                                                child:
                                                                  SizedBox(
                                                                    width: 28.0,
                                                                    child:
                                                                    Checkbox(
                                                                      value: notSure['height'],
                                                                      activeColor: Colors.red,
                                                                      onChanged: (val) {
                                                                        notSure['height'] = val;
                                                                        setState(() {});
                                                                      }
                                                                    )
                                                                  )
                                                              ),
                                                              Text('н/у', style: TextStyle(fontSize: 14)),
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
                                              validators: [FormBuilderValidators.min(1)],
                                              min: 0,
                                              max: 30,
                                              initialValue: 1,
                                              divisions: 30,
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
                              child: args==null?Text("Сохранить и отправить", style: TextStyle(fontSize: 16, color: Colors.white)):Text("Сохранить изменения", style: TextStyle(fontSize: 16, color: Colors.white)),
                              onPressed: () async {
                                if (_fbKey.currentState.saveAndValidate()) {
                                  //print(_fbKey.currentState.value);
                                  final errors = validateTree(); 

                                  if(errors.length == 0)
                                  {
                                    //await saveTreeLocal();
                                    /*
                                    final File tstimage = _fbKey.currentState.value['treeimages'][0];
                                    print(tstimage.path);
                                    //var testFilename = _fbKey.currentState.value['treeimages'][0].toString().replaceAll("'", "").replaceAll("File: ", "file://");

                                    LocalImage.Image image = LocalImage.decodeImage(tstimage.readAsBytesSync());
                                    LocalImage.Image thumbnail = LocalImage.copyResize(image, width: 120); 
                                    new File('$localDocPath/thumbnail-test.jpg')
                                      ..writeAsBytesSync(LocalImage.encodeJpg(thumbnail));                                  
                                    */
                                    final ProgressDialog pr = ProgressDialog(context);
                                    pr.style(message: 'Отправка данных...');
                                    await pr.show();

                                    final localSaveRes = await saveTreeLocal();

                                    if(localSaveRes != null)
                                    {
                                      final remoteSaveRes = await Tree.sendToServer(localSaveRes); 
                                      final resultMessage = remoteSaveRes==0?'Сохранить на сервере не удалось, информация сохранена локально.':'Информация о дереве сохранена';

                                      //saveTreeLocal().then((value) async {
                                        showDialog(
                                          context: context,
                                          builder: (context) => new AlertDialog(
                                            title: new Text(resultMessage),
                                            content: new Text('Вы можете добавить ещё одно дерево или вернуться к карте'),
                                            actions: <Widget>[
                                              new FlatButton(
                                                child: new Text('На карту', style: TextStyle(fontSize: 20)),
                                                onPressed: () async {
                                                  await _rememberMapPosition();
                                                  /*
                                                  Navigator.of(context).pop(true);
                                                  Navigator.of(context).pop(true);
                                                  Navigator.of(context).pop(true);
                                                  if(args!=null)
                                                    Navigator.of(context).pop(true);
                                                  */
                                                  Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
                                                }
                                              ),
                                              new FlatButton(
                                                child: new Text('Ещё дерево', style: TextStyle(fontSize: 20, color: Colors.red)),
                                                onPressed: () async {
                                                  await _rememberMapPosition();
                                                  Navigator.of(context).pop(true);
                                                  Navigator.of(context).pop(true);
                                                  Navigator.pushNamed(context, TreeformPage.route); //Navigator.pushNamedAndRemoveUntil(context, "treeform", (r) => false),
                                                }
                                              ),
                                            ],
                                          ),
                                        );
                                      //});                                      
                                    }
                                    else
                                      showDialog(
                                        context: context,
                                        builder: (context) => new AlertDialog(
                                          title: new Text('Произошла ошибка при сохранениии'),
                                          content: new Text('Не удалось сохранить информацию о дереве на устройстве'),
                                          actions: <Widget>[
                                            new FlatButton(
                                              child: new Text('Понятно'),
                                              onPressed: () => {
                                                Navigator.of(context).pop(),
                                              }
                                            ),
                                          ],
                                        ),
                                      );                                    
                                    
                                  }
                                  else
                                  {
                                    showDialog(
                                      context: context,
                                      builder: (context) => new AlertDialog(
                                        title: new Text('В форме есть ошибки'),
                                        content: new Text(errors.join('\n')),
                                        actions: <Widget>[
                                          new FlatButton(
                                            child: new Text('Понятно'),
                                            onPressed: () => {
                                              Navigator.of(context).pop(),
                                            }
                                          ),
                                        ],
                                      ),
                                    );                                    
                                  }                                

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
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
            floatingActionButton: 
              Padding(
                padding: EdgeInsets.only(top: 100),
                child: 
                  FloatingActionButton(
                    onPressed: () {
                      return showDialog(
                        context: context,
                        builder: (context) => new AlertDialog(
                          title: new Text('Скопировать предыдущее?'),
                          content: new Text('Информация в форме редактирования будет заменена на информацию о предыдущем дереве'),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text('Отмена', style: TextStyle(fontSize: 20)),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            new FlatButton(
                              onPressed: () async {
                                await _copyPervTree();
                                //final last = await Dbtree.Tree().select().orderByDesc('created').toSingle();
                                //print(last.created);
                                Navigator.of(context).pop(false);
                              },
                              child: new Text('Скопировать', style: TextStyle(fontSize: 20, color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Icon(Icons.content_copy),
                    backgroundColor: countreeTheme.shade200 ,
                  ) ,
              )
                       
        )
      );
  }

}