import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';
import 'package:countree/data/cities.dart';

import 'package:countree/widgets/drawer.dart';
//import 'package:photo_view/photo_view.dart';
//import 'package:photo_view/photo_view_gallery.dart';
  import 'package:carousel_slider/carousel_slider.dart';

class ViewPage extends StatefulWidget {
  static const String route = 'view';

  @override
ViewPageState createState() {
    return ViewPageState();
  }
}

class ViewPageState extends State<ViewPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool signed = false;
  CountreeCity currentCity;
  int args;

  // описание дерева
  String treetype = '';
  int is_seedling = 0;
  int is_alive = 0;
  double diameter = 0;
  int theight = 0;
  String surround = '';
  String state = '';
  String multibarrel = 'нет';
  String firstthread = 'н/д';
  String overall = 'н/д';
  var conditionsWidgets = List<Widget>();
  var neighboursWidgets = List<Widget>();
  var imagesWidgets = List<Widget>();
  var pics = List<String>();

  _getLoggedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('logged') ?? false);
  }  

  _getCurrentCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int idCity = (prefs.getInt('currentCity') ?? 0);

    return CountreeCities.cities[idCity];
  }

  Future<dynamic> _loadInfo(String uri, String idtree) async {
     print(idtree);
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

      Response response = await dio.post('/mobile/treedetail?id='+idtree, data: FormData.fromMap({}), options: options);
      //print(response);
      if (response.statusCode == 200 || response.statusCode == 201) {

        var responseJson = json.decode(response.data);

        if(responseJson.containsKey('data'))
        {
          print(responseJson['data']);

          pics = [];
          for (var pic in responseJson['data']['pics']) {
            pics.add(pic);
          }

          treetype = responseJson['data']['treetype']??'-';
          is_alive = responseJson['data']['is_alive']??0;
          is_seedling = responseJson['data']['is_seedling']??0;
          diameter = responseJson['data']['diameter']??0;
          theight = responseJson['data']['height']??0;
          surround = responseJson['data']['surround']??'-';
          state = responseJson['data']['state']??'';

          if(responseJson['data']['multibarrel'] != null && responseJson['data']['multibarrel']!=0)
            multibarrel = 'да';
          else 
            multibarrel = 'нет';

          final temp1 = responseJson['data']['firstthread']??-1;
          firstthread = temp1.toString();

          if(responseJson['data']['overall'] != null && responseJson['data']['overall']!=0)
          {
            if(responseJson['data']['overall']==1)
              overall = 'хорошее';
            if(responseJson['data']['overall']==2)
              overall = 'удовл.';
            if(responseJson['data']['overall']==3)
              overall = 'неудовл.';
          }

          conditionsWidgets = [];
          if(responseJson['data']['conditions'].length>0)
            conditionsWidgets.add(Text('Состояние дерева:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
          for (var cond in responseJson['data']['conditions']) {
            conditionsWidgets.add(Text(cond, softWrap: true)); 
          }

          neighboursWidgets = [];
          if(responseJson['data']['neighbours'].length>0)
            neighboursWidgets.add(Text('Окружение дерева:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
          for (var cond in responseJson['data']['neighbours']) {
            neighboursWidgets.add(Text(cond, overflow: TextOverflow.fade, maxLines: 1, softWrap: false)); 
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

  @override
  void initState() {
    super.initState();

    _getLoggedState().then((result){
        setState(() {
          signed = result;
        });
    });

    _getCurrentCity().then((result){
        setState(() {
          currentCity = result;
          print(currentCity.uri);
          /*_loadInfo(currentCity.uri, args.toString()).then((result){
            setState(() {
              
            });
          });
          */
        });
    });
  }


  Widget treeinfoWidget(idtree) {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (projectSnap.connectionState == ConnectionState.none &&
            projectSnap.hasData == null) {
          //print('project snapshot data is: ${projectSnap.data}');
          return Container();
        }

        if(is_alive==0 && is_seedling==0)
          return  Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        Text(treetype, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ]
                )
              ),            
              Container(
                child: CarouselSlider(
                  options: CarouselOptions(
                      
                      autoPlay: true,
                      aspectRatio: 2.0,
                      enlargeCenterPage: true,
                  ),
                  items: pics.map((item) => Container(
                    child: Center(
                      child: Image.network(item, fit: BoxFit.cover, width: 1000)
                    ),
                  )).toList()
                )
              ),
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        Text('Диаметер (см): $diameter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Text('Высота (м): $theight', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 10),                
                    Row(
                      children: <Widget>[
                        Text('Многоствольное: $multibarrel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Крона у дерева:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('$state'),
                          ],
                        )
                      ],
                    ),  
                    Row(
                      children: <Widget>[
                        Text('начинается на высоте: $firstthread м', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ), 
                    SizedBox(height: 10), 
                    conditionsWidgets.isNotEmpty?
                    Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: conditionsWidgets
                        )
                      ],
                    ):Container(),
                    surround.isNotEmpty?
                    Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Условия роста:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('$surround')
                          ],
                        )
                      ],
                    ):Container(),
                    neighboursWidgets.isNotEmpty?
                    Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: neighboursWidgets
                        )
                      ],
                    ):Container(),
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Text('Общая оценка: $overall', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),  
                  ]
                )
              ),           
            ],
          );
        else if(is_alive==1)
          return  Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        Text('Мертвое дерево ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ]
                )
              )
            ]
          ); 
        else if(is_seedling==1)
          return  Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        Text('Саженец ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ]
                )
              )
            ]
          );          
      },
      future: _loadInfo("https://24.countree.ru", idtree),
    );
  }


  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('#24-'+args.toString())),
      endDrawer: buildDrawer(context, ViewPage.route, signed:signed),
      body: SingleChildScrollView(
        child: treeinfoWidget(args.toString())
      )
    );
  }

}