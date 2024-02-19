import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class ChatWallpaperSettings extends StatefulWidget {
  @override
  State<ChatWallpaperSettings> createState() => _ChatWallpaperSettingsState();
}

class _ChatWallpaperSettingsState extends State<ChatWallpaperSettings> {
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
              "Chat wallpaper",
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
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            shadowColor: boxShadowTwo,
            elevation: 0,
            child: Container(
              decoration: decorateBox(),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Photo Gallery",
                      maxLines: 1,
                      style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    trailing: Icon(Icons.navigate_next),
                    onTap: () async {
                      await getFile(context).then((value) {});
                    },
                  ),
                  ListTile(
                    title: Text(
                      "Wallpaper Library",
                      maxLines: 1,
                      style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    trailing: Icon(Icons.navigate_next),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text(
                      "Solid color",
                      maxLines: 1,
                      style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    trailing: Icon(Icons.navigate_next),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            shadowColor: boxShadowTwo,
            elevation: 0,
            child: Container(
              decoration: decorateBox(),
              child: ListTile(
                title: Text(
                  "Reset wallpaper",
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                leading: Icon(
                  Icons.clear_rounded,
                  color: Colors.red,
                ),
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
