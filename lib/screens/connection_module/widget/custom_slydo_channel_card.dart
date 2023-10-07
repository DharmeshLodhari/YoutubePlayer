import 'dart:async';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/channel_model.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../routes/route_constants.dart';
import '../../../widget/LoadingIndicator.dart';
import '../../../widget/item_display_card.dart';
import '../../more_apps/messaging/message_auth.dart';
import 'package:badges/badges.dart' as badges;

import '../../more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../../more_apps/yarn/utils/utils.dart';
import '../../more_apps/yarn/utils/yarn_enum.dart';

// ignore: must_be_immutable
class CustomSlydoChannelCard extends StatefulWidget {
  ChannelModel? channelModel;
  final TileRenderPlace tileRenderPlace;

  CustomSlydoChannelCard({required this.channelModel,
    this.tileRenderPlace = TileRenderPlace.YarnTimeLine,});

  @override
  _CustomSlydoChannelCardState createState() => _CustomSlydoChannelCardState();
}

class _CustomSlydoChannelCardState extends State<CustomSlydoChannelCard> {
  bool isTyping = false;

  MainSocketProvider? mainSocketProvider;
  StreamSubscription? streamSubscription;
  String? typingMessage = "";

  late UserBloc userBloc;
  bool isLoading = false;

  @override
  void dispose() {
    mainSocketProvider?.removeStreamSubscription(streamSubscription);
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return getChannel();
  }


  Widget getChannel() {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      shadowColor: boxShadow,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                  height: getContainerHeight(widget.tileRenderPlace, context),
                  child: getWallpaper()),
              Positioned(
                left: 10,
                top: getContainerHeight(widget.tileRenderPlace, context) - 20,
                child: InkWell(
                  onTap: () {
                    String? image = '';
                    if (widget.channelModel!.avatar == "" ||
                        widget.channelModel!.avatar ==
                            "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
                      image = getInitials(widget.channelModel!.owner!)
                          .toUpperCase();
                    } else {
                      image = widget.channelModel!.avatar;
                    }

                    Navigator.of(context)
                        .pushNamed(Routes.PHOTO_VIEWER, arguments: image);
                  },
                  child: SizedBox(
                      width: widget.tileRenderPlace == TileRenderPlace.Thiny
                          ? 40
                          : 50,
                      height: widget.tileRenderPlace == TileRenderPlace.Thiny
                          ? 40
                          : 50,
                      child: CircularUserColorImage(
                          imageUrl: widget.channelModel!.avatar!,
                          name: widget.channelModel!.owner!)),
                ),
              ),
            ],
          ),
          Container(
            padding: widget.tileRenderPlace == TileRenderPlace.Thiny
                ? const EdgeInsets.only(left: 15, top: 20, bottom: 5, right: 15)
                : const EdgeInsets.only(left: 15, top: 30, bottom: 10, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, Routes.USER_PROFILE, arguments: {
                          "searchedUserName": widget.channelModel!.owner!
                        });
                      },
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  appendStringDot(
                                      messageDecoderWithEmoji(
                                          widget.channelModel!.groupName ??
                                              "") ??
                                          "",
                                      widget.tileRenderPlace ==
                                          TileRenderPlace.Thiny
                                          ? 13
                                          : 20),
                                  style: TextStyle(
                                      fontSize: widget.tileRenderPlace ==
                                          TileRenderPlace.Thiny
                                          ? 12
                                          : 16,
                                      fontWeight: FontWeight.w700,
                                      color: yarnBlack),
                                )),
                            Row(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: userNameWithVerifiedIcon(
                                      name: appendStringDot(
                                          messageDecoderWithEmoji(
                                              '@${widget.channelModel!.owner}') ??
                                              "",
                                          widget.tileRenderPlace ==
                                              TileRenderPlace.Thiny
                                              ? 13
                                              : 20),
                                      isVerified: false,
                                      textStyle: TextStyle(
                                        fontSize: widget.tileRenderPlace ==
                                            TileRenderPlace.Thiny
                                            ? 11
                                            : 14,
                                        color: HexColor("#151515"),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      verifiedIconColor: verifyGreen,
                                      verifiedIconSize: widget.tileRenderPlace ==
                                          TileRenderPlace.Thiny
                                          ? 12
                                          : 15),
                                ),

                                if(widget.channelModel?.isMember == false)...[
                                  SizedBox(width: 20),
                                  Text(
                                    '${getFormattedViewCount(
                                      noOfViews: widget.channelModel!.noOfMembers!,
                                      addViewText: false,
                                    )} Member(s)',
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                  )
                                ],

                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      // padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: getJoinUnJoinedBtn(),
                    ),
                  ],
                ),
                SizedBox(
                  height: widget.tileRenderPlace == TileRenderPlace.Thiny
                      ? 2.0
                      : 5.0,
                ),

                if (widget.channelModel!.description!.isNotEmpty ||
                    widget.channelModel!.description! != null) ...[
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          messageDecoderWithEmoji(widget.channelModel!.description!) ??
                              "",
                          style: TextStyle(
                            fontSize:
                            getFontSize(widget.tileRenderPlace, context),
                            fontWeight: FontWeight.w600,
                            color: blackFont,
                          ),
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            height:
            widget.tileRenderPlace == TileRenderPlace.Thiny ? 5.0 : 10.0,
          ),
        ],
      ),
    );
  }

  Widget getJoinUnJoinedBtn() {
    return InkWell(
      onTap: widget.channelModel?.isMember == true
          ? () {
        showToast(message: 'You are already a member');
      }
          : () {
        if (mounted) setState(() => isLoading = true);
        MessageAuth()
            .joinChannel(
            channelId: widget.channelModel!.id!,
            userName: userBloc.user.userName!)
            .then((value) {
          if (mounted) setState(() => isLoading = false);

          if (value) {
            showToast(message: "Joined channel successfully");
            widget.channelModel!.isMember = true;
            if (mounted) setState(() {});
          }
        }).catchError((error) {
          if (mounted) setState(() => isLoading = false);
          if (error.toString().contains('is full')) {
            showToast(message: error.toString());
          } else {
            showToast(message: 'Something went wrong, please try again.');
          }

          debugPrint("ERROR: $error");
        });
      },
      child: isLoading
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularLoadingIndicator(color: navyBlue),
      )
          : Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 1, color: black),
          color: widget.channelModel?.isMember == true ? black : white,
        ),
        child: Text(
          widget.channelModel?.isMember == true ? 'Joined' : 'Join',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: widget.channelModel?.isMember == true ? white : black),
        ),
      ),
    );

  }

  Widget getWallpaper() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      child: widget.channelModel!.banner == "" ||
          widget.channelModel!.banner == null
          ? Image.asset(
        "assets/images/default_user_wallpaper.png",
        width: double.infinity,
        fit: BoxFit.cover,
      )
          : GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed("/photo-viewer",
              arguments: widget.channelModel!.banner);
        },
        child: Container(
          color: navyBlue,
          child: CachedNetworkImage(
            width: double.infinity,
            // height: double.infinity,
            errorWidget: wallpaperErrorWidget,
            imageUrl: widget.channelModel!.banner!,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Center(child: CircularLoadingIndicator()),
            color: blackFont.withOpacity(0.4),
            colorBlendMode: BlendMode.darken,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

