// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// SqfEntityGenerator
// **************************************************************************

//  These classes was generated by SqfEntity
//  Copyright (c) 2019, All rights reserved. Use of this source code is governed by a
//  Apache license that can be found in the LICENSE file.

//  To use these SqfEntity classes do following:
//  - import model.dart into where to use
//  - start typing ex:User.select()... (add a few filters with fluent methods)...(add orderBy/orderBydesc if you want)...
//  - and then just put end of filters / or end of only select()  toSingle() / or toList()
//  - you can select one or return List<yourObject> by your filters and orders
//  - also you can batch update or batch delete by using delete/update methods instead of tosingle/tolist methods
//    Enjoy.. Huseyin Tokpunar

// ignore_for_file:
// BEGIN TABLES
// User TABLE
class TableUser extends SqfEntityTableBase {
  TableUser() {
    // declare properties of EntityTable
    tableName = 'user';
    primaryKeyName = 'id_user';
    primaryKeyType = PrimaryKeyType.integer_auto_incremental;
    useSoftDeleting = true;
    // when useSoftDeleting is true, creates a field named 'isDeleted' on the table, and set to '1' this field when item deleted (does not hard delete)

    // declare fields
    fields = [
      SqfEntityFieldBase('name', DbType.text, isNotNull: false),
      SqfEntityFieldBase('pass', DbType.text, isNotNull: false),
      SqfEntityFieldBase('email', DbType.text, isNotNull: false),
      SqfEntityFieldBase('role', DbType.integer,
          defaultValue: 0, isNotNull: false),
      SqfEntityFieldBase('updated', DbType.integer, isNotNull: false),
      SqfEntityFieldBase('id_system', DbType.integer,
          defaultValue: 0, isNotNull: false),
      SqfEntityFieldBase('total_trees', DbType.integer,
          defaultValue: 0, isNotNull: false),
      SqfEntityFieldBase('moderated_trees', DbType.integer,
          defaultValue: 0, isNotNull: false),
      SqfEntityFieldBase('isActive', DbType.bool,
          defaultValue: false, isNotNull: false),
    ];
    super.init();
  }
  static SqfEntityTableBase _instance;
  static SqfEntityTableBase get getInstance {
    return _instance = _instance ?? TableUser();
  }
}
// END TABLES

// BEGIN DATABASE MODEL
class CountreeDbModel extends SqfEntityModelProvider {
  CountreeDbModel() {
    databaseName = countreeDbModel.databaseName;
    password = countreeDbModel.password;
    dbVersion = countreeDbModel.dbVersion;
    databaseTables = [
      TableUser.getInstance,
    ];

    bundledDatabasePath = countreeDbModel
        .bundledDatabasePath; //'assets/sample.db'; // This value is optional. When bundledDatabasePath is empty then EntityBase creats a new database when initializing the database
  }
  Map<String, dynamic> getControllers() {
    final controllers = <String, dynamic>{};

    return controllers;
  }
}
// END DATABASE MODEL

// BEGIN ENTITIES
// region User
class User {
  User(
      {this.id_user,
      this.name,
      this.pass,
      this.email,
      this.role,
      this.updated,
      this.id_system,
      this.total_trees,
      this.moderated_trees,
      this.isActive,
      this.isDeleted}) {
    _setDefaultValues();
  }
  User.withFields(
      this.name,
      this.pass,
      this.email,
      this.role,
      this.updated,
      this.id_system,
      this.total_trees,
      this.moderated_trees,
      this.isActive,
      this.isDeleted) {
    _setDefaultValues();
  }
  User.withId(
      this.id_user,
      this.name,
      this.pass,
      this.email,
      this.role,
      this.updated,
      this.id_system,
      this.total_trees,
      this.moderated_trees,
      this.isActive,
      this.isDeleted) {
    _setDefaultValues();
  }
  User.fromMap(Map<String, dynamic> o, {bool setDefaultValues = true}) {
    if (setDefaultValues) {
      _setDefaultValues();
    }
    id_user = int.tryParse(o['id_user'].toString());
    if (o['name'] != null) {
      name = o['name'] as String;
    }
    if (o['pass'] != null) {
      pass = o['pass'] as String;
    }
    if (o['email'] != null) {
      email = o['email'] as String;
    }
    if (o['role'] != null) {
      role = int.tryParse(o['role'].toString());
    }
    if (o['updated'] != null) {
      updated = int.tryParse(o['updated'].toString());
    }
    if (o['id_system'] != null) {
      id_system = int.tryParse(o['id_system'].toString());
    }
    if (o['total_trees'] != null) {
      total_trees = int.tryParse(o['total_trees'].toString());
    }
    if (o['moderated_trees'] != null) {
      moderated_trees = int.tryParse(o['moderated_trees'].toString());
    }
    if (o['isActive'] != null) {
      isActive = o['isActive'] == 1 || o['isActive'] == true;
    }
    isDeleted = o['isDeleted'] != null
        ? o['isDeleted'] == 1 || o['isDeleted'] == true
        : null;
  }
  // FIELDS (User)
  int id_user;
  String name;
  String pass;
  String email;
  int role;
  int updated;
  int id_system;
  int total_trees;
  int moderated_trees;
  bool isActive;
  bool isDeleted;

