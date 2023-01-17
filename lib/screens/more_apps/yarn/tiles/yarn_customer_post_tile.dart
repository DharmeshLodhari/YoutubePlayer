// ignore_for_file: must_be_immutable

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/yarn_enum.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../../../locale/app_localization.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/slydo_app_icon_icons.dart';
import '../../../../widget/bottom_sheet_item.dart';
import '../../../../widget/dialog.dart';
import '../../../../widget/rounded_background_icon.dart';

class YarnCustomerPostTile extends StatefulWidget {
  CustomerProfile? customerProfile;
  bool? isNavigable;
  Function onDeleteBlog;
  final bool showAuthorDetails;
  final TileRenderPlace tileRenderPlace;

  YarnCustomerPostTile({
    Key? key,
    this.customerProfile,
    this.showAuthorDetails = true,
    required this.onDeleteBlog,
    this.isNavigable = true,
    this.tileRenderPlace = TileRenderPlace.YarnTimeLine,
  }) : super(key: key);

  @override
  _YarnCustomerPostTileState createState() => _YarnCustomerPostTileState();
}

class _YarnCustomerPostTileState extends State<YarnCustomerPostTile> {
  UserBloc? userBloc;
  bool isAuthor = false;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();

    // print(
    //     'CustomerProfile wallpaper::::: ${widget.customerProfile!.wallpaper}');
    // print('CustomerProfile type::::: ${widget.customerProfile!.type}');
    // print(
    //     'CustomerProfile user about::::: ${widget.customerProfile!.userAbout!.wallpaper}');
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return _buildProfileCard();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildProfileCard() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        decoration: decorateBox(borderColor: greySecondaryYarn),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // checkAccountType(),

                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: CachedNetworkImage(
                        height: getWallPaperCoverHeight(
                            widget.tileRenderPlace, context),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: imageErrorWidget,
                        imageUrl: widget.customerProfile?.wallpaper ?? ""),
                  ),
                  Positioned(
                    top: getAvatarTop(widget.tileRenderPlace, context),
                    left: 22,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, Routes.USER_PROFILE, arguments: {
                          "searchedUserName": widget.customerProfile?.userName
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 3, color: white)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: widget.customerProfile?.avatar ?? '',
                            errorWidget: imageErrorWidget,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.USER_PROFILE,
                        arguments: {
                          "searchedUserName": widget.customerProfile?.userName
                        });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  messageDecoderWithEmoji(
                                          widget.customerProfile?.fullName ??
                                              "") ??
                                      '',
                                  style: TextStyle(
                                    fontSize: getFontSize(
                                        widget.tileRenderPlace, context),
                                    fontWeight: FontWeight.w400,
                                    color: blackFont,
                                  ),
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.clip,
                                ),
                                SizedBox(height: 2),
                                userNameWithVerifiedIcon(
                                    name:
                                        '@${widget.customerProfile?.displayName() ?? ""}',
                                    isVerified:
                                        widget.customerProfile?.isVerified,
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: getFontSize(
                                            widget.tileRenderPlace, context),
                                        color: blackFont))
                              ],
                            ),
                          ),
                          SvgPicture.asset('circle_chat'.toSVG()),
                          SizedBox(width: 7),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 18, vertical: 7),
                            decoration: BoxDecoration(
                                color: blackFont,
                                borderRadius: BorderRadius.circular(17)),
                            child: Text(
                              'Following',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: getFontSize(
                                      widget.tileRenderPlace, context),
                                  color: white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 8),
                      Linkify(
                        onOpen: (_) {},
                        text: widget.customerProfile?.bio == null
                            ? ''
                            : messageDecoderWithEmoji(
                                    widget.customerProfile?.bio) ??
                                "",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize:
                              getFontSize(widget.tileRenderPlace, context),
                        ),
                        maxLines: 6,
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showUserProfileActionsSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: generateBottomSheetItem(),
                ),
              ));
        });
  }

  List<Widget> generateBottomSheetItem() {
    List<Widget> list = [];

    list.add(
      bottomSheetItem(
        title: AppLocalization.of(context)!.share,
        iconData: SlydoAppIcon.share,
        onTap: () {
          Navigator.pop(context);
          var shareBody =
              "https://merchant.slydo.co/${widget.customerProfile?.userName}/blog/${widget.customerProfile?.uuid}";
          Share.share(shareBody,
              subject: "${widget.customerProfile?.userName}");
        },
      ),
    );

    list.add(
      bottomSheetItem(
        title: "Share in Chat",
        iconData: SlydoAppIcon.text_message,
        onTap: () async {
          Navigator.pop(context);
          /*   UserPostUtils.sendPostToUserInChat(
            context: context,
            userPost: widget.post!,
          ); */
        },
      ),
    );

    if (userBloc?.user.userName == widget.customerProfile?.userName) {
      list.add(
        bottomSheetItem(
          title: AppLocalization.of(context)!.editPost,
          iconData: SlydoAppIcon.edit,
          onTap: () async {
            Navigator.pop(context);
            await Navigator.pushNamed(context, Routes.CREATE_BLOG,
                arguments: widget.customerProfile);
          },
        ),
      );
    }

    if (userBloc!.user.userName == widget.customerProfile?.userName) {
      list.add(
        bottomSheetItem(
          title: AppLocalization.of(context)!.deletePost,
          iconData: SlydoAppIcon.delete,
          onTap: () {
            Navigator.pop(context);
            showDialogBox(
              context: context,
              actionOneTextColor: white,
              actionOneBgColor: mateRed,
              actionTwoTextColor: blackFont,
              actionTwoBgColor: greyBorderColor,
              title: AppLocalization.of(context)!.delete,
              actionTwoText: AppLocalization.of(context)!.cancel,
              actionOneText: AppLocalization.of(context)!.delete,
              description: 'Are you sure you want to delete this blog post?',
              roundedBackgroundIcon: RoundedBackgroundIcon(
                width: 90,
                height: 90,
                enableMargin: false,
                image: Image.asset('assets/images/delete_dialog_icon.png'),
              ),
              leftButtonOnPressed: () {
                UserPostUtils.deleteBlogPost(
                  context: context,
                  blogId: widget.customerProfile?.uuid ?? '',
                  onDeleteBlog: widget.onDeleteBlog,
                );
              },
            );
          },
        ),
      );
    }

    return list;
  }

  // checkAccountType() {
  //   if (widget.customerProfile!.type == 'User') {
  //     return ClipRRect(
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(10),
  //         topRight: Radius.circular(10),
  //       ),
  //       child: CachedNetworkImage(
  //           height: getWallPaperCoverHeight(widget.tileRenderPlace, context),
  //           width: double.infinity,
  //           fit: BoxFit.cover,
  //           errorWidget: imageErrorWidget,
  //           imageUrl: widget.customerProfile?.wallpaper ?? ""),
  //     );
  //   } else {
  //     return ClipRRect(
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(10),
  //         topRight: Radius.circular(10),
  //       ),
  //       child: CachedNetworkImage(
  //           height: getWallPaperCoverHeight(widget.tileRenderPlace, context),
  //           width: double.infinity,
  //           fit: BoxFit.cover,
  //           errorWidget: imageErrorWidget,
  //           imageUrl: widget.customerProfile?.userAbout!.wallpaper ?? ''),
  //     );
  //   }
  // }
}
