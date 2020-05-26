import 'package:flutter/material.dart';
import 'package:countree/pages/home.dart';
import 'package:countree/pages/settings.dart';
import 'package:countree/pages/mytrees.dart';
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
          title: const Text('Карта'),
          selected: currentRoute == HomePage.route,
          onTap: () {
            Navigator.pop(context);
            Navigator.maybePop(context, "/");
          },
        ),
        ListTile(
          title: const Text('О проекте'),
          selected: currentRoute == HomePage.route,
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, HomePage.route);
          },
        ),
        ListTile(
          title: const Text('Настройки'),
          selected: currentRoute == SettingsPage.route,
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, SettingsPage.route);
          },
        ),
        Visibility(
          visible: signed,
          child:
            ListTile(
              title: const Text('Мои деревья'),
              selected: currentRoute == MytreesPage.route,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, MytreesPage.route);
              },
            ),
        ),
        ListTile(
          title: signed?(const Text('Выход')):(const Text('Вход')),
          selected: currentRoute == LoginPage.route,
          onTap: () {
            Navigator.pop(context);
            if(!signed)
              Navigator.pushNamed(context, LoginPage.route);
            else
              Navigator.pushReplacementNamed(context, LogoutPage.route);
          },
        ),        
      ],
    ),
  );
}        