import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
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
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class ChatScreen extends StatefulWidget {
  final arguments;

  ChatScreen({this.arguments});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  CustomerProfile recipientUser;

  TextEditingController messageController;
  FocusNode messageFocus;

  UserBloc userBloc;

  Map<String, dynamic> headers;

  List<String> messageList = [];
  IOWebSocketChannel channel;
  String socketUrl = "wss://slydo.co/ws/chat";

  ScrollController messageScrollController;
  bool fabIsVisible = false;

  bool isConnected = false;
  Timer _timerForRetryConnection;
  int numberOfRetry = 30;
  int countRetry = 0;
  Duration connectionRetryDuration = Duration(seconds: 3);

  Timer _timerForPingServer;
  Duration _timePeriodForSecond = Duration(seconds: 3);
  DateTime _lastSent = DateTime.now();
  DateTime _lastReceive = DateTime.now();
  Duration _socketTimeout = Duration(minutes: 4);

  Timer _timerForUserTypingState;
  Duration userMessageTypingStateUpdateTime = Duration(seconds: 2);
  bool isRecipientTyping = false;

  bool isLoading = false;
  int count = 0;
  String next = "";
  String previous = "";

  @override
  void initState() {
    messageController = TextEditingController();
    messageFocus = FocusNode();
    recipientUser = widget.arguments["searchedUser"];

    connectSocket();

    setupScrollController();

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
        ..onDone(() {
          debugPrint("onDone:-  OnDone Called !!!!");
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
        debugPrint("ping Timer tic !!!");
        ping();
      });
    }
  }

  void ping() async {
    debugPrint("ping call !!!");
    var currentTime = DateTime.now();

    if (currentTime.difference(_lastSent) > _socketTimeout &&
        currentTime.difference(_lastReceive) > _socketTimeout) {
      var data = {
        "message": "ping",
        "type": "ping",
        "headers": headers,
      };

      try {
        if (isConnected) {
          channel.sink.add(jsonEncode(data));
          _lastSent = DateTime.now();
          debugPrint("ping Done!!");
        }
      } catch (e) {
        debugPrint("ERROR:- $e");

        numberOfRetry = 0;
        isConnected = false;

        await connectSocket().then((value) {
          channel.sink.add(jsonEncode(data));
          _lastSent = DateTime.now();
          debugPrint("ping Done!!");
        });
      }
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

  void fetchPreviousMessages() async {
    debugPrint("Fetching previous messages !!");
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          isLoading = true;
          setState(() {});
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

    switch (messageData['type']) {
      case "chatroom_message":
        messageList.add(message);

        if (mounted) setState(() {});

        Timer(
            Duration(milliseconds: 100),
            () => messageScrollController
                .jumpTo(messageScrollController.position.maxScrollExtent));
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

  void userTyping() async {
    var data = {
      "username": userBloc.user.userName,
      "recipient": recipientUser.userName.trim(),
      "message": "",
      // "type": "chatroom_message",
      "type": "user_typing_message",
      "headers": headers,
    };

    try {
      if (isConnected) {
        channel.sink.add(jsonEncode(data));
        _lastSent = DateTime.now();
      } else {
        throw Exception("Not Connected");
      }
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
                  isRecipientTyping ? "Typing.." : "Online",
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

    if (message.isEmpty) {
      return;
    }

    /// message = Message(
    //             check_id=data["check_id"],
    //             conversation=data["conversation"],
    //             author=data["author"],
    //             text=data["text"],
    //             media=data["media"],
    //             kind=data["kind"],
    //             read_by_author=data["read_by_author"],
    //             was_edited=data["was_edited"],
    //             updated_at=data["updated_at"],
    //             created_at=data["created_at"],
    //         )

    var data = {
      "check_id": Uuid().v4(),
      "conversation": recipientUser.conversationId,
      "author": userBloc.user.userName,
      "message": message,
      "kind": "text",
      "read_by_author": true,
      "created_at": DateTime.now().toUtc().toString(),
      "type": "chatroom_message",
      "headers": headers,
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

  String getDateTime(String dateAndTime) {
    DateTime requestTime = DateTime.parse(dateAndTime);
    String date = DateFormat("dd/MM/yyyy").format(requestTime);
    String time = DateFormat("hh:mm a").format(requestTime);
    return "$date • $time";
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
