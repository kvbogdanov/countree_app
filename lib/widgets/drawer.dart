import 'package:flutter/material.dart';
import 'package:countree/data/colors.dart';
import 'package:countree/pages/home.dart';
import 'package:countree/pages/settings.dart';
import 'package:countree/pages/mytrees.dart';
import 'package:countree/pages/login.dart';
import 'package:countree/pages/logout.dart';
import 'package:countree/pages/about.dart';

const double MENUSIZE = 20;

Drawer buildDrawer(BuildContext context, String currentRoute, {bool signed = false, Function setState}) {
  return Drawer(
    child: ListView(
      children: <Widget>[
        const DrawerHeader(
          child: Center(
            child: Text(''),
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/mainlogo.png'),
              fit: BoxFit.contain
            )
          ),
        ),
        ListTile(
          title: const Text('Карта', style: TextStyle(fontSize: MENUSIZE)),
          selected: currentRoute == HomePage.route,
          onTap: () {
            Navigator.pop(context);
            Navigator.maybePop(context, "/");
          },
        ),
        ListTile(
          title: const Text('О проекте', style: TextStyle(fontSize: MENUSIZE)),
          selected: currentRoute == AboutPage.route,
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, AboutPage.route);
          },
        ),
        ListTile(
          title: const Text('Настройки', style: TextStyle(fontSize: MENUSIZE)),
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
              title: const Text('Мои деревья', style: TextStyle(fontSize: MENUSIZE)),
              selected: currentRoute == MytreesPage.route,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, MytreesPage.route);
              },
            ),
        ),
        ListTile(
          title: signed?(const Text('Выход', style: TextStyle(fontSize: MENUSIZE))):(const Text('Вход', style: TextStyle(fontSize: MENUSIZE))),
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