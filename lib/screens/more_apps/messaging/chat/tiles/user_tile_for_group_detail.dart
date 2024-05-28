import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/group_detail_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UserTileForGroupDetail extends StatefulWidget {
  CustomerProfile? user;

  GroupDetailModel? groupDetail;

  UserTileForGroupDetail({this.user, this.groupDetail});

  @override
  _UserTileForGroupDetailState createState() => _UserTileForGroupDetailState();
}

class _UserTileForGroupDetailState extends State<UserTileForGroupDetail> {
  @override
  Widget build(BuildContext context) {
    final Widget tile = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          dense: true,
          title: userNameWithVerifiedIcon(
            name: _buildName() ?? "",
            isVerified: widget.user!.isVerified!,
            verifiedIconColor: verifyGreen,
          ),
          subtitle: getSubtitle(context),
          leading: showSelectedUserAvatar(
              widget.user!.avatar!, widget.user!.fullName!),
          trailing: getTrailing(),
          onTap: () async {
            await Navigator.pushNamed(context, '/profile',
                arguments: {"searchedUserName": widget.user!.userName});
          },
        ),
      ),
    );
    return tile;
  }

  Widget showSelectedUserAvatar(String imageUrl, String fullName) {
    final Color borderColor = getUserTypeColor(user: widget.user!);

    if (imageUrl == null ||
        imageUrl == "" ||
        imageUrl ==
            "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
              arguments: getInitials(fullName).toUpperCase());
        },
        child: CircleAvatar(
          backgroundColor: navyBlue,
          radius: 25,
          child: Text(
            getInitials(fullName).toUpperCase(),
            style: TextStyle(color: white, fontWeight: FontWeight.w700),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(Routes.PHOTO_VIEWER, arguments: widget.user!.avatar);
        },
        child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  25,
                ),
                border: Border.all(color: borderColor, width: 2)),
            child: ClipOval(
              child: CachedNetworkImage(
                errorWidget: imageErrorWidget,
                imageUrl: imageUrl == "" ? defaultImage : imageUrl,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            )),
      );
    }
  }

  String? _buildName() {
    if (widget.user?.nickName != null && widget.user?.nickName != "") {
      return widget.user?.nickName;
    }
    return widget.user?.fullName;
  }

  Widget getSubtitle(BuildContext context) {
    return Text(
      widget.user!.userName!,
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
    bool isOwner = false;
    bool isAdmin = false;
    bool isBlocked = false;
    bool isMuted = false;

    bool hasNoStatus = true;

    if (widget.groupDetail!.owner == widget.user!.userName) {
      isOwner = true;
    }
    if (widget.groupDetail!.adminUsers.contains(widget.user!.userName)) {
      isAdmin = true;
    }
    if (widget.groupDetail!.blockedParticipants
        .contains(widget.user!.userName)) {
      isBlocked = true;
    }
    if (widget.groupDetail!.mutedParticipants.contains(widget.user!.userName)) {
      isMuted = true;
    }

    if (isOwner || isAdmin || isMuted || isBlocked) {
      hasNoStatus = false;
    }

    return hasNoStatus
        ? Container(width: 0)
        : Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isOwner
                    ? naturalGreen.withOpacity(0.1)
                    : isAdmin
                        ? navyBlue.withOpacity(0.1)
                        : isMuted
                            ? lightGrey
                            : mateRed.withOpacity(0.1)),
            child: Text(
              isOwner
                  ? "Owner"
                  : isAdmin
                      ? "Admin"
                      : isMuted
                          ? "Muted"
                          : "Blocked",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isOwner
                      ? naturalGreen
                      : isAdmin
                          ? navyBlue
                          : isMuted
                              ? darkGrey
                              : mateRed),
            ),
          );
  }
}
