import 'dart:async';
import 'dart:convert';

import 'package:Slydo/screens/more_apps/messaging/chat/helpers/db_socket_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatTextMessage.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class MainSocketProvider extends ChangeNotifier {
  IOWebSocketChannel _channel;

  User _currentUser;
  String _socketUrl = "wss://slydo.co/ws/main";
  var _headers;
  String _currentConversationId;

  static bool _isChatOnScreen = false;

  bool get isChatOnScreen => _isChatOnScreen;

  static List<StreamSubscription> _streamSubscriptions = [];

  static List<String> _queueMessages = [];

  bool _isNetworkConnectionIsOn;

  bool get isNetworkOn => _isNetworkConnectionIsOn;
  static bool _isFirstTime = true;
  static StreamSubscription networkConnectionSubscription;

  set isChatOnScreen(bool value) {
    _isChatOnScreen = value;
    notifyListeners();
  }

  String get currentConversationId => _currentConversationId;

  set currentConversationId(String value) {
    _currentConversationId = value;
    notifyListeners();
  }

  /// Reconnect server variables
  static bool _isConnected = false;
  static Timer _timerForRetryConnection;
  static int _numberOfRetry = 30;
  static int _countRetry = 0;
  static Duration _connectionRetryDuration = Duration(seconds: 3);

  User get currentUser => _currentUser;

  /// ping server variables
  static Timer _timerForPingServer;
  static Duration _timePeriodForSecond = Duration(seconds: 20);
  static DateTime _lastSent = DateTime.now();
  static DateTime _lastReceive = DateTime.now();
  static Duration _socketTimeout = Duration(seconds: 19);

  set currentUser(User value) {
    _currentUser = value;
    connect();
    notifyListeners();
    setupNetworkConnectionListener();
  }

  /// This is a network connection listener which is continuously listening
  /// internet connection when user login in the app it will check a internet connection
  /// and set _isFirstTime to false so now whenever user disconnected from the internet and
  /// connect is back it will reconnect the socket and send all the messages of queue
  /// to the socket.
  void setupNetworkConnectionListener() {
    networkConnectionSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.none) {
        _isNetworkConnectionIsOn = false;
        notifyListeners();
      } else {
        _isNetworkConnectionIsOn = true;
        if (_isFirstTime) {
          _isFirstTime = false;
        } else {
          if (_queueMessages.isNotEmpty) {
            debugPrint("Clearing Pending Messages !!");
            // _streamSubscriptions.forEach((element) {
            //   element?.cancel();
            // });
            await connect().then((value) async {
              await addDataInTheCorrectOrder();
              _queueMessages.clear();
            });
          }
        }
        notifyListeners();
      }
      debugPrint("_isNetworkConnectionIsOn:- $_isNetworkConnectionIsOn");
    })
          ..onError((error) {
            debugPrint("ERROR:- while closing network status stream $error");
          });
  }

  StreamController _streamController;

  Stream get socketStream => _streamController?.stream;
  StreamSubscription streamSubscription;

  IOWebSocketChannel get channel => _channel;

  /// this function will continually call periodically ping method to send
  /// ping to the server we need to call it when socket connection established
  /// in order to keep socket connection alive
  void pingServer() {
    if (_timerForPingServer?.isActive ?? false) {
      _timerForPingServer.cancel();
    }

    /// for reconnection the socket as define
    _timerForPingServer = Timer.periodic(_timePeriodForSecond, (time) {
      ping();
    });
  }

  /// this method will ping the server
  void ping() async {
    var currentTime = DateTime.now();

    if (currentTime.difference(_lastSent) > _socketTimeout &&
        currentTime.difference(_lastReceive) > _socketTimeout) {
      var data = {
        "message": "ping",
        "type": "ping",
      };

      try {
        if (_isConnected) {
          _channel.sink.add(jsonEncode(data));
          _lastSent = DateTime.now();
          print("ping sent!!");
          _isConnected = false;
        } else {
          throw Exception("Not Connected");
        }
      } catch (e) {
        print("ERROR:- $e");

        _numberOfRetry = 0;
        _isConnected = false;

        await connect().then((value) async {
          _channel.sink.add(jsonEncode(data));
          _lastSent = DateTime.now();
          print("ping Done!!");
          _isConnected = false;
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
      _channel = IOWebSocketChannel.connect(
        finalUrl,
        headers: _headers,
      );
      _streamController = StreamController.broadcast();
      notifyListeners();
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
      notifyListeners();

      streamSubscription?.cancel();
      streamSubscription = _streamController.stream.listen((message) {
        _isConnected = true;

        /// listen every message from the socket
        debugPrint(
            "Got Message on main socket:- $message  LastReceive = $_lastReceive");

        _lastReceive = DateTime.now();
      })
        ..onError((error) {
          /// if there is any error while listing the socket

          _isConnected = false;
          debugPrint("ERROR:- While listening the Socket $error");
          reconnectSocket();
        })
        ..onDone(() {
          debugPrint("On Done called:-  Socket Closed !!!!");
          _isConnected = false;
        });
      _streamSubscriptions.add(streamSubscription);
    }

    if (_isConnected) {
      pingServer();
      sendPendingQueueMessages();
    }

    notifyListeners();
  }

  /// for reconnection the socket connection
  void reconnectSocket() {
    if (_isConnected) {
      _timerForRetryConnection?.cancel();
    }
    if (_timerForRetryConnection?.isActive ?? false) {
      _timerForRetryConnection.cancel();
    }

    /// for reconnection the socket as define

    if (_countRetry < _numberOfRetry) {
      _timerForRetryConnection = Timer(_connectionRetryDuration, () async {
        if (!_isConnected) {
          _countRetry++;
          debugPrint("Trying to reconnect $_countRetry!! ");

          await connect();
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
  StreamSubscription listen(Function(dynamic event) listener) {
    StreamSubscription newStreamSubscription =
        _streamController?.stream?.listen(listener);
    _streamSubscriptions.add(newStreamSubscription);
    notifyListeners();

    return newStreamSubscription;
  }

  /// from remove listening subscription from socket
  void removeStreamSubscription(StreamSubscription streamSubscription) {
    _streamSubscriptions.forEach((element) {
      if (element == streamSubscription) {
        element.cancel();
        // debugPrint("Stream Subscription removed successfully !");
      }
    });
  }

  /// for adding data into user socket
  Future<bool> add(Map<String, dynamic> data) async {
    String _data = jsonEncode(data);

    _queueMessages.add(_data);

    return await addDataInTheCorrectOrder();
  }

  /// adding all the queue data to the socket when socket connection is alive
  /// if socket connection is not alive then it will reconnect the socket and send
  /// all the data in correct order
  Future<bool> addDataInTheCorrectOrder() async {
    try {
      if (_isConnected) {
        _queueMessages.forEach((message) {
          _channel.sink.add(message);
        });

        _lastSent = DateTime.now();
        debugPrint("Data added in webSocket :- $_queueMessages");

        if (await checkConnection()) {
          _queueMessages.clear();
        }

        return true;
      } else {
        throw Exception("Not Connected");
      }
    } catch (e) {
      debugPrint(
          "ERROR:- While adding data in WebSocket for user ${currentUser.userName}");

      _numberOfRetry = 0;
      _isConnected = false;

      await connect().then((value) async {
        _queueMessages.forEach((message) {
          _channel.sink.add(message);
        });

        _lastSent = DateTime.now();
        debugPrint("Data added in webSocket :- $_queueMessages");
        if (await checkConnection()) {
          _queueMessages.clear();
        }

        return true;
      });
    }
    notifyListeners();
    return false;
  }

  void sendPendingQueueMessages() async {
    List<ChatTextMessage> pendingMessages =
        await DBSocketMessageHandler().getChatTextMessage();

    int count = 0;
    pendingMessages.forEach((element) async {
      count++;
      await add(element.toJson(isForSendingToSocket: true));
    });

    debugPrint("Sending $count Pending Text Message !!");
  }

  /// checking internet connectivity
  Future<bool> checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return true;
  }

  /// for closing all the subscription which are alive
  Future<void> close() async {
    _timerForRetryConnection?.cancel();
    _timerForPingServer?.cancel();

    _streamSubscriptions.forEach((element) async {
      await element?.cancel();
    });

    await networkConnectionSubscription?.cancel();
    _streamController = null;

    _channel = null;
    debugPrint(
        "WebSocket disconnected to $_socketUrl for user ${currentUser.userName}");
    notifyListeners();
  }
}
