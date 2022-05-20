import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:countree/widgets/drawer.dart';

class AboutPage extends StatefulWidget {
  static const String route = 'about';

  @override
  AboutPageState createState() {
    return AboutPageState();
  }
}

class AboutPageState extends State<AboutPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool signed = false;

  _getLoggedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('logged') ?? false);
  }

  @override
  void initState() {
    super.initState();

    _getLoggedState().then((result) {
      setState(() {
        signed = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text('О проекте')),
        endDrawer: buildDrawer(context, AboutPage.route, signed: signed),
        body: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(children: [
              Image.asset('assets/images/mainlogo.png'),
              Text('', style: TextStyle(fontSize: 16)),
            ])));
  }
}
