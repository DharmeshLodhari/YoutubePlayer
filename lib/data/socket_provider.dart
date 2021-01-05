import 'dart:async';
import 'dart:convert';

import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class MainSocketProvider extends ChangeNotifier {
  IOWebSocketChannel _channel;

  User _currentUser;
  String _socketUrl = "wss://slydo.co/ws/main";
  var _headers;

  bool _isConnected = false;
  Timer _timerForRetryConnection;
  int _numberOfRetry = 30;
  int _countRetry = 0;
  Duration _connectionRetryDuration = Duration(seconds: 3);

  User get currentUser => _currentUser;

  /// Reconnect server variables
  bool isConnected = false;
  int numberOfRetry = 30;
  int countRetry = 0;
  Duration connectionRetryDuration = Duration(seconds: 3);

  /// ping server variables
  Timer _timerForPingServer;
  Duration _timePeriodForSecond = Duration(seconds: 20);
  DateTime _lastSent = DateTime.now();
  DateTime _lastReceive = DateTime.now();
  Duration _socketTimeout = Duration(seconds: 19);

  set currentUser(User value) {
    _currentUser = value;
    connect();
    notifyListeners();
  }

  StreamController _streamController;

  Stream get socketStream => _streamController?.stream;

  IOWebSocketChannel get channel => _channel;

  void pingServer() {
    if (_timerForPingServer?.isActive ?? false) {
      _timerForPingServer.cancel();
    }

    /// for reconnection the socket as define
    _timerForPingServer = Timer.periodic(_timePeriodForSecond, (time) {
      ping();
    });
  }

  void ping() async {
    var currentTime = DateTime.now();

    if (currentTime.difference(_lastSent) > _socketTimeout &&
        currentTime.difference(_lastReceive) > _socketTimeout) {
      var data = {
        "message": "ping",
        "type": "ping",
      };

      try {
        if (isConnected) {
          channel.sink.add(jsonEncode(data));
          _lastSent = DateTime.now();
          isConnected = false;
          print("ping sent!!");
        } else {
          throw Exception("Not Connected");
        }
      } catch (e) {
        print("ERROR:- $e");

        numberOfRetry = 0;
        isConnected = false;

        await connect().then((value) {
          channel.sink.add(jsonEncode(data));
          _lastSent = DateTime.now();
          isConnected = false;
          print("ping Done!!");
        });
      }
    }
  }

  /// for connecting the user socket
  Future<void> connect() async {
    _isConnected = false;

    /// change socket url according to recipient user url
    // var finalUrl = "$_socketUrl";
    var finalUrl = "$_socketUrl/${_currentUser.userName}/";

    // Set auth headers or socket will be closed
    _headers = await MessageAuth().getAuthHeaders();

    /// for connecting the socket
    try {
      _channel = IOWebSocketChannel.connect(finalUrl, headers: _headers);
      _streamController = StreamController.broadcast();
      debugPrint(
          "WebSocket Connected to $finalUrl for user ${currentUser.userName}");
      _isConnected = true;
    } catch (e) {
      debugPrint(
          "ERROR:- While connecting WebSocket for user ${currentUser.userName}");
      reconnectSocket();
    }

    /// for listening message in the Socket
    if (_isConnected) {
      debugPrint("Listener called!!");
      _streamController.addStream(_channel.stream);

      _streamController.stream.listen((message) {
        /// listen every message from the socket
        debugPrint("Got Message on main socket:- $message");
      }).onError((error) {
        /// if there is any error while listing the socket

        _isConnected = false;
        debugPrint("ERROR:- While listening the Socket $error");
        reconnectSocket();
      });
    }

    notifyListeners();
  }

  void reconnectSocket() {
    if (_isConnected) {
      _timerForRetryConnection?.cancel();
    }
    if (_timerForRetryConnection?.isActive ?? false) {
      _timerForRetryConnection.cancel();
    }

    /// for reconnection the socket as define

    if (_countRetry < _numberOfRetry) {
      _timerForRetryConnection = Timer(_connectionRetryDuration, () {
        if (!_isConnected) {
          _countRetry++;
          debugPrint("Trying to reconnect $_countRetry!! ");

          connect();
        } else {
          _timerForRetryConnection.cancel();
        }
      });
    } else {
      _timerForRetryConnection?.cancel();
      _countRetry = 0;
    }
    notifyListeners();
  }

  /// for listening the user socket
  void listen(Function(dynamic event) listener) {
    _streamController.stream.listen(listener).onError((error) {
      /// if there is any error while listing the socket

      _isConnected = false;
      debugPrint("ERROR:- While listening the Socket $error");
      reconnectSocket();
    });
    notifyListeners();
  }

  /// for adding data into user socket
  void add(Map<String, dynamic> data) {
    String _data = jsonEncode(data);
    try {
      if (_isConnected) {
        _channel.sink.add(_data);
        debugPrint("Data added in webSocket :- $_data");
      } else {
        throw Exception("Not Connected");
      }
    } catch (e) {
      debugPrint(
          "ERROR:- While adding data in WebSocket for user ${currentUser.userName}");

      reconnectSocket();
      _channel.sink.add(_data);
      debugPrint("Data added in webSocket :- $_data");
    }
    notifyListeners();
  }

  void close() {
    _timerForRetryConnection?.cancel();

    _streamController = null;

    _channel = null;
    debugPrint(
        "WebSocket disconnected to $_socketUrl for user ${currentUser.userName}");
    notifyListeners();
  }
}
