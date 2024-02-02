import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/messaging/models/message.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/colors.dart';
import '../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';

// ignore: must_be_immutable
class MessageTile extends StatefulWidget {
  final PartialMessage? partialMessage;
  Widget? expandedWidget = Container();

  MessageTile({this.partialMessage, this.expandedWidget});

  @override
  _MessageTileState createState() =>
      _MessageTileState(partialMessage: partialMessage);
}

class _MessageTileState extends State<MessageTile> {
  late UserBloc userBloc;
  final _messageAuth = MessageAuth();
  PartialMessage? partialMessage;

  _MessageTileState({this.partialMessage});

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                  dense: true,
                  leading: getLeading(),
                  title: getTitle(),
                  trailing: getTrailing(),
                  subtitle: getSubtitle()),
            ),
            widget.expandedWidget!,
          ],
        ),
      ),
    );
  }

  Widget getLeading() {
    bool currentUserIsSender = userBloc.user.userName == partialMessage!.sender;

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
          String? image = '';
          if (partialMessage!.senderAvatar == "" ||
              partialMessage!.senderAvatar ==
                  "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
            image = getInitials(partialMessage!.sender!).toUpperCase();
          } else {
            image = partialMessage!.senderAvatar;
          }

          Navigator.of(context)
              .pushNamed(Routes.PHOTO_VIEWER, arguments: image);
        },
        child: userImageUserInitialsPic(
            currentUserIsSender
                ? partialMessage!.recipientAvatar!
                : partialMessage!.senderAvatar!,
            currentUserIsSender
                ? partialMessage!.recipient!
                : partialMessage!.sender!,
            25,
            48),
      ),
    );
  }

  Widget getTitle() {
    bool currentUserIsSender = userBloc.user.userName == partialMessage!.sender;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Text(
        currentUserIsSender
            ? partialMessage!.recipient!
            : partialMessage!.subject!,
        maxLines: 1,
        style: TextStyle(
            color: partialMessage!.isRead! ? darkGrey : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15),
      ),
    );
  }

  Widget getTrailing() {
    // this variable is responsible for the message which is user seeing isRecipient is seeing message
    // or isSender is seeing message we got that user and check if it is recipient then
    // we are showing and modifying star icon by message's isStarredByRecipient property and if it sender then
    // we are showing and modifying star icon by message's isStarredBySender property
    bool isRecipient = userBloc.user.userName == partialMessage!.recipient;
    return IconButton(
      icon: isRecipient
          ? partialMessage!.isStarredByRecipient!
              ? Icon(
                  SlydoAppIcon.star,
                  color: starYellow,
                  size: 20,
                )
              : Icon(
                  SlydoAppIcon.star,
                  color: greyBorderColor,
                  size: 20,
                )
          : partialMessage!.isStarredBySender!
              ? Icon(
                  SlydoAppIcon.star,
                  color: starYellow,
                  size: 20,
                )
              : Icon(
                  SlydoAppIcon.star,
                  color: greyBorderColor,
                  size: 20,
                ),
      onPressed: () async {
        var action = isRecipient
            ? partialMessage!.isStarredByRecipient!
                ? AppLocalization.of(context)!.unstar
                : AppLocalization.of(context)!.star
            : partialMessage!.isStarredBySender!
                ? AppLocalization.of(context)!.unstar
                : AppLocalization.of(context)!.star;
        await _messageAuth.updateMessage(partialMessage!.id!, action);

        if (isRecipient) {
          partialMessage!.isStarredByRecipient =
              partialMessage!.isStarredByRecipient! ? false : true;
        } else {
          partialMessage!.isStarredBySender =
              partialMessage!.isStarredBySender! ? false : true;
        }
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget getSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          partialMessage!.subtitle!,
          style: TextStyle(
            color: darkGrey,
            fontSize: 12,
          ),
        ),
        Text(
          partialMessage!.timeStamp!,
          style: TextStyle(
            color: darkGrey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
