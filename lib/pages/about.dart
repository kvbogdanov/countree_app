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
        appBar: AppBar(
            title: Text('О проекте'),
            automaticallyImplyLeading: true,
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                );
              },
            )),
        endDrawer: buildDrawer(context, AboutPage.route, signed: signed, cu: currentUser),
        body: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(children: [
              Image.asset('assets/images/mainlogo.png'),
              Text(
                  'Мы – красноярская общественная организация «Живой город». В 2018 году мы создали систему учёта городских зелёных насаждений, с помощью которой волонтеры уже нанесли на карту более 22 тысяч деревьев и кустарников в 3 городах Красноярского края. Опыт других стран показывает, что такие интерактивные карты помогают защищать уже растущие деревья и выбирать подходящие места для новых, эффективно расходуя городской бюджет.',
                  style: TextStyle(fontSize: 16)),
            ])));
  }
}
