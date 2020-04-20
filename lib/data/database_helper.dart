import 'dart:async';
import 'dart:io' as io;

import 'package:Slydo/models/user.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

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
    String path = join(documentsDirectory.path, "main.db");
    var theDb = await openDatabase(path,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return theDb;
  }

  // UPGRADE DATABASE TABLES BY APPLYING MIGRATIONS
  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < newVersion) {
      debugPrint("Appling migrations");
      // when we upgrade and database has changed we should put our migration statement over here
      // db.execute("ALTER TABLE table_name ADD column_name TEXT;")  adding column
      // db.execute("ALTER TABLE table_name DROP column_name;")  adding column
//      db.execute("ALTER TABLE User ADD is_verified INTEGER;");
    } else {
      debugPrint("No migrations to apply");
    }
  }

  // Create this database tables when we initialize app
  void _onCreate(Database db, int version) async {
    // Create the user table
    await db.execute(
        "CREATE TABLE User(uuid TEXT PRIMARY KEY, fullName TEXT, userName TEXT, "
        "phoneNumber TEXT, password TEXT, avatar TEXT, qrCode TEXT, url TEXT, currency TEXT)");

    // Create the jwt table
    await db.execute(
        "CREATE TABLE Jwt(access TEXT PRIMARY KEY, refresh TEXT, expiration TEXT)");

    // Create the device table
    await db.execute(
        "CREATE TABLE Device(firebaseToken TEXT PRIMARY KEY, type TEXT, mode TEXT, deviceId TEXT, deviceName TEXT)");
  }

  // Close connect to the db
  Future close() async => _db.close();

  // User operations

  // Save user to the db
  Future<int> saveUser(User user) async {
    var dbClient = await db;
    int res;
    try {
      res = await dbClient.insert("User", user.toMap());
      debugPrint("User saved to db");
    } catch (error) {
      await dbClient.delete("User");
      res = await dbClient.insert("User", user.toMap());
      debugPrint("User saved to db");
    }
    return res;
  }

  // Delete user from db
  Future<int> deleteUsers() async {
    var dbClient = await db;
    int res = await dbClient.delete("User");
    debugPrint("User deleted from db");
    return res;
  }

  // check if the current user is logged in
  Future<bool> isLoggedIn() async {
    var dbClient = await db;
    var res = await dbClient.query("User");
    return res.length > 0 ? true : false;
  }

  // Get the current user
  Future<User> getUser() async {
    // Get the user
    var dbClient = await db;
    var res = await dbClient.query("User");
//    List<User> users = [];

    var obj = res.first;
    var user = User(
      uuid: obj["uuid"],
      url: obj["url"],
      phoneNumber: obj["phoneNumber"],
      fullName: obj["fullName"],
      userName: obj["userName"],
      avatar: obj["avatar"],
      qrCode: obj["qrCode"],
      password: obj["password"],
      isVerified: obj["is_verified"],
    );
    return user;
  }

  // Jwt operations

  // save user's jwt to the db
  Future<int> saveJwt(Map<String, dynamic> data) async {
    var dbClient = await db;
    int res = await dbClient.insert("Jwt", data);
    debugPrint("Jwt saved to db");
    return res;
  }

  // Delete the jwt from the db
  Future<int> deleteJwt() async {
    var dbClient = await db;
    int res = await dbClient.delete("Jwt");
    debugPrint("Jwt deleted from db");
    return res;
  }

  // Get current user's jwt from db
  Future<Map<String, dynamic>> getJwt() async {
    var dbClient = await db;
    var res = await dbClient.query("Jwt");

    if (res != null) {
      try {
        return res[0];
      } catch (e) {
        throw e;
      }
    }
    return null;
  }

  // Device operation

  // get device information
  Future<Map<String, dynamic>> getDevice() async {
    var dbClient = await db;
    var res = await dbClient.query("Device");

    try {
      return res[0];
    } catch (e) {
      throw e;
    }

    // if the dbClient.query return error
  }

  // delete device
  Future<int> deleteDevice() async {
    var dbClient = await db;
    try {
      int res = await dbClient.delete("Device");
      return res;
    } catch (e) {
      debugPrint(e.toString());
    }
    // if the dbclient.delete return error
    return 1000;
  }

  // save user's Device data to the db
  Future<int> saveDevice(Map<String, dynamic> data) async {
    var dbClient = await db;
    try {
      await dbClient.delete("Device");
    } catch (e) {}
    int res = await dbClient.insert("Device", data);
    return res;
  }
}
