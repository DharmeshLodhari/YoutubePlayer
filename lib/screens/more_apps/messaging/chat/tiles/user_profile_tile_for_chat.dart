import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfileTileForChat extends StatefulWidget {
  final Map<String, dynamic> message;

  UserProfileTileForChat({this.message});

  @override
  _UserProfileTileForChatState createState() => _UserProfileTileForChatState();
}

class _UserProfileTileForChatState extends State<UserProfileTileForChat> {
  UserBloc userBloc;

  CustomerProfile customerProfile;
  @override
  void initState() {
    /// {meta_data:
    /// {"full_name":"Black Striker Enterprise",
    /// "username":"black",
    /// "avatar":"https://slydo-assets.s3.amazonaws.com/media/customer/avatar/4f4470b6dbf44b62859ddf2b945d7472.jpg",
    /// "qr_code":"https://slydo-assets.s3.amazonaws.com/media/customer/qr-code/eae6ec308ace4edca0ff4a16889be3dd.png",
    /// "type":"Developer"},
    /// check_id: 580d8439-2907-4f1c-84e3-7f60957ac8a4,
    /// conversation_id: 9ae68069-b342-4e04-b568-602bde6fe901,
    /// author: black,
    /// message: ,
    /// kind: user_profile,
    /// created_at: 2021-03-25 09:08:42.478942Z,
    /// type: chatroom_message}

    Map<String, dynamic> data = {
      "full_name": "Black Striker Enterprise",
      "username": "black",
      "avatar":
          "https://slydo-assets.s3.amazonaws.com/media/customer/avatar/4f4470b6dbf44b62859ddf2b945d7472.jpg",
      "qr_code":
          "https://slydo-assets.s3.amazonaws.com/media/customer/qr-code/eae6ec308ace4edca0ff4a16889be3dd.png",
      "type": "Developer"
    };

    // customerProfile = CustomerProfile.fromJson(widget.message["meta_data"]);
    customerProfile = CustomerProfile.fromJson(data);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    bool isSend = widget.message["author"] == userBloc.user.userName;

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            isSend ? Container() : Container(width: 20),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.30,
                  minWidth: MediaQuery.of(context).size.width / 1.30,
                  minHeight: 50),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(!isSend ? 0 : 6),
                  bottomRight: Radius.circular(isSend ? 0 : 6),
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
              child: UserProfileTile(
                user: customerProfile,
              ),
            ),
            isSend
                ? Container(
                    width: 20,
                    child: isSend
                        ? Center(
                            child: getMessageTick(message: widget.message),
                          )
                        : Container(),
                  )
                : Container(),
          ],
        ),
        SizedBox(
          height: 1,
        ),
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
              formatTime(widget.message['created_at']),
              style: TextStyle(
                  color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
            ),
            isSend
                ? SizedBox(
                    width: 20,
                  )
                : Container(),
          ],
        )
      ],
    );
  }
}

class UserProfileTile extends StatefulWidget {
  CustomerProfile user;

  UserProfileTile({this.user});

  @override
  _UserProfileTileState createState() => _UserProfileTileState();
}

class _UserProfileTileState extends State<UserProfileTile> {
  Widget avatarImage;

  Color borderColor;

  @override
  void initState() {
    borderColor = getUserTypeColor(user: widget.user);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getTile();
  }

  Widget getAvatar() {
    return Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              25,
            ),
            border: Border.all(color: borderColor, width: 2)),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.user.avatar == ""
                ? "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png"
                : widget.user.avatar,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
            errorWidget: imageErrorWidget,
          ),
        ));
  }

  Widget getTile() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      elevation: 3,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          dense: true,
          title: getTitle(),
          subtitle: getSubtitle(),
          leading: getAvatar(),
          // trailing: getTrailing(),
        ),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      widget.user.fullName,
      maxLines: 1,
      style: TextStyle(
        color: blackFont,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      overflow: TextOverflow.fade,
      softWrap: false,
    );
  }

  Widget getSubtitle() {
    return Text(
      widget.user.userName,
      maxLines: 1,
      style: TextStyle(
        color: darkGrey,
        fontSize: 12,
      ),
      overflow: TextOverflow.fade,
      softWrap: false,
    );
  }

  Widget getTrailing() {
    return Container();
  }
}
