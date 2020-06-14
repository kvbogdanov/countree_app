import 'dart:convert';
//import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

part 'tree.g.dart';

const tableTree = SqfEntityTable(
  tableName: 'tree',
  primaryKeyName: 'id_tree',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  useSoftDeleting: true,
//  modelName: null,
  fields: [
    SqfEntityField('id_system', DbType.integer, defaultValue: 0),
    SqfEntityField('created', DbType.integer),
    SqfEntityField('uploaded', DbType.integer, defaultValue: 0),
    SqfEntityField('is_deleted', DbType.integer, defaultValue: 0),
    SqfEntityField('id_user', DbType.integer),

    SqfEntityField('id_treetype', DbType.integer),
    SqfEntityField('custom_treetype', DbType.text),
    SqfEntityField('notsure_treetype', DbType.integer, defaultValue: 0),

    SqfEntityField('longitude', DbType.real),
    SqfEntityField('latitude', DbType.real),

    SqfEntityField('is_alive', DbType.integer, defaultValue: 0), // is_dead actually
    SqfEntityField('notsure_is_alive', DbType.integer, defaultValue: 0),

    SqfEntityField('is_seedling', DbType.integer, defaultValue: 0),
    SqfEntityField('notsure_is_seedling', DbType.integer, defaultValue: 0),

    SqfEntityField('diameter', DbType.integer, defaultValue: 0), // perimeter actaully
    SqfEntityField('notsure_diameter', DbType.integer, defaultValue: 0),

    SqfEntityField('multibarrel', DbType.integer, defaultValue: 0),
    SqfEntityField('notsure_multibarrel', DbType.integer, defaultValue: 0),

    SqfEntityField('id_state', DbType.integer), // крона
    SqfEntityField('notsure_id_state', DbType.integer, defaultValue: 0),

    SqfEntityField('firstthread', DbType.integer), // высота первой ветви
    SqfEntityField('notsure_firstthread', DbType.integer, defaultValue: 0),

    SqfEntityField('ids_condition', DbType.text), // состояние дерева
    SqfEntityField('custom_condition', DbType.text),
    SqfEntityField('notsure_ids_condition', DbType.integer, defaultValue: 0),

    SqfEntityField('id_surroundings', DbType.integer), // условия роста    
    SqfEntityField('notsure_id_surroundings', DbType.integer, defaultValue: 0),

    SqfEntityField('ids_neighbours', DbType.text), // окружение    
    SqfEntityField('notsure_ids_neighbours', DbType.integer, defaultValue: 0),

    SqfEntityField('id_overall', DbType.integer), // общая оценка    
    SqfEntityField('notsure_id_overall', DbType.integer, defaultValue: 0),

    SqfEntityField('images', DbType.text),

    SqfEntityField('height', DbType.real),
    SqfEntityField('notsure_height', DbType.integer, defaultValue: 0),
  ]
);

@SqfEntityBuilder(countreeDbModel)
const countreeDbModel = SqfEntityModel(
    modelName: 'CountreeStoreDbModel',
    databaseName: 'countreeORM.db',
    password: null, // You can set a password if you want to use crypted database (For more information: https://github.com/sqlcipher/sqlcipher)
    // put defined tables into the tables list.
    databaseTables: [tableTree],
    // You can define tables to generate add/edit view forms if you want to use Form Generator property
    //formTables: [tableProduct, tableCategory, tableTodo],
    // put defined sequences into the sequences list.
    //sequences: [seqIdentity],
    dbVersion: 2,
    bundledDatabasePath: null //         'assets/sample.db'
    // This value is optional. When bundledDatabasePath is empty then
    // EntityBase creats a new database when initializing the database
    );
