import 'dart:async';
import 'dart:io' as io;

import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatUserModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessage.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessagePagination.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/SocketQueueChatMessage.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/nudge_notification/NudgeNotification.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/VirtualAccount.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database _db;

  static int _databaseVersion = 1;

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
    String path = join(documentsDirectory.path, "initial.db");
    var theDb = await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure);
    return theDb;
  }

  // UPGRADE DATABASE TABLES BY APPLYING MIGRATIONS
  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < newVersion) {
      debugPrint("Applying migrations");
      // when we upgrade and database has changed we should put our migration statement over here
      // db.execute("ALTER TABLE table_name ADD column_name TEXT;")  adding column
      // db.execute("ALTER TABLE table_name DROP column_name;")  adding column
      // db.execute("ALTER TABLE User ADD is_verified INTEGER;");

    } else {
      debugPrint("No migrations to apply");
    }
  }

  // To configure foreign key support in SQFLITE
  FutureOr<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    return;
  }

  // Create this database tables when we initialize app
  void _onCreate(Database db, int version) async {
    try {
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
      "currency"	TEXT);
    """);

      // Create the jwt table
      await db.execute('''CREATE TABLE "Jwt" (
      "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
      "access"	TEXT,
      "refresh"	TEXT,
      "expiration"	TEXT);
    ''');

      // Create the device table
      await db.execute('''CREATE TABLE "Device" (
      "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
      "firebaseToken"	TEXT,
      "type"	TEXT,
      "mode"	TEXT,
      "deviceId"	TEXT,
      "deviceName"	TEXT);
      ''');

      // Create the ChatUser table which will handle count of the messages in user connection
      await db.execute('''CREATE TABLE "ChatUser" (
      "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
      "conversationId" TEXT UNIQUE,
      "messageCount" INTEGER,
      "hashedMessage" TEXT UNIQUE);
    ''');

      // Create the SocketQueueChatMessage table which will store all the sent messages when user is offline
      await db.execute('''CREATE TABLE "SocketQueueChatMessage" (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "check_id" TEXT UNIQUE,
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

      // Create the userConnections table
      await db.execute('''CREATE TABLE "UserConnection" (
      "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
      "conversation_id" TEXT UNIQUE,
      "full_name" TEXT,
      "username" TEXT,
      "avatar" TEXT,
      "qr_code" TEXT,
      "type" TEXT,
      "created_at" INTEGER,
      "admin_users" TEXT,
      "blocked_participants" TEXT,
      "description" TEXT,
      "is_group_conversation" INTEGER,
      "muted_participants" TEXT,
      "owner" TEXT,
      "participants" TEXT,
      "last_message_time" INTEGER
   );
    ''');

      // Create the ChatMessage table
      await db.execute('''CREATE TABLE "ChatMessage" (
      "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
      "author" TEXT,
      "author_full_name" TEXT,
      "check_id" TEXT,
      "created_at" INTEGER,
      "updated_at" INTEGER,
      "meta_data" TEXT,
      "deleted_for_author" INTEGER,
      "deleted_for_recipient" INTEGER,
      "delivered" INTEGER,
      "message_id" TEXT,
      "kind" TEXT,
      "media" TEXT,
      "poster" TEXT,
      "read_by_author" INTEGER,
      "read_by_recipient" INTEGER,
      "from_customer_avatar" TEXT,
      "to_customer_avatar" TEXT,
      "replied_to" TEXT,
      "text" TEXT,
      "type" TEXT,
      "was_edited" INTEGER,
      "conversation_id" TEXT,
      FOREIGN KEY(conversation_id) REFERENCES UserConnection(conversation_id) ON DELETE CASCADE,
      UNIQUE(check_id,conversation_id)
   );
    ''');

      // Create the ChatMessagePagination table
      await db.execute('''CREATE TABLE "ChatMessagePagination" (
      "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
      "conversation_id" TEXT UNIQUE,
      "count" INTEGER,
      "next" TEXT,
      "previous" TEXT
    );
    ''');

      // Create the NUDGENOTIFICATION table
      await db.execute('''CREATE TABLE "NUDGENOTIFICATION" (     
            "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
            "check_id" TEXT,
            "conversation_id" TEXT,
            "notification_id" TEXT,
            "author" TEXT,
            "recipient" TEXT,
            "created_at" TEXT,
            "acknowledgement_type" TEXT,
            "author_avatar" TEXT,
            "actions" TEXT,
            "type" TEXT,
            "recipient_username" TEXT
          );
    ''');

      // Create the NOTIFICATION table
      await db.execute('''CREATE TABLE "NOTIFICATION" (     
            "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
            "notification" TEXT
          );
    ''');

      // Create the Virtual Bank Account table
      await db.execute('''CREATE TABLE "VirtualAccount" (     
            "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
            "account_number" TEXT,
            "financial_institution" TEXT,
            "account_name" TEXT,
            "customer_username" TEXT,
            "is_active" INTEGER,
            "created_at" TEXT,
            "updated_at" TEXT,
            "note" TEXT
          );
    ''');

      // Create the General Settings table
      await db.execute('''CREATE TABLE "GeneralSettings" (     
            "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
            "playIncomingMessageSound" INTEGER,
            "playOutgoingMessageSound" INTEGER
          );
    ''');

      debugPrint("DATABASE:- Tables are created !!");
    } catch (e) {
      debugPrint("DATABASE:- ERROR: while creating tables: $e");
    }
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
      debugPrint("DATABASE:- User saved to db");
    } catch (error) {
      await dbClient.delete("User");
      res = await dbClient.insert("User", user.toMap());
      debugPrint("DATABASE:- User saved to db");
    }
    return res;
  }

  // Delete user from db
  Future<int> deleteUsers() async {
    var dbClient = await db;
    _user = null;
    int res = await dbClient.delete("User");
    debugPrint("DATABASE:- User deleted from db");
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
    debugPrint("DATABASE:- Jwt saved to db");
    return res;
  }

  // Delete the jwt from the db
  Future<int> deleteJwt() async {
    var dbClient = await db;
    _jwt = null;
    int res = await dbClient.delete("Jwt");
    debugPrint("DATABASE:- Jwt deleted from db");
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

  /// ChatUser Operation

  Future<Map<String, dynamic>> getChatUser(String conversationId) async {
    Database dbClient = await db;

    List<Map<String, dynamic>> result = await dbClient.query("ChatUser",
        where: "conversationId = ?", whereArgs: [conversationId]);

    return result.first;
  }

  void saveChatUserCount(List<ChatUserModel> users) async {
    Database dbClient = await db;

    Batch insertUserBatch = dbClient.batch();

    users.forEach((user) {
      insertUserBatch.insert("ChatUser", user.toJson(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    });

    await insertUserBatch.commit();
  }

  Future<void> saveChatUser(ChatUserModel user) async {
    Database dbClient = await db;

    int res = await dbClient.insert("ChatUser", user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    if (res != null) {
      debugPrint("DATABASE:- Save Chat User !!");
    }

    return;
  }

  // delete chatUsers
  Future<int> deleteChatUsers() async {
    var dbClient = await db;
    int res = await dbClient.delete("ChatUser");
    debugPrint("DATABASE:- ChatUsers deleted from db");
    return res;
  }

  Future<int> deleteSingleChatUsers({String conversationId}) async {
    var dbClient = await db;
    int res = await dbClient.delete("ChatUser",
        where: "conversationId = ?", whereArgs: [conversationId]);
    debugPrint("DATABASE:- ChatUser $conversationId is Deleted !!");
    return res;
  }

  Future<void> updateChatUserMessageCount(
      {String conversationId, String hashedMessage}) async {
    var dbClient = await db;
    try {
      await dbClient.execute(
          "UPDATE ChatUser SET messageCount = messageCount + 1 , hashedMessage = ? where conversationId = ? AND hashedMessage != ?",
          [hashedMessage, conversationId, hashedMessage]);
      debugPrint(
          "DATABASE:- Chat message count updated from db $conversationId");
    } catch (e) {
      debugPrint("DATABASE:- ERROR:- while updating the Chat Message count $e");
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
      debugPrint("DATABASE:- ERROR:- while Clearing MessageCount $e");
    }
    debugPrint("DATABASE:- ChatUsers MessageCount clear from db");
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

  /// SocketQueueChatMessage

  Future<List<SocketQueueChatMessage>> getSocketQueueChatMessages() async {
    var dbClient = await db;
    List<Map<String, dynamic>> res =
        await dbClient.query("SocketQueueChatMessage");

    if (res != null && res.length > 0) {
      List<SocketQueueChatMessage> socketQueueChatMessages = res
          .map((element) => SocketQueueChatMessage.fromJson(element))
          .toList();
      return socketQueueChatMessages;
    }
    return [];
  }

  Future<int> saveSocketQueueChatMessage(
      {SocketQueueChatMessage message}) async {
    Database dbClient = await db;

    int res = await dbClient.insert("SocketQueueChatMessage", message.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    if (res != null) {
      debugPrint("DATABASE:- <<<<< SocketQueueChatMessage Added !! $res");
    }

    return res;
  }

  Future<int> deleteSocketQueueChatMessage(
      {SocketQueueChatMessage message}) async {
    var dbClient = await db;
    int res = await dbClient.delete("SocketQueueChatMessage",
        where: "check_id = ?", whereArgs: [message.checkId]);
    debugPrint("DATABASE:- >>>> SocketQueueChatMessage deleted !!");
    return res;
  }

  Future<int> deleteSocketQueueForSpecificConversation(
      {String conversationId}) async {
    var dbClient = await db;
    int res = await dbClient.delete("SocketQueueChatMessage",
        where: "conversation_id = ?", whereArgs: [conversationId]);
    debugPrint(
        "DATABASE:- >>>> SocketQueueChatMessage deleted for Conversation $conversationId !!");
    return res;
  }

  Future<int> clearSocketQueueChatMessage() async {
    var dbClient = await db;
    int res = await dbClient.delete("SocketQueueChatMessage");
    debugPrint("DATABASE:- SocketQueueChatMessage Cleared !!");
    return res;
  }

  ///UserConnection operations
  Future<dynamic> saveUserConnections(
      List<ChatConversation> chatConversations) async {
    Database dbClient = await db;

    List<ChatConversation> existingChatConversation =
        await getUserConnections();

    Batch insertUserBatch = dbClient.batch();

    chatConversations.forEach((user) {
      Map<String, dynamic> data = user.toDBJson();

      /// for checking if the chatConversation is already stored in the db
      bool isChatConversationIsExist = false;
      for (int i = 0; i < existingChatConversation.length; i++) {
        if (user.conversationId == existingChatConversation[i].conversationId) {
          isChatConversationIsExist = true;
          break;
        }
      }

      /// if ChatConversation is new then we will set last_message_time as 0
      if (!isChatConversationIsExist) {
        data["last_message_time"] = data['created_at'];
      }

      insertUserBatch.insert("UserConnection", data,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    });

    return await insertUserBatch.commit();
  }

  Future<dynamic> saveMissedUserConnections(
      List<ChatConversation> chatConversations) async {
    Database dbClient = await db;

    List<ChatConversation> existingChatConversation =
        await getUserConnections();

    Batch insertUserBatch = dbClient.batch();

    chatConversations.forEach((user) {
      Map<String, dynamic> data = user.toDBJson();

      /// for checking if the chatConversation is already stored in the db
      bool isChatConversationIsExist = false;
      for (int i = 0; i < existingChatConversation.length; i++) {
        if (user.conversationId == existingChatConversation[i].conversationId) {
          isChatConversationIsExist = true;
          break;
        }
      }

      /// if ChatConversation is new then we will set last_message_time as 0
      if (!isChatConversationIsExist) {
        data["last_message_time"] = data['created_at'];
      }

      insertUserBatch.insert("UserConnection", data,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    });

    var result = await insertUserBatch.commit();
    debugPrint("Result From Batch:- $result");

    return result;
  }

  Future<int> addUserConnection({ChatConversation chatConversation}) async {
    Database dbClient = await db;

    List<ChatConversation> existingChatConversation =
        await getUserConnections();

    Map<String, dynamic> data = chatConversation.toDBJson();

    /// for checking if the chatConversation is already stored in the db
    bool isChatConversationIsExist = false;
    for (int i = 0; i < existingChatConversation.length; i++) {
      if (chatConversation.conversationId ==
          existingChatConversation[i].conversationId) {
        isChatConversationIsExist = true;
        break;
      }
    }

    /// if ChatConversation is new then we will set last_message_time as 0
    if (!isChatConversationIsExist) {
      DateTime dateTime = DateTime.now();
      data["last_message_time"] = dateTime.millisecondsSinceEpoch;
    }

    return await dbClient.insert("UserConnection", data,
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<ChatConversation>> getUserConnections() async {
    Database dbClient = await db;

    List<Map<String, dynamic>> res = await dbClient.query("UserConnection",
        orderBy: "last_message_time DESC");

    if (res != null && res.length > 0) {
      List<ChatConversation> connectionList =
          res.map((element) => ChatConversation.fromDBJson(element)).toList();

      return connectionList;
    }
    return [];
  }

  Future<List<ChatConversation>> getSearchedUserConnections(
      {String searchedText}) async {
    Database dbClient = await db;

    List<Map<String, dynamic>> result = await dbClient.query("UserConnection",
        where: "username LIKE ? OR full_name LIKE ?",
        whereArgs: ['%$searchedText%', '%$searchedText%']);

    if (result != null && result.length > 0) {
      List<ChatConversation> connectionList = result
          .map((element) => ChatConversation.fromDBJson(element))
          .toList();
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

    // await deleteChatMessagePagination();
    // await deleteChatMessage();
    debugPrint("DATABASE:- UserConnection Cleared !!");
    return res;
  }

  Future<int> updateChatConversation(
      {ChatConversation chatConversation}) async {
    Database dbClient = await db;

    return await dbClient.update("UserConnection", chatConversation.toDBJson(),
        where: "conversation_id = ?",
        whereArgs: [chatConversation.conversationId]);
  }

  Future<int> deleteChatConversation({String conversationId}) async {
    var dbClient = await db;
    int res = await dbClient.delete("UserConnection",
        where: "conversation_id = ?", whereArgs: [conversationId]);
    debugPrint("UserConnection $conversationId is Deleted !!");
    await deleteSingleChatUsers(conversationId: conversationId);
    await deleteSingleUserChatMessage(conversationId: conversationId);
    return res;
  }

  Future<ChatConversation> getLastChatConversation(
      {String conversationId}) async {
    Database dbClient = await db;

    List<Map<String, dynamic>> res = await dbClient.query("UserConnection",
        orderBy: "created_at DESC", limit: 1);

    if (res != null && res.length > 0) {
      ChatConversation chatConversation =
          ChatConversation.fromDBJson(res.first);
      return chatConversation;
    }
    return null;
  }

  /// ChatMessage Operations
  Future<List<ChatMessage>> saveChatMessage(
      List<ChatMessage> chatMessages) async {
    Database dbClient = await db;

    Batch insertUserBatch = dbClient.batch();

    chatMessages.forEach((chatMessage) {
      Map<String, dynamic> data = chatMessage.toDBJson();

      insertUserBatch.insert("ChatMessage", data,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    });

    List<dynamic> result = await insertUserBatch.commit();

    List<ChatMessage> insertedMessages = await getInsertedChatMessages(result);
    debugPrint("Batch Result:- $result");
    return insertedMessages;
  }

  Future<List<ChatMessage>> getInsertedChatMessages(
      List<dynamic> idList) async {
    Database dbClient = await db;
    String idListString = idList.toString();

    String firstRemove = idListString.replaceFirst("[", "(");
    String secondRemove = firstRemove.replaceFirst("]", ")");

    List<Map<String, dynamic>> result = await dbClient.rawQuery(
        "SELECT * FROM ChatMessage WHERE id IN $secondRemove ORDER BY created_at DESC");

    if (result != null && result.length > 0) {
      List<ChatMessage> chatMessages = result.map((element) {
        // debugPrint(
        //     "ELEMENT ID:- ${element['id']} TEXT ${element['text']} CREATED AT:- ${convertMillisecondsSinceEpochToString(element['created_at'])}");
        return ChatMessage.fromDBJson(element);
      }).toList();
      return chatMessages;
    }
    return [];
  }

  Future<List> insertMissedMessage(List<ChatMessage> chatMessages) async {
    Database dbClient = await db;

    Batch insertUserBatch = dbClient.batch();

    chatMessages.forEach((chatMessage) {
      Map<String, dynamic> data = chatMessage.toDBJson();

      insertUserBatch.insert("ChatMessage", data,
          conflictAlgorithm: ConflictAlgorithm.replace);
    });

    List<dynamic> result = await insertUserBatch.commit();

    debugPrint("Batch Result:- $result");

    return result;
  }

  Future<List<ChatMessage>> getChatMessages(
      {ChatConversation chatConversation}) async {
    Database dbClient = await db;

    List<Map<String, dynamic>> res = await dbClient.query("ChatMessage",
        orderBy: "created_at DESC",
        where: "conversation_id = ?",
        whereArgs: [chatConversation.conversationId]);

    if (res != null && res.length > 0) {
      List<ChatMessage> chatMessages = res.map((element) {
        return ChatMessage.fromDBJson(element);
      }).toList();
      return chatMessages;
    }
    return [];
  }

  Future<List<ChatMessage>> getLimitedChatMessages(
      {String conversationId, int limit = 10}) async {
    Database dbClient = await db;

    List<Map<String, dynamic>> res = await dbClient.query("ChatMessage",
        orderBy: "created_at DESC",
        where: "conversation_id = ? AND delivered = ?",
        whereArgs: [conversationId, 1],
        limit: limit);

    if (res != null && res.length > 0) {
      List<ChatMessage> chatMessages = res.map((element) {
        return ChatMessage.fromDBJson(element);
      }).toList();
      return chatMessages;
    }
    return [];
  }

  Future<int> deleteChatMessages() async {
    Database dbClient = await db;
    int res = await dbClient.delete("ChatMessage");
    await deleteChatMessagePagination();
    return res;
  }

  Future<int> deleteChatMessage(String checkId, String conversationId) async {
    Database dbClient = await db;
    int res = await dbClient.delete("ChatMessage",
        where: "conversation_id = ? AND check_id = ?",
        whereArgs: [conversationId, checkId]);
    return res;
  }

  Future<int> updateEditedChatMessage(String checkId, String conversationId,
      bool wasEdited, String text) async {
    Database dbClient = await db;
    var result = await dbClient.update(
        "ChatMessage", {"was_edited": wasEdited == true ? 1 : 0, "text": text},
        where: "conversation_id = ? AND check_id = ?",
        whereArgs: [conversationId, checkId]);
    return result;
  }

  Future<int> deleteSingleUserChatMessage({String conversationId}) async {
    var dbClient = await db;
    int res = await dbClient.delete("ChatMessage",
        where: "conversation_id = ?", whereArgs: [conversationId]);
    debugPrint("DATABASE:- ChatMessage $conversationId is Deleted !!");

    await deleteSingleChatMessagePagination(conversationId: conversationId);
    return res;
  }

  Future<int> updateChatMessageReadByRecipient(
      String checkId, String conversationId) async {
    Database dbClient = await db;
    var result = await dbClient.update("ChatMessage", {"read_by_recipient": 1},
        where: "conversation_id = ? AND check_id = ?",
        whereArgs: [conversationId, checkId]);

    return result;
  }

  Future<int> insertSingleChatMessage(ChatMessage chatMessage) async {
    Database dbClient = await db;

    return await dbClient.insert("ChatMessage", chatMessage.toDBJson());
  }

  Future<List<ChatMessage>> getLastChatMessage() async {
    Database dbClient = await db;

    // List<Map<String, dynamic>> res = await dbClient.query(
    //   "ChatMessage",
    //   where: "delivered = ?",
    //   whereArgs: [1],
    //   orderBy: "created_at DESC",
    //   groupBy: "conversation_id",
    // );

    List<Map<String, dynamic>> res = await dbClient.rawQuery(
        "SELECT * FROM ChatMessage where delivered=? order by created_at DESC;",
        [1]);

    if (res != null && res.length > 0) {
      var newMap = groupBy(res, (obj) => obj['conversation_id']);
      // debugPrint("==> $newMap");
      List<Map<String, dynamic>> messages = List<Map<String, dynamic>>();
      newMap.forEach((key, value) {
        messages.add(value[0]);
      });

      List<ChatMessage> chatMessages = List<ChatMessage>();
      messages.forEach((message) {
        chatMessages.add(ChatMessage.fromDBJson(message));
      });
      debugPrint("Messages from DB:- ${chatMessages.length}");
      return chatMessages;
    }
    return null;
  }

  Future<int> updateSingleChatMessage(ChatMessage chatMessage) async {
    Database dbClient = await db;
    var result = await dbClient.update("ChatMessage", chatMessage.toDBJson(),
        where: "conversation_id = ? AND check_id = ?",
        whereArgs: [chatMessage.conversationId, chatMessage.checkId]);
    if (result == 0) {
      await dbClient.insert("ChatMessage", chatMessage.toDBJson());
    }
    return result;
  }

  ///save ChatMessagePagination

  Future<void> saveChatMessagePagination(
      ChatMessagePagination chatMessagePagination) async {
    Database dbClient = await db;

    int res = await dbClient.insert(
        "ChatMessagePagination", chatMessagePagination.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    if (res != null) {
      debugPrint("DATABASE:- Save ChatMessagePagination !!");
    }

    return;
  }

  Future<ChatMessagePagination> getChatMessagePagination(
      String conversationId) async {
    Database dbClient = await db;

    List<Map<String, dynamic>> result = await dbClient.query(
        "ChatMessagePagination",
        where: "conversation_id = ?",
        whereArgs: [conversationId]);

    if (result != null && result.length > 0) {
      ChatMessagePagination chatMessagePagination =
          ChatMessagePagination.fromJson(result.first);
      return chatMessagePagination;
    }

    return ChatMessagePagination(conversationId: conversationId);
  }

  Future<int> updateChatMessagePagination(
      ChatMessagePagination chatMessagePagination) async {
    Database dbClient = await db;

    return await dbClient.update(
        "ChatMessagePagination", chatMessagePagination.toJson(),
        where: "conversation_id = ?",
        whereArgs: [chatMessagePagination.conversationId]);
  }

  Future<int> deleteChatMessagePagination() async {
    Database dbClient = await db;
    int res = await dbClient.delete("ChatMessagePagination");
    return res;
  }

  Future<int> deleteSingleChatMessagePagination({String conversationId}) async {
    var dbClient = await db;
    int res = await dbClient.delete("ChatMessagePagination",
        where: "conversation_id = ?", whereArgs: [conversationId]);
    debugPrint(
        "DATABASE:- ChatMessagePagination $conversationId is Deleted !!");
    return res;
  }

  /// NOTIFICATION OPERATION

  Future<int> saveNudgeNotification(NudgeNotification nudgeNotification) async {
    Database dbClient = await db;

    int res = await dbClient.insert(
        "NUDGENOTIFICATION", nudgeNotification.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    if (res != null) {
      debugPrint("DATABASE:- Save NUDGE NOTIFICATION !!");
      return res;
    }
    return null;
  }

  Future<int> deleteNudgeNotification() async {
    Database dbClient = await db;

    int res = await dbClient.delete("NUDGENOTIFICATION");
    if (res != null) {
      debugPrint("DATABASE:- DELETE NUDGE NOTIFICATION !!");
      return res;
    }
    return null;
  }

  Future<NudgeNotification> getNudgeNotification() async {
    Database dbClient = await db;

    List<Map<String, dynamic>> notifications =
        await dbClient.query("NUDGENOTIFICATION");
    if (notifications != null) {
      if (notifications.length > 0)
        return NudgeNotification.fromJson(notifications.first);
    }
    return null;
  }

  Future<int> saveNotification(String notification) async {
    Database dbClient = await db;

    await deleteNotification();

    int res = await dbClient.insert(
        "NOTIFICATION", {"notification": notification},
        conflictAlgorithm: ConflictAlgorithm.replace);
    if (res != null) {
      debugPrint("DATABASE:- Save NOTIFICATION !!");
      return res;
    }
    return null;
  }

  Future<int> deleteNotification() async {
    Database dbClient = await db;

    int res = await dbClient.delete("NOTIFICATION");
    if (res != null) {
      debugPrint("DATABASE:- DELETE NOTIFICATION !!");
      return res;
    }
    return null;
  }

  Future<Map<String, dynamic>> getNotification() async {
    Database dbClient = await db;

    List<Map<String, dynamic>> notifications =
        await dbClient.query("NOTIFICATION");
    if (notifications != null) {
      if (notifications.length > 0) return notifications.first;
    }
    return null;
  }

  /// VirtualAccount OPERATION

  Future<int> saveVirtualAccount(VirtualAccount virtualAccount) async {
    Database dbClient = await db;

    int res = await dbClient.insert("VirtualAccount", virtualAccount.toDBJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    if (res != null) {
      debugPrint("DATABASE:- Saved Virtual Account !!");
      return res;
    }
    return null;
  }

  Future<VirtualAccount> getVirtualAccount() async {
    Database dbClient = await db;

    List<Map<String, dynamic>> virtualAccounts =
        await dbClient.query("VirtualAccount");
    if (virtualAccounts != null) {
      if (virtualAccounts.length > 0)
        return VirtualAccount.fromDBJson(virtualAccounts.first);
    }
    return null;
  }

  Future<int> deleteVirtualAccount() async {
    Database dbClient = await db;

    int res = await dbClient.delete("VirtualAccount");
    if (res != null) {
      debugPrint("DATABASE:- DELETE VirtualAccount !!");
      return res;
    }
    return null;
  }

  /// GeneralSettings OPERATION

  Future<int> saveGeneralSettings(Map<String, dynamic> data) async {
    Database dbClient = await db;

    int res = await dbClient.insert("GeneralSettings", data,
        conflictAlgorithm: ConflictAlgorithm.ignore);
    if (res != null) {
      debugPrint("DATABASE:- Saved GeneralSettings !!");
      return res;
    }
    return null;
  }

  Future<int> updateGeneralSettings(Map<String, dynamic> data) async {
    Database dbClient = await db;

    int res = await dbClient.update("GeneralSettings", data);
    if (res != null) {
      debugPrint("DATABASE:- Update GeneralSettings !!");
      return res;
    }
    return null;
  }

  Future<Map<String, dynamic>> getGeneralSettings() async {
    Database dbClient = await db;

    List<Map<String, dynamic>> generalSettings =
        await dbClient.query("GeneralSettings");
    if (generalSettings != null) {
      if (generalSettings.length > 0) return generalSettings.first;
    }
    return null;
  }

  Future<int> deleteGeneralSettings() async {
    Database dbClient = await db;

    int res = await dbClient.delete("GeneralSettings");
    if (res != null) {
      debugPrint("DATABASE:- DELETE GeneralSettings !!");
      return res;
    }
    return null;
  }
}
