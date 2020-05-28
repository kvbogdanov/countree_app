import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

class TreeType {
  final int id;
  final String name;
  final decidious;
  final bool isTop;
  String userEnt;

  TreeType(id, name, decidious, isTop): id = id, name = name, decidious = decidious, isTop = isTop;
}
//typedef TreeTypeList = List<TreeType> Function();


class TreeTypeList{
  static List<TreeType> types = [
    TreeType(1,'Барбарис амурский', true, false),
    TreeType(3,'Береза бородавчатая (повислая)', true, false),
    TreeType(16,'Боярышник кроваво-красный', true, false),
    TreeType(17,'Вишня войлочная', true, false),
    TreeType(4,'Вяз (род)', true, false),
    TreeType(28,'Ель колючая', false, false),
    TreeType(29,'Ель сибирская', false, false),
    TreeType(18,'Жимолость татарская', true, false),
    TreeType(34,'Ива (род)', true, false),
    TreeType(19,'Калина обыкновенная (Калина красная)', true, false),
    TreeType(36,'Карагана древовидная (акация желтая)', true, false),
    TreeType(32,'Каштан конский', true, false),
    TreeType(20,'Кизильник блестящий', true, false),
    TreeType(5,'Клён ясенелистный', true, false),
    TreeType(6,'Липа мелколистная', true, false),
    TreeType(2,'Лиственница сибирская', false, false),
    TreeType(7,'Орех маньчжурский', true, false),
    TreeType(21,'Пузыреплодник калинолистный', true, false),
    TreeType(22,'Роза  морщинистая', true, false),
    TreeType(23,'Роза  сизая', true, false),
    TreeType(8,'Рябина обыкновенная', true, false),
    TreeType(24,'Рябинник рябинолистный', true, false),
    TreeType(25,'Сирень венгерская', true, false),
    TreeType(26,'Сирень обыкновенная', true, false),
    TreeType(27,'Смородина золотистая', true, false),
    TreeType(38,'Сосна кедровая сибирская', false, false),
    TreeType(30,'Сосна обыкновенная', false, false),
    TreeType(9,'Тополь бальзамический', true, false),
    TreeType(10,'Тополь белый', true, false),
    TreeType(11,'Черемуха Маака', true, false),
    TreeType(12,'Черемуха Обыкновенная или кистевая', true, false),
    TreeType(13,'Яблоня Недзвецкого', true, false),
    TreeType(14,'Яблоня сибирская (ягодная)', true, false),
    TreeType(15,'Ясень обыкновенный', true, false),
    TreeType(35,'другой вид', true, false),
  ];

  static TreeType getByName(name){
    var tempList = types.where((element) => element.name == name).toList();
    if(tempList.isEmpty)
      return null;
    else
      return tempList[0];
  }

  static TreeType getById(id){
    var tempList = types.where((element) => element.id == id).toList();
    if(tempList.isEmpty)
      return null;
    else
      return tempList[0];
  }

  static List<String> getNames()
  {
    return types.map((e) => e.name ).toList();
  }

}



class TreeCondition {
  final int id;
  final String name;

  TreeCondition(id, name): id = id, name = name;
}
typedef TreeConditionList = List<TreeCondition> Function();

class TreeNeighbour {
  final int id;
  final String name;

  TreeNeighbour(id, name): id = id, name = name;
}
typedef TreeNeighbourList = List<TreeNeighbour> Function();

class TreeState {
  final int id;
  final String name;
  final String imageUri;

  TreeState(id, name, imageUri): id = id, name = name, imageUri= imageUri;
}
typedef TreeStateList = List<TreeState> Function();

class TreeSurround {
  final int id;
  final String name;

  TreeSurround(id, name): id = id, name = name;
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

class Tree{
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
}