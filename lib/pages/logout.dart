import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:countree/model/user.dart';

class LogoutPage extends StatefulWidget {
  static const String route = 'logout';

  @override
  LogoutPageState createState() {
    return LogoutPageState();
  }
}

class LogoutPageState extends State<LogoutPage>{


  _setLoggedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged', false);

    await User().select().delete();

    //setState(() {});
    return false;
  }  

  bool signed = false;

  @override
  void initState() {
    super.initState();

    _setLoggedState().then((result){
        setState(() {
          signed = false;
          Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
        });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Countree')),
      body: Padding(
        padding: EdgeInsets.all(0.0),
        child: Column(
          children: [
            Center(
              child: Text(
                  'Выход произведен',
                  style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );  


  }

}