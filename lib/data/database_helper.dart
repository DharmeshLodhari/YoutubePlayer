import 'dart:async';
import 'dart:io' as io;

import 'package:PayBay/models/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main2.db");
    var theDb = await openDatabase(path, version: 2, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE User(uuid TEXT PRIMARY KEY, fullName TEXT, userName TEXT, "
        "phoneNumber TEXT, password TEXT, avatar TEXT, qrCode TEXT, url TEXT)");

    await db.execute(
        "CREATE TABLE Jwt(access TEXT PRIMARY KEY, refresh TEXT, expiration TEXT)");
  }

  // User Object methods
  Future<int> saveUser(User user) async {
    var dbClient = await db;
    int res = await dbClient.insert("User", user.toMap());
    return res;
  }

  Future<int> deleteUsers() async {
    var dbClient = await db;
    int res = await dbClient.delete("User");
    return res;
  }

  Future close() async => _db.close();

  Future<bool> isLoggedIn() async {
    var dbClient = await db;
    var res = await dbClient.query("User");
    return res.length > 0 ? true : false;
  }

  Future<User> getUser() async {
    // Get the user
    var dbClient = await db;
    var res = await dbClient.query("User");
    List<User> users = [];

    for (var obj in res) {
      var u = User(
          uuid: obj["uuid"],
          url: obj["url"],
          phoneNumber: obj["phoneNumber"],
          fullName: obj["fullName"],
          userName: obj["userName"],
          avatar: obj["avatar"],
          qrCode: obj["qrCode"],
          password: obj["password"]);
      users.add(u);
    }
    return users[0];
  }

  // Jwt Object methods
  Future<int> saveJwt(Map<String, dynamic> data) async {
    var dbClient = await db;
    int res = await dbClient.insert("Jwt", data);
    return res;
  }

  Future<int> deleteJwt() async {
    var dbClient = await db;
    int res = await dbClient.delete("Jwt");
    return res;
  }

  Future<Map<String, dynamic>> getJwt() async {
    // Get the user
    var dbClient = await db;
    var res = await dbClient.query("Jwt");

    try {
      return res[0];
    } catch (e) {
      throw e;
    }
  }
}
