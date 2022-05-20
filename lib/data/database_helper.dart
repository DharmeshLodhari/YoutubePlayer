import 'dart:async';

import 'package:Slydo/data/database_migrations.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatUserModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessage.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessagePagination.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/SocketQueueChatMessage.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/VirtualAccount.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/fee_structure.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/jwt.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_migration/sqflite_migration.dart';

import '../screens/more_apps/messaging/chat/models/DocumentFileInChatModel.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static late Database _db;

  DatabaseHelper.internal();

  Future<Database> get db async {
    _db = await openDB();
    return _db;
  }

  final config = MigrationConfig(
      initializationScript: initialDBSchema, migrationScripts: dbMigrations);

  Future<Database> openDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'Initial_Slydo.db');

    return await openDatabaseWithMigration(path, config);
  }

  // Close connect to the db
  Future close() async => _db.close();

  /// User operations

  // Save user to the db
  Future<int> saveUser(User user) async {
    var dbClient = await db;
    int res;
    try {
      res = await dbClient.insert(USER_TABLE, user.toMap());
      debugPrint("DATABASE:- $USER_TABLE saved to db");
    } catch (error) {
      await dbClient.delete(USER_TABLE);
      res = await dbClient.insert("User", user.toMap());
      debugPrint("DATABASE:- $USER_TABLE saved to db");
    }
    return res;
  }

  Future<int> updateUserPassword(String password) async {
    var dbClient = await db;
    int res;
    res = await dbClient.update(USER_TABLE, {"password": password});
    debugPrint("DATABASE:- $USER_TABLE Password Updated to db");
    return res;
  }

  // Delete user from db
  Future<int> deleteUsers() async {
    var dbClient = await db;
    int res = await dbClient.delete(USER_TABLE);
    debugPrint("DATABASE:- $USER_TABLE deleted from db");
    return res;
  }

  // check if the current user is logged in
  Future<bool> isLoggedIn() async {
    var dbClient = await db;
    var res = await dbClient.query(USER_TABLE);
    return res.length > 0 ? true : false;
  }

  // Get the current user
  Future<User?> getUser() async {
    // Get the user
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient.query(USER_TABLE);

    User? user;
    if (res.length > 0) {
      var obj = res.first;

      user = User(
        uuid: obj["uuid"],
        url: obj["url"],
        phoneNumber: obj["phoneNumber"],
        fullName: obj["fullName"],
        userName: obj["userName"],
        nickName: obj['nickname'],
        avatar: obj["avatar"],
        qrCode: obj["qrCode"],
        password: obj["password"],
        isVerified: obj["is_verified"],
        type: obj['type'],
      );
    }

    return Future.value(user);
  }

  /// Jwt operations

  // save user's jwt to the db
  Future<int> saveJwt(Jwt jwt) async {
    var dbClient = await db;
    // await deleteJwt();
    int? res;
    if (jwt.access != null &&
        jwt.refresh != null &&
        jwt.expiration != null &&
        jwt.access != "" &&
        jwt.refresh != "" &&
        jwt.expiration != "") {
      res = await dbClient.update(JWT_TABLE, jwt.toDBJson());
      if (res == 0) res = await dbClient.insert(JWT_TABLE, jwt.toDBJson());
      debugPrint("DATABASE:- $JWT_TABLE saved to db");
    }
    return res ?? 0;
  }

  // Delete the jwt from the db
  Future<int> deleteJwt() async {
    var dbClient = await db;
    int res = await dbClient.delete(JWT_TABLE);
    debugPrint("DATABASE:- $JWT_TABLE deleted from db");
    return res;
  }

  // Get current user's jwt from db
  Future<Jwt?> getJwt() async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient.query(JWT_TABLE);
    Jwt? jwt;
    if (res.length > 0) {
      jwt = Jwt.fromDBJson(res.last);
    }
    return Future.value(jwt);
  }

  /// Device operation

  // get device information
  Future<Map<String, dynamic>?> getDevice() async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient.query(DEVICE_TABLE);

    Map<String, dynamic>? deviceData;
    if (res.length > 0) {
      deviceData = res.first;
    }
    return deviceData;
  }

  // delete device
  Future<int> deleteDevice() async {
    var dbClient = await db;
    try {
      int res = await dbClient.delete(DEVICE_TABLE);
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
      await dbClient.delete(DEVICE_TABLE);
    } catch (e) {}
    int res = await dbClient.insert(DEVICE_TABLE, data);
    return res;
  }

  /// ChatUser Operation

  Future<Map<String, dynamic>> getChatUser(String? conversationId) async {
    Database dbClient = await db;

    List<Map<String, dynamic>> result = await dbClient.query(CHAT_USER_TABLE,
        where: "conversationId = ?", whereArgs: [conversationId]);

    return result.first;
  }

  void saveChatUserCount(List<ChatUserModel> users) async {
    Database dbClient = await db;

    Batch insertUserBatch = dbClient.batch();

    users.forEach((user) {
      insertUserBatch.insert(CHAT_USER_TABLE, user.toJson(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    });

    await insertUserBatch.commit();
  }

  Future<int> saveChatUser(ChatUserModel user) async {
    Database dbClient = await db;

    int res = await dbClient.insert(CHAT_USER_TABLE, user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore);

    debugPrint("DATABASE:- Save $CHAT_USER_TABLE !!");

    return res;
  }

  // delete chatUsers
  Future<int> deleteChatUsers() async {
    var dbClient = await db;
    int res = await dbClient.delete(CHAT_USER_TABLE);
    debugPrint("DATABASE:- $CHAT_USER_TABLE deleted from db");
    return res;
  }

  Future<int> deleteSingleChatUsers({String? conversationId}) async {
    var dbClient = await db;
    int res = await dbClient.delete(CHAT_USER_TABLE,
        where: "conversationId = ?", whereArgs: [conversationId]);
    debugPrint("DATABASE:- ChatUser $conversationId is Deleted !!");
    return res;
  }

  Future<void> updateChatUserMessageCount(
      {String? conversationId, String? hashedMessage}) async {
    var dbClient = await db;
    try {
      await dbClient.execute(
          "UPDATE $CHAT_USER_TABLE SET messageCount = messageCount + 1 , hashedMessage = ? where conversationId = ? AND hashedMessage != ?",
          [hashedMessage, conversationId, hashedMessage]);
      debugPrint(
          "DATABASE:- Chat message count updated from db $conversationId");
    } catch (e) {
      debugPrint("DATABASE:- ERROR:- while updating the Chat Message count $e");
    }

    return;
  }

  Future<int?> clearChatUserMessageCount({String? conversationId}) async {
    var dbClient = await db;
    int? result;
    try {
      result = await dbClient.update(CHAT_USER_TABLE, {"messageCount": 0},
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
        .rawQuery("SELECT SUM(messageCount) as Total FROM $CHAT_USER_TABLE");

    int? count = result.first["Total"];
    return Future.value(count ?? 0);
  }

  /// SocketQueueChatMessage

  Future<List<SocketQueueChatMessage>> getSocketQueueChatMessages() async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient.query(SOCKET_QUEUE_TABLE);

    if (res.length > 0) {
      List<SocketQueueChatMessage> socketQueueChatMessages = res
          .map((element) => SocketQueueChatMessage.fromJson(element))
          .toList();
      return socketQueueChatMessages;
    }
    return [];
  }

  Future<int> saveSocketQueueChatMessage(
      {required SocketQueueChatMessage message}) async {
    Database dbClient = await db;

    int res = await dbClient.insert(SOCKET_QUEUE_TABLE, message.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore);

    debugPrint("DATABASE:- <<<<< SocketQueueChatMessage Added !! $res");

    return res;
  }

  Future<int> deleteSocketQueueChatMessage(
      {required SocketQueueChatMessage message}) async {
    var dbClient = await db;
    int res = await dbClient.delete(SOCKET_QUEUE_TABLE,
        where: "check_id = ?", whereArgs: [message.checkId]);
    debugPrint("DATABASE:- >>>> SocketQueueChatMessage deleted !!");
    return res;
  }

  Future<int> deleteSocketQueueForSpecificConversation(
      {String? conversationId}) async {
    var dbClient = await db;
    int res = await dbClient.delete(SOCKET_QUEUE_TABLE,
        where: "conversation_id = ?", whereArgs: [conversationId]);
    debugPrint(
        "DATABASE:- >>>> SocketQueueChatMessage deleted for Conversation $conversationId !!");
    return res;
  }

  Future<int> clearSocketQueueChatMessage() async {
    var dbClient = await db;
    int res = await dbClient.delete(SOCKET_QUEUE_TABLE);
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

      insertUserBatch.insert(USER_CONNECTION_TABLE, data,
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

      insertUserBatch.insert(USER_CONNECTION_TABLE, data,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    });

    var result = await insertUserBatch.commit();
    debugPrint("Result From Batch:- $result");

    return result;
  }

  Future<int> addUserConnection(
      {required ChatConversation chatConversation}) async {
    Database? dbClient = await db;

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

    return await dbClient.insert(USER_CONNECTION_TABLE, data,
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /*Returns a list of all your user's connection name.*/
  Future<List<String>> listUserConnections() async {
    Database dbClient = await db;

    List<Map<String, dynamic>> result =
        await dbClient.query(USER_CONNECTION_TABLE);

    if (result.length > 0) {
      List<String> connectionList = [];
      for (int i = 0; i < result.length; i++) {
        connectionList.add(result[i]['username']);
      }

      debugPrint('CONNECTIONS LIST NAME ::: $connectionList');

      return connectionList;
    }
    return [];
  }

  Future<List<ChatConversation>> getUserConnections() async {
    Database dbClient = await db;

    List<Map<String, dynamic>> res = await dbClient.query(USER_CONNECTION_TABLE,
        orderBy: "last_message_time DESC");

    if (res.length > 0) {
      List<ChatConversation> connectionList =
          res.map((element) => ChatConversation.fromDBJson(element)).toList();

      return connectionList;
    }
    return [];
  }

  Future<bool> checkUserInConnection({required String searchedText}) async {
    Database dbClient = await db;

    List<Map<String, dynamic>> result = await dbClient.query(
        USER_CONNECTION_TABLE,
        where: "username = ?",
        whereArgs: [searchedText]);

    if (result.length == 1) {
      return true;
    }
    return false;
  }

  Future<List<ChatConversation>> getSearchedUserConnections(
      {String? searchedText}) async {
    Database dbClient = await db;

    List<Map<String, dynamic>> result = await dbClient.query(
        USER_CONNECTION_TABLE,
        where: "username LIKE ? OR full_name LIKE ?",
        whereArgs: ['%$searchedText%', '%$searchedText%']);

    if (result.length > 0) {
      List<ChatConversation> connectionList = result
          .map((element) => ChatConversation.fromDBJson(element))
          .toList();
      return connectionList;
    }
    return [];
  }

  Future<int> getUserConnectionsCount() async {
    Database dbClient = await db;

    List<Map<String, dynamic>> res =
        await dbClient.query(USER_CONNECTION_TABLE);
    if (res.length > 0) {
      return res.length;
    }
    return 0;
  }

  Future<int> updateConnectionListLastMessageTime(
      {String? conversationId, int? time}) async {
    Database dbClient = await db;

    return await dbClient.update(
        USER_CONNECTION_TABLE, {"last_message_time": time},
        where: "conversation_id = ?", whereArgs: [conversationId]);
  }

  Future<int> clearUserConnections() async {
    var dbClient = await db;
    int res = await dbClient.delete(USER_CONNECTION_TABLE);

    // await deleteChatMessagePagination();
    // await deleteChatMessage();
    debugPrint("DATABASE:- UserConnection Cleared !!");
    return res;
  }

  Future<int> updateChatConversation(
      {required ChatConversation chatConversation}) async {
    Database dbClient = await db;

    return await dbClient.update(
        USER_CONNECTION_TABLE, chatConversation.toDBJson(),
        where: "conversation_id = ?",
        whereArgs: [chatConversation.conversationId]);
  }

  Future<int> deleteChatConversation({String? conversationId}) async {
    var dbClient = await db;
    int res = await dbClient.delete(USER_CONNECTION_TABLE,
        where: "conversation_id = ?", whereArgs: [conversationId]);
    debugPrint("UserConnection $conversationId is Deleted !!");
    await deleteSingleChatUsers(conversationId: conversationId);
    await deleteSingleUserChatMessage(conversationId: conversationId);
    return res;
  }

  Future<ChatConversation?> getLastChatConversation(
      {String? conversationId}) async {
    Database dbClient = await db;

    List<Map<String, dynamic>> res = await dbClient.query(USER_CONNECTION_TABLE,
        orderBy: "created_at DESC", limit: 1);

    if (res.length > 0) {
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

      insertUserBatch.insert(CHAT_MESSAGE_TABLE, data,
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
        "SELECT * FROM $CHAT_MESSAGE_TABLE WHERE id IN $secondRemove ORDER BY created_at DESC");

    if (result.length > 0) {
      List<ChatMessage> chatMessages = result.map((element) {
        // debugPrint(
        //     "ELEMENT ID:- ${element['id']} TEXT ${element['text']} CREATED AT:- ${convertMillisecondsSinceEpochToString(element['created_at'])}");
        return ChatMessage.fromDBJson(element);
      }).toList();
      return chatMessages;
    }
    return [];
  }

  Future<List> insertMissedMessages(List<ChatMessage> chatMessages) async {
    Database dbClient = await db;

    Batch insertUserBatch = dbClient.batch();

    chatMessages.forEach((chatMessage) {
      Map<String, dynamic> data = chatMessage.toDBJson();

      insertUserBatch.insert(CHAT_MESSAGE_TABLE, data,
          conflictAlgorithm: ConflictAlgorithm.replace);
    });

    List<dynamic> result = await insertUserBatch.commit();

    debugPrint("Batch Result:- $result");

    return result;
  }

  Future<int> insertMissedMessage(ChatMessage chatMessage) async {
    Database dbClient = await db;

    List<Map<String, dynamic>> res = await dbClient.query(CHAT_MESSAGE_TABLE,
        where: "conversation_id = ? AND check_id = ?",
        whereArgs: [chatMessage.conversationId, chatMessage.checkId]);

    if (res.length > 0) {
      int result = await dbClient.update(
          CHAT_MESSAGE_TABLE, chatMessage.toDBJson(),
          where: "conversation_id = ? AND check_id = ?",
          whereArgs: [chatMessage.conversationId, chatMessage.checkId]);
      debugPrint("MISSED MESSAGE UPDATED $result");
      return 0;
    } else {
      int result =
          await dbClient.insert(CHAT_MESSAGE_TABLE, chatMessage.toDBJson());
      debugPrint("MISSED MESSAGE INSERTED $result");
      return 1;
    }
  }

  Future<List<ChatMessage>> getChatMessages(
      {required ChatConversation chatConversation}) async {
    Database dbClient = await db;

    List<Map<String, dynamic>> res = await dbClient.query(CHAT_MESSAGE_TABLE,
        orderBy: "created_at DESC",
        where: "conversation_id = ?",
        whereArgs: [chatConversation.conversationId]);

    if (res.length > 0) {
      List<ChatMessage> chatMessages = res.map((element) {
        return ChatMessage.fromDBJson(element);
      }).toList();
      return chatMessages;
    }
    return [];
  }

  Future<List<ChatMessage>> getLimitedChatMessages(
      {String? conversationId, int? limit = 10}) async {
    Database dbClient = await db;

    List<Map<String, dynamic>> res = await dbClient.query(CHAT_MESSAGE_TABLE,
        orderBy: "created_at DESC",
        where: "conversation_id = ? AND delivered = ?",
        whereArgs: [conversationId, 1],
        limit: limit);

    if (res.length > 0) {
      List<ChatMessage> chatMessages = res.map((element) {
        return ChatMessage.fromDBJson(element);
      }).toList();
      return chatMessages;
    }
    return [];
  }

  Future<int> deleteChatMessages() async {
    Database dbClient = await db;
    int res = await dbClient.delete(CHAT_MESSAGE_TABLE);
    await deleteChatMessagePagination();
    return res;
  }

  Future<int> deleteChatMessage(String? checkId, String? conversationId) async {
    Database dbClient = await db;
    int res = await dbClient.delete(CHAT_MESSAGE_TABLE,
        where: "conversation_id = ? AND check_id = ?",
        whereArgs: [conversationId, checkId]);
    return res;
  }

  Future<int> updateEditedChatMessage(String? checkId, String? conversationId,
      bool? wasEdited, String? text) async {
    Database dbClient = await db;
    var result = await dbClient.update(CHAT_MESSAGE_TABLE,
        {"was_edited": wasEdited == true ? 1 : 0, "text": text},
        where: "conversation_id = ? AND check_id = ?",
        whereArgs: [conversationId, checkId]);
    return result;
  }

  Future<int> deleteSingleUserChatMessage({String? conversationId}) async {
    var dbClient = await db;
    int res = await dbClient.delete(CHAT_MESSAGE_TABLE,
        where: "conversation_id = ?", whereArgs: [conversationId]);
    debugPrint("DATABASE:- ChatMessage $conversationId is Deleted !!");

    await deleteSingleChatMessagePagination(conversationId: conversationId);
    return res;
  }

  Future<int> updateChatMessageReadByRecipient(
      String? checkId, String? conversationId) async {
    Database dbClient = await db;
    var result = await dbClient.update(
        CHAT_MESSAGE_TABLE, {"read_by_recipient": 1, "delivered": 1},
        where: "conversation_id = ? AND check_id = ?",
        whereArgs: [conversationId, checkId]);

    return result;
  }

  Future<int> updateChatMessageDeliverStatus(
      String? checkId, String? conversationId) async {
    if (checkId == null || conversationId == null) return 0;
    Database dbClient = await db;
    var result = await dbClient.update(CHAT_MESSAGE_TABLE, {"delivered": 1},
        where: "conversation_id = ? AND check_id = ?",
        whereArgs: [conversationId, checkId]);

    return result;
  }

  Future<int> insertSingleChatMessage(ChatMessage chatMessage) async {
    Database dbClient = await db;

    List<Map<String, dynamic>> res = await dbClient.query(CHAT_MESSAGE_TABLE,
        where: "conversation_id = ? AND check_id = ?",
        whereArgs: [chatMessage.conversationId, chatMessage.checkId]);

    if (res.length > 0) {
      int result = await dbClient.update(
          CHAT_MESSAGE_TABLE, chatMessage.toDBJson(),
          where: "conversation_id = ? AND check_id = ?",
          whereArgs: [chatMessage.conversationId, chatMessage.checkId]);
      debugPrint("MISSED MESSAGE UPDATED $result");
      return 0;
    } else {
      int result =
          await dbClient.insert(CHAT_MESSAGE_TABLE, chatMessage.toDBJson());
      debugPrint("MISSED MESSAGE INSERTED $result");
      return 1;
    }
  }

  Future<List<ChatMessage>?> getLastChatMessage() async {
    Database dbClient = await db;

    // List<Map<String, dynamic>> res = await dbClient.query(
    //   "ChatMessage",
    //   where: "delivered = ?",
    //   whereArgs: [1],
    //   orderBy: "created_at DESC",
    //   groupBy: "conversation_id",
    // );

    List<Map<String, dynamic>> res = await dbClient.rawQuery(
        "SELECT * FROM $CHAT_MESSAGE_TABLE where delivered=? order by created_at DESC;",
        [1]);

    if (res.length > 0) {
      var newMap = groupBy(res, (dynamic obj) => obj['conversation_id']);
      // debugPrint("==> $newMap");
      List<Map<String, dynamic>> messages = [];
      newMap.forEach((key, value) {
        messages.add(value[0]);
      });

      List<ChatMessage> chatMessages = [];
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
    var result = await dbClient.update(
        CHAT_MESSAGE_TABLE, chatMessage.toDBJson(),
        where: "conversation_id = ? AND check_id = ?",
        whereArgs: [chatMessage.conversationId, chatMessage.checkId],
        conflictAlgorithm: ConflictAlgorithm.replace);
    if (result == 0) {
      await dbClient.insert("ChatMessage", chatMessage.toDBJson());
    }
    return result;
  }

  ///save ChatMessagePagination

  Future<int> saveChatMessagePagination(
      ChatMessagePagination chatMessagePagination) async {
    Database dbClient = await db;

    int res = await dbClient.insert(
        CHAT_MESSAGE_PAGINATION_TABLE, chatMessagePagination.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore);

    debugPrint("DATABASE:- Save ChatMessagePagination !!");

    return res;
  }

  Future<ChatMessagePagination> getChatMessagePagination(
      String? conversationId) async {
    Database dbClient = await db;

    List<Map<String, dynamic>> result = await dbClient.query(
        CHAT_MESSAGE_PAGINATION_TABLE,
        where: "conversation_id = ?",
        whereArgs: [conversationId]);

    if (result.length > 0) {
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
        CHAT_MESSAGE_PAGINATION_TABLE, chatMessagePagination.toJson(),
        where: "conversation_id = ?",
        whereArgs: [chatMessagePagination.conversationId]);
  }

  Future<int> deleteChatMessagePagination() async {
    Database dbClient = await db;
    int res = await dbClient.delete(CHAT_MESSAGE_PAGINATION_TABLE);
    return res;
  }

  Future<int> deleteSingleChatMessagePagination(
      {String? conversationId}) async {
    var dbClient = await db;
    int res = await dbClient.delete(CHAT_MESSAGE_PAGINATION_TABLE,
        where: "conversation_id = ?", whereArgs: [conversationId]);
    debugPrint(
        "DATABASE:- ChatMessagePagination $conversationId is Deleted !!");
    return res;
  }

  /// VirtualAccount OPERATION

  Future<int?> saveVirtualAccount(VirtualAccount virtualAccount) async {
    Database dbClient = await db;

    int res = await dbClient.insert(
        VIRTUAL_ACCOUNT_TABLE, virtualAccount.toDBJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore);

    debugPrint("DATABASE:- Saved Virtual Account !!");
    return res;
  }

  Future<VirtualAccount?> getVirtualAccount() async {
    Database dbClient = await db;

    List<Map<String, dynamic>> virtualAccounts =
        await dbClient.query(VIRTUAL_ACCOUNT_TABLE);
    if (virtualAccounts.length > 0)
      return VirtualAccount.fromDBJson(virtualAccounts.first);
    return null;
  }

  Future<int?> deleteVirtualAccount() async {
    Database dbClient = await db;

    int res = await dbClient.delete(VIRTUAL_ACCOUNT_TABLE);

    debugPrint("DATABASE:- DELETE VirtualAccount !!");
    return res;
  }

  /// GeneralSettings OPERATION

  Future<int?> saveGeneralSettings(Map<String, dynamic> data) async {
    Database dbClient = await db;

    int res = await dbClient.insert(APP_SETTING_TABLE, data,
        conflictAlgorithm: ConflictAlgorithm.ignore);

    debugPrint("DATABASE:- Saved GeneralSettings !!");
    return res;
  }

  Future<int?> updateGeneralSettings(Map<String, dynamic> data) async {
    Database dbClient = await db;

    int res = await dbClient.update(APP_SETTING_TABLE, data);

    debugPrint("DATABASE:- Update GeneralSettings !!");
    return res;
  }

  Future<Map<String, dynamic>> getGeneralSettings() async {
    Database dbClient = await db;

    List<Map<String, dynamic>> generalSettings =
        await dbClient.query(APP_SETTING_TABLE);
    if (generalSettings.length > 0) {
      return generalSettings.first;
    }
    return Future.value({});
  }

  Future<int?> deleteGeneralSettings() async {
    Database dbClient = await db;

    int res = await dbClient.delete(APP_SETTING_TABLE);

    debugPrint("DATABASE:- DELETE GeneralSettings !!");
    return res;
  }

  /// Fee structure operations

  // save user's fee structure to the db
  Future<int> saveFeeStructure(FeeStructure feeStructure) async {
    var dbClient = await db;
    await deleteFeeStructure();
    int res = await dbClient.insert(FEE_STRUCTURE, feeStructure.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    debugPrint("DATABASE:- $FEE_STRUCTURE saved to db");
    return res;
  }

  // Delete the fee structure from the db
  Future<int> deleteFeeStructure() async {
    var dbClient = await db;
    int res = await dbClient.delete(FEE_STRUCTURE);
    debugPrint("DATABASE:- $FEE_STRUCTURE deleted from db");
    return res;
  }

  // Get current user's fee structure from db
  Future<FeeStructure?> getFeeStructure() async {
    Database dbClient = await db;

    List<Map<String, dynamic>> feeStructure =
        await dbClient.query(FEE_STRUCTURE);
    if (feeStructure.length > 0)
      return FeeStructure.fromJson(feeStructure.first);
    return null;
  }

  Future<int> saveDocumentFileInChat(
      DocumentFileInChatDownloadModel model) async {
    Database dbClient = await db;

    int res = await dbClient.insert(
        DOCUMENT_FILE_IN_CHAT_DOWNLOAD_TABLE, model.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore);

    debugPrint(
        "DOCUMENT FILE DATABASE:- Save $DOCUMENT_FILE_IN_CHAT_DOWNLOAD_TABLE !!");

    return res;
  }
}
