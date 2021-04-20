import 'dart:async';
import 'dart:io' as io;

import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatUserModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatTextMessage.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database _db;

  /// if _db fail to get this data then we will return this variables
  User _user;
  Map<String, String> _jwt;
  Map<String, dynamic> _deviceData;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main3.db");
    var theDb = await openDatabase(path,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return theDb;
  }

  // UPGRADE DATABASE TABLES BY APPLYING MIGRATIONS
  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < newVersion) {
      debugPrint("Applying migrations");
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
    await db.execute("""CREATE TABLE "User" (
        "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
        "uuid"	TEXT,
        "fullName"	TEXT,
        "userName"	TEXT,
        "phoneNumber"	TEXT,
        "password"	TEXT,
        "avatar"	TEXT,
        "qrCode"	TEXT,
        "url"	TEXT,
        "currency"	TEXT
    );""");

    // Create the jwt table
    await db.execute('''CREATE TABLE "Jwt" (
                "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
                "access"	TEXT,
                "refresh"	TEXT,
                "expiration"	TEXT
            );
    ''');

    // Create the device table
    await db.execute('''CREATE TABLE "Device" (
                "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
                "firebaseToken"	TEXT,
                "type"	TEXT,
                "mode"	TEXT,
                "deviceId"	TEXT,
                "deviceName"	TEXT
             );
      ''');

    // Create the ChatUser table
    await db
        .execute('''CREATE TABLE "ChatUser" ("conversationId" TEXT PRIMARY KEY,
                     "messageCount" INTEGER,
                     "hashedMessage" TEXT UNIQUE     
              );
    ''');

    // Create the ChatTextMessage table
    await db.execute('''CREATE TABLE "ChatTextMessage" (
      "check_id" TEXT PRIMARY KEY,
      "conversation_id" TEXT,
      "author" TEXT,
      "author_full_name" TEXT,
      "author_avatar" TEXT,
      "message" TEXT,
      "kind" TEXT,
      "read_by_author" INTEGER,
      "read_by_recipient" INTEGER,
      "delivered" INTEGER,
      "created_at" TEXT,
      "type" TEXT,
      "replied_to" TEXT);
    ''');

    ///{full_name: Iyalaje Stores,
    /// username: olabisi.abraham.1,
    /// avatar: https://slydo-assets.s3.amazonaws.com/media/customer/avatar/c06810e3dc334d088cc864c16655f974.jpg,
    /// qr_code: https://slydo-assets.s3.amazonaws.com/media/customer/qr-code/ed2ee782326a4526a1d804c410f2336b.png,
    /// conversation_id: 0fa8952a-e6a5-4aee-bf2a-ec074254ab46,
    /// type: Business}

    // Create the userConnections table
    await db.execute('''CREATE TABLE "UserConnection" (
      "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
      "conversation_id" TEXT UNIQUE,
      "full_name" TEXT,
      "username" TEXT,
      "avatar" TEXT,
      "qr_code" TEXT,
      "type" TEXT,
      "last_message_time" INTEGER
   );
    ''');
  }

  // Close connect to the db
  Future close() async => _db.close();

  /// User operations

  // Save user to the db
  Future<int> saveUser(User user) async {
    var dbClient = await db;
    _user = user;
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
    _user = null;
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
    List<Map<String, dynamic>> res = await dbClient.query("User");
//    List<User> users = [];
    var user;
    if (res != null && res.length > 0) {
      var obj = res.first;
      user = User(
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
    } else {
      user = _user;
    }

    return user;
  }

  /// Jwt operations

  // save user's jwt to the db
  Future<int> saveJwt(Map<String, String> data) async {
    var dbClient = await db;
    _jwt = data;
    int res = await dbClient.insert("Jwt", data);
    debugPrint("Jwt saved to db");
    return res;
  }

  // Delete the jwt from the db
  Future<int> deleteJwt() async {
    var dbClient = await db;
    _jwt = null;
    int res = await dbClient.delete("Jwt");
    debugPrint("Jwt deleted from db");
    return res;
  }

  // Get current user's jwt from db
  Future<Map<String, dynamic>> getJwt() async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient.query("Jwt");

    if (res != null && res.length > 0) {
      return res.first;
    }
    return _jwt;
  }

  /// Device operation

  // get device information
  Future<Map<String, dynamic>> getDevice() async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient.query("Device");

    if (res != null && res.length > 0) {
      return res.first;
    } else {
      return _deviceData;
    }
  }

  // delete device
  Future<int> deleteDevice() async {
    var dbClient = await db;
    _deviceData = null;
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
    _deviceData = data;
    int res = await dbClient.insert("Device", data);
    return res;
  }

  Future<Map<String, dynamic>> getChatUser(String conversationId) async {
    Database dbClient = await db;

    List<Map<String, dynamic>> result = await dbClient.query("ChatUser",
        where: "conversationId = ?", whereArgs: [conversationId]);

    return result.first;
  }

  /// ChatUsers Operation

  void saveChatUsers(List<ChatUserModel> users) async {
    Database dbClient = await db;

    Batch insertUserBatch = dbClient.batch();

    users.forEach((user) {
      insertUserBatch.insert("ChatUser", user.toJson(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    });

    await insertUserBatch.commit();
  }

  void saveChatUser(ChatUserModel user) async {
    Database dbClient = await db;

    int res = await dbClient.insert("ChatUser", user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    if (res != null) {
      debugPrint("Save Chat User !!");
    }

    return;
  }

  // delete chatUsers
  Future<int> deleteChatUsers() async {
    var dbClient = await db;
    int res = await dbClient.delete("ChatUser");
    debugPrint("ChatUsers deleted from db");
    return res;
  }

  Future<void> updateChatUserMessageCount(
      {String conversationId, String hashedMessage}) async {
    var dbClient = await db;
    try {
      await dbClient.execute(
          "UPDATE ChatUser SET messageCount = messageCount + 1 , hashedMessage = ? where conversationId = ? AND hashedMessage != ?",
          [hashedMessage, conversationId, hashedMessage]);
      debugPrint("Chat message count updated from db");
    } catch (e) {
      debugPrint("ERROR:- while updating the Chat Message count $e");
    }

    return;
  }

  Future<int> clearChatUserMessageCount({String conversationId}) async {
    var dbClient = await db;
    int result;
    try {
      result = await dbClient.update("ChatUser", {"messageCount": 0},
          where: "conversationId = ?", whereArgs: [conversationId]);
      // await dbClient.execute(
      //     "UPDATE ChatUser SET messageCount = 0 where conversationId = ?", [conversationId]);
    } catch (e) {
      debugPrint("ERROR:- while Clearing MessageCount $e");
    }
    debugPrint("ChatUsers MessageCount clear from db");
    return result;
  }

  Future<int> getChatMessageCount() async {
    var dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient
        .rawQuery("SELECT SUM(messageCount) as Total FROM ChatUser");
    if (result != null) {
      int count = result.first["Total"];
      return count;
    }
    return 0;
  }

  /// ChatTextMessage

  Future<List<ChatTextMessage>> getChatTextMessages() async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient.query("ChatTextMessage");

    if (res != null && res.length > 0) {
      List<ChatTextMessage> chatTextMessages =
          res.map((element) => ChatTextMessage.fromJson(element)).toList();
      return chatTextMessages;
    }
    return [];
  }

  void saveChatTextMessage({ChatTextMessage message}) async {
    Database dbClient = await db;

    int res = await dbClient.insert("ChatTextMessage", message.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    if (res != null) {
      debugPrint("<<<<< ChatTextMessage Added !!");
    }

    return;
  }

  Future<int> deleteChatTextMessage({ChatTextMessage message}) async {
    var dbClient = await db;
    int res = await dbClient.delete("ChatTextMessage",
        where: "check_id = ?", whereArgs: [message.checkId]);
    debugPrint(">>>> ChatTextMessage deleted !!");
    return res;
  }

  Future<int> clearChatTextMessage() async {
    var dbClient = await db;
    int res = await dbClient.delete("ChatTextMessage");
    debugPrint("ChatTextMessage Cleared !!");
    return res;
  }

  ///UserConnection operations
  Future<dynamic> saveUserConnections(List<CustomerProfile> users) async {
    Database dbClient = await db;

    Batch insertUserBatch = dbClient.batch();

    users.forEach((user) {
      Map<String, dynamic> data = user.toJsonForDB();
      data["last_message_time"] = 0;

      insertUserBatch.insert("UserConnection", data,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    });

    await insertUserBatch.commit();
  }

  Future<List<CustomerProfile>> getUserConnections() async {
    Database dbClient = await db;

    List<Map<String, dynamic>> res = await dbClient.query("UserConnection",
        orderBy: "last_message_time DESC");

    if (res != null && res.length > 0) {
      List<CustomerProfile> connectionList =
          res.map((element) => CustomerProfile.fromDBJson(element)).toList();
      return connectionList;
    }
    return [];
  }

  Future<int> getUserConnectionsCount() async {
    Database dbClient = await db;

    List<Map<String, dynamic>> res = await dbClient.query("UserConnection");
    if (res != null && res.length > 0) {
      return res.length;
    }
    return 0;
  }

  Future<int> updateConnectionListLastMessageTime(
      {String conversationId, int time}) async {
    Database dbClient = await db;

    return await dbClient.update("UserConnection", {"last_message_time": time},
        where: "conversation_id = ?", whereArgs: [conversationId]);
  }

  Future<int> clearUserConnections() async {
    var dbClient = await db;
    int res = await dbClient.delete("UserConnection");
    debugPrint("UserConnection Cleared !!");
    return res;
  }
}
