import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:countree/model/user.dart';

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
  User currentUser;

  _getLoggedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final res = (prefs.getBool('logged') ?? false);
    if (res == true) return await loadCurrentUser();
    return res;
  }

  @override
  void initState() {
    super.initState();

    _getLoggedState().then((result) {
      setState(() {
        if (result is User) {
          currentUser = result;
          signed = true;
        } else
          signed = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text('О проекте')),
        endDrawer: buildDrawer(context, AboutPage.route, signed: signed, cu: currentUser),
        body: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(children: [
              Image.asset('assets/images/mainlogo.png'),
              Text('', style: TextStyle(fontSize: 16)),
            ])));
  }
}
