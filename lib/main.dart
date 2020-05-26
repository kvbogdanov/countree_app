import 'package:flutter/material.dart';

import 'package:countree/data/colors.dart';
import 'package:countree/pages/home.dart';
import 'package:countree/pages/settings.dart';
import 'package:countree/pages/mytrees.dart';
import 'package:countree/pages/treeform.dart';
import 'package:countree/pages/login.dart';
import 'package:countree/pages/logout.dart';

void main() => runApp(CountreeApp());

class CountreeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countree',
      theme: ThemeData(
        primarySwatch: countreeTheme,
      ),
      home: HomePage(),
      routes: <String, WidgetBuilder>{
        LoginPage.route: (context) => LoginWithRestfulApi(),
        LogoutPage.route: (context) => LogoutPage(),
        SettingsPage.route: (context) => SettingsPage(),
        MytreesPage.route: (context) => MytreesPage(),
        TreeformPage.route: (context) => TreeformPage(),
      },
    );
  }
}
