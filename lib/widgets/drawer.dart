import 'package:flutter/material.dart';
import 'package:countree/pages/home.dart';
import 'package:countree/pages/login.dart';
import 'package:countree/pages/logout.dart';

Drawer buildDrawer(BuildContext context, String currentRoute, {bool signed = false, Function setState}) {
  return Drawer(
    child: ListView(
      children: <Widget>[
        const DrawerHeader(
          child: Center(
            child: Text('Countree'),
          ),
        ),
        ListTile(
          title: const Text('Главная'),
          selected: currentRoute == HomePage.route,
          onTap: () {
            Navigator.pushReplacementNamed(context, HomePage.route);
          },
        ),
        ListTile(
          title: signed?(const Text('Выход')):(const Text('Вход')),
          selected: currentRoute == LoginPage.route,
          onTap: () {
            if(!signed)
              Navigator.pushReplacementNamed(context, LoginPage.route);
            else
              Navigator.pushReplacementNamed(context, LogoutPage.route);
          },
        ),        
      ],
    ),
  );
}        