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
import 'package:provider/provider.dart';

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

  List<Widget> messageList = [];

  @override
  void initState() {
    messageController = TextEditingController();
    recipientUser = widget.arguments["searchedUser"];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: scaffoldBody(),
      floatingActionButton: floatingActionBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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

  Widget floatingActionBar() {
    return Card(
      elevation: 10,
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      child: Container(
        height: MediaQuery.of(context).viewInsets.bottom != 0 ? 116 : 58,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom != 0 ? 58 : 0,
          left: 16,
          right: 16,
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
            SizedBox(
              width: 8,
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
    return GestureDetector(
      onTap: sendMessage,
      child: Icon(
        SlydoAppIcon.send_message,
        color: navyBlue,
        size: 22,
      ),
    );
  }

  void sendMessage() async {
    var data = {
      "sender": userBloc.user.userName,
      "recipient": recipientUser.userName.trim(),
      "body": messageController.text.trim(),
    };

    MessageAuth().sendSocketMessage(data).then((value) {
      if (value) {
        messageController.text = "";
        int randomInt = Random().nextInt(5);
        // int randomInt = 2;
        switch (randomInt) {
          case 1:
            bool isSent = Random().nextBool();
            Widget getMessageUi = renderMessage(isSent: isSent);
            messageList.add(getMessageUi);
            break;
          case 2:
            bool isSent = Random().nextBool();
            Widget getPaymentUI = renderSendPayment(isSent: isSent);
            messageList.add(getPaymentUI);
            break;
          case 3:
            bool isSent = Random().nextBool();
            Widget getPaymentUI = renderPaymentRequest(isSent: isSent);
            messageList.add(getPaymentUI);
            break;
          case 4:
            bool isSent = Random().nextBool();
            Widget getProductUI = renderProduct(isSent: isSent);
            messageList.add(getProductUI);
            break;
          case 5:
            bool isSent = Random().nextBool();
            Widget getServiceUI = renderService(isSent: isSent);
            messageList.add(getServiceUI);
            break;

          default:
            Widget getTypingUI = renderTypingMsg();
            messageList.add(getTypingUI);
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
            child: SingleChildScrollView(
              child: Column(
                children: messageList
                    .map((e) => Container(
                          child: e,
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        ))
                    .toList(),
              ),
            ),
          ),
          SizedBox(
            height: 58,
          )
        ],
      ),
    );
  }

  Widget renderMessage({bool isSent}) {
    return Row(
      mainAxisAlignment:
          isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSent ? navyBlue : chatBackgroundColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(!isSent ? 0 : 10),
                bottomRight: Radius.circular(isSent ? 0 : 10),
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              "Hello",
              style: TextStyle(
                  color: isSent ? Colors.white : blackFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
            ))
      ],
    );
  }

  Widget renderPaymentRequest({bool isSent}) {
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

  Widget renderSendPayment({bool isSent}) {
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

  Widget renderProduct({bool isSent}) {
    if (isSent) {
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

  Widget renderService({bool isSent}) {
    if (isSent) {
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
