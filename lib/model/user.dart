import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

part 'user.g.dart';

const tableUser = SqfEntityTable(
  tableName: 'user',
  primaryKeyName: 'id_user',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  useSoftDeleting: true,
//  modelName: null,
  fields: [
    SqfEntityField('name', DbType.text),
    SqfEntityField('pass', DbType.text),
    SqfEntityField('email', DbType.text),
    SqfEntityField('role', DbType.integer, defaultValue: 0),
    SqfEntityField('updated', DbType.integer),
    SqfEntityField('isActive', DbType.bool, defaultValue: false),
  ]
);

@SqfEntityBuilder(countreeDbModel)
const countreeDbModel = SqfEntityModel(
    modelName: 'CountreeDbModel',
    databaseName: 'sampleORM_v1.4.0.db',
    password: null, // You can set a password if you want to use crypted database (For more information: https://github.com/sqlcipher/sqlcipher)
    // put defined tables into the tables list.
    databaseTables: [tableUser],
    // You can define tables to generate add/edit view forms if you want to use Form Generator property
    //formTables: [tableProduct, tableCategory, tableTodo],
    // put defined sequences into the sequences list.
    //sequences: [seqIdentity],
    dbVersion: 2,
    bundledDatabasePath: null //         'assets/sample.db'
    // This value is optional. When bundledDatabasePath is empty then
    // EntityBase creats a new database when initializing the database
    );
