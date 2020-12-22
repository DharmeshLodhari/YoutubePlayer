import 'dart:convert';

import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class SocketProvider extends ChangeNotifier {
  IOWebSocketChannel _channel;

  User currentUser;

  SocketProvider({@required this.currentUser});

  IOWebSocketChannel get channel => _channel;

  /// for connecting the user socket
  void connect() {
    try {
      String socketUrl = "wss://echo.websocket.org";
      // String socketUrl = "wss://slydo.co/user/${currentUser.userName}";
      _channel = IOWebSocketChannel.connect(socketUrl);
      debugPrint(
          "WebSocket Connected to $socketUrl for user ${currentUser.userName}");

      _channel.stream.listen((event) {
        debugPrint("Data from user socket:- $event");
      });
    } catch (e) {
      debugPrint(
          "ERROR:- While connecting WebSocket for user ${currentUser.userName}");
    }
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
}
