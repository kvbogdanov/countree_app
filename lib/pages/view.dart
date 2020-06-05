import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:countree/widgets/drawer.dart';

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
    final int args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('О проекте')),
      endDrawer: buildDrawer(context, ViewPage.route, signed:signed),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: [
            Text(args.toString(), style: TextStyle(fontSize: 16)),
          ]
        )
      )
    );
  }

}