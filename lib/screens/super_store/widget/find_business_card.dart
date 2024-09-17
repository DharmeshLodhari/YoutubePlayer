import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/screens/user_profile/user_auth.dart';
import 'package:Slydo/screens/yarn/utils/utils.dart';
import 'package:Slydo/screens/yarn/utils/yarn_enum.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FindBusiness extends StatefulWidget {
  CustomerProfile customerProfile;
  final Function()? onProductRefresh;
  final TileRenderPlace tileRenderPlace;
  final Function(String, bool) callback;

  FindBusiness(
      {super.key,
      required this.customerProfile,
      this.tileRenderPlace = TileRenderPlace.YarnTimeLine,
      this.onProductRefresh,
      required this.callback});

  @override
  State<FindBusiness> createState() => _FindBusinessState();
}

class _FindBusinessState extends State<FindBusiness> {
  bool isLoadingFollowingAction = false;
  late UserBloc userBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return getNearByBusiness();
  }

  Widget getNearByBusiness() {
    return Card(
      color: Colors.white,
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: EdgeInsets.zero,
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
              SizedBox(
                  height: getContainerHeight(widget.tileRenderPlace, context),
                  child: getWallpaper()),
              Positioned(
                left: 10,
                top: getContainerHeight(widget.tileRenderPlace, context) - 20,
                child: InkWell(
                  onTap: () {
                    String? image = '';
                    if (widget.customerProfile.avatar! == "" ||
                        widget.customerProfile.avatar! ==
                            "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
                      image = getInitials(widget.customerProfile.fullName!)
                          .toUpperCase();
                    } else {
                      image = widget.customerProfile.avatar!;
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
                          imageUrl: widget.customerProfile.avatar!,
                          name: widget.customerProfile.fullName!)),
                ),
              ),
            ],
          ),
          Container(
            padding: widget.tileRenderPlace == TileRenderPlace.Thiny
                ? const EdgeInsets.only(left: 15, top: 20, bottom: 5, right: 15)
                : const EdgeInsets.only(
                    left: 15, top: 30, bottom: 10, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, Routes.USER_PROFILE, arguments: {
                            "searchedUserName": widget.customerProfile.userName
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  appendStringDot(
                                      messageDecoderWithEmoji(
                                              widget.customerProfile.fullName ??
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
                            Align(
                              alignment: Alignment.centerLeft,
                              child: userNameWithVerifiedIcon(
                                  name: appendStringDot(
                                      messageDecoderWithEmoji(
                                              '@${widget.customerProfile.userName}') ??
                                          "",
                                      widget.tileRenderPlace ==
                                              TileRenderPlace.Thiny
                                          ? 13
                                          : 20),
                                  isVerified: widget.customerProfile.isVerified,
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
                          ],
                        ),
                      ),
                    ),
                    Container(
                      // padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: getFollowUnFollowBtn(),
                    ),
                  ],
                ),
                SizedBox(
                  height: widget.tileRenderPlace == TileRenderPlace.Thiny
                      ? 2.0
                      : 5.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  padding: widget.tileRenderPlace == TileRenderPlace.Thiny
                      ? const EdgeInsets.symmetric(horizontal: 3, vertical: 1)
                      : const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  child: getRating(
                      numberOfRating: widget.customerProfile.rating.toInt()),
                ),
                if (widget.customerProfile.bio!.isNotEmpty ||
                    widget.customerProfile.bio != null) ...[
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          messageDecoderWithEmoji(widget.customerProfile.bio) ??
                              "",
                          style: TextStyle(
                            fontSize:
                                getFontSize(widget.tileRenderPlace, context),
                            fontWeight: FontWeight.w600,
                            color: blackFont,
                          ),
                          maxLines: 1,
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

    if (widget.customerProfile.userName! == userBloc.user.userName) {
      return const SizedBox.shrink();
    }
    if (widget.customerProfile.isFollowing != null &&
        widget.customerProfile.isFollowing == true) {
      return InkWell(
        onTap: () {
          isLoadingFollowingAction = true;
          if (mounted) setState(() {});
          UserAuth()
              .followOrUnfollowUser(widget.customerProfile.userName!,
                  shouldFollow: false)
              .then((value) async {
            if (value == true) {
              // await getSearchedUser(load: false);
              // Call the callback function and pass the username and bool as false
              widget.callback(widget.customerProfile.userName!, false);
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
          height: widget.tileRenderPlace == TileRenderPlace.Thiny ? 20 : 30,
          width: widget.tileRenderPlace == TileRenderPlace.Thiny ? 60 : 80,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              color: blackFont,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: HexColor("#292929"), width: 1)),
          child: Center(
            child: Text(
              'Following',
              style: TextStyle(
                fontSize:
                    widget.tileRenderPlace == TileRenderPlace.Thiny ? 10 : 12,
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
            .followOrUnfollowUser(widget.customerProfile.userName!,
                shouldFollow: true)
            .then((value) async {
          if (value == true) {
            // await getSearchedUser(load: false);
            // Call the callback function and pass the username and bool as true
            widget.callback(widget.customerProfile.userName!, true);
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
        height: widget.tileRenderPlace == TileRenderPlace.Thiny ? 20 : 30,
        width: widget.tileRenderPlace == TileRenderPlace.Thiny ? 60 : 80,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: HexColor("#292929"), width: 1)),
        child: Center(
          child: Text(
            'Follow',
            style: TextStyle(
              fontSize:
                  widget.tileRenderPlace == TileRenderPlace.Thiny ? 11 : 13,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
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
      child: widget.customerProfile.wallpaper == "" ||
              widget.customerProfile.wallpaper == null
          ? Image.asset(
              "assets/images/default_user_wallpaper.png",
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed("/photo-viewer",
                    arguments: widget.customerProfile.wallpaper);
              },
              child: Container(
                color: navyBlue,
                child: CachedNetworkImage(
                  width: double.infinity,
                  // height: double.infinity,
                  errorWidget: wallpaperErrorWidget,
                  imageUrl: widget.customerProfile.wallpaper!,
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

  Future<void> getSearchedUser({bool load = true}) async {
    late CustomerProfile user;

    if (load) {
      isLoadingFollowingAction = true;
      if (mounted) setState(() {});
    }

    try {
      user = await UserAuth().fetchCustomerProfileWithAuth(
          widget.customerProfile.userName!.toString());
    } catch (e) {
      Navigator.pop(context);
      showToast(message: 'User not found');
    }

    widget.customerProfile = user;

    isLoadingFollowingAction = false;
    if (mounted) setState(() {});
  }
}

class CircularUserColorImage extends StatelessWidget {
  final String imageUrl;
  final String name;

  const CircularUserColorImage(
      {super.key, required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: naturalGreen,
            width: 3.0,
          ),
        ),
        child: getUserProfilePic(imageUrl, name),
      ),
    );
  }
}
