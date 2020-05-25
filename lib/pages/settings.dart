import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:countree/widgets/drawer.dart';
//import 'package:countree/data/cities.dart';
//import 'package:countree/data/colors.dart';

class SettingsPage extends StatefulWidget {
  static const String route = 'settings';

  @override
  SettingsPageState createState() {
    return SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool signed = false;

  _getLoggedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('logged') ?? false);
  }  

  @override
  void initState() {
    super.initState();

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
      endDrawer: buildDrawer(context, SettingsPage.route, signed:signed),
      body: Padding(
        padding: EdgeInsets.all(0.0),
        child: Column(
          children: [
            Text('Настройки'),
          ]
        )
      )
    );
  }

}