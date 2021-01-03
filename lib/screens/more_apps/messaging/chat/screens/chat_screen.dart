import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/music/music_detail_page.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class ChatScreen extends StatefulWidget {
  final arguments;

  ChatScreen({this.arguments});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  /// Text message controller
  TextEditingController messageController;
  FocusNode messageFocus;

  /// Current chat users
  UserBloc userBloc;
  CustomerProfile recipientUser;

  /// Messages list variables
  List<String> messageList = [];
  bool isLoading = false;
  int count = 0;
  String next = "";
  String previous = "";

  /// Socket variables
  IOWebSocketChannel channel;
  String socketUrl = "wss://slydo.co/ws/chat";
  Map<String, dynamic> headers;

  /// Message scrolling variables
  ScrollController messageScrollController;
  bool fabIsVisible = false;

  /// Reconnect server variables
  bool isConnected = false;
  Timer _timerForRetryConnection;
  int numberOfRetry = 30;
  int countRetry = 0;
  Duration connectionRetryDuration = Duration(seconds: 3);

  /// ping server variables
  Timer _timerForPingServer;
  Duration _timePeriodForSecond = Duration(seconds: 20);
  DateTime _lastSent = DateTime.now();
  DateTime _lastReceive = DateTime.now();
  Duration _socketTimeout = Duration(seconds: 19);

  /// User typing state variables
  Timer _timerForUserTypingState;
  Duration userMessageTypingStateUpdateTime = Duration(seconds: 2);
  bool isRecipientTyping = false;

  /// Music Player
  AssetsAudioPlayer _audioPlayer = AssetsAudioPlayer();
  bool isAudioPlaying = false;

  /// User status
  String userStatus = "";

  @override
  void initState() {
    messageController = TextEditingController();
    messageFocus = FocusNode();
    recipientUser = widget.arguments["searchedUser"];

    connectSocket();

    setupScrollController();
    getUserStatus();
    pingServer();

    messageController.addListener(sendUserTypingState);
    messageController.addListener(searchUserProduct);

    fetchPreviousMessages();

    setupKeyboardFocusListener();

    super.initState();
  }

  @override
  void dispose() {
    _timerForUserTypingState?.cancel();
    _timerForRetryConnection?.cancel();
    _timerForPingServer?.cancel();

    _audioPlayer?.stop();
    _audioPlayer?.dispose();

    messageController.removeListener(sendUserTypingState);
    messageController.removeListener(searchUserProduct);

    messageController.dispose();

    try {
      channel.sink.close(status.goingAway);
      debugPrint("Socket Connection close for $socketUrl");
    } catch (e) {
      debugPrint("ERROR:- to close Socket Connection");
    }
    super.dispose();
  }

  Future<void> connectSocket() async {
    isConnected = false;

    /// change socket url according to recipient user url
    var finalUrl = "$socketUrl/${recipientUser.conversationId}/";

    // Set auth headers or socket will be closed
    if (headers == null) headers = await MessageAuth().getAuthHeaders();

    /// for connecting the socket
    try {
      channel = IOWebSocketChannel.connect(
        finalUrl,
        headers: headers,
        pingInterval: Duration(seconds: 1),
      );
      debugPrint("connected to $finalUrl ");
      isConnected = true;
    } catch (e) {
      debugPrint("Error to connect Web Socket !!!! ");
      reconnectSocket();
    }

    /// for listening message in the Socket
    if (isConnected) {
      debugPrint("Listener called!!");
      channel.stream.listen((message) {
        /// listen every message from the socket

        debugPrint("Got Message:- $message");
        determineMessageType(message);
      })
        ..onError((error) {
          /// if there is any error while listing the socket

          isConnected = false;
          debugPrint("ERROR:- While listening the Socket $error");
          reconnectSocket();
        })
        ..onDone(() async {
          debugPrint("On Done called:-  Socket Closed !!!!");

          if (mounted) {
            isConnected = false;

            /// fetching latest messages
            // count = 0;
            // next = "";
            // previous = "";
            // messageList.clear();
            // fetchPreviousMessages(showLoading: false);
          }
        });
    }
  }

  void reconnectSocket() {
    if (mounted) {
      if (isConnected) {
        _timerForRetryConnection?.cancel();
      }
      if (_timerForRetryConnection?.isActive ?? false) {
        _timerForRetryConnection.cancel();
      }

      /// for reconnection the socket as define

      if (countRetry < numberOfRetry) {
        _timerForRetryConnection = Timer(connectionRetryDuration, () {
          if (!isConnected) {
            countRetry++;
            debugPrint("Trying to reconnect $countRetry!! ");

            connectSocket();
          } else {
            _timerForRetryConnection.cancel();
          }
        });
      } else {
        _timerForRetryConnection?.cancel();
        countRetry = 0;
      }
    }
  }

  void pingServer() {
    if (mounted) {
      if (_timerForPingServer?.isActive ?? false) {
        _timerForPingServer.cancel();
      }

      /// for reconnection the socket as define
      _timerForPingServer = Timer.periodic(_timePeriodForSecond, (time) {
        ping();
      });
    }
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

        await connectSocket().then((value) {
          channel.sink.add(jsonEncode(data));
          _lastSent = DateTime.now();
          isConnected = false;
          print("ping Done!!");
        });
      }
      getUserStatus();
    }
  }

  void sendUserTypingState() {
    if (_timerForUserTypingState?.isActive ?? true) {
      userTyping();
    }
    if (messageController.text != "") {
      if (_timerForUserTypingState?.isActive ?? false) {
        _timerForUserTypingState.cancel();
      }

      _timerForUserTypingState = Timer(userMessageTypingStateUpdateTime, () {
        // userTyping();
        sendUserTypingState();
      });
    }
  }

  void searchUserProduct() {
    if (messageController.text.isNotEmpty) {
      if (messageController.text.toString().characters.first == '@') {
        debugPrint("i am @");
      }
    }
  }

  void setupScrollController() {
    messageScrollController = ScrollController();

    messageScrollController.addListener(() {
      /// when scroll view is at top
      if (messageScrollController.position.pixels ==
          messageScrollController.position.maxScrollExtent) {}

      /// when scroll view is at last
      if (messageScrollController.position.pixels ==
          messageScrollController.position.minScrollExtent) {
        fetchPreviousMessages();
      }

      /// for floating button to show scroll to bottom

      fabIsVisible = messageScrollController.position.userScrollDirection ==
          ScrollDirection.reverse;
      if (messageScrollController.position.pixels ==
          messageScrollController.position.maxScrollExtent) {
        fabIsVisible = false;
      }

      if (mounted) setState(() {});
    });
  }

  void setupKeyboardFocusListener() {
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        if (visible) {
          if (mounted) {
            Timer(
                Duration(milliseconds: 100),
                () => messageScrollController
                    .jumpTo(messageScrollController.position.maxScrollExtent));
          }
        }
      },
    );
  }

  void fetchPreviousMessages({bool showLoading = true}) async {
    debugPrint("Fetching previous messages !!");
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          if (showLoading) {
            isLoading = true;
            setState(() {});
          }
        }
        Map<String, dynamic> result = await MessageAuth().getChatMessages(
            next, previous,
            conversionId: recipientUser.conversationId);
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        List<String> tempList = result['results'];
        if (mounted) {
          setState(() {
            isLoading = false;
            bool isFirstTime;
            if (messageList.isEmpty) {
              isFirstTime = true;
            } else {
              isFirstTime = false;
            }

            messageList.insertAll(0, tempList.reversed);

            if (mounted) setState(() {});
            Future.delayed(Duration(milliseconds: 100)).then((value) {
              if (isFirstTime)
                scrollToBottom();
              else {
                scrollToTopWithTopSpace();
              }
            });
          });
        }
      }
      if (messageList.isEmpty) {
        if (mounted) {
          /// set flag if chat is empty
          setState(() {});
        }
      }
    }
  }

  void determineMessageType(String message) async {
    Map<String, dynamic> messageData = jsonDecode(message);
    _lastReceive = DateTime.now();
    isConnected = true;
    if (mounted) setState(() {});
    getUserStatus();

    switch (messageData['type']) {
      case "chatroom_message":
        checkMessageToAdd(message: message);

        break;

      case "user_typing_message":
        if (messageData['username'] != userBloc.user.userName) {
          isRecipientTyping = true;
          if (mounted) setState(() {});

          Future.delayed(Duration(seconds: 1)).then((value) {
            isRecipientTyping = false;
            if (mounted) setState(() {});
          });
        }
        break;
      case "pong":
        break;

      case "image":
        Future.delayed(Duration(microseconds: 300))
            .then((value) => scrollToBottom());
        break;

      case "transaction":
        Future.delayed(Duration(microseconds: 300))
            .then((value) => scrollToBottom());
        break;

      case "payment-request":
        Future.delayed(Duration(microseconds: 300))
            .then((value) => scrollToBottom());
        break;

      default:
        debugPrint("Message type:- ${messageData['type'] ?? messageData}");
    }
  }

  void checkMessageToAdd({String message}) {
    if (messageList.length > 0) {
      Map<String, dynamic> newMessage = jsonDecode(message);
      Map<String, dynamic> previousMessage = jsonDecode(messageList.last);

      debugPrint("new message :- ${newMessage['check_id']}");
      debugPrint("previousMessage message :- ${previousMessage['check_id']}");

      if (newMessage['check_id'] == previousMessage['check_id'] &&
          newMessage["text"] == previousMessage["text"]) {
        return;
      } else {
        addMessageToChat(message: message);
        scrollToBottom();
      }
    } else {
      addMessageToChat(message: message);
      scrollToBottom();
    }
  }

  void addMessageToChat({String message}) {
    messageList.add(message);

    if (mounted) setState(() {});

    Timer(
        Duration(milliseconds: 100),
        () => messageScrollController
            .jumpTo(messageScrollController.position.maxScrollExtent));
  }

  void userTyping() async {
    var data = {
      "message": "typing",
      "type": "user_typing_message",
    };

    try {
      if (!isConnected) {
        numberOfRetry = 0;
        isConnected = false;
        await connectSocket();
      }

      channel.sink.add(jsonEncode(data));
      _lastSent = DateTime.now();
    } catch (e) {
      debugPrint("ERROR:- $e");

      numberOfRetry = 0;
      isConnected = false;

      await connectSocket().then((value) {
        channel.sink.add(jsonEncode(data));
        _lastSent = DateTime.now();
      });
    }
  }

  void scrollToBottom() {
    debugPrint("Scrolling to Bottom");
    messageScrollController.animateTo(
        messageScrollController.position.maxScrollExtent,
        duration: Duration(microseconds: 100),
        curve: Curves.easeOut);
  }

  void scrollToTopWithTopSpace() {
    messageScrollController.animateTo(
        messageScrollController.position.minScrollExtent + 10,
        duration: Duration(microseconds: 100),
        curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: scaffoldBody(),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 48),
        child: AnimatedOpacity(
          child: FloatingActionButton(
            backgroundColor: dividerColor,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 28,
              color: blackFont,
            ),
            tooltip: "Increment",
            onPressed: scrollToBottom,
          ),
          duration: Duration(milliseconds: 100),
          opacity: fabIsVisible ? 1 : 0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/profile',
              arguments: {"searchedUser": recipientUser});
        },
        child: Row(
          children: [
            getUserIcon(),
            SizedBox(
              width: 8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipientUser.fullName,
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                ),
                Text(
                  isRecipientTyping ? "Typing.." : userStatus, //"Online",
                  style: TextStyle(
                    color: darkGrey,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                ),
              ],
            ),
          ],
        ),
      ),
      // actions: [
      //   userProfileIcon(),
      //   SizedBox(
      //     width: 16,
      //   )
      // ],
    );
  }

  void  getUserStatus() async {
    var data = await MessageAuth().getChatUserStatus(recipientUser.userName);

    print("userdata:$data");
    setState(() {
      if (data["status"] == "Online")
        {
          userStatus = "Online";
        }
      else{
        DateTime  now = new DateTime.now();
        DateTime today = new DateTime(now.year, now.month, now.day);
        DateTime yesterday = now.subtract(Duration(days: 1));

        DateTime lastSeenDateTime = DateTime.parse(data["last_seen"]);
        DateTime lastSeenDate = new DateTime(lastSeenDateTime.year, lastSeenDateTime.month, lastSeenDateTime.day);

        String lastSeenDateString = DateFormat("dd/MM/yyyy").format(lastSeenDateTime);
        String lastSeenTime = DateFormat("hh:mm a").format(lastSeenDateTime);

        if (today == lastSeenDate){
          userStatus = 'last seen today at ' + lastSeenTime;
          return;
        }

        if (yesterday == lastSeenDate){
          userStatus = 'last seen yesterday at ' + lastSeenTime;
          return;
        }
        //Todo: Add within last 7 day (last seen Monday at 1.30 AM)
        userStatus = 'last seen ' + lastSeenDateString + ' ' + lastSeenTime;
      }

    });
  }

  Widget getUserIcon() => Container(
        height: 36,
        width: 36,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: recipientUser.avatar == ""
                ? "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png"
                : recipientUser.avatar,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
            errorWidget: imageErrorWidget,
          ),
        ),
      );

  Widget userProfileIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.circle_user,
        size: 16,
        color: blackFont,
      ),
      onTap: () {},
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget messageActionBar() {
    return Card(
      elevation: 10,
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      child: Container(
        height: 58,
        padding: EdgeInsets.only(
          left: 16,
        ),
        child: Row(
          children: <Widget>[
            MediaQuery.of(context).viewInsets.bottom != 0
                ? addMediaButton()
                : Row(
                    children: [
                      requestMoneyBtn(),
                      SizedBox(
                        width: 8,
                      ),
                      sendMoneyBtn(),
                      SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
            Expanded(
              child: textMessageField(),
            ),
            sendMessageBtn(),
          ],
        ),
      ),
    );
  }

  Widget requestMoneyBtn() {
    return RoundedBackgroundIcon(
      borderRadius: 16,
      height: 44,
      width: 44,
      icon: Icon(
        SlydoAppIcon.receive,
        color: navyBlue,
        size: 22,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {
        var customerProfileBloc =
            Provider.of<CustomerProfileBloc>(context, listen: false);
        customerProfileBloc.customer =
            await UserAuth().fetchCustomerProfile(recipientUser.userName);
        Navigator.of(context).pushNamed(
          '/request-payment',
          arguments: <String, bool>{
            'isFromProfile': false,
            'isFromChat': true,
          },
        );
      },
    );
  }

  Widget sendMoneyBtn() {
    return RoundedBackgroundIcon(
      borderRadius: 16,
      height: 44,
      width: 44,
      icon: Icon(
        SlydoAppIcon.send,
        color: naturalGreen,
        size: 22,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {
        var customerProfileBloc =
            Provider.of<CustomerProfileBloc>(context, listen: false);
        customerProfileBloc.customer =
            await UserAuth().fetchCustomerProfile(recipientUser.userName);
        Navigator.of(context).pushNamed(
          '/send-payment',
          arguments: <String, bool>{
            'isFromProfile': false,
            'isFromChat': true,
          },
        );
      },
    );
  }

  Widget textMessageField() {
    return TextFormField(
      controller: messageController,
      textInputAction: TextInputAction.send,
      focusNode: messageFocus,
      onFieldSubmitted: (value) {
        sendMessage();
      },
      cursorColor: blackFont,
      cursorWidth: 1,
      cursorHeight: 20,
      cursorRadius: Radius.circular(16),
      decoration: InputDecoration(
        hintText: "Type message",
        hintStyle: TextStyle(
          color: darkGrey.withOpacity(0.5),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        prefix: Padding(
          padding: EdgeInsets.only(left: 12),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: navyBlue,
            width: 1.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  Widget addMediaButton() {
    return InkWell(
      onTap: addMediaToMessage,
      child: Container(
        padding: EdgeInsets.all(2),
        child: Row(
          children: [
            Icon(
              SlydoAppIcon.add_image,
              color: navyBlue,
              size: 22,
            ),
            SizedBox(
              width: 12,
            ),
          ],
        ),
      ),
    );
  }

  void addMediaToMessage() async {
    ImageSource imageSource = await selectMediaSource();
    if (imageSource == null) return;

    // FilePickerResult pickedMedia = await FilePicker.platform
    //     .pickFiles(allowMultiple: false, type: FileType.media);

    // if (pickedMedia != null) {
    //   File file = File(pickedMedia.files.single.path);

    // }

    PickedFile media = await ImagePicker().getImage(source: imageSource);

    if (media == null) return;

    var result = await Navigator.of(context).pushNamed(
      "/send-media-to-chat-message",
      arguments: {
        "data": {
          "conversation": recipientUser.conversationId,
          "author": userBloc.user.userName,
        },
        "media": File(media.path),
        "message": messageController.text.trim(),
      },
    ).catchError((error) {
      debugPrint("Error: = = = = $error");
    });

    if (result == null) return;

    messageController.text = "";
    debugPrint("Result:- $result");
  }

  Future<ImageSource> selectMediaSource() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    var source = await showModalBottomSheet<ImageSource>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    bottomSheetItem(
                      title: "Camera",
                      icon: Icons.camera_alt_rounded,
                      iconSize: 18,
                      onTap: () {
                        Navigator.pop(context, ImageSource.camera);
                      },
                    ),
                    bottomSheetItem(
                      title: "Gallery",
                      icon: SlydoAppIcon.image,
                      isLast: true,
                      onTap: () {
                        Navigator.pop(context, ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              ));
        });

    return source;
  }

  Widget sendMessageBtn() {
    return InkWell(
      onTap: sendMessage,
      child: Container(
        padding: EdgeInsets.all(2),
        child: Row(
          children: [
            SizedBox(
              width: 12,
            ),
            Icon(
              SlydoAppIcon.send_message,
              color: navyBlue,
              size: 22,
            ),
            SizedBox(
              width: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget renderDataAccordingType(String message) {
    // int randomInt = Random().nextInt(5);

    Map<String, dynamic> messageData = jsonDecode(message);

    String messageType = messageData["kind"];
    switch (messageType) {
      case "text":
        Widget getMessageUi = renderMessage(message: messageData);
        return getMessageUi;
        break;

      case "image":
        Widget getMessageUi = renderImageMedia(message: messageData);
        return getMessageUi;
        break;

      case "video":
        Widget getMessageUi = renderVideoMedia(message: messageData);
        return getMessageUi;
        break;

      case "audio":
        Widget getMessageUi = renderAudioMedia(message: messageData);
        return getMessageUi;
        break;

      case "transaction":
        Widget getPaymentUI = renderSendPayment(item: messageData);
        return getPaymentUI;

        break;
      case "payment-request":
        Widget getPaymentUI = renderPaymentRequest(message: messageData);
        return getPaymentUI;
        break;
      case "4":
        Widget getProductUI = renderProduct(message: messageData);
        return getProductUI;
        break;
      case "5":
        Widget getServiceUI = renderService(message: messageData);
        return getServiceUI;
        break;

      default:
        Widget getTypingUI = renderTypingMsg();
        return getTypingUI;
    }
  }

  void sendMessage() async {
    String message = messageController.text.trim();

    /// this is a second level of protection to ensure the connection
    /// this code of bloc is replicated in userTyping()
    if (!isConnected) {
      numberOfRetry = 0;
      isConnected = false;
      await connectSocket();
    }

    if (message.isEmpty) {
      return;
    }

    var data = {
      "check_id": Uuid().v4(),
      "conversation_id": recipientUser.conversationId,
      "author": userBloc.user.userName,
      "message": message,
      "kind": "text",
      "read_by_author": true,
      "created_at": DateTime.now().toUtc().toString(),
      "type": "chatroom_message",
    };

    try {
      if (isConnected) {
        channel.sink.add(jsonEncode(data));
        debugPrint("Data sent!!!");
        _lastSent = DateTime.now();
      } else {
        throw Exception("Not Connected");
      }
    } catch (e) {
      debugPrint("ERROR:- While adding data in WebSocket $e");

      numberOfRetry = 0;
      isConnected = false;
      await connectSocket().then((value) {
        channel.sink.add(jsonEncode(data));
        _lastSent = DateTime.now();
        debugPrint("Data added in webSocket :- $data");
      });
    }

    messageController.text = "";
    setState(() {});
  }

  Widget scaffoldBody() {
    // if (MediaQuery.of(context).viewInsets.bottom != 0) {
    //   scrollToBottom();
    // }
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Image.asset(
                        "assets/images/index_screen.png",
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                Theme(
                  data: ThemeData(highlightColor: navyBlue),
                  child: Scrollbar(
                    controller: messageScrollController,
                    radius: Radius.circular(10),
                    thickness: 3,
                    child: messageListBuilder(),
                  ),
                ),
              ],
            ),
          ),
          messageActionBar()
        ],
      ),
    );
  }

  Widget messageListBuilder() {
    return ListView.builder(
      controller: messageScrollController,
      padding: EdgeInsets.symmetric(vertical: 4),
      //+1 for progressbar
      itemCount: messageList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _buildIndicator();
        } else {
          return Container(
            child: renderDataAccordingType(messageList[index - 1]),
            padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
          );
        }
      },
    );
  }

  Widget _buildIndicator() {
    return isLoading
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Center(
              child: new Opacity(
                opacity: isLoading ? 1.0 : 00,
                child: CircularLoadingIndicator(),
              ),
            ),
          )
        : Container();
  }

  Widget renderMessage({Map<String, dynamic> message}) {
    bool isSend = message["author"] == userBloc.user.userName;
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(new ClipboardData(text: message['text']));
        Toast.show("Text copied !!", context,
            gravity: Toast.BOTTOM,
            duration: Toast.LENGTH_LONG,
            backgroundColor: navyBlue,
            textColor: Colors.white);
      },
      child: Row(
        mainAxisAlignment:
            isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.only(left: isSend ? 30 : 0, right: !isSend ? 30 : 0),
            child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSend ? navyBlue : chatBackgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(!isSend ? 0 : 10),
                    bottomRight: Radius.circular(isSend ? 0 : 10),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  message['text'],
                  style: TextStyle(
                      color: isSend ? Colors.white : blackFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                )),
          )
        ],
      ),
    );
  }

  String getDateTime(String dateAndTime) {
    DateTime requestTime = DateTime.parse(dateAndTime);
    String date = DateFormat("dd/MM/yyyy").format(requestTime);
    String time = DateFormat("hh:mm a").format(requestTime);
    return "$date • $time";
  }

  Widget renderImageMedia({Map<String, dynamic> message}) {
    bool isSend = message["author"] == userBloc.user.userName;
    String messageText = message['text'] ?? "";
    bool isMessageEmpty = messageText == "";

    return GestureDetector(
      onTap: () {
        var result = Navigator.of(context).pushNamed(
          "/view-chat-media",
          arguments: {
            "type": "image",
            "file": message['media'],
            "message": message['text']
          },
        );

        debugPrint("Result:- $result");
      },
      onLongPress: () {
        Clipboard.setData(
            new ClipboardData(text: message['text'] ?? message['media']));
        Toast.show("Text copied !!", context,
            gravity: Toast.BOTTOM,
            duration: Toast.LENGTH_LONG,
            backgroundColor: navyBlue,
            textColor: Colors.white);
      },
      child: Row(
        mainAxisAlignment:
            isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 1.35,
              minWidth: MediaQuery.of(context).size.width / 1.35,
            ),
            decoration: BoxDecoration(
              color: isSend ? navyBlue : chatBackgroundColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(!isSend ? 0 : 6),
                bottomRight: Radius.circular(isSend ? 0 : 6),
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            padding: EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  child: CachedNetworkImage(
                    height: MediaQuery.of(context).size.width / 1.35,
                    width: MediaQuery.of(context).size.width / 1.35,
                    imageUrl: message['media'],
                    fit: BoxFit.cover,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Center(
                      child: CircularProgressIndicator(
                        value: downloadProgress.progress,
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(navyBlue),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    errorWidget: imageErrorWidget,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(
                  height: isMessageEmpty ? 2 : 2,
                ),
                isMessageEmpty
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.only(left: 2.0),
                        child: Text(
                          messageText,
                          style: TextStyle(
                              color: isSend ? Colors.white : blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                SizedBox(
                  height: isMessageEmpty ? 2 : 6,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget renderAudioMedia({Map<String, dynamic> message}) {
    bool isSend = message["author"] == userBloc.user.userName;
    // String messageText = message['text'] ?? "";
    // bool isMessageEmpty = messageText == "";

    return Row(
      mainAxisAlignment:
          isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 1.35,
              minWidth: MediaQuery.of(context).size.width / 1.35,
              minHeight: 50),
          decoration: BoxDecoration(
            color: chatBackgroundColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(!isSend ? 0 : 6),
              bottomRight: Radius.circular(isSend ? 0 : 6),
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
          padding: EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 6, left: 4),
                    child: _audioPlayer.builderRealtimePlayingInfos(
                        builder: (context, info) {
                      if (info == null || info.current == null) {
                        return GestureDetector(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: navyBlue,
                            size: 32,
                          ),
                          onTap: () {
                            _audioPlayer.open(
                              Audio.network(
                                  "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/f133a23f344e2e96b275800d505011f54a4dc20f/Burna-Boy-Monsters-You-Made-ft-Chris-Martin.mp3"),
                              autoStart: true,
                            );
                            isAudioPlaying = !isAudioPlaying;
                            setState(() {});
                          },
                        );
                      }
                      return GestureDetector(
                        child: Icon(
                          _audioPlayer.isPlaying.value
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: navyBlue,
                          size: 32,
                        ),
                        onTap: () {
                          if (_audioPlayer.isPlaying.value) {
                            _audioPlayer.pause();
                          } else {
                            _audioPlayer.play();
                          }
                          setState(() {});
                        },
                      );
                    }),
                  ),
                  _audioPlayer.builderRealtimePlayingInfos(
                      builder: (context, info) {
                    if (info == null || info.current == null) {
                      return Expanded(
                        child: Column(
                          children: [
                            PositionSeekWidget(
                              currentPosition: Duration.zero,
                              duration: Duration.zero,
                              seekTo: (to) {},
                            ),
                            SizedBox(
                              height: 6,
                            )
                          ],
                        ),
                      );
                    }
                    return Expanded(
                      child: Column(
                        children: [
                          PositionSeekWidget(
                            currentPosition: info.currentPosition,
                            duration: info.duration,
                            seekTo: (to) {
                              _audioPlayer.seek(to);
                            },
                          ),
                          SizedBox(
                            height: 6,
                          )
                        ],
                      ),
                    );
                  }),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Future<Uint8List> getVideoThumbnail(String url) async {
    Uint8List uInt8list = await VideoThumbnail.thumbnailData(
      video: url,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          512, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    return uInt8list;
  }

  Widget renderVideoMedia({Map<String, dynamic> message}) {
    bool isSend = message["author"] == userBloc.user.userName;
    String messageText = message['text'] ?? "";
    bool isMessageEmpty = messageText == "";

    return GestureDetector(
      onTap: () {
        var result = Navigator.of(context).pushNamed(
          "/view-chat-media",
          arguments: {
            "type": "video",
            "file":
                "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/e4199d196b558eb45681c194e3ce2734486e38aa/dawn-of-thunder.mp4?raw=true",
            "message": message['text']
          },
        );

        debugPrint("Result:- $result");
      },
      onLongPress: () {
        Clipboard.setData(
            new ClipboardData(text: message['text'] ?? message['media']));
        Toast.show("Text copied !!", context,
            gravity: Toast.BOTTOM,
            duration: Toast.LENGTH_LONG,
            backgroundColor: navyBlue,
            textColor: Colors.white);
      },
      child: Row(
        mainAxisAlignment:
            isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 1.35,
              minWidth: MediaQuery.of(context).size.width / 1.35,
            ),
            decoration: BoxDecoration(
              color: isSend ? navyBlue : chatBackgroundColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(!isSend ? 0 : 6),
                bottomRight: Radius.circular(isSend ? 0 : 6),
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            padding: EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: ClipRRect(
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          height: MediaQuery.of(context).size.width / 1.35,
                          width: MediaQuery.of(context).size.width / 1.35,
                          imageUrl:
                              "https://c1.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,f_auto,h_630,w_1200/v1506734779/wcsmythcukjuuglotjvb.jpg",
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Center(
                            child: CircularProgressIndicator(
                              value: downloadProgress.progress,
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(navyBlue),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          errorWidget: imageErrorWidget,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.35,
                          height: MediaQuery.of(context).size.width / 1.35,
                          child: Center(
                            child: ClipOval(
                              child: Container(
                                height: 55,
                                width: 55,
                                color: Colors.white60,
                                child: Center(
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: blackFont,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(
                  height: isMessageEmpty ? 2 : 2,
                ),
                isMessageEmpty
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.only(left: 2.0),
                        child: Text(
                          messageText,
                          style: TextStyle(
                              color: isSend ? Colors.white : blackFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                SizedBox(
                  height: isMessageEmpty ? 2 : 6,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getVideoImage() {
    Widget test = Container();
    getVideoThumbnail(
            "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/e4199d196b558eb45681c194e3ce2734486e38aa/dawn-of-thunder.mp4?raw=true")
        .then((value) {
      return Image.memory(
        value,
        height: MediaQuery.of(context).size.width / 1.35,
        width: MediaQuery.of(context).size.width / 1.35,
        fit: BoxFit.cover,
        frameBuilder: imageFrameBuilder,
      );
    });
    return test;
  }

  Widget renderPaymentRequest({Map<String, dynamic> message}) {
    bool isSent = message["author"] == userBloc.user.userName;

    PaymentRequest paymentRequest = PaymentRequest.fromJson(
        jsonDecode(message['text']),
        currentUser: userBloc.user);

    return GestureDetector(
      onLongPress: () {
        if (paymentRequest.description.isNotEmpty) {
          Clipboard.setData(
              new ClipboardData(text: paymentRequest.description));
          Toast.show("Text copied !!", context,
              gravity: Toast.BOTTOM,
              duration: Toast.LENGTH_LONG,
              backgroundColor: navyBlue,
              textColor: Colors.white);
        }
      },
      child: Row(
        mainAxisAlignment:
            isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: chatBackgroundColor,
              border: Border.all(color: chatBackgroundColor),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(!isSent ? 0 : 10),
                bottomRight: Radius.circular(isSent ? 0 : 10),
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width / 1.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Icon(
                        SlydoAppIcon.naira,
                        color: blackFont,
                        size: 16,
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      paymentRequest.amount.toString(),
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: blackFont),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    paymentRequest.description,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: blackFont),
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Container(
                  child: isSent
                      ? Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: CurvedButton(
                                text: "Cancel",
                                height: 36,
                                backgroundColor: navyBlue,
                                textColor: Colors.white,
                                onPressed: () {},
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: <Widget>[
                            Expanded(
                              child: CurvedButton(
                                text: "Pay",
                                height: 36,
                                backgroundColor: navyBlue,
                                textColor: Colors.white,
                                onPressed: () async {
                                  var response = await PaymentAndBankingAuth()
                                      .acceptPaymentRequests(paymentRequest,
                                          messageId: message["message_id"]);
                                  debugPrint("${response.body}");
                                },
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: CurvedButton(
                                height: 36,
                                text: "Reject",
                                backgroundColor: navyBlue,
                                textColor: Colors.white,
                                onPressed: () async {
                                  var result = await PaymentAndBankingAuth()
                                      .rejectPaymentRequests(paymentRequest,
                                          messageId: message["message_id"]);
                                  debugPrint("$result");
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget renderSendPayment({Map<String, dynamic> item}) {
    bool isSent = item["author"] == userBloc.user.userName;

    Transaction transaction = Transaction.fromJson(jsonDecode(item['text']));

    return GestureDetector(
      onLongPress: () {
        if (transaction.description.isNotEmpty) {
          Clipboard.setData(new ClipboardData(text: transaction.description));
          Toast.show("Text copied !!", context,
              gravity: Toast.BOTTOM,
              duration: Toast.LENGTH_LONG,
              backgroundColor: navyBlue,
              textColor: Colors.white);
        }
      },
      child: Row(
        mainAxisAlignment:
            isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: chatBackgroundColor,
              border: Border.all(color: chatBackgroundColor),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(!isSent ? 0 : 10),
                bottomRight: Radius.circular(isSent ? 0 : 10),
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width / 1.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Icon(
                        SlydoAppIcon.naira,
                        color: blackFont,
                        size: 14,
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      transaction.amount.toString(),
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: blackFont),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    transaction.description,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: blackFont),
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Container(
                  child: Row(
                    children: [
                      Icon(
                        SlydoAppIcon.true_icon,
                        size: 12,
                        color: naturalGreen,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        isSent
                            ? "You paid • ${getDateTime(transaction.createdAt)}"
                            : "You were paid • 10:13 AM",
                        style: TextStyle(color: blackFont, fontSize: 12),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget renderProduct({Map<String, dynamic> message}) {
    bool isSend = message["isSent"];
    if (isSend) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: dividerColor),
                borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width / 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CachedNetworkImage(
                    imageUrl:
                        "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZHVjdHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80"),
                SizedBox(
                  height: 12,
                ),
                Text("Sony HeadPhone",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    )),
                SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      SlydoAppIcon.naira,
                      color: blackFont,
                      size: 12,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(
                      "500",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: blackFont),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: dividerColor),
              borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.all(8),
          width: MediaQuery.of(context).size.width / 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedNetworkImage(
                  imageUrl:
                      "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZHVjdHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80"),
              SizedBox(
                height: 12,
              ),
              Text("Sony HeadPhone",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  )),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    SlydoAppIcon.naira,
                    color: blackFont,
                    size: 12,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    "500",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: blackFont),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              CurvedButton(
                height: 36,
                textColor: Colors.white,
                backgroundColor: navyBlue,
                text: "Buy",
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget renderService({Map<String, dynamic> message}) {
    bool isSend = message["isSent"];
    if (isSend) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: dividerColor),
                borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width / 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CachedNetworkImage(
                    imageUrl:
                        "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZHVjdHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80"),
                SizedBox(
                  height: 12,
                ),
                Text("HeadPhone on Rent",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    )),
                SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      SlydoAppIcon.naira,
                      color: blackFont,
                      size: 12,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(
                      "500",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: blackFont),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: dividerColor),
              borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.all(8),
          width: MediaQuery.of(context).size.width / 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedNetworkImage(
                  imageUrl:
                      "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZHVjdHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80"),
              SizedBox(
                height: 12,
              ),
              Text("HeadPhone on Rent",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  )),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    SlydoAppIcon.naira,
                    color: blackFont,
                    size: 12,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    "500",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: blackFont),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              CurvedButton(
                textColor: Colors.white,
                backgroundColor: navyBlue,
                text: "Buy",
                onPressed: () {},
              ),
              SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget renderTypingMsg() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [Text("Typing...")],
    );
  }
}
