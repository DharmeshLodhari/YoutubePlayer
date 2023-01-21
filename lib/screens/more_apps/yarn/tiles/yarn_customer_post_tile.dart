// ignore_for_file: must_be_immutable

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/yarn_enum.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
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
  bool isLoadingFollowingAction = false;

  @override
  void initState() {
    super.initState();
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
                          InkWell(
                              onTap: () {},
                              child: SvgPicture.asset('circle_chat'.toSVG())),
                          SizedBox(width: 7),
                          // InkWell(
                          //   onTap: () {
                          //     print(
                          //         'follow tapped::: ${widget.customerProfile!.userName}');
                          //     if(widget.customerProfile!.isFollowing == false){
                          //       if (mounted) setState(() {});
                          //       UserAuth()
                          //           .followOrUnfollowUser(widget.customerProfile!.userName!,
                          //           shouldFollow: false)
                          //           .then((value) async {
                          //         if (value == true) {
                          //           // await getSearchedUser(load: false);
                          //         }
                          //         isLoadingFollowingAction = false;
                          //         if (mounted) setState(() {});
                          //       }).catchError((e) {
                          //         isLoadingFollowingAction = false;
                          //         if (mounted) setState(() {});
                          //         showToast(message: e.toString());
                          //       });
                          //     }else{
                          //       if (mounted) setState(() {});
                          //       UserAuth()
                          //           .followOrUnfollowUser(widget.customerProfile!.userName!, shouldFollow: true)
                          //           .then((value) async {
                          //         if (value == true) {
                          //           // await getSearchedUser(load: false);
                          //         }
                          //         isLoadingFollowingAction = false;
                          //         if (mounted) setState(() {});
                          //       }).catchError((e) {
                          //         isLoadingFollowingAction = true;
                          //         if (mounted) setState(() {});
                          //         showToast(message: e.toString());
                          //       });
                          //     }
                          //   },
                          //   child: Container(
                          //     padding: EdgeInsets.symmetric(
                          //         horizontal: 18, vertical: 7),
                          //     decoration: BoxDecoration(
                          //         color: blackFont,
                          //         borderRadius: BorderRadius.circular(17)),
                          //     child: Text(
                          //       widget.customerProfile!.isFollowing == false
                          //           ? 'Follow'
                          //           : 'Following',
                          //       style: TextStyle(
                          //           fontWeight: FontWeight.w500,
                          //           fontSize: getFontSize(
                          //               widget.tileRenderPlace, context),
                          //           color: white),
                          //       maxLines: 2,
                          //       overflow: TextOverflow.ellipsis,
                          //     ),
                          //   ),
                          // )
                          getFollowUnFollowBtn(),
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

  Widget getFollowUnFollowBtn() {
    if (isLoadingFollowingAction) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularLoadingIndicator(),
        ),
      );
    }

    // if (searchedUser!.userName == userBloc.user.userName) {
    //   return SizedBox.shrink();
    // }
    if (widget.customerProfile?.isFollowing != null &&
        widget.customerProfile!.isFollowing == true) {
      return InkWell(
        onTap: () {
          isLoadingFollowingAction = true;
          if (mounted) setState(() {});
          UserAuth()
              .followOrUnfollowUser(widget.customerProfile!.userName!,
                  shouldFollow: false)
              .then((value) async {
            if (value == true) {
              // await getSearchedUser(load: false);
            }
            isLoadingFollowingAction = false;
            if (mounted) setState(() {});
          }).catchError((e) {
            isLoadingFollowingAction = false;
            if (mounted) setState(() {});
            showToast(message: e.toString());
          });
        },
        child: Container(
          height: 30,
          width: 80,
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: blackFont,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: HexColor("#292929"), width: 1)),
          child: Center(
            child: Text(
              'Following',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        isLoadingFollowingAction = true;
        if (mounted) setState(() {});
        UserAuth()
            .followOrUnfollowUser(widget.customerProfile!.userName!,
                shouldFollow: true)
            .then((value) async {
          if (value == true) {
            // await getSearchedUser(load: false);
          }
          isLoadingFollowingAction = false;
          if (mounted) setState(() {});
        }).catchError((e) {
          isLoadingFollowingAction = true;
          if (mounted) setState(() {});
          showToast(message: e.toString());
        });
      },
      child: Container(
        height: 30,
        width: 80,
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: HexColor("#292929"), width: 1)),
        child: Center(
          child: Text(
            'Follow',
            style: TextStyle(
              fontSize: 10,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
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
