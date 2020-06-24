import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:countree/widgets/drawer.dart';
import 'package:countree/data/maps.dart';
import 'package:countree/data/colors.dart';

class SettingsPage extends StatefulWidget {
  static const String route = 'settings';

  @override
  SettingsPageState createState() {
    return SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  bool signed = false;
  String sourcesDefault = '';
  List<DropdownMenuItem> sourcesMenuItems = [];
  ValueNotifier<String> _activeMapName;

  _getLoggedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('logged') ?? false);
  }  

  _getMapLayer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getString('mapsrc') ?? '');
  }

  _setMapLayer(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mapsrc', name);
    return true;    
  }  

  @override
  void initState() {
    super.initState();

    mapSourcesNames.forEach((key, value) { 
      sourcesMenuItems.add(DropdownMenuItem(
                                value: value,
                                child: Text('$value'),
                              ));
    });

    sourcesDefault = sourcesMenuItems[1].value;
   
    _getMapLayer().then((result){
        setState(() {
          print(result);
          if(result != '')
          {
            sourcesDefault = result;
            _activeMapName.value = sourcesDefault;
            _fbKey.currentState.fields['mapsrc'].currentState.didChange(sourcesDefault);
          }
        });
    });

  }

  @override
  Widget build(BuildContext context) {
     _activeMapName = ValueNotifier<String>(sourcesDefault);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Настройки'),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.save_alt),
              onPressed: () {
                if (_fbKey.currentState.saveAndValidate()) {
                  _setMapLayer(_fbKey.currentState.value['mapsrc']);
                  if(sourcesDefault == _fbKey.currentState.value['mapsrc'])
                    Navigator.of(context).pop();
                  else
                    Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
                }                
              },
            ),
         ],  
      ),
      endDrawer: buildDrawer(context, SettingsPage.route, signed:signed),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(          
          children: <Widget>[
            FormBuilder(
              key: _fbKey,
              child: 
                Column(
                  children: <Widget>[
                    ValueListenableBuilder(
                      builder: (BuildContext context, String value, Widget child) {
                        return FormBuilderDropdown(
                          attribute: "mapsrc",
                          decoration: InputDecoration(
                            labelText: "Карта",
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.green,
                                width: 20,
                              ),
                            ),
                          ),
                          initialValue: value,
                          hint: Text('Выберите источник тайлов'),
                          validators: [FormBuilderValidators.required()],
                          items: sourcesMenuItems
                        );
                      },
                      valueListenable: _activeMapName
                    ),
                    SizedBox(height: 15),
                    FormBuilderSwitch(
                      attribute: "savepos",
                      label: Text("Сохранять позицию и масштаб", style: TextStyle(color: Colors.black87, fontSize: 16))
                    ),
                    FormBuilderSwitch(
                      attribute: "animationon",
                      label: Text("Анимированные кластеры", style: TextStyle(color: Colors.black87, fontSize: 16))
                    ),
                    FormBuilderSwitch(
                      attribute: "clearcache",
                      label: Text("Очистить кэш деревьев", style: TextStyle(color: Colors.black87, fontSize: 16)),
                      onChanged: (val) {
                        if(val)
                          return showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Внимание'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text('Удаление кэша данных может привести к длительной загрзузке данных при следующем запуске.'),
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
                        else
                          return false;                      
                      },
                    ),
                  ],
                ),
            ),
            Text('ver: 1.0.2 build 21', style: TextStyle(fontSize: 12))  
            /*
            Row(  
              mainAxisAlignment: MainAxisAlignment.center,                         
              children: <Widget>[
                RaisedButton(
                  child: Text("Сохранить"),
                  color: countreeTheme.shade400,
                  onPressed: () {
                    if (_fbKey.currentState.saveAndValidate()) {
                      _setMapLayer(_fbKey.currentState.value['mapsrc']);
                      if(sourcesDefault == _fbKey.currentState.value['mapsrc'])
                        Navigator.of(context).pop();
                      else
                        Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
                    }
                  },
                ),
                SizedBox(width: 30),
                RaisedButton(
                  child: Text("Отмена"),
                  //color: countreeTheme.shade400,
                  onPressed: () {
                    _fbKey.currentState.reset();
                  },
                ),
              ],
            )
            */
          ]
        ),
      )
    );
  }

}