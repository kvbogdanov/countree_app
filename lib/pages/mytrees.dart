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
import 'package:countree/pages/treeform.dart';
import 'package:progress_dialog/progress_dialog.dart';

class MytreesPage extends StatefulWidget {
  static const String route = 'mytrees';

  @override
  MytreesPageState createState() {
    return MytreesPageState();
  }
}

class MytreesPageState extends State<MytreesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool signed = false;
  User currentUser;
  List<Dbtree.Tree> localTrees;

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

  Future<dynamic> _loadLocalTrees() async {
    localTrees = await Dbtree.Tree().select().orderByDesc('created').toList();

    return true;
  }

  Future<bool> _removeTree(int timestamp) async {
    var tree = await Dbtree.Tree().select().where('created=$timestamp').toSingle();
    if (tree != null) tree.delete();
    return true;
  }

  Widget treelistWidget() {
    return FutureBuilder(
        builder: (context, projectSnap) {
          if (localTrees == null)
            return Container(
              child: Text('Деревьев нет'),
            );

          return ListView.builder(
            itemCount: localTrees.length,
            itemBuilder: (context, index) {
              DateTime date = new DateTime.fromMillisecondsSinceEpoch(localTrees[index].created);
              var formaty = new DateFormat.y();
              var formatm = new DateFormat.M();
              var formatd = new DateFormat.d();
              var formath = new DateFormat.Hm();
              var dateString = formath.format(date) + ' ' + formatd.format(date) + '/' + formatm.format(date) + '/' + formaty.format(date);

              return ListTile(
                title: Text(TreeTypeList.getById(localTrees[index].id_treetype).name),
                subtitle: Text('создано: $dateString'),
                trailing: localTrees[index].uploaded == 0
                    ? Icon(Icons.error_outline, color: Colors.redAccent)
                    : Icon(Icons.check_circle_outline, color: countreeTheme.shade600),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    TreeformPage.route,
                    arguments: localTrees[index].created,
                  );
                },
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => new AlertDialog(
                      title: new Text('Удалить запись о дереве?'),
                      content: new Text('Эта операция уничтожит запись о дереве локально и на сервере (если оно сохранено)'),
                      actions: <Widget>[
                        new FlatButton(
                            child: new Text('Отмена', style: TextStyle(fontSize: 20)),
                            onPressed: () async {
                              Navigator.of(context).pop(true);
                            }),
                        new FlatButton(
                            child: new Text('Удалить', style: TextStyle(fontSize: 20, color: Colors.red)),
                            onPressed: () async {
                              await _removeTree(localTrees[index].created);
                              setState(() {});
                              Navigator.of(context).pop(true);
                            }),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        future: _loadLocalTrees());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            title: Text('Мои деревья'),
            actions: <Widget>[
              new IconButton(
                icon: new Icon(Icons.update),
                onPressed: () async {
                  if (localTrees.isNotEmpty) {
                    final ProgressDialog pr = ProgressDialog(context);
                    pr.style(message: 'Отправка данных...');
//                  pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
                    await pr.show();
                    for (var lt in localTrees) {
                      if (lt.uploaded == 0) await Tree.sendToServer(lt);
                    }
                    await pr.hide();
                  }
                  /*
                return showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Отправка на сервер'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                        Text('Отправка даных на сервер временно запрещена'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Понятно'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
                */
                },
              ),
            ],
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
        endDrawer: buildDrawer(context, MytreesPage.route, signed: signed, cu: currentUser),
        body: treelistWidget());
  }
}
