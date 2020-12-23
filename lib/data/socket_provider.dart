import 'dart:convert';

import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class SocketProvider extends ChangeNotifier {
  IOWebSocketChannel _channel;

  User _currentUser;

  String _socketUrl = "wss://echo.websocket.org";

  SocketProvider();

  User get currentUser => _currentUser;

  set currentUser(User value) {
    _currentUser = value;
    connect();
    notifyListeners();
  }

  IOWebSocketChannel get channel => _channel;

  /// for connecting the user socket
  void connect() {
    try {
      // String socketUrl = "wss://slydo.co/user/${currentUser.userName}";
      _channel = IOWebSocketChannel.connect(_socketUrl);
      debugPrint(
          "WebSocket Connected to $_socketUrl for user ${currentUser.userName}");

      _channel.stream.listen((event) {
        debugPrint("Data from user socket:- $event");
      });
    } catch (e) {
      debugPrint(
          "ERROR:- While connecting WebSocket for user ${currentUser.userName}");
    }
    notifyListeners();
  }

  /// for listening the user socket
  void listen(Function(dynamic event) listener) {
    _channel.stream.listen(listener);
  }

  /// for adding data into user socket
  void add(Map<String, dynamic> data) {
    String _data = jsonEncode(data);
    try {
      _channel.sink.add(_data);
      debugPrint("Data added in webSocket :- $_data");
    } catch (e) {
      debugPrint(
          "ERROR:- While adding data in WebSocket for user ${currentUser.userName}");
    }
  }

  void close() {
    _channel.sink.close();
    _channel = null;
    debugPrint(
        "WebSocket disconnected to $_socketUrl for user ${currentUser.userName}");
    notifyListeners();
  }
}
