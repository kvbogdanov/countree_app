import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

class TreeType {
  final int id;
  final String name;
  String userEnt;

  TreeType(id, name): id = id, name = name;
}
typedef TreeTypeList = List<TreeType> Function();

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