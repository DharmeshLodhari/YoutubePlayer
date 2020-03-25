//TODO: Display sender message

//TODO: allow user to type recevierName like we do in payment request
//TODO: allow user to input body
//TODO: allow user to click send button
//TODO: inputs {recipient, subject, body, submitButton }

import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/message.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

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
  final _auth = AuthService();

  @override
  void initState() {
    fetchMessage();
    super.initState();
  }

  void fetchMessage() async {
    await _auth.getMessage(id).then((value) {
      message = value;
      setState(() {
        isLoading = false;
      });
    });
  }

  Widget showBackArrow() {
    if (Platform.isAndroid) {
      return IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        },
      );
    } else {
      return IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            leading: showBackArrow(),
            automaticallyImplyLeading: Platform.isAndroid ? false : true,
            title: Center(child: Text("Message")),
            backgroundColor: darkBlue()),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              )
            : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 10),
                      displayMessageInfo(),
                      SizedBox(height: 10),
                      displayReplayButton(),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget displaySubject() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            message.subject,
            style: TextStyle(
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(getDate(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  Widget displaySenderInfo() {
    return Container(
      height: 50,
      width: double.infinity,
      child: ListTile(
//        contentPadding: EdgeInsets.symmetric(horizontal: 15),
        leading: getLeading(),
        title: getSender(),
        subtitle: Text("to: test"),
        trailing: Container(
          width: 100,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[getArchivedButton(), getIsStarredButton()],
          ),
        ),
      ),
    );
  }

  getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: message.senderAvatar,
        height: 40,
        width: 40,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => message.senderAvatar == ""
            ? Icon(Icons.person)
            : CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
      ),
    );
  }

  getSender() {
    return Text(
      message.sender,
      style: TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  getArchivedButton() {
    // this variable is responsible for the message which is user seeing isRecipient is seeing message
    // or isSender is seeing message we got that user and check if it is recipient then
    // we are showing and modifying archive icon by message's isArchivedByRecipient property and if it sender then
    // we are showing and modifying archive icon by message's isArchivedBySender property
    bool isRecipient = userBloc.user.userName == message.recipient;
    return IconButton(
      icon: isRecipient
          ? message.isArchivedByRecipient
              ? Icon(
                  Icons.archive,
                )
              : Icon(Icons.unarchive)
          : message.isArchivedBySender
              ? Icon(
                  Icons.archive,
                )
              : Icon(Icons.unarchive),
      onPressed: () async {
        var action = isRecipient
            ? message.isArchivedByRecipient ? "unarchive" : "archive"
            : message.isArchivedBySender ? "unarchive" : "archive";
        await _auth.updateMessage(message.id, action);
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
    return IconButton(
      icon: isRecipient
          ? message.isStarredByRecipient
              ? Icon(
                  Icons.star,
                  color: Colors.orangeAccent,
                )
              : Icon(Icons.star_border)
          : message.isStarredBySender
              ? Icon(
                  Icons.star,
                  color: Colors.orangeAccent,
                )
              : Icon(Icons.star_border),
      onPressed: () async {
        var action = isRecipient
            ? message.isStarredByRecipient ? "unstar" : "star"
            : message.isStarredBySender ? "unstar" : "star";
        await _auth.updateMessage(message.id, action);
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
      child: Column(
        children: <Widget>[
          displaySubject(),
          displaySenderInfo(),
          displayBodyOfMessage(),
        ],
      ),
    );
  }

  displayBodyOfMessage() {
    return Padding(
      padding: const EdgeInsets.all(35.0),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          text: message.body,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    );
  }

  displayReplayButton() {
    return MaterialButton(
      minWidth: double.infinity,
      elevation: 4.0,
      textColor: Colors.white,
      color: darkBlue(),
      height: 50,
      child: Text("Replay"),
      onPressed: () {
        Navigator.of(context).pushNamed('/compose_message', arguments: {
          'recipient': message.sender,
          'subject': message.subject,
        });
      },
    );
  }
}
