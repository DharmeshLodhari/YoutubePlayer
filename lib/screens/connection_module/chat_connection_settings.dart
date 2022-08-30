import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatConnectionSettings extends StatefulWidget {
  @override
  State<ChatConnectionSettings> createState() => _ChatConnectionSettingsState();
}

class _ChatConnectionSettingsState extends State<ChatConnectionSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Chat settings",
              maxLines: 1,
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            shadowColor: boxShadowTwo,
            elevation: 0,
            child: Container(
              decoration: decorateBox(),
              child: ListTile(
                title: Text(
                  "Chat wallpaper",
                  maxLines: 1,
                  style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                trailing: Icon(Icons.navigate_next_rounded, color: navyBlueLight,),
                onTap: () {

                },
              ),
            ),
          ),

      ],),
    );
  }
}