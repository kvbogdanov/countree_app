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
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

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

  int totalItemsCount = 0;
  bool _showOnlyRejected = false;
  bool _showDaterange = false;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

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
    final idUserSystem = currentUser.id_system;

    String condition = 'id_user=$idUserSystem';
    final start = _startDate.millisecondsSinceEpoch;
    final end = _endDate.millisecondsSinceEpoch;

    //print(start);

    //if (_showOnlyRejected) condition += ' AND (status==$STATE_DECLINE)';
    condition += " AND created>$start AND created<=$end";

    condition = " created>$start AND created<=$end";
    localTrees = await Dbtree.Tree().select().where(condition).orderByDesc('created').toList();
    totalItemsCount = (localTrees == null) ? 0 : localTrees.length;

    //localTrees = await Dbtree.Tree().select().orderByDesc('created').toList();

    return true;
  }

  Future<bool> _removeTree(int timestamp) async {
    var tree = await Dbtree.Tree().select().where('created=$timestamp').toSingle();
    if (tree != null) tree.delete();
    return true;
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      _startDate = args.value.startDate;
      _endDate = args.value.endDate ?? args.value.startDate;
      var _range = DateFormat('dd/MM/yyyy').format(args.value.startDate).toString() +
          ' - ' +
          DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate).toString();
      print(_range);
    }
  }

  Future<void> _pullRefresh() async {
    //Tree.loadAllFromServer(currentUser);
    return;
  }

  Widget treelistWidget() {
    return FutureBuilder(
        builder: (context, projectSnap) {
          SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
                totalItemsCount = (localTrees == null) ? 0 : localTrees.length;
              }));

          if (localTrees == null)
            return Container(
              child: Center(child: Text('Записей о насаждениях нет', style: TextStyle(color: countreeTheme.shade900, fontSize: 18.0))),
            );

          return RefreshIndicator(
              onRefresh: _pullRefresh,
              child: ListView.builder(
                itemCount: localTrees.length,
                itemBuilder: (context, index) {
                  //print(localTrees[index].created);
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
              ));
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
        body: Column(
          children: [
            Ink(
                color: Colors.grey.shade300,
                child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _showOnlyRejected,
                          onChanged: (value) {
                            setState(() {
                              _showOnlyRejected = !_showOnlyRejected;
                              _loadLocalTrees();
                            });
                          },
                        ),
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              _showOnlyRejected = !_showOnlyRejected;
                              _loadLocalTrees();
                            });
                          },
                          child: Text('только с замечаниями'),
                        ),
                        Expanded(child: SizedBox()),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showDaterange = !_showDaterange;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: countreeTheme.shade200,
                            enableFeedback: true,
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            //color: Colors.white,
                          ),
                        )
                      ],
                    ))),
            Visibility(
                visible: _showDaterange,
                child: Expanded(
                    child: Container(
                        color: Colors.grey.shade300,
                        child: SfDateRangePicker(
                          onSelectionChanged: _onSelectionChanged,
                          selectionMode: DateRangePickerSelectionMode.range,
                          initialSelectedRange: PickerDateRange(_startDate, _endDate),
                          //initialSelectedRange: PickerDateRange(DateTime.now().subtract(const Duration(days: 30)), DateTime.now()),
                        )))),
            Expanded(
                child: Container(
              child: treelistWidget(),
            ))
          ],
        ));
  }
}
