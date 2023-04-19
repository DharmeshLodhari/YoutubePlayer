import 'dart:convert';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/locator.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_followers_view.dart';
import 'package:Slydo/screens/more_apps/user_profile/tiles/following_and_follwers_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/models/share_as_yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/share_as_a_yarn_screen.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_dashboard_bloc.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/common.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/slydo_app_icon_new_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../messaging/message_auth.dart';
import '../screens/user_profile_module_new/utils.dart';

class GetAppbarTile extends StatefulWidget {
  CustomerProfile? searchedUser;
  bool isLoading = true;
  bool isShrink = false;
  ScrollController? scrollController;
  String? userType;
  Map<String, dynamic>? channelDetail;

  GetAppbarTile(
      {Key? key,
      required this.searchedUser,
      required this.isLoading,
      required this.isShrink,
      required this.scrollController,
      this.userType,
      this.channelDetail})
      : super(key: key);

  @override
  State<GetAppbarTile> createState() => _GetAppbarTileState();
}

class _GetAppbarTileState extends State<GetAppbarTile> {
  CustomerProfile? searchedUser;
  late UserBloc userBloc;
  bool isOwner = false;
  String? searchedUserName;
  bool isInRequestList = false;
  bool isLoadingFollowingAction = false;
  bool isLoadingFriendRequest = false;

  AppConfigurationModel? appConfigurationModel;
  late YarnDashboardBloc yarnDashboardBloc;
  late CustomerProfileBloc customerProfileBloc;
  Map<String, dynamic>? channelDetail;
  bool isLoading = false;
  bool hasAddress = false;
  bool hasContact = false;

