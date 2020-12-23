import 'dart:convert';
import 'dart:math';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:Slydo/services/auth.dart';

class ChatScreen extends StatefulWidget {
  final arguments;

  ChatScreen({this.arguments});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  CustomerProfile recipientUser;

  TextEditingController messageController;

  UserBloc userBloc;

  List<String> messageList = [];
  IOWebSocketChannel channel;
  String socketUrl = "wss://slydo.co/ws/chat/89815ef4-0442-4073-b7b6-3fd10ab516be/";

  ScrollController messageScrollController;
  bool fabIsVisible = false;

  bool isConnected = false;
  Duration connectionRetryDuration = Duration(seconds: 2);

  @override
  void initState() {
    messageController = TextEditingController();
    recipientUser = widget.arguments["searchedUser"];

    connectSocket();

    setupScrollController();

    super.initState();
  }

  Future<void> connectSocket() async {
    /// change socket url according to recipient user url
    // socketUrl = "wss://slydo.co/chat/${recipientUser.userName}";

    /// for connecting the socket
    try {
      // Set auth headers or socket will be closed
      var headers = await MessageAuth().getAuthHeaders();
      channel = IOWebSocketChannel.connect(socketUrl, headers: headers);
    } catch (e) {
      debugPrint("Error to connect Web Socket !!!! ${channel.closeCode}");
      Future.delayed(connectionRetryDuration).then((value) => connectSocket());
    }

    debugPrint("connected to $socketUrl ");
    isConnected = true;

    /// for listening message in the Socket
    if (isConnected) {
      debugPrint("Listener called!!");
      channel.stream.listen((message) {
        debugPrint("Got Message:- $message");
        determineMessageType(message);
      });
    }
  }

  void setupScrollController() {
    messageScrollController = ScrollController();

    messageScrollController.addListener(() {
      /// when scroll view is at top
      if (messageScrollController.position.pixels ==
          messageScrollController.position.maxScrollExtent) {
        fetchPreviousMessages();
      }

      /// when scroll view is at last
      if (messageScrollController.position.pixels ==
          messageScrollController.position.minScrollExtent) {}

      /// for floating button to show scroll to bottom

      fabIsVisible = messageScrollController.position.userScrollDirection ==
          ScrollDirection.forward;
      if (messageScrollController.position.pixels == 0.0) {
        fabIsVisible = false;
      }

      setState(() {});
    });
  }

  void fetchPreviousMessages() {
    debugPrint("Fetching previous messages !!");
    List<String> previousMessages = List.generate(
        8,
        (index) => jsonEncode({
              "sender": "black",
              "recipient": "pankaj.sakariya",
              "body": "test $index",
              "type": "message",
              "isSent": Random().nextBool()
            }));

    messageList.insertAll(0, previousMessages);
    setState(() {});
  }

  void determineMessageType(String message) {
    messageList.add(message);
    setState(() {});
    if (MediaQuery.of(context).viewInsets.bottom != 0) {
      scrollToBottom();
    }
  }

  void scrollToBottom() {
    messageScrollController.animateTo(0.0,
        duration: Duration(microseconds: 100),
        curve: Curves.fastLinearToSlowEaseIn);
  }

  @override
  void dispose() {
    try {
      channel.sink.close(status.goingAway);
      debugPrint("Socket Connection close for $socketUrl");
    } catch (e) {
      debugPrint("ERROR:- to close Socket Connection");
    }
    super.dispose();
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
                  "Online",
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
        ),
      ));

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
                ? Container()
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

    String messageType = "message";

    switch (messageType) {
      case "message":
        Widget getMessageUi = renderMessage(message: messageData);
        return getMessageUi;
        break;
      case "2":
        Widget getPaymentUI = renderSendPayment(message: messageData);
        return getPaymentUI;

        break;
      case "3":
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
    var headers = await MessageAuth().getAuthHeaders();
    String message = messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    var data = {
      "username": userBloc.user.userName,
      "recipient": recipientUser.userName.trim(),
      "message": message,
      "type": "chatroom_message",
      // "isSent": Random().nextBool(),
      "headers": headers,
    };

    MessageAuth().sendSocketMessage(data).then((value) {
      if (value) {
        messageController.text = "";
        try {

          data["headers"] = headers;
          channel.sink.add(jsonEncode(data));
        } catch (e) {
          debugPrint("error $e");
        }
        setState(() {});
      }
    });


  }

  Widget scaffoldBody() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Theme(
              data: ThemeData(highlightColor: navyBlue),
              child: Scrollbar(
                controller: messageScrollController,
                radius: Radius.circular(10),
                thickness: 3,
                child: SingleChildScrollView(
                  reverse: true,
                  controller: messageScrollController,
                  child: Column(
                    children: messageList
                        .map((message) => Container(
                              child: renderDataAccordingType(message),
                              padding:
                                  EdgeInsets.only(left: 8, right: 8, bottom: 8),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
          messageActionBar()
        ],
      ),
    );
  }

  Widget renderMessage({Map<String, dynamic> message}) {
    bool isSend = false;
    // if message["username"] == userBloc.user.userName {
    //   isSend = false;
    //
    // }
    return Row(
      mainAxisAlignment:
          isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding:
                EdgeInsets.only(left: isSend ? 30 : 0, right: !isSend ? 30 : 0),
            child: Container(
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
                  message['message'],
                  style: TextStyle(
                      color: isSend ? Colors.white : blackFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                )),
          ),
        )
      ],
    );
  }

  Widget renderPaymentRequest({Map<String, dynamic> message}) {
    bool isSent = message["isSent"];
    return Row(
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
          width: MediaQuery.of(context).size.width / 2,
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
                    "500",
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
                  "Shopping",
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
                              onPressed: () {},
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
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget renderSendPayment({Map<String, dynamic> message}) {
    bool isSent = message["isSent"];
    return Row(
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
          width: MediaQuery.of(context).size.width / 2,
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
                    "500",
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
                  "Shopping",
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
                          ? "You paid • 06:15 PM"
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
      children: [Text("Abiola is typing...")],
    );
  }
}
