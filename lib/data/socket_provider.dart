import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_synchronizer.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/connection_list_synchronizer.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/db_socket_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/SocketQueueChatMessage.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class MainSocketProvider extends ChangeNotifier {
  static IOWebSocketChannel? _channel;

  static User? _currentUser;
  static Map<String, String>? _headers;
  static String? _currentConversationId;

  static bool _isChatOnScreen = false;

  bool get isChatOnScreen => _isChatOnScreen;

  static List<StreamSubscription?> _streamSubscriptions = [];

  /// Queue for the messages which users sends in to the socket
  static List<String> _queueMessages = [];

  /// Variable for listening the internet connections
  static bool? _isNetworkConnectionIsOn;
  bool? get isNetworkOn => _isNetworkConnectionIsOn;
  static bool _isFirstTime = true;
  static StreamSubscription? networkConnectionSubscription;

  set isChatOnScreen(bool value) {
    _isChatOnScreen = value;
    notifyListeners();
  }

  List<String> get queueMessages => _queueMessages;

  String? get currentConversationId => _currentConversationId;

  set currentConversationId(String? value) {
    _currentConversationId = value;
    notifyListeners();
  }

  /// Reconnect server variables
  static bool _isConnected = false;
  static Timer? _timerForRetryConnection;
  static int _numberOfRetry = 30;
  static int _countRetry = 0;
  static Duration _connectionRetryDuration = Duration(seconds: 3);

  User? get currentUser => _currentUser;

  /// ping server variables
  static Timer? _timerForPingServer;
  static Duration _pingInterval = Duration(seconds: 2);
  static DateTime _lastSent = DateTime.now();
  static DateTime _lastReceive = DateTime.now();
  static Duration _socketTimeout = Duration(seconds: Platform.isIOS ? 2 : 1);
  static int pingCount = 0;

  // set currentUser(User? value) {
  //   _currentUser = value;
  //   connect();
  //   notifyListeners();
  //   setupNetworkConnectionListener();
  // }

  Future<void> setCurrentUser(User? value) async {
    _currentUser = value;
    try {
      await connect();
      setupNetworkConnectionListener();
    } catch (error) {
      return Future.error("Something went wrong");
    }
    notifyListeners();
    return Future.value();
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
            await connect().then((value) async {
              if (_isConnected) {
                try {
                  bool result = await addDataInTheCorrectOrder();
                  if (result) {
                    debugPrint("Clearing Pending Messages 1!!");
                    _queueMessages.clear();
                  }
                } catch (error) {
                  debugPrint(
                      "Failed to Clear Pending Messages  Web Socket is Not connected1!!");
                }
              } else {
                debugPrint(
                    "Failed to Clear Pending Messages  Web Socket is Not connected2!!");
              }
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

  StreamController? _streamController;

  Stream? get socketStream => _streamController?.stream;
  StreamSubscription? streamSubscription;

  IOWebSocketChannel? get channel => _channel;

  /// this function will continually call periodically ping method to send
  /// ping to the server we need to call it when socket connection established
  /// in order to keep socket connection alive
  void pingServer() {
    if (_timerForPingServer?.isActive ?? false) {
      _timerForPingServer!.cancel();
    }

    /// for reconnection the socket as define
    _timerForPingServer = Timer.periodic(_pingInterval, (time) {
      ping();
    });
  }

  /// this method will ping the server
  void ping() async {
    var currentTime = DateTime.now();

    /// only ping server when there is no user activity is done with in _socketTimeout time
    if (currentTime.difference(_lastSent) > _socketTimeout &&
        currentTime.difference(_lastReceive) > _socketTimeout) {
      var data = {
        "message": "ping",
        "type": "ping",
      };

      try {
        if (_isConnected) {
          _channel!.sink.add(jsonEncode(data));
          _lastSent = DateTime.now();

          print(
              "ping sent ${++pingCount} Status Code:  ${_channel?.closeCode} Reason: ${_channel?.closeReason}!!");
          _isConnected = false;
        } else {
          throw Exception(
              "Not Connected Status Code:  ${_channel!.closeCode} Reason: ${_channel!.closeReason}");
        }
      } catch (e) {
        print("ERROR:- $e ");

        _numberOfRetry = 0;
        _isConnected = false;

        await connect().then((value) async {
          _channel!.sink.add(jsonEncode(data));
          _lastSent = DateTime.now();
          print(
              "ping Done ${++pingCount} Status Code:  ${_channel?.closeCode} Reason: ${_channel?.closeReason}!!");
          pingCount = 0;
          _isConnected = false;
          ChatMessageSynchronizer().updateFetchStream(isFetching: true);

          ///TODO: UNCOMMENT THIS WHEN IT IS DONE
          await ConnectionSynchronizer().update();
          // await ChatMessageSynchronizer().updateMessages();
          await ChatMessageSynchronizer().syncMessages(fetchFresh: true);
          ChatMessageSynchronizer().updateFetchStream(isFetching: false);
        });
      }
    }
  }

  /// for connecting the user socket
  Future<void> connect() async {
    _isConnected = false;

    /// change socket url according to recipient user url
    // var finalUrl = "$_socketUrl";
    var finalUrl = "${AppConfig.socketUrl}/${_currentUser!.userName}/";

    // Set auth headers or socket will be closed
    _headers = await MessageAuth().getAuthHeaders();

    log("$_headers");

    /// for connecting the socket
    try {
      _channel = IOWebSocketChannel.connect(
        finalUrl,
        headers: _headers,
      );

      _streamController?.close();
      _streamController = StreamController.broadcast();

      debugPrint(
          "WebSocket Connected to $finalUrl for user ${currentUser!.userName}");
      _isConnected = true;

      notifyListeners();
    } catch (e) {
      debugPrint(
          "ERROR:- While connecting WebSocket for user ${currentUser!.userName}");
      await reconnectSocket();
    }

    /// for listening message in the Socket
    if (_isConnected) {
      debugPrint("Listener called!!");

      try {
        _streamController!.addStream(_channel!.stream);
      } catch (error) {
        debugPrint("Stream is already in Adding state $error");
      }
      notifyListeners();

      streamSubscription?.cancel();
      streamSubscription = _streamController!.stream.listen((message) {
        _isConnected = true;

        /// listen every message from the socket
        // if (message['type'] != "pong") {
        //
        // }
        debugPrint(
            "Got Message on main socket:- $message  LastReceive = $_lastReceive");

        _lastReceive = DateTime.now();
      })
        ..onError((error) async {
          /// if there is any error while listing the socket

          _isConnected = false;
          debugPrint(
              "ERROR:- While listening the Socket $error Status Code:  ${_channel?.closeCode} Reason: ${_channel?.closeReason}");
          await reconnectSocket();
        })
        ..onDone(() {
          debugPrint(
              "On Done called:-  Socket Closed !!!! Status Code:  ${_channel?.closeCode} Reason: ${_channel?.closeReason}");
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
  Future<void> reconnectSocket() async {
    if (_isConnected) {
      _timerForRetryConnection?.cancel();
    }
    if (_timerForRetryConnection?.isActive ?? false) {
      _timerForRetryConnection!.cancel();
    }

    /// for reconnection the socket as define

    if (_countRetry < _numberOfRetry) {
      _timerForRetryConnection = Timer(_connectionRetryDuration, () async {
        if (!_isConnected) {
          _countRetry++;
          debugPrint("Trying to reconnect $_countRetry!! ");

          await connect();
        } else {
          _timerForRetryConnection!.cancel();
        }
      });
    } else {
      _timerForRetryConnection?.cancel();
      _countRetry = 0;
    }
    notifyListeners();
  }

  /// for listening the user socket
  StreamSubscription? listen(Function(dynamic event) listener) {
    StreamSubscription? newStreamSubscription =
        _streamController?.stream.listen(listener);
    _streamSubscriptions.add(newStreamSubscription);
    notifyListeners();

    return newStreamSubscription;
  }

  /// from remove listening subscriptions from socket
  void removeStreamSubscription(StreamSubscription? streamSubscription) {
    _streamSubscriptions.forEach((element) {
      if (element == streamSubscription) {
        element?.cancel();
        // debugPrint("Stream Subscription removed successfully !");
      }
    });
  }

  /// for adding data into user socket
  Future<bool> add(Map<String, dynamic> data) async {
    bool isDataAlreadyInQueue = false;
    String _data = jsonEncode(data);

    for (int i = 0; i < _queueMessages.length; i++) {
      if (_data == _queueMessages[i]) {
        isDataAlreadyInQueue = true;
        break;
      }
    }

    if (!isDataAlreadyInQueue) {
      _queueMessages.add(_data);
    }

    return await addDataInTheCorrectOrder();
  }

  /// adding all the queue data to the socket when socket connection is alive
  /// if socket connection is not alive then it will reconnect the socket and send
  /// all the data in correct order
  Future<bool> addDataInTheCorrectOrder() async {
    try {
      if (_isConnected) {
        _queueMessages.forEach((message) {
          _channel!.sink.add(message);
        });

        _lastSent = DateTime.now();
        pingCount = 0;
        debugPrint("Data added in webSocket :- $_queueMessages");

        if (await checkConnection()) {
          debugPrint("Clearing Pending Messages 2!!");
          _queueMessages.clear();
        } else {
          debugPrint("Failed to clear Pending Messages 1!!");
        }

        return true;
      } else {
        throw Exception(
            "Not Connected Status Code:  ${_channel?.closeCode} Reason: ${_channel?.closeReason}");
      }
    } catch (e) {
      debugPrint(
          "ERROR:- While adding data in WebSocket for user ${currentUser!.userName}");

      _numberOfRetry = 0;
      _isConnected = false;

      await connect().then((value) async {
        _queueMessages.forEach((message) {
          _channel!.sink.add(message);
        });

        _lastSent = DateTime.now();
        pingCount = 0;
        debugPrint("Data added in webSocket :- $_queueMessages");
        if (await checkConnection()) {
          _queueMessages.clear();
        } else {
          debugPrint("Failed to clear Pending Messages 2!!");
        }

        return true;
      });
    }
    notifyListeners();
    return false;
  }

  void removeFromTheQueue({required String message}) {
    Map<String, dynamic> decodedMessage = jsonDecode(message);
    if (decodedMessage.containsKey("check_id")) {
      int? index;

      for (int i = 0; i < _queueMessages.length; i++) {
        Map<String, dynamic> decodeQueueMessage = jsonDecode(_queueMessages[i]);

        if (decodeQueueMessage.containsKey("check_id")) {
          if (decodeQueueMessage["check_id"] == decodedMessage["check_id"]) {
            if (_queueMessages[i] == message) {
              index = i;
              break;
            }
            break;
          }
        }
      }

      if (index != null) {
        _queueMessages.removeAt(index);
        notifyListeners();
      }
    }
  }

  void sendPendingQueueMessages() async {
    List<SocketQueueChatMessage> pendingMessages =
        await DBSocketMessageHandler().getSocketQueueChatMessage();

    int count = 0;
    for (int i = 0; i < pendingMessages.length; i++) {
      count++;
      await add(pendingMessages[i].toJson(isForSendingToSocket: true));
    }

    debugPrint("Sending $count Pending Text Message !!");
  }

  void deleteQueueMessagesForSpecificConversation({String? conversationId}) {
    List<int> messagesIndex = [];
    for (int i = 0; i < _queueMessages.length; i++) {
      Map<String, dynamic> message = jsonDecode(_queueMessages[i]);

      if (message.containsKey("conversation_id")) {
        if (message['conversation_id'] == conversationId) {
          messagesIndex.add(i);
        }
      }
    }

    if (messagesIndex.isNotEmpty) {
      debugPrint("Messages related To Conversation id found at $messagesIndex");
      messagesIndex.forEach((element) {
        _queueMessages.removeAt(element);
      });
    }
  }

  /// checking internet connectivity
  Future<bool> checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return true;
  }

  /// for closing all the subscriptions which are alive
  Future<void> close() async {
    _timerForRetryConnection?.cancel();
    _timerForPingServer?.cancel();

    for (int i = 0; i < _streamSubscriptions.length; i++) {
      await _streamSubscriptions[i]?.cancel();
    }

    _queueMessages.clear();

    await networkConnectionSubscription?.cancel();
    _streamController = null;

    _channel = null;
    debugPrint(
        "WebSocket disconnected to ${AppConfig.socketUrl} for user ${currentUser?.userName}");
    notifyListeners();
  }
}