  @override
  void initState() {
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

    if (widget.channelDetail != null) {
      channelDetail = widget.channelDetail;

      if (mounted) setState(() {});
    }

    if (widget.searchedUser != null) {
      searchedUser = widget.searchedUser;

      if (mounted) setState(() {});
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);

    if (searchedUser != null) {
      hasAddress = searchedUser!.userAbout?.userAddress?.addressLine1 != null &&
          (searchedUser!.userAbout?.userAddress?.addressLine1?.isNotEmpty ??
              false);
      hasContact = searchedUser!.userAbout?.contact != null &&
          (searchedUser?.userAbout?.contact.isNotEmpty ?? false);

      if (mounted) setState(() {});
    }

    if (userBloc.user.userName == searchedUser?.userName) {
      isOwner = true;
    }

    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverSafeArea(
        top: false,
        bottom: false,
        sliver: SliverAppBar(
          forceElevated: false,
          elevation: 0,
          stretch: true,
          automaticallyImplyLeading: false,
          expandedHeight: getBgHeightOfAppBar(
            searchedUser?.bio == null
                ? ''
                : messageDecoderWithEmoji(searchedUser?.bio)!,
            hasAddress,
            hasContact,
          ),
          shadowColor: Colors.transparent,
          pinned: true,
          floating: true,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () {
              searchedUser = null;
              Navigator.pop(context);
            },
          ),
          actions: actionButtons(),
          title: widget.isShrink
              ? userNameWithVerifiedIcon(
                  name: searchedUser!.displayName()!,
                  isVerified: searchedUser!.isVerified,
                  textStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  verifiedIconColor: verifyGreen,
                )
              : SizedBox.shrink(),
          titleSpacing: 0,
          backgroundColor: navyBlue,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: <StretchMode>[
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
            ],
            background: widget.isLoading
                ? SizedBox.shrink()
                : getBgWidgetForAppBar(context),
          ),
        ),
      ),
    );
  }

  Widget getBgWidgetForAppBar(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: <Widget>[
        SizedBox.expand(
          child: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            height: 30,
            color: Colors.white,
          ),
        ),

        /// Banner image
        widget.userType == 'channel'
            ? getProfileCoverChannel()
            : getProfileCover(),

        /// UserModel avatar, message icon, profile edit
        widget.userType == 'channel'
            ? getUserDetailsChannel()
            : getUserDetails(),
      ],
    );
  }

  Widget getProfileCoverChannel() {
    return Container(
      height: 200,
      child: widget.isLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
                backgroundColor: Colors.transparent,
              ),
            )
          : widget.channelDetail == null
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: Colors.transparent,
                  ),
                )
              : getWallpaper(),
    );
  }

  Widget getProfileCover() {
    return Container(
      height: 200,
      child: widget.isLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
                backgroundColor: Colors.transparent,
              ),
            )
          : searchedUser!.userAbout == null
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: Colors.transparent,
                  ),
                )
              : getWallpaper(),
    );
  }

  Widget getWallpaper() {
    if (widget.userType == "channel") {
      return widget.channelDetail!['banner'] == "" ||
              widget.channelDetail!['banner'] == null
          ? Image.asset(
              "assets/images/default_user_wallpaper.png",
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed("/photo-viewer",
                    arguments: widget.channelDetail!['banner']);
              },
              child: Container(
                color: navyBlue,
                child: CachedNetworkImage(
                  width: double.infinity,
                  height: double.infinity,
                  errorWidget: wallpaperErrorWidget,
                  imageUrl: widget.channelDetail!['banner'],
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Center(child: CircularLoadingIndicator()),
                  color: blackFont.withOpacity(0.4),
                  colorBlendMode: BlendMode.darken,
                  filterQuality: FilterQuality.high,
                ),
              ),
            );
    } else if (searchedUser!.type!.toLowerCase() == "user") {
      return searchedUser!.wallpaper == "" || searchedUser!.wallpaper == null
          ? Image.asset(
              "assets/images/default_user_wallpaper.png",
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed("/photo-viewer",
                    arguments: searchedUser!.wallpaper);
              },
              child: Container(
                color: navyBlue,
                child: CachedNetworkImage(
                  width: double.infinity,
                  height: double.infinity,
                  errorWidget: wallpaperErrorWidget,
                  imageUrl: searchedUser!.wallpaper!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Center(child: CircularLoadingIndicator()),
                  color: blackFont.withOpacity(0.4),
                  colorBlendMode: BlendMode.darken,
                  filterQuality: FilterQuality.high,
                ),
              ),
            );
    } else {
      return searchedUser!.userAbout!.wallpaper == ""
          ? Image.asset(
              "assets/images/default_user_wallpaper.png",
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed("/photo-viewer",
                    arguments: searchedUser!.userAbout!.wallpaper);
              },
              child: Container(
                color: navyBlue,
                child: CachedNetworkImage(
                  width: double.infinity,
                  height: double.infinity,
                  errorWidget: wallpaperErrorWidget,
                  imageUrl: searchedUser!.userAbout!.wallpaper,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Center(child: CircularLoadingIndicator()),
                  color: blackFont.withOpacity(0.4),
                  colorBlendMode: BlendMode.darken,
                  filterQuality: FilterQuality.high,
                ),
              ),
            );
    }
  }

  Widget getUserDetailsChannel() {
    ///get the list of user subscribe to channel
    List<UserFollowers> userFollowers = [];

    channelDetail!['members'].forEach((k, v) {
      // debugPrint("Fola Key : $k, Value : $v");
      UserFollowers user = UserFollowers(
        avatar: v,
        userName: '',
        fullName: '',
        accountType: '',
      );
      user.avatar = v;
      userFollowers.add(user);
    });

    String channelUsername = getGroupUsername(
        channelDetail!['group_username'] != null
            ? channelDetail!['group_username']
            : channelDetail!['group_name']);

    return Positioned(
      top: searchedUser?.bio == null || searchedUser!.bio!.isEmpty ? 180 : 150,
      left: 20,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AnimatedContainer(
                width: 96,
                duration: Duration(milliseconds: 500),
                decoration: BoxDecoration(
                    border: Border.all(color: white, width: 3),
                    shape: BoxShape.circle),
                child: GestureDetector(
                  onTap: () {
                    // Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                    //     arguments: getInitials(
                    //         widget.channelDetail!['owner']['full_name']));
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Center(child: getUserProfilePic()),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        messageDecoderWithEmoji(
                                widget.channelDetail!['group_name'] ?? "") ??
                            "",
                        style: TextStyle(fontSize: 12, color: yarnBlack),
                      )),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "@$channelUsername",
                        style: TextStyle(fontSize: 12, color: yarnBlack),
                      )),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    getSubscriberBtn(),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          getUserBioStringWidget(),
          Row(
            children: [
              getJoinedDate(),
              SizedBox(width: 20),
              //get subscriber
              Column(
                children: [
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      // if (searchedUser?.userName != null) {
                      //   NavigationUtil.push(
                      //     context,
                      //     screen: FollowingAndFollowersList(
                      //         userName: searchedUser?.userName ?? "", index: 1),
                      //   );
                      // }
                    },
                    child: Row(
                      children: [
                        Text(
                          getFormattedViewCount(
                              noOfViews: searchedUser!.followers!,
                              addViewText: false,
                              showZeroViews: true),
                          style: TextStyle(
                              color: blackFont,
                              fontWeight: FontWeight.bold,
                              fontSize: 10),
                        ),
                        SizedBox(width: 2),
                        Text(
                          searchedUser!.followers! > 1
                              ? 'Subscribers'
                              : 'Subscriber',
                          style: TextStyle(color: blackFont, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              usernameNamePhoto(),
              followersWidget(userImages: userFollowers),
            ],
          ),
          // SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget getUserDetails() {
    Color borderColor = getUserTypeColor(user: searchedUser!);
    return Positioned(
      top: 170,
      left: 20,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AnimatedContainer(
                width: 96,
                duration: Duration(milliseconds: 500),
                decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 3),
                    shape: BoxShape.circle),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                        arguments: searchedUser!.avatar);
                  },
                  child: searchedUser?.type?.toLowerCase() != "user" &&
                          searchedUser?.rating != 0.0
                      ? Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Center(child: getUserProfilePic()),
                            Positioned.fill(
                              bottom: -12,
                              left: 0,
                              right: 0,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(60),
                                    border: Border.all(
                                      color: dividerColor,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                  child: getRating(
                                      numberOfRating:
                                          searchedUser?.rating.toInt()),
                                ),
                              ),
                            )
                          ],
                        )
                      : getUserProfilePic(),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        messageDecoderWithEmoji(
                                searchedUser!.displayName() ?? "") ??
                            "",
                        style: TextStyle(fontSize: 12, color: yarnBlack),
                      )),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: userNameWithVerifiedIcon(
                        name: "@${searchedUser!.userName ?? ''}",
                        isVerified: searchedUser!.isVerified,
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: HexColor("#151515"),
                          fontWeight: FontWeight.w500,
                        ),
                        verifiedIconColor: verifyGreen,
                        verifiedIconSize: 15),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    getActionOnUsersBtn(),
                    getFollowUnFollowBtn(),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          getUserBioStringWidget(),
          // displayUserAddress(),
          // getContact(),
          getJoinedDate(),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getFollowUnFollowWidget(),
              UserFollowersView(
                userName: searchedUser!.userName,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getUserProfilePic() {
    if (widget.userType == 'channel') {
      if (widget.channelDetail!['avatar'] == null) {
        return CircleAvatar(
          backgroundColor: navyBlue,
          radius: 25,
          child: Text(
            getInitials(widget.channelDetail!['group_name']).toUpperCase(),
            style: TextStyle(color: white, fontWeight: FontWeight.w700),
          ),
        );
      } else {
        return CircleAvatar(
          radius: 25,
          backgroundImage: CachedNetworkImageProvider(
            widget.channelDetail!['avatar'],
          ),
        );
      }
    } else {
      if (searchedUser!.avatar! == null) {
        return CircleAvatar(
          backgroundColor: navyBlue,
          radius: 25,
          child: Text(
            getInitials(searchedUser!.fullName!).toUpperCase(),
            style: TextStyle(color: white, fontWeight: FontWeight.w700),
          ),
        );
      } else {
        return CircleAvatar(
          radius: 25,
          backgroundImage: CachedNetworkImageProvider(
            searchedUser!.avatar!,
          ),
        );
      }
    }
  }

  Widget getSubscriberBtn() {
    return InkWell(
      onTap: channelDetail!['is_member'] == true
          ? () {
              showToast(message: 'You are already a member');
            }
          : () {
              if (mounted) setState(() => isLoading = true);
              MessageAuth()
                  .joinChannel(
                      channelId: channelDetail!['id'],
                      userName: userBloc.user.userName!)
                  .then((value) {
                if (mounted) setState(() => isLoading = false);

                if (value) {
                  showToast(message: "Joined channel successfully");
                  channelDetail!['is_member'] = true;
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
              child: CircularLoadingIndicator(color: naturalGreen),
            )
          : Container(
              height: 30,
              width: 80,
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color:
                      channelDetail!['is_member'] == true ? blackFont : white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: HexColor("#292929"), width: 1)),
              child: Center(
                child: Text(
                  channelDetail!['is_member'] == true ? 'Member' : 'Join',
                  style: TextStyle(
                    fontSize: 10,
                    color:
                        channelDetail!['is_member'] == true ? white : blackFont,
                    fontWeight: FontWeight.w600,
                  ),
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

    if (searchedUser!.userName == userBloc.user.userName) {
      return SizedBox.shrink();
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

  Widget usernameNamePhoto() {
    return Column(
      children: [
        SizedBox(height: 12),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed("/photo-viewer",
                    arguments: searchedUser!.avatar!);
              },
              child: CircleAvatar(
                radius: 15,
                backgroundImage: CachedNetworkImageProvider(
                  searchedUser!.avatar!,
                ),
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      messageDecoderWithEmoji(
                              searchedUser!.displayName() ?? "") ??
                          "",
                      style: TextStyle(
                          fontSize: 10,
                          color: HexColor("#151515"),
                          fontWeight: FontWeight.w600),
                    )),
                Align(
                  alignment: Alignment.centerLeft,
                  child: userNameWithVerifiedIcon(
                      name: "@${channelDetail!['owner']['username'] ?? ''}",
                      isVerified: searchedUser!.isVerified,
                      textStyle: TextStyle(
                        fontSize: 10,
                        color: HexColor("#151515"),
                        fontWeight: FontWeight.w600,
                      ),
                      verifiedIconColor: verifyGreen,
                      verifiedIconSize: 12),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget getJoinedDate() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Row(
          children: [
            //Icon(Icons.calendar_month_rounded, size: 16),
            SvgPicture.asset("yarn/calendar".toSVG()),
            SizedBox(width: 12),
            Text(
              '${getDate(searchedUser!.dateJoined!)}',
              style: TextStyle(
                  color: HexColor("78797A"),
                  fontSize: 10,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ],
    );
  }

  String getDate(String date) {
    if (date.isEmpty) {
      return '';
    }
    DateTime dateTime = DateTime.parse(date).toLocal();

    String month = DateFormat("MMMM").format(dateTime);
    String year = DateFormat("y").format(dateTime);

    return widget.userType == 'channel'
        ? 'Created $month $year'
        : 'Joined $month $year';
  }

  Widget getFollowUnFollowWidget() {
    if (searchedUser?.following != null && searchedUser?.followers != null) {
      return Row(
        children: [
          InkWell(
            onTap: () {
              if (searchedUser?.userName != null) {
                NavigationUtil.push(
                  context,
                  screen: FollowingAndFollowersList(
                      userName: searchedUser?.userName ?? ""),
                );
              }
            },
            child: Row(
              children: [
                Text(
                  getFormattedViewCount(
                      noOfViews: searchedUser?.following ?? 0,
                      addViewText: false,
                      showZeroViews: true),
                  style:
                      TextStyle(color: blackFont, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 2),
                Text('Following'),
              ],
            ),
          ),
          SizedBox(width: 30),
          InkWell(
            onTap: () {
              if (searchedUser?.userName != null) {
                NavigationUtil.push(
                  context,
                  screen: FollowingAndFollowersList(
                      userName: searchedUser?.userName ?? "", index: 1),
                );
              }
            },
            child: Row(
              children: [
                Text(
                  getFormattedViewCount(
                      noOfViews: searchedUser!.followers!,
                      addViewText: false,
                      showZeroViews: true),
                  style:
                      TextStyle(color: blackFont, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 2),
                Text(
                  searchedUser!.followers! > 1 ? 'Followers' : 'Follower',
                ),
              ],
            ),
          ),
        ],
      );
    }
    return SizedBox.shrink();
  }

  Widget getUserBioStringWidget() {
    if (searchedUser?.bio == null || searchedUser!.bio!.isEmpty) {
      return SizedBox.shrink();
    } else {
      return Container(
        margin: EdgeInsets.only(right: 6),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Linkify(
              onOpen: _onOpen,
              text: searchedUser?.bio == null
                  ? ''
                  : messageDecoderWithEmoji("${searchedUser?.bio}" "") ?? "",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 14),
              maxLines: 6,
            ),
            SizedBox(height: 8),
          ],
        ),
      );
    }
  }

  _onOpen(LinkableElement link) async {
    if (await canLaunchUrl(Uri.parse(link.url))) {
      await launchUrl(Uri.parse(link.url));
    } else {
      throw 'Could not launch $link';
    }
  }

  Future<void> getSearchedUser({bool load = true}) async {
    late CustomerProfile user;
    searchedUserName = searchedUser.toString();

    if (load) {
      widget.isLoading = true;
      if (mounted) setState(() {});
    }

    try {
      user = await UserAuth().fetchCustomerProfileWithAuth(searchedUserName);
    } catch (e) {
      Navigator.pop(context);
      showToast(message: 'User not found');
    }

    searchedUser = user;

    checkCurrentUserIsInRequestList();

    widget.isLoading = false;
    if (mounted) setState(() {});
  }

  void checkCurrentUserIsInRequestList() async {
    UserBloc _userBloc = Provider.of<UserBloc>(context, listen: false);
    debugPrint("is In Request List -");

    if (_userBloc.user.userName != searchedUser?.userName) {
      UserAuth().checkInRequest(searchedUser?.userName).then((value) {
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

  List<Widget> actionButtons() {
    return [
      getQRCodeIcon(),
      widget.userType == 'channel' ? SizedBox() : getSearchIcon(),
      menuIcon(),
      SizedBox(width: 16),
    ];
  }

  Widget getChatIcon() {
    return searchedUser!.conversationId != ""
        ? Row(
            children: [
              chatIcon(),
              SizedBox(
                width: 8,
              ),
            ],
          )
        : Container();
  }

  Widget getQRCodeIcon() {
    return Row(
      children: [
        qrCodeIcon(),
        SizedBox(
          width: 8,
        ),
      ],
    );
  }

  Widget getSearchIcon() {
    return searchedUser!.type!.toLowerCase() != "user"
        ? Row(
            children: [
              searchIcon(),
              SizedBox(
                width: 8,
              ),
            ],
          )
        : Container();
  }

  Widget qrCodeIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.qr_code,
        size: 16,
        color: Colors.white,
      ),
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.PHOTO_VIEWER, arguments: searchedUser!.qrCode);
      },
      backgroundColor: lightGrey.withOpacity(0.1),
      enableMargin: false,
    );
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
          Navigator.pushNamed(context, '/chat-screen',
              arguments: {"recipientUserName": searchedUser!.userName});
        },
        backgroundColor: lightGrey.withOpacity(0.1),
        enableMargin: true,
        margin: 8,
      ),
    );
  }

  Widget searchIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.search,
        size: 16,
        color: Colors.white,
      ),
      onTap: () {
        Navigator.of(context).pushNamed(Routes.USER_PRODUCT_AND_SERVICE_SEARCH,
            arguments: {"searchedUser": searchedUser});
      },
      backgroundColor: lightGrey.withOpacity(0.1),
      enableMargin: false,
    );
  }

  Widget menuIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.menu,
        size: 16,
        color: Colors.white,
      ),
      onTap: () {
        userProfileActionsSheet(context);
      },
      backgroundColor: lightGrey.withOpacity(0.1),
      enableMargin: true,
    );
  }

  Widget getAddConnectionBtn() {
    return Row(
      children: [
        getAddConnectionIcon(),
        SizedBox(width: 8),
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
                .cancelOrRejectContactRequest(searchedUser!)
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
            UserAuth().makeContactRequest(searchedUser!).then((value) async {
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

  Widget getActionOnUsersBtn() {
    if (isLoadingFriendRequest) {
      return Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularLoadingIndicator(),
          ),
          SizedBox(width: 24),
        ],
      );
    }

    if (searchedUser!.userName != userBloc.user.userName) {
      if (searchedUser!.conversationId != "") {
        return Row(
          children: [
            chatIcon(),
            SizedBox(width: 8),
          ],
        );
      } else {
        return Row(
          children: [
            getAddConnectionBtn(),
            SizedBox(width: 8),
          ],
        );
      }
    }

    return SizedBox.shrink();
  }

  void userProfileActionsSheet(BuildContext context) {
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

    if (searchedUser!.userName == userBloc.user.userName) {
      list.add(
        bottomSheetItem(
          title: AppLocalization.of(context)!.createAPost,
          iconData: Icons.add_circle_outlined,
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed(Routes.CREATE_BLOG);
          },
        ),
      );

      list.add(
        bottomSheetItem(
          title: "Edit Profile",
          iconData: SlydoAppIcon.edit,
          onTap: () async {
            Navigator.pop(context);
            await Navigator.of(context).pushNamed('/add-edit-user-bio',
                arguments: {"searchedUser": searchedUser});

            getSearchedUser();
            // if (result != null) {
            //   if (result is Map) {
            //     searchedUser!.userAbout = result["userAbout"];
            //     searchedUser!.avatar = result["user_avatar"];
            //
            //     debugPrint('SEARCHED USER -> ${result["userAbout"]} ');
            //     debugPrint('SEARCHED USER -> ${searchedUser!.userAbout!.bio} ');
            //   }
            //
            //   if (mounted) setState(() {});
            // }
          },
        ),
      );
    }

    if (searchedUser?.type?.toLowerCase() != "user") {
      list.add(
        bottomSheetItem(
          title: "Terms and Condition",
          iconData: Icons.insert_link_sharp,
          onTap: () async {
            Navigator.pop(context);
            String termsAndConditionUrl =
                "https://slydo.co/store/terms-and-conditions/${searchedUser?.userName}/";
            try {
              if (!await launchUrl(Uri.parse(termsAndConditionUrl)))
                throw 'Could not launch $termsAndConditionUrl';
            } catch (error) {
              debugPrint("Error:- $error");
            }
          },
        ),
      );
    }

    list.add(
      bottomSheetItem(
        title: "Share",
        iconData: SlydoAppIcon.share,
        onTap: () {
          Navigator.pop(context);
          String merchantUrl =
              'https://merchant.slydo.co/${searchedUser!.userName!}/payme';
          var shareBody = userBloc.user.type != 'User'
              ? merchantUrl
              : "https://slydo.co/" + searchedUser!.userName!;
          Share.share(shareBody, subject: "${searchedUser!.displayName()}");
        },
      ),
    );

    list.add(
      bottomSheetItem(
        title: "Share in Chat",
        iconData: SlydoAppIcon.text_message,
        isLast: searchedUser!.userName == userBloc.user.userName,
        onTap: () async {
          Navigator.pop(context);
          sendProfileToUsersInChat();
        },
      ),
    );

    list.add(
      bottomSheetItem(
        title: "Share As A Yarn",
        iconData: SlydoAppIconNew.dashboard_yarn,
        isLast: searchedUser!.userName == userBloc.user.userName,
        onTap: () async {
          Navigator.pop(context);
          shareAsYarn();
        },
      ),
    );

    if (searchedUser!.userName != userBloc.user.userName) {
      if (searchedUser?.type?.toLowerCase() != "user") {
        list.add(
          bottomSheetItem(
            title: "Write Review",
            iconData: SlydoAppIcon.star,
            isLast: userBloc.user.userName == searchedUser!.userName,
            onTap: () async {
              Navigator.pop(context);
              Navigator.of(context).pushNamed("/add-review",
                  arguments: {"searchedUser": searchedUser});
            },
          ),
        );
      }
    }

    ///check if the profile is not for channel
    if (widget.userType != 'channel') {
      if (userBloc.user.userName != searchedUser!.userName) {
        list.addAll(
          [
            bottomSheetItem(
              title: "Message",
              iconData: SlydoAppIcon.message,
              onTap: () {
                Navigator.pop(context);
                if (!isOwner) {
                  Navigator.of(context)
                      .pushNamed('/compose_message', arguments: {
                    'recipient': searchedUser!.userName,
                    'subject': "",
                  });
                }
              },
            ),
            bottomSheetItem(
              title: "Send",
              iconData: SlydoAppIcon.send,
              onTap: () {
                if (appConfigurationModel?.enablePayment == true) {
                  UserAuth()
                      .fetchCustomerProfile(searchedUserName)
                      .then((fetchedUser) {
                    customerProfileBloc.customer = fetchedUser;
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed('/send-payment',
                        arguments: <String, dynamic>{
                          'isFromProfile': false,
                          'recipient': searchedUser!.userName
                        });
                  });
                } else {
                  showToast(message: 'Payment not available at the moment');
                }
              },
            ),
            bottomSheetItem(
                title: "Request",
                iconData: SlydoAppIcon.receive,
                isLast: true,
                onTap: () {
                  if (appConfigurationModel?.enablePayment == true) {
                    UserAuth()
                        .fetchCustomerProfile(searchedUserName)
                        .then((fetchedUser) {
                      customerProfileBloc.customer = fetchedUser;
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/request-payment',
                          arguments: <String, dynamic>{
                            'recipient': searchedUser!.userName,
                            'isFromProfile': false,
                            'isRequest': true
                          });
                    });
                  } else {
                    showToast(message: 'Payment not available at the moment');
                  }
                }),
          ],
        );
      }
      if (userBloc.user.type == "User") {
        list.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: bottomSheetItem(
              title: "Upgrade",
              icon: Icon(Icons.upgrade_rounded),
              isLast: userBloc.user.userName == searchedUser!.userName,
              onTap: () async {
                Navigator.pop(context);
                upgradeAccount();
              },
              extraWidget: getColoredLabeledWidget(
                text: 'Pro',
                color: naturalGreen,
              ),
            ),
          ),
        );
      }
    }

    return list;
  }

  void upgradeAccount() async {
    Navigator.pushNamed(context, "/choose-subscriptions");

    // await getAccountBalance();
    // if (accountBalance! > 0) {
    //   Navigator.pushNamed(context, "/upgrade-user-profile");
    // } else {
    //   showToast(message: "Insufficient funds!!");
    // }
  }

  void sendProfileToUsersInChat() async {
    List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    Map<String, dynamic> itemData = searchedUser?.toJsonToSendInToChat() ?? {};

    if (listOfRecipient != null && listOfRecipient.isNotEmpty) {
      for (ChatConversation? recipient in listOfRecipient) {
        if (recipient != null) {
          addUserProfileToChat(itemData: itemData, recipientUser: recipient);
        }
      }
    }
  }

  void addUserProfileToChat(
      {Map<String, dynamic>? itemData,
      required ChatConversation recipientUser,
      String? url}) async {
    Map<String, dynamic> data = {
      "meta_data": messageDecoderWithEmoji(jsonEncode(itemData)),
      "check_id": Uuid().v4(),
      "conversation_id": recipientUser.conversationId,
      "author": userBloc.user.userName,
      "message": "user-profile",
      "kind": "user-profile",
      "created_at": DateTime.now().toUtc().toString(),
      "type": "chatroom_message",
    };

    debugPrint("Data To be send:- $data");

    await sendDataToSocket(data);
  }

  Future shareAsYarn() async {
    NavigationUtil.push(context,
        screen: ShareAsAyarnScreen(
            askCategories: yarnDashboardBloc.yarnCategories,
            shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
            userProfile: searchedUser,
            callback: (params) async {
              params..attachment = {"profile": searchedUser?.toJson()};
              bool data = await YarnAuth().addYarnAndQuestion(params, '');
              if (data) {
                showToast(message: "Share in Yarn successfully created");
              }
            }));
  }
}
