import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/models/message.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'message_auth.dart';

// ignore: must_be_immutable
class DetailedMessage extends StatefulWidget {
  var arguments;

  DetailedMessage({this.arguments});

  @override
  _DetailedMessageState createState() =>
      _DetailedMessageState(id: arguments['id']);
}

class _DetailedMessageState extends State<DetailedMessage> {
  bool isLoading = true;
  var id;
  Message message;
  UserBloc userBloc;

  _DetailedMessageState({this.id});

  final _messageAuth = MessageAuth();

  @override
  void initState() {
    fetchMessage();
    super.initState();
  }

  void fetchMessage() async {
    await _messageAuth.getMessage(id).then((value) {
      message = value;
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Widget showBackArrow() {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: appBar(),
        body: scaffoldBody(),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
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
      centerTitle: false,
      title: Text(
        AppLocalization.of(context).message,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  displayMessageInfo(),
                  SizedBox(height: 30),
                  displayReplyButton(),
                ],
              ),
            ),
          );
  }

  Widget displaySubject() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              message.subject,
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ),
          Text(getDate(),
              style: TextStyle(
                fontSize: 14,
                color: darkGrey,
              )),
        ],
      ),
    );
  }

  Widget displaySenderInfo() {
    return ListTile(
      leading: getLeading(),
      title: getSender(),
      subtitle: getRecipientWidget(),
      trailing: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[getArchivedButton(), getIsStarredButton()],
        ),
      ),
      onTap: () {
        Navigator.pushNamed(context, '/profile',
            arguments: {"searchedUserName": message.sender});
      },
    );
  }

  Widget getRecipientWidget() {
    return Text(
      AppLocalization.of(context).to + ": ${message.recipient}",
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.fade,
      style: TextStyle(
        color: darkGrey,
        fontSize: 12,
      ),
    );
  }

  Widget getLeading() {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          25,
        ),
        // border: Border.all(color: borderColor, width: 2),
        border: Border.all(color: Colors.transparent, width: 0),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed("/photo-viewer", arguments: message.senderAvatar);
        },
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: message.senderAvatar,
            height: 48,
            width: 48,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => message.senderAvatar == ""
                ? Icon(Icons.person)
                : CircularLoadingIndicator(),
          ),
        ),
      ),
    );
  }

  getSender() {
    return Text(
      message.sender,
      style: TextStyle(
        color: blackFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }

  getArchivedButton() {
    // this variable is responsible for the message which is user seeing isRecipient is seeing message
    // or isSender is seeing message we got that user and check if it is recipient then
    // we are showing and modifying archive icon by message's isArchivedByRecipient property and if it sender then
    // we are showing and modifying archive icon by message's isArchivedBySender property
    bool isRecipient = userBloc.user.userName == message.recipient;

    IconData icon = isRecipient
        ? message.isArchivedByRecipient
            ? SlydoAppIcon.archive
            : SlydoAppIcon.unarchive
        : message.isArchivedBySender
            ? SlydoAppIcon.archive
            : SlydoAppIcon.unarchive;

    return IconButton(
      icon: Icon(
        icon,
        color: naturalGreen,
        size: 24,
      ),
      onPressed: () async {
        var action = isRecipient
            ? message.isArchivedByRecipient
                ? "unarchive"
                : "archive"
            : message.isArchivedBySender
                ? "unarchive"
                : "archive";
        await _messageAuth.updateMessage(message.id, action);
        setState(() {
          if (isRecipient) {
            message.isArchivedByRecipient =
                message.isArchivedByRecipient ? false : true;
          } else {
            message.isArchivedBySender =
                message.isArchivedBySender ? false : true;
          }
        });
      },
    );
  }

  getIsStarredButton() {
    // this variable is responsible for the message which is user seeing isRecipient is seeing message
    // or isSender is seeing message we got that user and check if it is recipient then
    // we are showing and modifying star icon by message's isStarredByRecipient property and if it sender then
    // we are showing and modifying star icon by message's isStarredBySender property
    bool isRecipient = userBloc.user.userName == message.recipient;
    Color iconColor = isRecipient
        ? message.isStarredByRecipient
            ? starYellow
            : greyBorderColor
        : message.isStarredBySender
            ? starYellow
            : greyBorderColor;
    return IconButton(
      icon: Icon(
        SlydoAppIcon.star,
        color: iconColor,
      ),
      onPressed: () async {
        var action = isRecipient
            ? message.isStarredByRecipient
                ? AppLocalization.of(context).unstar
                : AppLocalization.of(context).star
            : message.isStarredBySender
                ? AppLocalization.of(context).unstar
                : AppLocalization.of(context).star;
        await _messageAuth.updateMessage(message.id, action);
        setState(() {
          if (isRecipient) {
            message.isStarredByRecipient =
                message.isStarredByRecipient ? false : true;
          } else {
            message.isStarredBySender =
                message.isStarredBySender ? false : true;
          }
        });
      },
    );
  }

  getDate() {
    return message.timeStamp;
  }

  displayMessageInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: dividerColor,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: dividerColor, width: 0.5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            displaySubject(),
            displaySenderInfo(),
            displayBodyOfMessage(),
          ],
        ),
      ),
    );
  }

  displayBodyOfMessage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          text: message.body,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    );
  }

  displayReplyButton() {
    return message.sender != userBloc.user.userName
        ? CurvedButton(
            backgroundColor: navyBlue,
            textColor: Colors.white,
            text: AppLocalization.of(context).reply,
            onPressed: () {
              Navigator.of(context).pushNamed('/compose_message', arguments: {
                'isReply': 1,
                'recipient': message.sender,
                'subject': message.subject,
              });
            },
          )
        : Container();
  }
}
