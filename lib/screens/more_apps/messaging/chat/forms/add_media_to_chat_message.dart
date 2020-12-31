import 'dart:io';

import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class AddMediaToChatMessage extends StatefulWidget {
  Map<String, dynamic> arguments;

  AddMediaToChatMessage({@required this.arguments});

  @override
  _AddMediaToChatMessageState createState() => _AddMediaToChatMessageState();
}

class _AddMediaToChatMessageState extends State<AddMediaToChatMessage> {
  Map<String, dynamic> data;
  File mediaFile;

  TextEditingController messageController;

  @override
  void initState() {
    var message = widget.arguments["message"];
    messageController = TextEditingController(text: message);
    data = widget.arguments["data"];
    mediaFile = widget.arguments["media"];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          return Future.value(true);
        },
        child: Scaffold(
          body: scaffoldBody(),
        ),
      ),
    );
  }

  Widget scaffoldBody() {
    return Container(
      child: Column(
        children: [
          Expanded(
              child: Stack(
            children: [
              ClipRect(
                  child: PhotoView(
                imageProvider: FileImage(mediaFile),
              )),
              Positioned(
                top: 4,
                left: 4,
                child: InkWell(
                  child: ClipOval(
                    child: Container(
                      height: 36,
                      width: 36,
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          )),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 8,
                ),
                Expanded(child: getMessageTextFormField()),
                InkWell(
                  onTap: sendMessage,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 8,
                      ),
                      Icon(
                        Icons.send,
                        color: navyBlue,
                      ),
                      SizedBox(
                        width: 8,
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

  Widget getMessageTextFormField() {
    return TextFormField(
      controller: messageController,
      autofocus: true,
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

  void sendMessage() async {
    // Navigator.pop(context, Future.error("error"));

    Map<String, dynamic> _data = {};
    _data['text'] = messageController.text.trim();
    _data['check_id'] = Uuid().v4();
    _data['kind'] = "image";
    _data['read_by_author'] = true;
    _data['created_at'] = DateTime.now().toUtc().toString();
    _data['type'] = "chatroom_message";
    _data.addAll(data);

    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularLoadingIndicator(),
            ));

    MessageAuth().sendSocketMessage(_data, mediaFile).then((value) {
      Navigator.pop(context);
      Navigator.pop(context, true);
    }).catchError((error) {
      Navigator.pop(context);
      Navigator.pop(context, Future.error(error));
    });
  }
}
