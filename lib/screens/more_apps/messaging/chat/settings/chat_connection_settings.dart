import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

import 'chat_wallpaper_settings.dart';

class ChatConnectionSettings extends StatefulWidget {
  const ChatConnectionSettings({super.key});

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
        leading: Icon(
          Icons.arrow_back_ios_rounded,
          color: navyBlue,
        ),
        backgroundColor: white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Chat settings",
              maxLines: 1,
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
                trailing: Icon(
                  Icons.navigate_next_rounded,
                  color: navyBlue,
                ),
                onTap: () {
                  NavigationUtil.push(context, screen: ChatWallpaperSettings());
                },
              ),
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            shadowColor: boxShadowTwo,
            elevation: 0,
            child: Container(
              decoration: decorateBox(),
              child: ListTile(
                title: Text(
                  "Save to Camera roll",
                  maxLines: 1,
                  style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                trailing: Switch(
                  value: false,
                  onChanged: (bool value) {},
                ),
                onTap: () {},
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          SizedBox(
            width: 340,
            child: Text(
              "Automatically save photos and videos you receive to your iPhone’s Camera Roll.",
              maxLines: 3,
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            shadowColor: boxShadowTwo,
            elevation: 0,
            child: Container(
              decoration: decorateBox(),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Archive all chats",
                      maxLines: 1,
                      style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    leading: const Icon(Icons.archive),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text(
                      "Clear all chats",
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    leading: const Icon(
                      Icons.clear_rounded,
                      color: Colors.red,
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text(
                      "Delete all chats",
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    leading: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
