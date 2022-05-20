import 'dart:typed_data';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/utils/common.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../../routes/route_constants.dart';

class VideoTileForChat extends StatelessWidget {
  final Map<String, dynamic>? message;
  final ChatConversation? chatConversation;

  VideoTileForChat({required this.message, this.chatConversation});

  @override
  Widget build(BuildContext context) {
    UserBloc userBloc = Provider.of<UserBloc>(context);

    bool isSend = message!["author"] == userBloc.user.userName;
    String? messageText = message!['text'] ?? "";
    bool isMessageEmpty = messageText == "";
    messageText = messageDecoderWithEmoji(messageText);

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            isSend
                ? Container()
                : Container(
                    width: 20,
                  ),
            GestureDetector(
              onTap: () {
                var result = Navigator.of(context).pushNamed(
                  Routes.VIEW_CHAT_MEDIA,
                  arguments: {
                    "type": "video",
                    "file": message!["media"],
                    "message": message!['text']
                  },
                );
                debugPrint("Result:- $result");
              },
              child: Container(
                constraints: BoxConstraints(
                  // maxWidth: MediaQuery.of(context).size.width / 1.30,
                  // minWidth: MediaQuery.of(context).size.width / 1.30,
                  maxWidth: MediaQuery.of(context).size.width / 1.8,
                  minWidth: MediaQuery.of(context).size.width / 1.8,
                ),
                decoration: BoxDecoration(
                  color: chatConversation!.isGroupConversation!
                      ? isSend
                          ? isMessageEmpty
                              ? Colors.transparent
                              : navyBlue
                          : Colors.white
                      : isMessageEmpty
                          ? Colors.transparent
                          : isSend
                              ? navyBlue
                              : Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(!isSend ? 0 : 10),
                    bottomRight: Radius.circular(isSend ? 0 : 10),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                padding: EdgeInsets.only(
                    top: chatConversation!.isGroupConversation!
                        ? isSend
                            ? 0
                            : 8
                        : isMessageEmpty
                            ? 0
                            : 8,
                    bottom: chatConversation!.isGroupConversation!
                        ? isSend
                            ? 0
                            : 8
                        : isMessageEmpty
                            ? 0
                            : 8,
                    left: chatConversation!.isGroupConversation!
                        ? isSend
                            ? 0
                            : 8
                        : 0,
                    right: chatConversation!.isGroupConversation!
                        ? isSend
                            ? 0
                            : 8
                        : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isSend
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    chatConversation!.isGroupConversation!
                        ? message!['author'] != userBloc.user.userName
                            ? Column(
                                children: [
                                  Text(
                                    message!['author_full_name'] ??
                                        message!['author'],
                                    style: TextStyle(
                                        color: isSend ? Colors.white : navyBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(
                                    height: isMessageEmpty ? 4 : 2,
                                  ),
                                ],
                              )
                            : Container(
                                width: 0,
                              )
                        : Container(
                            width: 0,
                          ),
                    isMessageEmpty
                        ? Container()
                        : Container(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    chatConversation!.isGroupConversation!
                                        ? 0
                                        : 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      messageText!,
                                      style: TextStyle(
                                          color:
                                              isSend ? Colors.white : blackFont,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    isMessageEmpty
                        ? Container()
                        : SizedBox(
                            height: 8,
                          ),
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              height: MediaQuery.of(context).size.width / 3,
                              width: MediaQuery.of(context).size.width / 1.8,
                              // height: MediaQuery.of(context).size.width / 2.2,
                              // width: MediaQuery.of(context).size.width / 1.30,
                              imageUrl: message!["poster"] ??
                                  "https://c1.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,f_auto,h_630,w_1200/v1506734779/wcsmythcukjuuglotjvb.jpg",
                              fit: BoxFit.cover,
                              color: Colors.black38,
                              colorBlendMode: BlendMode.darken,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Center(
                                child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(
                                      isSend ? Colors.white : navyBlue),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              errorWidget: imageErrorWidget,
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.width / 3,
                            width: MediaQuery.of(context).size.width / 1.8,
                            // height: MediaQuery.of(context).size.width / 2.2,
                            // width: MediaQuery.of(context).size.width / 1.30,
                            child: Center(
                              child: ClipOval(
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  color: Colors.white.withOpacity(0.2),
                                  child: Center(
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isSend
                ? Container(
                    width: 20,
                    child: isSend
                        ? Center(
                            child: getMessageTick(message: message!),
                          )
                        : Container(),
                  )
                : Container(),
          ],
        ),
        SizedBox(height: 1),
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            isSend
                ? Container()
                : SizedBox(
                    width: 20,
                  ),
            Text(
              formatTime(message!['created_at']),
              style: TextStyle(
                  color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
            ),
            isSend
                ? SizedBox(
                    width: 20,
                  )
                : Container(),
          ],
        ),
        SizedBox(height: 4),
        FileTileForChat(),
      ],
    );
  }

  Future<Uint8List?> getVideoThumbnail(String url) async {
    Uint8List? uInt8list = await VideoThumbnail.thumbnailData(
      video: url,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          512, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    return uInt8list;
  }
}

class FileTileForChat extends StatelessWidget {
  const FileTileForChat({Key? key}) : super(key: key);

  final bool isSend = true;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 1.8,
          minWidth: MediaQuery.of(context).size.width / 1.8,
        ),
        margin: EdgeInsets.only(right: 20),
        padding: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: navyBlue,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: SvgPicture.asset(
              'assets/images/pdf_icon.svg',
              width: 20,
              height: 20,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            'file.pdf',
            style: TextStyle(color: Colors.white),
          ),
          trailing: Expanded(
            child: InkWell(
                child: SvgPicture.asset(
                    'assets/images/file_in_chat_download_icon.svg')),
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            isSend
                ? Container()
                : Container(
                    width: 20,
                  ),
            Container(
              decoration: BoxDecoration(
                color: navyBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: SizedBox(height: 40, child: Text('')),
            ),
            isSend
                ? Container(
                    width: 20,
                    child: isSend
                        ? Center(
                            child: getMessageTick(message: {'delivered': true}),
                          )
                        : Container(),
                  )
                : Container(),
          ],
        ),
        SizedBox(height: 1),
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            isSend
                ? Container()
                : SizedBox(
                    width: 20,
                  ),
            Text(
              '3:43pm',
              style: TextStyle(
                  color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
            ),
            isSend
                ? SizedBox(
                    width: 20,
                  )
                : Container(),
          ],
        ),
        SizedBox(height: 4),
      ],
    );
  }
}
