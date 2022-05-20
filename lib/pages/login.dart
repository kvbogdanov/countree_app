import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:countree/data/json_user.dart';
import 'package:countree/data/colors.dart';

import 'dart:async';
import 'dart:convert';
//import 'dart:io';

import 'package:dio/dio.dart';
//import 'package:flutter/material.dart';

class LoginWithRestfulApi extends StatefulWidget {
  @override
  _LoginWithRestfulApiState createState() => _LoginWithRestfulApiState();
}

class _LoginWithRestfulApiState extends State<LoginWithRestfulApi> {
  static var uri = "https://29.countree.ru";

  _getLoggedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('logged') ?? false);
  }

  _setLoggedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged', true);
    setState(() {});
    return true;
  }

  Future<void> _showErrorDialog() async {
    setState(() => _isLoading = false);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Пользователь не найден'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Пользователя с такими данными не существует. Проверьте правильность ввода почты и пароля.'),
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
  }

  @override
  void initState() {
    super.initState();

    _getLoggedState().then((result) {
      if (result)
        Timer.run(() {
          Navigator.of(context).pushNamed("/");
        });
    });
  }

  static BaseOptions options = BaseOptions(
      baseUrl: uri,
      responseType: ResponseType.plain,
      connectTimeout: 30000,
      receiveTimeout: 30000,
      validateStatus: (code) {
        if (code >= 200) {
          return true;
        }

        return false;
      });
  static Dio dio = Dio(options);

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _emailController = TextEditingController();

  TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  JsonUser user;

  Future<dynamic> _loginUser(String email, String password) async {
    try {
      Options options = Options(
        followRedirects: true,
        contentType: 'application/json', //ContentType.parse('application/json')
      );

      Response response = await dio.post('/mobile/login', data: FormData.fromMap({"email": email, "password": password}), options: options);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseJson = json.decode(response.data);
        return responseJson;
      } else if (response.statusCode == 401) {
        _showErrorDialog();
        throw Exception("Incorrect Email/Password");
        //return null;
      } else
        throw Exception('Authentication Error');
    } on DioError catch (exception) {
      if (exception == null || exception.toString().contains('SocketException')) {
        throw Exception("Network Error");
      } else if (exception.type == DioErrorType.RECEIVE_TIMEOUT || exception.type == DioErrorType.CONNECT_TIMEOUT) {
        throw Exception("Could'nt connect, please ensure you have a stable network.");
      } else {
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Countree'),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.save_alt),
            onPressed: () async {
              setState(() => _isLoading = true);
              var res = await _loginUser(_emailController.text, _passwordController.text);
              setState(() => _isLoading = false);

              JsonUser user = JsonUser.fromJson(jsonDecode(res));

              if (user is JsonUser) {
                _setLoggedState();
                Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
              }
            },
          ),
        ],
        //leading: new Container(),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Пароль',
                      ),
                    ),
                  ),
                  /*
                  RaisedButton(
                    child: Text("Войти"),
                    color: countreeTheme.shade400,
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      var res = await _loginUser(
                          _emailController.text, _passwordController.text);
                      setState(() => _isLoading = false);
                      
                      JsonUser user = JsonUser.fromJson(jsonDecode(res));

                      if (user is JsonUser) {
                        _setLoggedState();
                        //Navigator.of(context).pushReplacementNamed("/");
                        Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
                      }
                    },
                  ),
                  */
                ],
              ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({@required this.user});
  static const String route = 'login';

  final JsonUser user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login Screen")),
      body: Center(
        child: user != null ? Text("Logged IN \n \n Email: ${user.email} ") : Text("Yore not Logged IN"),
      ),
    );
  }
}
