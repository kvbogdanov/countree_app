import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:dio/dio.dart';
import 'package:countree/model/tree.dart' as Dbtree;
import 'package:countree/model/user.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image/image.dart' as LocalImage;

import 'package:flutter_native_image/flutter_native_image.dart';

import 'dart:convert';

class TreeType {
  final int id;
  final String name;
  final decidious;
  final bool isTop;
  String userEnt;

  TreeType(id, name, decidious, isTop)
      : id = id,
        name = name,
        decidious = decidious,
        isTop = isTop;
}
//typedef TreeTypeList = List<TreeType> Function();

class TreeTypeList {
  static List<TreeType> types = [
    TreeType(1, 'Барбарис амурский', true, false),
    TreeType(3, 'Береза бородавчатая (повислая)', true, false),
    TreeType(16, 'Боярышник кроваво-красный', true, false),
    TreeType(17, 'Вишня войлочная', true, false),
    TreeType(4, 'Вяз (род)', true, false),
    TreeType(28, 'Ель колючая', false, false),
    TreeType(29, 'Ель сибирская', false, false),
    TreeType(18, 'Жимолость татарская', true, false),
    TreeType(34, 'Ива (род)', true, false),
    TreeType(19, 'Калина обыкновенная (Калина красная)', true, false),
    TreeType(36, 'Карагана древовидная (акация желтая)', true, false),
    TreeType(32, 'Каштан конский', true, false),
    TreeType(20, 'Кизильник блестящий', true, false),
    TreeType(5, 'Клён ясенелистный', true, false),
    TreeType(6, 'Липа мелколистная', true, false),
    TreeType(2, 'Лиственница сибирская', false, false),
    TreeType(7, 'Орех маньчжурский', true, false),
    TreeType(21, 'Пузыреплодник калинолистный', true, false),
    TreeType(22, 'Роза  морщинистая', true, false),
    TreeType(23, 'Роза  сизая', true, false),
    TreeType(8, 'Рябина обыкновенная', true, false),
    TreeType(24, 'Рябинник рябинолистный', true, false),
    TreeType(25, 'Сирень венгерская', true, false),
    TreeType(26, 'Сирень обыкновенная', true, false),
    TreeType(27, 'Смородина золотистая', true, false),
    TreeType(38, 'Сосна кедровая сибирская', false, false),
    TreeType(30, 'Сосна обыкновенная', false, false),
    TreeType(9, 'Тополь бальзамический', true, false),
    TreeType(10, 'Тополь белый', true, false),
    TreeType(11, 'Черемуха Маака', true, false),
    TreeType(12, 'Черемуха Обыкновенная или кистевая', true, false),
    TreeType(13, 'Яблоня Недзвецкого', true, false),
    TreeType(14, 'Яблоня сибирская (ягодная)', true, false),
    TreeType(15, 'Ясень обыкновенный', true, false),
    TreeType(35, 'другой вид', true, false),
  ];

  static TreeType getByName(name) {
    var tempList = types.where((element) => element.name == name).toList();
    if (tempList.isEmpty)
      return null;
    else
      return tempList[0];
  }

  static TreeType getById(id) {
    var tempList = types.where((element) => element.id == id).toList();
    if (tempList.isEmpty)
      return null;
    else
      return tempList[0];
  }

  static List<String> getNames() {
    return types.map((e) => e.name).toList();
  }
}

class TreeCondition {
  final int id;
  final String name;

  TreeCondition(id, name)
      : id = id,
        name = name;
}

typedef TreeConditionList = List<TreeCondition> Function();

class TreeNeighbour {
  final int id;
  final String name;

  TreeNeighbour(id, name)
      : id = id,
        name = name;
}

typedef TreeNeighbourList = List<TreeNeighbour> Function();

class TreeState {
  final int id;
  final String name;
  final String imageUri;

  TreeState(id, name, imageUri)
      : id = id,
        name = name,
        imageUri = imageUri;
}

typedef TreeStateList = List<TreeState> Function();

class TreeSurround {
  final int id;
  final String name;

  TreeSurround(id, name)
      : id = id,
        name = name;
}

typedef TreeSurroundList = List<TreeNeighbour> Function();

/*
class TreeSubstate {
  final int id;
  final String name;
  final String imageUri;

  TreeSubstate(id, name, imageUri): id = id, name = name, imageUri= imageUri;
}
typedef TreeSubstateList = List<TreeSubstate> Function();
*/

class Tree {
  int idTree;
  int idUser;
  int dateCreate;
  int dateCutdown;
  bool isCutdown;
  bool isDead;
  bool isSeedling;
  LatLng point;
  TreeType treeType;
  TreeCondition treeCondition;
  TreeNeighbour treeNeighbour;
  TreeSurround treeSurround;
  double diameter;
  double height;
  List<Image> images;

  int saveDate;

