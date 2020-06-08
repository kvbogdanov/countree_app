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

  String treetype = '';
  var conditionsWidgets = List<Widget>();
  var imagesWidgets = List<Widget>();
  var pics = List<String>();

  final List<String> picsTest = [
    "https://24.countree.ru/assets/preview/28/03/2803c3acac8e270614534a9a472a3516.jpg",
    "https://24.countree.ru/assets/preview/21/fa/21fa6170d200fb2758928b126978488b.jpg"   
  ];

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
      print(response);
      if (response.statusCode == 200 || response.statusCode == 201) {

        var responseJson = json.decode(response.data);

        if(responseJson.containsKey('data'))
        {
          print(responseJson['data']);
          treetype = responseJson['data']['treetype']??'';

          conditionsWidgets = [];
          for (var cond in responseJson['data']['conditions']) {
            conditionsWidgets.add(Text(cond)); 
          }

          pics = [];
          for (var pic in responseJson['data']['pics']) {
            //imagesWidgets.add(Image.network(pic, fit: BoxFit.cover, height: 300.0)); 
            pics.add(pic);
            /*
            imagesWidgets.add(
              Container(
                child: Center(
                  child: Image.network(pic, fit: BoxFit.cover, width: 1000)
                ),
              ) 
            );
            */
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
        return  Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Row(
                    children: <Widget>[
                      Text('#24-'+args.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: conditionsWidgets
                      )
                    ],
                  )
                ]
              )
            ),             
          ],
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
      appBar: AppBar(title: Text('О проекте')),
      endDrawer: buildDrawer(context, ViewPage.route, signed:signed),
      body: treeinfoWidget(args.toString())
    );
  }

}