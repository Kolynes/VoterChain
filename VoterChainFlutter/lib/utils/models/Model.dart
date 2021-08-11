import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

typedef Model ModelConstructor(Map<String, dynamic> map);

abstract class Model {
  dynamic get primaryKey;
  String get primaryKeyName;
  Stream<Model> get stream;

  Model();

  Map<String, dynamic> get toMap;

  void copy(Model m);

  dynamic encode(dynamic value) {
    if(value is List || value is Map)
      return jsonEncode(value);
    else if(value is Model)
      return jsonEncode(value.toMap);
    else if(value is DateTime)
      return value.millisecondsSinceEpoch;
    else return value;
  }

  operator ==(model) => model.runtimeType == runtimeType && model.primaryKey == primaryKey;

  @override
  get hashCode => primaryKey;
}

abstract class ModelManager<T extends Model> {
  static Database _database;
  final String _tableName;
  final String ordering;

  StreamController<T> _streamController;
  StreamController<T> get streamController => _streamController;
  Stream<T> get stream => _streamController.stream;

  ModelManager(this._tableName, {this.ordering}) {
    _streamController =  StreamController<T>.broadcast();
  }

  dynamic decode(dynamic value, Type type, {ModelConstructor constructor}) {
    switch(type) {
      case bool:
        return value is int
          ?value != 0
          :value ?? false;
      case List:
        if(value is List)
          return value;
        else if(value is String) {
          var list = jsonDecode(value);
          if(constructor != null)
            return List.generate(list.length, (index) => constructor(list[index]));
          else return list;
        }
        else return [];
        break;
      case Map:
        return value is Map
          ?value
          :constructor == null
            ?jsonDecode(value)
            :constructor(jsonDecode(value));
      case Model:
        return value is Map
          ?constructor(value)
          :value is String
            ?constructor(jsonDecode(value))
            :value;
      case int:
        return value ?? 0;
      case num:
        return value ?? 0;
      case double:
        return value ?? 0;
      case String:
        return value ?? "";
      case DateTime:
        return value is int
          ?DateTime.fromMillisecondsSinceEpoch(value)
          :value;
      default:
        return value;
    }
  }

  T fromMap(Map<String, dynamic> map);

  Future<bool> save(T model) async {
    try {
      await _database.insert(_tableName, model.toMap, conflictAlgorithm: ConflictAlgorithm.replace);
      _streamController.add(model);
      return true;
    } catch(error) {
      print(error.message);
      return false;
    }
  }

  Future<bool> delete(T model) async {
    try {
      await _database.delete(_tableName, where: "\"${model.primaryKeyName}\" = ?", whereArgs: [model.primaryKey]);
      return true;
    } catch(error) {
      print(error.message);
      return false;
    }
  }

  Future<bool> deleteAll() async {
    try {
      await _database.delete(_tableName);
      return true;
    } catch(error) {
      print(error.message);
      return false;
    }
  }

  Future<T> get(Map<String, dynamic> lookup) async {
    List<String> whereClauses = [];
    List<dynamic> values = [];
    lookup.forEach((key, value) {
      whereClauses.add("\"$key\" = ?");
      values.add(value);
    });
    List<Map<String, dynamic>> maps = await _database.query(_tableName, distinct: true, where: whereClauses.join(" AND "), whereArgs: values, limit: 1);
    if(maps.length == 0)
      return null;
    return fromMap(maps[0]);
  }

  Future<List<T>> filter(Map<String, dynamic> lookup, {page: 1}) async {
    List<String> whereClauses = [];
    List<dynamic> values = []; 
    lookup.forEach((key, value) {
      whereClauses.add("\"$key\" = ?");
      values.add(value);
    });
    List<Map<String, dynamic>> maps = await _database.query(_tableName, where: whereClauses.join(" AND "), whereArgs: values, orderBy: ordering);
    return List.generate(maps.length, (index) {
      return fromMap(maps[index]);
    });
  }

  Future<List<T>> all() async {
    List<Map<String, dynamic>> maps = await _database.query(_tableName, orderBy: ordering);
    return List.generate(maps.length, (index) {
      return fromMap(maps[index]);
    });
  }

  Future<int> count() async {
    return (await _database.rawQuery("SELECT COUNT(*) FROM $_tableName"))[0].values.first as int;
  }
  
  static Future<void> registerModels(String databaseName, List<String> schemas) async {
    String dbPath = join(await getDatabasesPath(), databaseName);
    // await deleteDatabase(dbPath);
    _database = await openDatabase(
      dbPath,
      onCreate: (database, version) {
        var batch = database.batch();
        schemas.forEach((schema) {
          batch.execute(schema);
        });
        batch.commit();
      },
      version: 1,
    );
  }
  
}