  static Future<int> sendToServer(Dbtree.Tree tree, {uri = 'https://24.countree.ru'}) async {
    final savePath = '/mobile/addtree';
    BaseOptions options = BaseOptions(
        baseUrl: uri,
        responseType: ResponseType.plain,
        connectTimeout: 10000,
        receiveTimeout: 10000,
        validateStatus: (code) {
          if (code >= 200) {
            return true;
          }
          return false;
        });

    Dio dio = Dio(options);

    List<String> filepaths = (tree.images != null) ? tree.images.split(';') : [];
    List<MultipartFile> files = [];
    final directory = await getApplicationDocumentsDirectory();
    final localDocPath = directory.path;

    for (var i = 0; i < filepaths.length; i++) {
      try {
        final curImage = new File(filepaths[i]);
        final fileExtension = filepaths[i].split(".").last;
        LocalImage.Image imageOrig = LocalImage.decodeImage(curImage.readAsBytesSync());
        LocalImage.Image imageResized = LocalImage.copyResize(imageOrig, width: 1290);
        new File('$localDocPath/picresized$i.$fileExtension')..writeAsBytesSync(LocalImage.encodeJpg(imageResized));

        files.add(await MultipartFile.fromFile('$localDocPath/picresized$i.$fileExtension', filename: "picture$i.$fileExtension"));
        //files.add(await MultipartFile.fromFile(filepaths[i], filename: "picture$i.$fileExtension"));
      } catch (e) {
        continue;
      }
    }

    Map<String, dynamic> data = tree.toMap();

    if (tree.images.length > 0) {
      List<String> filepaths = (tree.images != null) ? tree.images.split(';') : [];
      List<MultipartFile> files = [];

      await Future.forEach(filepaths, (filepath) async {
        try {
          ImageProperties properties = await FlutterNativeImage.getImageProperties(filepath);
          File compressedFile = await FlutterNativeImage.compressImage(filepath,
              quality: 80, targetWidth: 1290, targetHeight: (properties.height * 1290 / properties.width).round());
          print(compressedFile.path);
          files.add(await MultipartFile.fromFile(compressedFile.path));
        } catch (e) {
          debugPrint(e.toString());
        }
      });

      data['files'] = files;
    }

    data.remove('images');

    //data['files'] = files;

    FormData formData = new FormData.fromMap(data);
    //debugPrint(formData.toString());

    var response = await dio.post(savePath, data: formData);
    //debugPrint(response.toString());

    try {
      if (int.parse(response.toString()) != 0) {
        tree.id_system = int.parse(response.toString());
        tree.uploaded = new DateTime.now().millisecondsSinceEpoch;
        var res = await tree.save();

        return tree.id_system;
      }
    } catch (e) {
      return 0;
    }

    return 0;
  }

  static Future<dynamic> loadAllFromServer(User currentUser, {uri = 'https://24.countree.ru'}) async {
    print('update trees from server');
    if (currentUser == null) {
      print('no user');
      return null;
    }

    BaseOptions options = BaseOptions(
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

    Dio dio = Dio(options);

    try {
      /*
      dio.interceptors.clear();
      dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options) {
        options.headers["Authorization"] = "Bearer " + currentUser.token;
        return options;
      }));
      */

      var response = await dio.get('/usertrees/' + currentUser.id_system.toString());
      //debugPrint(response.toString());
      print(currentUser.toMap());
      var responseJson = json.decode(response.data);
      print(responseJson.length);
      //print(responseJson[0]);

      // проверяем, есть ли среди загруженных уже имеющиеся,
      // если нет, создаём
      // если есть - проверяем таймстемпы и, возможно, обновляем

      //DbModel.Violation().select().delete();

      Dbtree.Tree savedTree;

      for (var loadedTree in responseJson) {
        final ids = loadedTree['id_tree'];
        savedTree = null;
        final storedTree = await Dbtree.Tree().select().where('id_system=$ids').toSingle();

        bool needUpdate = false;
        //if (storedTree != null && (storedViolation.updated ?? 0) < (loadedViolation['updated_at'] * 1000)) {
        if (storedTree != null) {
          savedTree = storedTree;
          needUpdate = true;
        } else if (storedTree == null) {
          savedTree = new Dbtree.Tree();
          needUpdate = true;
        }

        if (needUpdate) {
          // если есть файлы - сложим их пути в обычном формате
          String imagesRaw = "";
          if (loadedTree['media'] != null && loadedTree['media'] is Map && loadedTree['media'].length > 0) {
            List<String> imagesString = [];

            loadedTree['media'].forEach((k, v) {
              if (v['url'] != null) imagesString.add(v['url']);
            });

            imagesRaw = imagesString.join(";");
          }

          //print(loadedTree);
          savedTree
            ..id_user = currentUser.id_system
            ..created = loadedTree['created'] * 1000
            ..uploaded = new DateTime.now().millisecondsSinceEpoch //loadedTree['uploaded']
            ..id_system = loadedTree['id_tree'] ?? 0
            ..longitude = loadedTree['longitude']
            ..latitude = loadedTree['latitude']
            ..is_alive = loadedTree['is_alive'] ?? 0
            ..is_seedling = loadedTree['is_seedling'] ?? 0
            ..id_treetype = loadedTree['id_treetype'] ?? 0
            ..custom_treetype = loadedTree['custom_treetype']
            ..diameter = loadedTree['diameter'] ?? 0
            ..height = (loadedTree['height'] ?? 0).toDouble()
            ..id_state = (loadedTree['state'] == "") ? 0 : (loadedTree['state'] ?? 0)
            ..multibarrel = loadedTree['is_multistem'] ?? 0
            ..firstthread = loadedTree['firstthread'] ?? 0
            ..ids_condition = (loadedTree['conditions'] != null) ? loadedTree['conditions'].join(",") : ""
            ..custom_condition = loadedTree['custom_condition']
            ..id_surroundings = loadedTree['id_treesurround'] ?? 0
            ..ids_neighbours = (loadedTree['neighbours'] != null) ? loadedTree['neighbours'].join(",") : ""
            ..images = imagesRaw //loadedTree['media']
            ..id_overall = loadedTree['overall'];

          print('tree loaded');

          var res = await savedTree.save();
          print(res);
          print(savedTree.saveResult);
        }
      }

      return responseJson;
    } catch (e) {
      print(e);
      return 0;
    }
  }
}
