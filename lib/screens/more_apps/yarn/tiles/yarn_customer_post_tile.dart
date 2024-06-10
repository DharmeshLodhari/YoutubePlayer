import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/slydo_yarn_links.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/yarn_enum.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_search_screen.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../locale/app_localization.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/slydo_app_icon_icons.dart';
import '../../../../widget/bottom_sheet_item.dart';
import '../../../../widget/dialog.dart';
import '../../../../widget/rounded_background_icon.dart';

class YarnCustomerPostTile extends StatefulWidget {
  final CustomerProfile? customerProfile;
  final bool? isNavigable;
  final Function onDeleteBlog;
  final bool showAuthorDetails;
  final TileRenderPlace tileRenderPlace;

  YarnCustomerPostTile({
    super.key,
    this.customerProfile,
    this.showAuthorDetails = true,
    required this.onDeleteBlog,
    this.isNavigable = true,
    this.tileRenderPlace = TileRenderPlace.YarnTimeLine,
  });

  @override
  _YarnCustomerPostTileState createState() => _YarnCustomerPostTileState();
}

class _YarnCustomerPostTileState extends State<YarnCustomerPostTile>
    with TickerProviderStateMixin {
  UserBloc? userBloc;
  bool isAuthor = false;
  bool isSelected = false;
  bool isLoadingFollowingAction = false;
  bool isLoadingFriendRequest = false;
  bool isInRequestList = false;
  bool isLoading = true;
  CustomerProfile? searchedUser;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();

    searchedUser = widget.customerProfile;

    checkConnection();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getSearchedUser();
    });
  }

  Future<void> checkConnection() async {
    isConnected = await DatabaseHelper()
        .checkUserNameInDB(widget.customerProfile!.userName!);
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return _buildProfileCard();
  }

  Widget _buildProfileCard() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        decoration: decorateBox(borderColor: greySecondaryYarn),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: CachedNetworkImage(
                      height: getWallPaperCoverHeight(
                          widget.tileRenderPlace, context),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Center(child: CircularLoadingIndicator()),
                      errorWidget: wallpaperErrorWidget,
                      imageUrl: searchedUser!.wallpaper ?? ""),
                ),
                Positioned(
                  top: getAvatarTop(widget.tileRenderPlace, context),
                  left: 22,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.USER_PROFILE,
                          arguments: {
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
                          imageUrl: searchedUser!.avatar ?? '',
                          errorWidget: imageErrorWidget,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Routes.USER_PROFILE, arguments: {
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
                              const SizedBox(height: 2),
                              userNameWithVerifiedIcon(
                                  name: '@${searchedUser!.displayName() ?? ""}',
                                  isVerified: searchedUser!.isVerified,
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: getFontSize(
                                          widget.tileRenderPlace, context),
                                      color: blackFont))
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            getActionOnUsersBtn(),
                            // getFollowUnFollowBtn(),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    YarnSmartText(
                      text: messageDecoderWithEmoji(searchedUser!.bio)!,
                      style: TextStyle(
                          color: blackFont,
                          fontSize: 16,
                          fontFamily: "OpenSans"),
                      maxLines: 6,
                      // atStyle: TextStyle(color: navyBlue, fontSize: 17, fontFamily: "OpenSans"),
                      disableAt: false,
                      onTagClick: (tag) {
                        NavigationUtil.push(context,
                            screen: SearchScreen(searchText: tag.trim()));
                      },
                      onUrlClicked: (open) {
                        // launch  url
                        launchUrl(Uri.parse(open.toString()));
                      },
                      onAtClick: (at) {
                        Navigator.pushNamed(context, Routes.USER_PROFILE,
                            arguments: {
                              "searchedUserName":
                                  at.replaceAll(RegExp('@'), '').trim()
                            });
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> getSearchedUser({bool load = true}) async {
    late CustomerProfile user;
    if (load) {
      isLoading = true;
      if (mounted) setState(() {});
    }

    try {
      user = await UserAuth()
          .fetchCustomerProfileWithAuth(widget.customerProfile!.userName);
    } catch (e) {
      // Navigator.pop(context);
      showToast(message: 'User not found');
    }

    searchedUser = user;

    checkCurrentUserIsInRequestList();

    isLoading = false;
    if (mounted) setState(() {});
  }

  Widget getActionOnUsersBtn() {
    if (isLoadingFriendRequest) {
      return Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularLoadingIndicator(),
          ),
          const SizedBox(width: 24),
        ],
      );
    }

    if (widget.customerProfile!.userName != userBloc!.user.userName) {
      if (isConnected) {
        return Row(
          children: [
            chatIcon(),
            const SizedBox(width: 8),
          ],
        );
      } else {
        return Row(
          children: [
            getAddConnectionBtn(),
            const SizedBox(width: 8),
          ],
        );
      }
    }

    return const SizedBox.shrink();
  }

  Widget chatIcon() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: HexColor("#292929"),
          ),
          shape: BoxShape.circle),
      child: RoundedBackgroundIcon(
        height: 30,
        width: 30,
        image: SvgPicture.asset(
          "yarn/chat_icon".toSVG(),
          height: 20,
          width: 20,
          color: HexColor("#292929"),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/chat-screen', arguments: {
            "recipientUserName": widget.customerProfile!.userName
          });
        },
        backgroundColor: lightGrey.withOpacity(0.1),
        enableMargin: true,
        margin: 8,
      ),
    );
  }

  Widget getAddConnectionBtn() {
    return Row(
      children: [
        getAddConnectionIcon(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget getAddConnectionIcon() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: greyBorderColor,
          ),
          shape: BoxShape.circle),
      child: RoundedBackgroundIcon(
        height: 34,
        width: 34,
        icon: Icon(
          isInRequestList
              ? SlydoAppIcon.cancel_connection_request
              : SlydoAppIcon.send_connection_request,
          size: 16,
          color: isInRequestList ? mateRed : blackFont,
        ),
        onTap: () {
          isLoadingFriendRequest = true;
          if (mounted) setState(() {});

          if (isInRequestList) {
            UserAuth()
                .cancelOrRejectContactRequest(widget.customerProfile!)
                .then((value) async {
              if (value) {
                showToast(message: "Friend request Canceled");
              } else {
                showToast(message: "Friend request Canceled unsuccessfully");
              }
              await getSearchedUser(load: false);
              isLoadingFriendRequest = false;
              if (mounted) setState(() {});
            }).catchError((error) {
              isLoadingFriendRequest = false;
              if (mounted) setState(() {});
            });
          } else {
            UserAuth()
                .makeContactRequest(widget.customerProfile!)
                .then((value) async {
              if (value) {
                showToast(message: "Friend Request Sent !!");
              } else {
                showToast(message: "Request Not Sent.. ");
              }
              await getSearchedUser(load: false);
              isLoadingFriendRequest = false;
              if (mounted) setState(() {});
            }).catchError((error) {
              isLoadingFriendRequest = false;
              if (mounted) setState(() {});
            });
          }
        },
        backgroundColor: lightGrey.withOpacity(0.1),
        enableMargin: false,
      ),
    );
  }

  void checkCurrentUserIsInRequestList() async {
    final UserBloc _userBloc = Provider.of<UserBloc>(context, listen: false);
    debugPrint("is In Request List -");

    if (_userBloc.user.userName != widget.customerProfile?.userName) {
      UserAuth().checkInRequest(widget.customerProfile?.userName).then((value) {
        if (mounted) {
          setState(() {
            debugPrint("is In Request List : $isInRequestList");

            if (value == true) {
              isInRequestList = true;
            } else {
              isInRequestList = false;
            }
          });
        }
      });
    }
  }

  Widget getFollowUnFollowBtn() {
    if (isLoadingFollowingAction) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularLoadingIndicator(),
        ),
      );
    }

    if (searchedUser!.userName! == userBloc!.user.userName) {
      return const SizedBox.shrink();
    }
    if (searchedUser!.isFollowing != null &&
        searchedUser!.isFollowing == true) {
      return InkWell(
        onTap: () {
          isLoadingFollowingAction = true;
          if (mounted) setState(() {});
          UserAuth()
              .followOrUnfollowUser(searchedUser!.userName!,
                  shouldFollow: false)
              .then((value) async {
            if (value == true) {
              await getSearchedUser(load: false);
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
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: blackFont,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: HexColor("#292929"), width: 1)),
          child: const Center(
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
            .followOrUnfollowUser(searchedUser!.userName!, shouldFollow: true)
            .then((value) async {
          if (value == true) {
            await getSearchedUser(load: false);
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
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: HexColor("#292929"), width: 1)),
        child: const Center(
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
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: generateBottomSheetItem(),
                ),
              ));
        });
  }

  List<Widget> generateBottomSheetItem() {
    final List<Widget> list = [];

    list.add(
      bottomSheetItem(
        title: AppLocalization.of(context)!.share,
        iconData: SlydoAppIcon.share,
        onTap: () {
          Navigator.pop(context);
          final shareBody =
              "https://slydo.co/store/${widget.customerProfile?.userName}/blogs/${widget.customerProfile?.uuid}";
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
              actionOneTextColor: blackFont,
              actionOneBgColor: greyBorderColor,
              actionTwoTextColor: white,
              actionTwoBgColor: mateRed,
              title: 'Delete Blog Post',
              actionOneText: AppLocalization.of(context)!.discard,
              actionTwoText: AppLocalization.of(context)!.continueMsg,
              description: 'Are you sure you want to delete this blog post?',
              roundedBackgroundIcon: RoundedBackgroundIcon(
                width: 90,
                height: 90,
                enableMargin: false,
                image: Image.asset('assets/images/delete_dialog_icon.png'),
              ),
              rightButtonOnPressed: () {
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
}