  BoolResult saveResult;
  // end FIELDS (User)

  static const bool _softDeleteActivated = true;
  UserManager __mnUser;

  UserManager get _mnUser {
    return __mnUser = __mnUser ?? UserManager();
  }

  // METHODS
  Map<String, dynamic> toMap(
      {bool forQuery = false, bool forJson = false, bool forView = false}) {
    final map = <String, dynamic>{};
    if (id_user != null) {
      map['id_user'] = id_user;
    }
    if (name != null) {
      map['name'] = name;
    }

    if (pass != null) {
      map['pass'] = pass;
    }

    if (email != null) {
      map['email'] = email;
    }

    if (role != null) {
      map['role'] = role;
    }

    if (updated != null) {
      map['updated'] = updated;
    }

    if (id_system != null) {
      map['id_system'] = id_system;
    }

    if (total_trees != null) {
      map['total_trees'] = total_trees;
    }

    if (moderated_trees != null) {
      map['moderated_trees'] = moderated_trees;
    }

    if (isActive != null) {
      map['isActive'] = forQuery ? (isActive ? 1 : 0) : isActive;
    }

    if (isDeleted != null) {
      map['isDeleted'] = forQuery ? (isDeleted ? 1 : 0) : isDeleted;
    }

    return map;
  }

  Future<Map<String, dynamic>> toMapWithChildren(
      [bool forQuery = false,
      bool forJson = false,
      bool forView = false]) async {
    final map = <String, dynamic>{};
    if (id_user != null) {
      map['id_user'] = id_user;
    }
    if (name != null) {
      map['name'] = name;
    }

    if (pass != null) {
      map['pass'] = pass;
    }

    if (email != null) {
      map['email'] = email;
    }

    if (role != null) {
      map['role'] = role;
    }

    if (updated != null) {
      map['updated'] = updated;
    }

    if (id_system != null) {
      map['id_system'] = id_system;
    }

    if (total_trees != null) {
      map['total_trees'] = total_trees;
    }

    if (moderated_trees != null) {
      map['moderated_trees'] = moderated_trees;
    }

    if (isActive != null) {
      map['isActive'] = forQuery ? (isActive ? 1 : 0) : isActive;
    }

    if (isDeleted != null) {
      map['isDeleted'] = forQuery ? (isDeleted ? 1 : 0) : isDeleted;
    }

    return map;
  }

  /// This method returns Json String
  String toJson() {
    return json.encode(toMap(forJson: true));
  }

  /// This method returns Json String
  Future<String> toJsonWithChilds() async {
    return json.encode(await toMapWithChildren(false, true));
  }

  List<dynamic> toArgs() {
    return [
      name,
      pass,
      email,
      role,
      updated,
      id_system,
      total_trees,
      moderated_trees,
      isActive,
      isDeleted
    ];
  }

  List<dynamic> toArgsWithIds() {
    return [
      id_user,
      name,
      pass,
      email,
      role,
      updated,
      id_system,
      total_trees,
      moderated_trees,
      isActive,
      isDeleted
    ];
  }

  static Future<List<User>> fromWebUrl(String url) async {
    try {
      final response = await http.get(url);
      return await fromJson(response.body);
    } catch (e) {
      print('SQFENTITY ERROR User.fromWebUrl: ErrorMessage: ${e.toString()}');
      return null;
    }
  }

