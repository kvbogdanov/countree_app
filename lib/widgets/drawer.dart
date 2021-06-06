import 'package:flutter/material.dart';
import 'package:countree/data/colors.dart';
import 'package:countree/pages/home.dart';
import 'package:countree/pages/settings.dart';
import 'package:countree/pages/mytrees.dart';
import 'package:countree/pages/login.dart';
import 'package:countree/pages/logout.dart';
import 'package:countree/pages/about.dart';
import 'package:countree/model/user.dart';

const double MENUSIZE = 20;

Future<User> loadCurrentUser() async
{
  final currentUser = await User().select().toSingle();
//  print(currentUser.toJson());
  return currentUser;
}

String getInitials(userName) {
  List<String> names = userName.split(" ");
  String initials = "";
  int numWords = 1;
  
  if(numWords < names.length) {
    numWords = names.length;
  }

  for(var i = 0; i < numWords; i++){
    initials += '${names[i][0]}';
  }
  return initials;
}

Drawer buildDrawer(BuildContext context, String currentRoute, {bool signed = false, Function setState, User cu}) {
  precacheImage(AssetImage("assets/images/countree_logo.png"), context);


  return Drawer(
    child: ListView(
      children: <Widget>[
        (!signed)?
          const DrawerHeader(
            child: Center(
              child: Text(''),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/countree_logo.png'),
                fit: BoxFit.contain
              )
            ),
          )
        :
        UserAccountsDrawerHeader(
          accountName: Text(cu!=null?cu.name:'Анонимный пользователь'),
          accountEmail: Text(cu!=null?cu.email:'Неизвестен'),
          decoration: BoxDecoration(
            color: null
          ),
          currentAccountPicture: 
            CircleAvatar(
              backgroundColor: countreeTheme.shade400,
              child: Text(
                getInitials(cu!=null?cu.name:'Анонимный Пользователь'),
                style: TextStyle(fontSize: 40.0, color: Colors.white),
              ),
            ),
          otherAccountsPictures: <Widget> [
            CircleAvatar(
              backgroundColor: countreeTheme.shade100,
              child: Text(
                cu!=null?cu.total_trees.toString():'0',
                style: TextStyle(fontSize: 12.0, color: countreeTheme.shade800),
              ),
            ),
          ]
        ) ,
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
            //Navigator.pushNamed(context, AboutPage.route);
            Navigator.pushReplacementNamed(context, AboutPage.route);
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