import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:countree/widgets/drawer.dart';
import 'package:countree/data/tree.dart';
//import 'package:countree/data/cities.dart';
import 'package:countree/data/colors.dart';
import 'package:countree/model/user.dart';
import 'package:countree/model/tree.dart' as Dbtree;
import 'package:intl/intl.dart';
//import 'package:intl/intl_browser.dart';

class MytreesPage extends StatefulWidget {
  static const String route = 'mytrees';

  @override
  MytreesPageState createState() {
    return MytreesPageState();
  }
}

class MytreesPageState extends State<MytreesPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool signed = false;
  User currentUser;
  List<Dbtree.Tree> localTrees;

  _getLoggedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final res = (prefs.getBool('logged') ?? false);
    if(res == true)
      return await loadCurrentUser();
    return res;
  }   

  @override
  void initState() {
    super.initState();

    _getLoggedState().then((result){
        setState(() {
          if(result is User)
          {
            currentUser = result;
            signed = true;
          }
          else
            signed = false;
        });
    });    
  }

  Future<dynamic> _loadLocalTrees() async
  {
    localTrees = await Dbtree.Tree().select().orderByDesc('created').toList();

    return true;
  }

  Widget treelistWidget() {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if(localTrees == null)
          return Container(
            child: Text('Деревьев нет'),
          );

        return ListView.builder(
          itemCount: localTrees.length,
          itemBuilder: (context, index) {
            DateTime date = new DateTime.fromMillisecondsSinceEpoch(localTrees[index].created);
            var formaty =  new DateFormat.y();
            var formatm =  new DateFormat.M();
            var formatd =  new DateFormat.d();
            var formath =  new DateFormat.Hm();
            var dateString = formath.format(date) + ' ' + formatd.format(date) + '/' + formatm.format(date) + '/' + formaty.format(date);

            return ListTile(
              title: Text( TreeTypeList.getById(localTrees[index].id_treetype).name),
              subtitle: Text('создано: $dateString'),
              trailing: localTrees[index].uploaded==0?Icon(Icons.error_outline, color: Colors.redAccent):Icon(Icons.check_circle_outline, color: countreeTheme.shade600),
            );
          },
        );
      },
      future:  _loadLocalTrees()
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Мои деревья')),
      endDrawer: buildDrawer(context, MytreesPage.route, signed:signed, cu: currentUser),
      body: treelistWidget()
    );
  }

}