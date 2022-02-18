import 'package:flutter/material.dart';

import '../../locale/app_localization.dart';
import '../../utils/colors.dart';

class BlogSettings extends StatefulWidget {
  const BlogSettings({Key? key}) : super(key: key);

  @override
  State<BlogSettings> createState() => _BlogSettingsState();
}

class _BlogSettingsState extends State<BlogSettings> {
  bool enableLikes = false;
  bool enableComments = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar() as PreferredSizeWidget?,
      body: _scaffoldBody(),
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
      title: Text(
        AppLocalization.of(context)!.settings,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _scaffoldBody() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          BlogSettingsTitles(
            title: 'Privacy',
            hasSwitch: false,
            trialingWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Public',
                  style:
                      TextStyle(color: blackFont, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_ios_sharp,
                  size: 18,
                  color: darkGrey,
                )
              ],
            ),
            icon: Icon(Icons.sports_baseball, color: blackFont),
          ),
          BlogSettingsTitles(
            title: 'Enable Comments',
            isSwitched: enableComments,
            icon: Icon(Icons.message_rounded, color: blackFont),
          ),
          BlogSettingsTitles(
            title: 'Enable Likes',
            isSwitched: enableLikes,
            icon: Icon(Icons.thumb_up, color: blackFont),
          ),
        ],
      ),
    );
  }
}

class BlogSettingsTitles extends StatefulWidget {
  bool? isSwitched;
  final Widget icon;
  final String title;
  final bool hasSwitch;
  final Widget? trialingWidget;
  BlogSettingsTitles(
      {required this.icon,
      required this.title,
      this.isSwitched,
      this.hasSwitch = true,
      this.trialingWidget,
      Key? key})
      : super(key: key);

  @override
  State<BlogSettingsTitles> createState() => _BlogSettingsTitlesState();
}

class _BlogSettingsTitlesState extends State<BlogSettingsTitles> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        leading: CircleAvatar(
          backgroundColor: lightGrey,
          child: widget.icon,
        ),
        title: Text(
          widget.title,
          style: TextStyle(color: blackFont, fontWeight: FontWeight.w600),
        ),
        trailing: widget.hasSwitch
            ? Switch(
                value: widget.isSwitched!,
                onChanged: (switched) {
                  setState(() => widget.isSwitched = switched);
                },
              )
            : widget.trialingWidget,
      ),
    );
  }
}