  static Future<List<User>> fromJson(String jsonBody) async {
    final Iterable list = await json.decode(jsonBody) as Iterable;
    var objList = <User>[];
    try {
      objList = list
          .map((user) => User.fromMap(user as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('SQFENTITY ERROR User.fromJson: ErrorMessage: ${e.toString()}');
    }
    return objList;
  }

  static Future<List<User>> fromMapList(List<dynamic> data,
      {bool preload = false,
      List<String> preloadFields,
      bool loadParents = false,
      List<String> loadedFields,
      bool setDefaultValues = true}) async {
    final List<User> objList = <User>[];
    loadedFields = loadedFields ?? [];
    for (final map in data) {
      final obj = User.fromMap(map as Map<String, dynamic>,
          setDefaultValues: setDefaultValues);

      objList.add(obj);
    }
    return objList;
  }

  /// returns User by ID if exist, otherwise returns null
  ///
  /// Primary Keys: int id_user
  ///
  /// bool preload: if true, loads all related child objects (Set preload to true if you want to load all fields related to child or parent)
  ///
  /// ex: getById(preload:true) -> Loads all related objects
  ///
  /// List<String> preloadFields: specify the fields you want to preload (preload parameter's value should also be "true")
  ///
  /// ex: getById(preload:true, preloadFields:['plField1','plField2'... etc])  -> Loads only certain fields what you specified
  ///
  /// bool loadParents: if true, loads all parent objects until the object has no parent

  ///
  /// <returns>returns User if exist, otherwise returns null
  Future<User> getById(int id_user,
      {bool preload = false,
      List<String> preloadFields,
      bool loadParents = false,
      List<String> loadedFields}) async {
    if (id_user == null) {
      return null;
    }
    User obj;
    final data = await _mnUser.getById([id_user]);
    if (data.length != 0) {
      obj = User.fromMap(data[0] as Map<String, dynamic>);
    } else {
      obj = null;
    }
    return obj;
  }

  /// Saves the (User) object. If the id_user field is null, saves as a new record and returns new id_user, if id_user is not null then updates record

  /// <returns>Returns id_user
  Future<int> save() async {
    if (id_user == null || id_user == 0) {
      id_user = await _mnUser.insert(this);
    } else {
      // id_user= await _upsert(); // removed in sqfentity_gen 1.3.0+6
      await _mnUser.update(this);
    }

    return id_user;
  }

  /// saveAs User. Returns a new Primary Key value of User

  /// <returns>Returns a new Primary Key value of User
  Future<int> saveAs() async {
    id_user = null;

    return save();
  }

  /// saveAll method saves the sent List<User> as a bulk in one transaction
  ///
  /// Returns a <List<BoolResult>>
  Future<List<dynamic>> saveAll(List<User> users) async {
    // final results = _mnUser.saveAll('INSERT OR REPLACE INTO user (id_user,name, pass, email, role, updated, id_system, total_trees, moderated_trees, isActive,isDeleted)  VALUES (?,?,?,?,?,?,?,?,?,?,?)',users);
    // return results; removed in sqfentity_gen 1.3.0+6
    CountreeDbModel().batchStart();
    for (final obj in users) {
      await obj.save();
    }
    return CountreeDbModel().batchCommit();
  }

  /// Updates if the record exists, otherwise adds a new row

  /// <returns>Returns id_user
  Future<int> upsert() async {
    try {
      if (await _mnUser.rawInsert(
              'INSERT OR REPLACE INTO user (id_user,name, pass, email, role, updated, id_system, total_trees, moderated_trees, isActive,isDeleted)  VALUES (?,?,?,?,?,?,?,?,?,?,?)',
              [
                id_user,
                name,
                pass,
                email,
                role,
                updated,
                id_system,
                total_trees,
                moderated_trees,
                isActive,
                isDeleted
              ]) ==
          1) {
        saveResult = BoolResult(
            success: true,
            successMessage: 'User id_user=$id_user updated successfully');
      } else {
        saveResult = BoolResult(
            success: false,
            errorMessage: 'User id_user=$id_user did not update');
      }
      return id_user;
    } catch (e) {
      saveResult = BoolResult(
          success: false,
          errorMessage: 'User Save failed. Error: ${e.toString()}');
      return 0;
    }
  }

  /// inserts or replaces the sent List<<User>> as a bulk in one transaction.
  ///
  /// upsertAll() method is faster then saveAll() method. upsertAll() should be used when you are sure that the primary key is greater than zero
  ///
  /// Returns a BoolCommitResult
  Future<BoolCommitResult> upsertAll(List<User> users) async {
    final results = await _mnUser.rawInsertAll(
        'INSERT OR REPLACE INTO user (id_user,name, pass, email, role, updated, id_system, total_trees, moderated_trees, isActive,isDeleted)  VALUES (?,?,?,?,?,?,?,?,?,?,?)',
        users);
    return results;
  }

  /// Deletes User

  /// <returns>BoolResult res.success=Deleted, not res.success=Can not deleted
  Future<BoolResult> delete([bool hardDelete = false]) async {
    print('SQFENTITIY: delete User invoked (id_user=$id_user)');
    if (!_softDeleteActivated || hardDelete || isDeleted) {
      return _mnUser.delete(
          QueryParams(whereString: 'id_user=?', whereArguments: [id_user]));
    } else {
      return _mnUser.updateBatch(
          QueryParams(whereString: 'id_user=?', whereArguments: [id_user]),
          {'isDeleted': 1});
    }
  }

  /// Recover User>

  /// <returns>BoolResult res.success=Recovered, not res.success=Can not recovered
  Future<BoolResult> recover([bool recoverChilds = true]) async {
    print('SQFENTITIY: recover User invoked (id_user=$id_user)');
    {
      return _mnUser.updateBatch(
          QueryParams(whereString: 'id_user=?', whereArguments: [id_user]),
          {'isDeleted': 0});
    }
  }

  UserFilterBuilder select({List<String> columnsToSelect, bool getIsDeleted}) {
    return UserFilterBuilder(this)
      .._getIsDeleted = getIsDeleted == true
      ..qparams.selectColumns = columnsToSelect;
  }

  UserFilterBuilder distinct(
      {List<String> columnsToSelect, bool getIsDeleted}) {
    return UserFilterBuilder(this)
      .._getIsDeleted = getIsDeleted == true
      ..qparams.selectColumns = columnsToSelect
      ..qparams.distinct = true;
  }

  void _setDefaultValues() {
    role = role ?? 0;
    id_system = id_system ?? 0;
    total_trees = total_trees ?? 0;
    moderated_trees = moderated_trees ?? 0;
    isActive = isActive ?? false;
    isDeleted = isDeleted ?? false;
  }
  // END METHODS
  // CUSTOM CODES
  /*
      you must define customCode property of your SqfEntityTable constant for ex:
      const tablePerson = SqfEntityTable(
      tableName: 'person',
      primaryKeyName: 'id',
      primaryKeyType: PrimaryKeyType.integer_auto_incremental,
      fields: [
        SqfEntityField('firstName', DbType.text),
        SqfEntityField('lastName', DbType.text),
      ],
      customCode: '''
       String fullName()
       { 
         return '$firstName $lastName';
       }
      ''');
     */
  // END CUSTOM CODES
}
// endregion user

// region UserField
class UserField extends SearchCriteria {
  UserField(this.userFB) {
    param = DbParameter();
  }
  DbParameter param;
  String _waitingNot = '';
  UserFilterBuilder userFB;

  UserField get not {
    _waitingNot = ' NOT ';
    return this;
  }

  UserFilterBuilder equals(dynamic pValue) {
    param.expression = '=';
    userFB._addedBlocks = _waitingNot == ''
        ? setCriteria(pValue, userFB.parameters, param, SqlSyntax.EQuals,
            userFB._addedBlocks)
        : setCriteria(pValue, userFB.parameters, param, SqlSyntax.NotEQuals,
            userFB._addedBlocks);
    _waitingNot = '';
    userFB._addedBlocks.needEndBlock[userFB._blockIndex] =
        userFB._addedBlocks.retVal;
    return userFB;
  }

  UserFilterBuilder equalsOrNull(dynamic pValue) {
    param.expression = '=';
    userFB._addedBlocks = _waitingNot == ''
        ? setCriteria(pValue, userFB.parameters, param, SqlSyntax.EQualsOrNull,
            userFB._addedBlocks)
        : setCriteria(pValue, userFB.parameters, param,
            SqlSyntax.NotEQualsOrNull, userFB._addedBlocks);
    _waitingNot = '';
    userFB._addedBlocks.needEndBlock[userFB._blockIndex] =
        userFB._addedBlocks.retVal;
    return userFB;
  }

  UserFilterBuilder isNull() {
    userFB._addedBlocks = setCriteria(
        0,
        userFB.parameters,
        param,
        SqlSyntax.IsNULL.replaceAll(SqlSyntax.notKeyword, _waitingNot),
        userFB._addedBlocks);
    _waitingNot = '';
    userFB._addedBlocks.needEndBlock[userFB._blockIndex] =
        userFB._addedBlocks.retVal;
    return userFB;
  }

  UserFilterBuilder contains(dynamic pValue) {
    if (pValue != null) {
      userFB._addedBlocks = setCriteria(
          '%${pValue.toString()}%',
          userFB.parameters,
          param,
          SqlSyntax.Contains.replaceAll(SqlSyntax.notKeyword, _waitingNot),
          userFB._addedBlocks);
      _waitingNot = '';
      userFB._addedBlocks.needEndBlock[userFB._blockIndex] =
          userFB._addedBlocks.retVal;
    }
    return userFB;
  }

  UserFilterBuilder startsWith(dynamic pValue) {
    if (pValue != null) {
      userFB._addedBlocks = setCriteria(
          '${pValue.toString()}%',
          userFB.parameters,
          param,
          SqlSyntax.Contains.replaceAll(SqlSyntax.notKeyword, _waitingNot),
          userFB._addedBlocks);
      _waitingNot = '';
      userFB._addedBlocks.needEndBlock[userFB._blockIndex] =
          userFB._addedBlocks.retVal;
      userFB._addedBlocks.needEndBlock[userFB._blockIndex] =
          userFB._addedBlocks.retVal;
    }
    return userFB;
  }

  UserFilterBuilder endsWith(dynamic pValue) {
    if (pValue != null) {
      userFB._addedBlocks = setCriteria(
          '%${pValue.toString()}',
          userFB.parameters,
          param,
          SqlSyntax.Contains.replaceAll(SqlSyntax.notKeyword, _waitingNot),
          userFB._addedBlocks);
      _waitingNot = '';
      userFB._addedBlocks.needEndBlock[userFB._blockIndex] =
          userFB._addedBlocks.retVal;
    }
    return userFB;
  }

  UserFilterBuilder between(dynamic pFirst, dynamic pLast) {
    if (pFirst != null && pLast != null) {
      userFB._addedBlocks = setCriteria(
          pFirst,
          userFB.parameters,
          param,
          SqlSyntax.Between.replaceAll(SqlSyntax.notKeyword, _waitingNot),
          userFB._addedBlocks,
          pLast);
    } else if (pFirst != null) {
      if (_waitingNot != '') {
        userFB._addedBlocks = setCriteria(pFirst, userFB.parameters, param,
            SqlSyntax.LessThan, userFB._addedBlocks);
      } else {
        userFB._addedBlocks = setCriteria(pFirst, userFB.parameters, param,
            SqlSyntax.GreaterThanOrEquals, userFB._addedBlocks);
      }
    } else if (pLast != null) {
      if (_waitingNot != '') {
        userFB._addedBlocks = setCriteria(pLast, userFB.parameters, param,
            SqlSyntax.GreaterThan, userFB._addedBlocks);
      } else {
        userFB._addedBlocks = setCriteria(pLast, userFB.parameters, param,
            SqlSyntax.LessThanOrEquals, userFB._addedBlocks);
      }
    }
    _waitingNot = '';
    userFB._addedBlocks.needEndBlock[userFB._blockIndex] =
        userFB._addedBlocks.retVal;
    return userFB;
  }

  UserFilterBuilder greaterThan(dynamic pValue) {
    param.expression = '>';
    userFB._addedBlocks = _waitingNot == ''
        ? setCriteria(pValue, userFB.parameters, param, SqlSyntax.GreaterThan,
            userFB._addedBlocks)
        : setCriteria(pValue, userFB.parameters, param,
            SqlSyntax.LessThanOrEquals, userFB._addedBlocks);
    _waitingNot = '';
    userFB._addedBlocks.needEndBlock[userFB._blockIndex] =
        userFB._addedBlocks.retVal;
    return userFB;
  }

  UserFilterBuilder lessThan(dynamic pValue) {
    param.expression = '<';
    userFB._addedBlocks = _waitingNot == ''
        ? setCriteria(pValue, userFB.parameters, param, SqlSyntax.LessThan,
            userFB._addedBlocks)
        : setCriteria(pValue, userFB.parameters, param,
            SqlSyntax.GreaterThanOrEquals, userFB._addedBlocks);
    _waitingNot = '';
    userFB._addedBlocks.needEndBlock[userFB._blockIndex] =
        userFB._addedBlocks.retVal;
    return userFB;
  }

  UserFilterBuilder greaterThanOrEquals(dynamic pValue) {
    param.expression = '>=';
    userFB._addedBlocks = _waitingNot == ''
        ? setCriteria(pValue, userFB.parameters, param,
            SqlSyntax.GreaterThanOrEquals, userFB._addedBlocks)
        : setCriteria(pValue, userFB.parameters, param, SqlSyntax.LessThan,
            userFB._addedBlocks);
    _waitingNot = '';
    userFB._addedBlocks.needEndBlock[userFB._blockIndex] =
        userFB._addedBlocks.retVal;
    return userFB;
  }

  UserFilterBuilder lessThanOrEquals(dynamic pValue) {
    param.expression = '<=';
    userFB._addedBlocks = _waitingNot == ''
        ? setCriteria(pValue, userFB.parameters, param,
            SqlSyntax.LessThanOrEquals, userFB._addedBlocks)
        : setCriteria(pValue, userFB.parameters, param, SqlSyntax.GreaterThan,
            userFB._addedBlocks);
    _waitingNot = '';
    userFB._addedBlocks.needEndBlock[userFB._blockIndex] =
        userFB._addedBlocks.retVal;
    return userFB;
  }

  UserFilterBuilder inValues(dynamic pValue) {
    userFB._addedBlocks = setCriteria(
        pValue,
        userFB.parameters,
        param,
        SqlSyntax.IN.replaceAll(SqlSyntax.notKeyword, _waitingNot),
        userFB._addedBlocks);
    _waitingNot = '';
    userFB._addedBlocks.needEndBlock[userFB._blockIndex] =
        userFB._addedBlocks.retVal;
    return userFB;
  }
}
// endregion UserField

// region UserFilterBuilder
class UserFilterBuilder extends SearchCriteria {
  UserFilterBuilder(User obj) {
    whereString = '';
    qparams = QueryParams();
    parameters = <DbParameter>[];
    orderByList = <String>[];
    groupByList = <String>[];
    _addedBlocks = AddedBlocks(<bool>[], <bool>[]);
    _addedBlocks.needEndBlock.add(false);
    _addedBlocks.waitingStartBlock.add(false);
    _pagesize = 0;
    _page = 0;
    _obj = obj;
  }
  AddedBlocks _addedBlocks;
  int _blockIndex = 0;
  List<DbParameter> parameters;
  List<String> orderByList;
  User _obj;
  QueryParams qparams;
  int _pagesize;
  int _page;

  /// put the sql keyword 'AND'
  UserFilterBuilder get and {
    if (parameters.isNotEmpty) {
      parameters[parameters.length - 1].wOperator = ' AND ';
    }
    return this;
  }

  /// put the sql keyword 'OR'
  UserFilterBuilder get or {
    if (parameters.isNotEmpty) {
      parameters[parameters.length - 1].wOperator = ' OR ';
    }
    return this;
  }

  /// open parentheses
  UserFilterBuilder get startBlock {
    _addedBlocks.waitingStartBlock.add(true);
    _addedBlocks.needEndBlock.add(false);
    _blockIndex++;
    if (_blockIndex > 1) {
      _addedBlocks.needEndBlock[_blockIndex - 1] = true;
    }
    return this;
  }

  /// String whereCriteria, write raw query without 'where' keyword. Like this: 'field1 like 'test%' and field2 = 3'
  UserFilterBuilder where(String whereCriteria, {dynamic parameterValue}) {
    if (whereCriteria != null && whereCriteria != '') {
      final DbParameter param =
          DbParameter(columnName: parameterValue == null ? null : '');
      _addedBlocks = setCriteria(parameterValue ?? 0, parameters, param,
          '($whereCriteria)', _addedBlocks);
      _addedBlocks.needEndBlock[_blockIndex] = _addedBlocks.retVal;
    }
    return this;
  }

  /// page = page number,
  ///
  /// pagesize = row(s) per page
  UserFilterBuilder page(int page, int pagesize) {
    if (page > 0) {
      _page = page;
    }
    if (pagesize > 0) {
      _pagesize = pagesize;
    }
    return this;
  }

  /// int count = LIMIT
  UserFilterBuilder top(int count) {
    if (count > 0) {
      _pagesize = count;
    }
    return this;
  }

  /// close parentheses
  UserFilterBuilder get endBlock {
    if (_addedBlocks.needEndBlock[_blockIndex]) {
      parameters[parameters.length - 1].whereString += ' ) ';
    }
    _addedBlocks.needEndBlock.removeAt(_blockIndex);
    _addedBlocks.waitingStartBlock.removeAt(_blockIndex);
    _blockIndex--;
    return this;
  }

  /// argFields might be String or List<String>.
  ///
  /// Example 1: argFields='name, date'
  ///
  /// Example 2: argFields = ['name', 'date']
  UserFilterBuilder orderBy(dynamic argFields) {
    if (argFields != null) {
      if (argFields is String) {
        orderByList.add(argFields);
      } else {
        for (String s in argFields as List<String>) {
          if (s != null && s != '') {
            orderByList.add(' $s ');
          }
        }
      }
    }
    return this;
  }

  /// argFields might be String or List<String>.
  ///
  /// Example 1: argFields='field1, field2'
  ///
  /// Example 2: argFields = ['field1', 'field2']
  UserFilterBuilder orderByDesc(dynamic argFields) {
    if (argFields != null) {
      if (argFields is String) {
        orderByList.add('$argFields desc ');
      } else {
        for (String s in argFields as List<String>) {
          if (s != null && s != '') {
            orderByList.add(' $s desc ');
          }
        }
      }
    }
    return this;
  }

  /// argFields might be String or List<String>.
  ///
  /// Example 1: argFields='field1, field2'
  ///
  /// Example 2: argFields = ['field1', 'field2']
  UserFilterBuilder groupBy(dynamic argFields) {
    if (argFields != null) {
      if (argFields is String) {
        groupByList.add(' $argFields ');
      } else {
        for (String s in argFields as List<String>) {
          if (s != null && s != '') {
            groupByList.add(' $s ');
          }
        }
      }
    }
    return this;
  }

  UserField setField(UserField field, String colName, DbType dbtype) {
    return UserField(this)
      ..param = DbParameter(
          dbType: dbtype,
          columnName: colName,
          wStartBlock: _addedBlocks.waitingStartBlock[_blockIndex]);
  }

  UserField _id_user;
  UserField get id_user {
    return _id_user = setField(_id_user, 'id_user', DbType.integer);
  }

  UserField _name;
  UserField get name {
    return _name = setField(_name, 'name', DbType.text);
  }

  UserField _pass;
  UserField get pass {
    return _pass = setField(_pass, 'pass', DbType.text);
  }

  UserField _email;
  UserField get email {
    return _email = setField(_email, 'email', DbType.text);
  }

  UserField _role;
  UserField get role {
    return _role = setField(_role, 'role', DbType.integer);
  }

  UserField _updated;
  UserField get updated {
    return _updated = setField(_updated, 'updated', DbType.integer);
  }

  UserField _id_system;
  UserField get id_system {
    return _id_system = setField(_id_system, 'id_system', DbType.integer);
  }

  UserField _total_trees;
  UserField get total_trees {
    return _total_trees = setField(_total_trees, 'total_trees', DbType.integer);
  }

  UserField _moderated_trees;
  UserField get moderated_trees {
    return _moderated_trees =
        setField(_moderated_trees, 'moderated_trees', DbType.integer);
  }

  UserField _isActive;
  UserField get isActive {
    return _isActive = setField(_isActive, 'isActive', DbType.bool);
  }

  UserField _isDeleted;
  UserField get isDeleted {
    return _isDeleted = setField(_isDeleted, 'isDeleted', DbType.bool);
  }

  bool _getIsDeleted;

  void _buildParameters() {
    if (_page > 0 && _pagesize > 0) {
      qparams
        ..limit = _pagesize
        ..offset = (_page - 1) * _pagesize;
    } else {
      qparams
        ..limit = _pagesize
        ..offset = _page;
    }
    for (DbParameter param in parameters) {
      if (param.columnName != null) {
        if (param.value is List) {
          param.value = param.value
              .toString()
              .replaceAll('[', '')
              .replaceAll(']', '')
              .toString();
          whereString += param.whereString
              .replaceAll('{field}', param.columnName)
              .replaceAll(
                  '?',
                  param.value is String
                      ? '\'${param.value.toString()}\''
                      : param.value.toString());
          param.value = null;
        } else {
          whereString +=
              param.whereString.replaceAll('{field}', param.columnName);
        }
        if (!param.whereString.contains('?')) {
        } else {
          switch (param.dbType) {
            case DbType.bool:
              param.value =
                  param.value == null ? null : param.value == true ? 1 : 0;
              param.value2 =
                  param.value2 == null ? null : param.value2 == true ? 1 : 0;
              break;
            case DbType.date:
            case DbType.datetime:
            case DbType.datetimeUtc:
              param.value = param.value == null
                  ? null
                  : (param.value as DateTime).millisecondsSinceEpoch;
              param.value2 = param.value2 == null
                  ? null
                  : (param.value2 as DateTime).millisecondsSinceEpoch;
              break;
            default:
          }
          if (param.value != null) {
            whereArguments.add(param.value);
          }
          if (param.value2 != null) {
            whereArguments.add(param.value2);
          }
        }
      } else {
        whereString += param.whereString;
      }
    }
    if (User._softDeleteActivated) {
      if (whereString != '') {
        whereString =
            '${!_getIsDeleted ? 'ifnull(isDeleted,0)=0 AND' : ''} ($whereString)';
      } else if (!_getIsDeleted) {
        whereString = 'ifnull(isDeleted,0)=0';
      }
    }

    if (whereString != '') {
      qparams.whereString = whereString;
    }
    qparams
      ..whereArguments = whereArguments
      ..groupBy = groupByList.join(',')
      ..orderBy = orderByList.join(',');
  }

  /// Deletes List<User> bulk by query
  ///
  /// <returns>BoolResult res.success=Deleted, not res.success=Can not deleted
  Future<BoolResult> delete([bool hardDelete = false]) async {
    _buildParameters();
    var r = BoolResult();

    if (User._softDeleteActivated && !hardDelete) {
      r = await _obj._mnUser.updateBatch(qparams, {'isDeleted': 1});
    } else {
      r = await _obj._mnUser.delete(qparams);
    }
    return r;
  }

  /// Recover List<User> bulk by query
  Future<BoolResult> recover() async {
    _getIsDeleted = true;
    _buildParameters();
    print('SQFENTITIY: recover User bulk invoked');
    return _obj._mnUser.updateBatch(qparams, {'isDeleted': 0});
  }

  /// using:
  ///
  /// update({'fieldName': Value})
  ///
  /// fieldName must be String. Value is dynamic, it can be any of the (int, bool, String.. )
  Future<BoolResult> update(Map<String, dynamic> values) {
    _buildParameters();
    if (qparams.limit > 0 || qparams.offset > 0) {
      qparams.whereString =
          'id_user IN (SELECT id_user from user ${qparams.whereString.isNotEmpty ? 'WHERE ${qparams.whereString}' : ''}${qparams.limit > 0 ? ' LIMIT ${qparams.limit}' : ''}${qparams.offset > 0 ? ' OFFSET ${qparams.offset}' : ''})';
    }
    return _obj._mnUser.updateBatch(qparams, values);
  }

  /// This method always returns User Obj if exist, otherwise returns null
  ///
  /// bool preload: if true, loads all related child objects (Set preload to true if you want to load all fields related to child or parent)
  ///
  /// ex: toSingle(preload:true) -> Loads all related objects
  ///
  /// List<String> preloadFields: specify the fields you want to preload (preload parameter's value should also be "true")
  ///
  /// ex: toSingle(preload:true, preloadFields:['plField1','plField2'... etc])  -> Loads only certain fields what you specified
  ///
  /// bool loadParents: if true, loads all parent objects until the object has no parent

  ///
  /// <returns>List<User>
  Future<User> toSingle(
      {bool preload = false,
      List<String> preloadFields,
      bool loadParents = false,
      List<String> loadedFields}) async {
    _pagesize = 1;
    _buildParameters();
    final objFuture = _obj._mnUser.toList(qparams);
    final data = await objFuture;
    User obj;
    if (data.isNotEmpty) {
      obj = User.fromMap(data[0] as Map<String, dynamic>);
    } else {
      obj = null;
    }
    return obj;
  }

  /// This method returns int.
  ///
  /// <returns>int
  Future<int> toCount([VoidCallback Function(int c) userCount]) async {
    _buildParameters();
    qparams.selectColumns = ['COUNT(1) AS CNT'];
    final usersFuture = await _obj._mnUser.toList(qparams);
    final int count = usersFuture[0]['CNT'] as int;
    if (userCount != null) {
      userCount(count);
    }
    return count;
  }

  /// This method returns List<User>.
  ///
  /// bool preload: if true, loads all related child objects (Set preload to true if you want to load all fields related to child or parent)
  ///
  /// ex: toList(preload:true) -> Loads all related objects
  ///
  /// List<String> preloadFields: specify the fields you want to preload (preload parameter's value should also be "true")
  ///
  /// ex: toList(preload:true, preloadFields:['plField1','plField2'... etc])  -> Loads only certain fields what you specified
  ///
  /// bool loadParents: if true, loads all parent objects until the object has no parent

  ///
  /// <returns>List<User>
  Future<List<User>> toList(
      {bool preload = false,
      List<String> preloadFields,
      bool loadParents = false,
      List<String> loadedFields}) async {
    final data = await toMapList();
    final List<User> usersData = await User.fromMapList(data,
        preload: preload,
        preloadFields: preloadFields,
        loadParents: loadParents,
        loadedFields: loadedFields,
        setDefaultValues: qparams.selectColumns == null);
    return usersData;
  }

  /// This method returns Json String
  Future<String> toJson() async {
    final list = <dynamic>[];
    final data = await toList();
    for (var o in data) {
      list.add(o.toMap(forJson: true));
    }
    return json.encode(list);
  }

  /// This method returns Json String.
  Future<String> toJsonWithChilds() async {
    final list = <dynamic>[];
    final data = await toList();
    for (var o in data) {
      list.add(await o.toMapWithChildren(false, true));
    }
    return json.encode(list);
  }

  /// This method returns List<dynamic>.
  ///
  /// <returns>List<dynamic>
  Future<List<dynamic>> toMapList() async {
    _buildParameters();
    return await _obj._mnUser.toList(qparams);
  }

  /// This method returns Primary Key List<int>.
  /// <returns>List<int>
  Future<List<int>> toListPrimaryKey([bool buildParameters = true]) async {
    if (buildParameters) {
      _buildParameters();
    }
    final List<int> id_userData = <int>[];
    qparams.selectColumns = ['id_user'];
    final id_userFuture = await _obj._mnUser.toList(qparams);

    final int count = id_userFuture.length;
    for (int i = 0; i < count; i++) {
      id_userData.add(id_userFuture[i]['id_user'] as int);
    }
    return id_userData;
  }

  /// Returns List<dynamic> for selected columns. Use this method for 'groupBy' with min,max,avg..
  ///
  /// Sample usage: (see EXAMPLE 4.2 at https://github.com/hhtokpinar/sqfEntity#group-by)
  Future<List<dynamic>> toListObject() async {
    _buildParameters();

    final objectFuture = _obj._mnUser.toList(qparams);

    final List<dynamic> objectsData = <dynamic>[];
    final data = await objectFuture;
    final int count = data.length;
    for (int i = 0; i < count; i++) {
      objectsData.add(data[i]);
    }
    return objectsData;
  }

  /// Returns List<String> for selected first column
  ///
  /// Sample usage: await User.select(columnsToSelect: ['columnName']).toListString()
  Future<List<String>> toListString(
      [VoidCallback Function(List<String> o) listString]) async {
    _buildParameters();

    final objectFuture = _obj._mnUser.toList(qparams);

    final List<String> objectsData = <String>[];
    final data = await objectFuture;
    final int count = data.length;
    for (int i = 0; i < count; i++) {
      objectsData.add(data[i][qparams.selectColumns[0]].toString());
    }
    if (listString != null) {
      listString(objectsData);
    }
    return objectsData;
  }
}
// endregion UserFilterBuilder

// region UserFields
class UserFields {
  static TableField _fId_user;
  static TableField get id_user {
    return _fId_user =
        _fId_user ?? SqlSyntax.setField(_fId_user, 'id_user', DbType.integer);
  }

  static TableField _fName;
  static TableField get name {
    return _fName = _fName ?? SqlSyntax.setField(_fName, 'name', DbType.text);
  }

  static TableField _fPass;
  static TableField get pass {
    return _fPass = _fPass ?? SqlSyntax.setField(_fPass, 'pass', DbType.text);
  }

  static TableField _fEmail;
  static TableField get email {
    return _fEmail =
        _fEmail ?? SqlSyntax.setField(_fEmail, 'email', DbType.text);
  }

  static TableField _fRole;
  static TableField get role {
    return _fRole =
        _fRole ?? SqlSyntax.setField(_fRole, 'role', DbType.integer);
  }

  static TableField _fUpdated;
  static TableField get updated {
    return _fUpdated =
        _fUpdated ?? SqlSyntax.setField(_fUpdated, 'updated', DbType.integer);
  }

  static TableField _fId_system;
  static TableField get id_system {
    return _fId_system = _fId_system ??
        SqlSyntax.setField(_fId_system, 'id_system', DbType.integer);
  }

  static TableField _fTotal_trees;
  static TableField get total_trees {
    return _fTotal_trees = _fTotal_trees ??
        SqlSyntax.setField(_fTotal_trees, 'total_trees', DbType.integer);
  }

  static TableField _fModerated_trees;
  static TableField get moderated_trees {
    return _fModerated_trees = _fModerated_trees ??
        SqlSyntax.setField(
            _fModerated_trees, 'moderated_trees', DbType.integer);
  }

  static TableField _fIsActive;
  static TableField get isActive {
    return _fIsActive =
        _fIsActive ?? SqlSyntax.setField(_fIsActive, 'isActive', DbType.bool);
  }

  static TableField _fIsDeleted;
  static TableField get isDeleted {
    return _fIsDeleted = _fIsDeleted ??
        SqlSyntax.setField(_fIsDeleted, 'isDeleted', DbType.integer);
  }
}
// endregion UserFields

//region UserManager
class UserManager extends SqfEntityProvider {
  UserManager()
      : super(CountreeDbModel(),
            tableName: _tableName,
            primaryKeyList: _primaryKeyList,
            whereStr: _whereStr);
  static final String _tableName = 'user';
  static final List<String> _primaryKeyList = ['id_user'];
  static final String _whereStr = 'id_user=?';
}

//endregion UserManager
class CountreeDbModelSequenceManager extends SqfEntityProvider {
  CountreeDbModelSequenceManager() : super(CountreeDbModel());
}
// END OF ENTITIES