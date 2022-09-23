import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/screens/moments/screens/moments_screen.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/following_and_follwers_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_about_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_product_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_review_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_service_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/keep_alive_page.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../../../locale/app_localization.dart';
import '../../../../../locator.dart';
import '../../../../../utils/navigation_util.dart';
import '../../../../moments/screens/moment_detail_page.dart';
import '../../../../moments/screens/moments_service.dart';
import '../../models/UserAbout.dart';

// ignore: must_be_immutable
class UserProfileScreen extends StatefulWidget {
  final arguments;
  UserProfileScreen({required this.arguments});

  @override
  _UserProfileScreenState createState() =>
      _UserProfileScreenState(arguments: arguments);
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  var arguments;
  late UserBloc userBloc;

  bool isLoading = true;

  TabController? _tabController;

  _UserProfileScreenState({this.arguments});

  int currentIndex = 0;
  BehaviorSubject<int> selectedIndexStream = BehaviorSubject<int>();
  CustomerProfile? searchedUser;
  String? searchedUserName;

  // this variable will responsible for is the user is owner of the products and add
  // edit button on the product if user is owner
  bool isOwner = false;
  double? top;

  // pageview controller
  PageController? pageController;

  late CustomerProfileBloc customerProfileBloc;

  ScrollController? _scrollController;
  bool appBarStatus = true;

  bool isUserIsSimpleUser = false;
  bool showProductTab = false;
  bool showPostsTab = false;
  bool showServiceTab = false;
  bool myMomentsLoading = false;
  AppConfigurationModel? appConfigurationModel;

  bool isInRequestList = false;
  bool isLoadingFollowingAction = false;

  @override
  void initState() {
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;
    initializeVariables();

    // WidgetsBinding.instance!.addPostFrameCallback((_) => getSizeAndPosition());
    // Future.delayed(Duration(microseconds: 1)).then((value) {
    //   setState(() {
    //     _visible = false;
    //   });
    // });
    // Future.delayed(Duration(seconds: 2)).then((value) {
    //   debugPrint('CARD BOXES --> ${_flexibleSpaceBarKey.currentContext}');
    //
    //   getSizeAndPosition();
    //   setState(() {
    //     _visible = false;
    //   });
    // });
    super.initState();
  }

  void initializeVariables() async {
    await getSearchedUser();
    currentIndex = arguments['index'] ?? 0;
    debugPrint('CURRENT INDEX -> $currentIndex');
    selectedIndexStream.sink.add(currentIndex);
    pageController = PageController(initialPage: currentIndex);
    if (mounted) setState(() {});

    _scrollController = ScrollController();
    _scrollController?.addListener(_scrollListener);
  }

  Future<void> dispose() async {
    super.dispose();
    selectedIndexStream.close();
    _scrollController?.removeListener(_scrollListener);
    _scrollController?.dispose();
  }

  Future<void> getSearchedUser({bool load = true}) async {
    late CustomerProfile user;
    searchedUserName = arguments['searchedUserName'];

    if (load) {
      isLoading = true;
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

    int tabCount = 1;

    showPostsTab = await getIsShowPost();

    if (searchedUser!.type!.toLowerCase() == "user") {
      isUserIsSimpleUser = true;

      if (showPostsTab) {
        tabCount++;
      }
    } else {
      tabCount = 3;
      showProductTab = await getIsShowProduct();
      showServiceTab = await getIsShowService();

      if (showProductTab) {
        tabCount++;
      }
      if (showServiceTab) {
        tabCount++;
      }

      if (showPostsTab) {
        tabCount++;
      }
    }

    _tabController = TabController(length: tabCount, vsync: this);
    isLoading = false;
    if (mounted) setState(() {});
  }

  void _scrollListener() {
    if (isShrink != appBarStatus) {
      appBarStatus = isShrink;
      if (mounted) setState(() {});
    }
  }

  bool get isShrink {
    return (_scrollController?.hasClients ?? false) &&
        (_scrollController?.offset ?? 0) > (150 - kToolbarHeight);
  }

  Future<bool> getIsShowProduct() async {
    debugPrint('IS SHOW PRODUCT <-->');

    Map<String, dynamic>? data;
    try {
      data = await ShoppingAuthService()
          .listOfProduct("", "", userName: searchedUser?.userName);
    } catch (error) {}
    if (data != null) {
      debugPrint('IS SHOW PRODUCT ---> $data');
      int count = data["count"] ?? 0;
      if (count > 0) return true;
    }

    return false;
  }

  Future<bool> getIsShowService() async {
    Map<String, dynamic>? data;
    try {
      data = await ShoppingAuthService()
          .listServicesByProvider("", "", userName: searchedUser?.userName);
    } catch (error) {}
    if (data != null) {
      int count = data["count"] ?? 0;
      if (count > 0) return true;
    }

    return false;
  }

  Future<bool> getIsShowPost() async {
    debugPrint('IS SHOW POST <-->');

    Map<String, dynamic>? data;
    try {
      data = await UserPostAuth()
          .listUserPosts(next: '', userName: searchedUser!.userName);
    } catch (error) {}
    if (data != null) {
      debugPrint('IS SHOW POST ---> $data');
      int count = data["count"] ?? 0;
      if (count > 0) return true;
    }

    return false;
  }

  double getBgHeightOfAppBar(String bio, bool hasAddress, bool hasContact) {
    int bioLength = bio.length;
    debugPrint('GET BIO LEN -> $bioLength');
    debugPrint('GET ADDRESS -> $hasAddress');
    debugPrint('GET CONTACT -> $hasContact');

    double? height;

    if (bioLength == 0) {
      if (hasAddress && hasContact) {
        height = 380;
      } else if (hasAddress || hasContact) {
        height = 360;
      } else {
        height = 340;
      }
    } else if (bioLength <= 50) {
      if (hasAddress && hasContact) {
        height = 420;
      } else if (hasAddress || hasContact) {
        height = 400;
      } else {
        height = 380;
      }
    } else if (bioLength <= 100) {
      if (hasAddress && hasContact) {
        height = 460;
      } else if (hasAddress || hasContact) {
        height = 460;
      } else {
        height = 400;
      }
    } else if (bioLength <= 200) {
      if (hasAddress && hasContact) {
        height = 460;
      } else if (hasAddress || hasContact) {
        height = 480;
      } else {
        height = 460;
      }
    }

    debugPrint('GET HEIGHT -> $height');

    if (height == null) {
      height = 300;
    }

    return height;
  }

  void checkCurrentUserIsInRequestList() async {
    UserBloc _userBloc = Provider.of<UserBloc>(context, listen: false);
    debugPrint("is In Request List -");

    if (_userBloc.user.userName != searchedUser!.userName) {
      UserAuth().checkInRequest(searchedUser!.userName).then((value) {
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

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);

    if (isLoading) {
      return Scaffold(
        appBar: appBar() as PreferredSizeWidget?,
        body: Center(
          child: CircularLoadingIndicator(),
        ),
      );
    }

    if (userBloc.user.userName == searchedUser?.userName) {
      isOwner = true;
    }

    return WillPopScope(
      onWillPop: () async {
        return await Future.value(true);
      },
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
              return <Widget>[
                getAppbar(context),
                SliverPersistentHeader(
                  key: UniqueKey(),
                  floating: true,
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelPadding: EdgeInsets.zero,
                      indicator: BoxDecoration(),
                      onTap: (int index) {
                        changeIndex(index);
                      },
                      tabs: getTabs(),
                    ),
                  ),
                )
              ];
            },
            body: SafeArea(
              bottom: false,
              top: false,
              child: tabViews(),
            ),
          ),
        ),
      ),
    );
  }

  void changeIndex(int index) {
    currentIndex = index;

    pageController?.jumpToPage(currentIndex);

    setState(() {});
  }

  Widget getAppbar(BuildContext context) {
    bool hasAddress =
        searchedUser!.userAbout?.userAddress?.addressLine1 != null &&
            searchedUser!.userAbout!.userAddress!.addressLine1!.isNotEmpty;
    bool hasContact = searchedUser?.userAbout?.contact != null &&
        searchedUser!.userAbout!.contact.isNotEmpty;

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
          title: isShrink
              ? userNameWithVerifiedIcon(
                  name: searchedUser!.displayName()!,
                  isVerified: searchedUser!.isVerified,
                  textStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  verifiedIconColor: Colors.white,
                )
              : Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    SizedBox.expand(
                      child: Container(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top),
                        height: 30,
                        color: Colors.white,
                      ),
                    ),

                    /// Banner image
                    getProfileCover(),

                    /// UserModel avatar, message icon, profile edit
                    getUserDetails(),
                  ],
                ),
          titleSpacing: 0,
          backgroundColor: navyBlue,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: <StretchMode>[
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
            ],
            background: isLoading ? SizedBox.shrink() : getBgWidgetForAppBar(),
          ),
        ),
      ),
    );
  }

  Widget getBgWidgetForAppBar() {
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
        getProfileCover(),

        /// UserModel avatar, message icon, profile edit
        getUserDetails(),
      ],
    );
  }

  void getCurrentUserMoment() {
    myMomentsLoading = true;
    if (mounted) setState(() {});
    MomentsService()
        .getMomentsWithOwnerName(
            ownerName: searchedUser!.userName!, fromUserProfile: true)
        .then((momentsModelList) {
      debugPrint('MY MOMENTS -> ${momentsModelList.isNotEmpty}');

      myMomentsLoading = false;
      if (mounted) setState(() {});
      if (momentsModelList.isNotEmpty) {
        NavigationUtil.push(
          context,
          screen: MomentsDetailsScreen(
            indexOfMoment: 0,
            // Wrapping it around a List ([]) because the moment detail screen requires a List<List<MomentModel>>
            momentsModelList: [momentsModelList],
          ),
        );
      } else {
        if (searchedUser!.userName! != getLoggedInUserName(context)) {
          showToast(
              message: '${searchedUser!.userName!} does not have any moment.');
        } else {
          showToast(message: 'You do not have any moment.');
        }
      }
    }).catchError((e) {
      myMomentsLoading = false;
      if (mounted) setState(() {});
      showToast(message: e.toString());
    });
  }

  Widget getProfileCover() {
    return Container(
      height: 200,
      child: isLoading
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
    if (searchedUser!.type!.toLowerCase() == "user") {
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

  Widget getUserDetails() {
    Color borderColor = getUserTypeColor(user: searchedUser!);
    return Positioned(
      top: 160,
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
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width - 116,
                  padding:
                      const EdgeInsets.only(top: 40.0, left: 10, right: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
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
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: userNameWithVerifiedIcon(
              name: searchedUser!.displayName()!,
              isVerified: searchedUser!.isVerified,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '@${searchedUser!.userName!}',
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 14.0, color: darkGrey, fontWeight: FontWeight.w400),
            ),
          ),
          SizedBox(height: 12),
          getUserBioStringWidget(),
          displayUserAddress(),
          getContact(),
          getJoinedDate(),
          SizedBox(height: 12),
          getFollowUnFollowWidget(),
        ],
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
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: blackFont,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: greyBorderColor, width: 2)),
          child: Text(
            'Following',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
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
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: greyBorderColor, width: 2)),
        child: Text(
          'Follow',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
            Icon(Icons.calendar_month_rounded, size: 16),
            SizedBox(width: 12),
            Text('${getDate(searchedUser!.dateJoined!)}'),
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

    return 'Joined $month $year';
  }

  Widget getFollowUnFollowWidget() {
    if (searchedUser!.following != null && searchedUser!.followers != null) {
      return InkWell(
        onTap: () {
          NavigationUtil.push(
            context,
            screen:
                FollowingAndFollowersList(userName: searchedUser!.userName!),
          );
        },
        child: Row(
          children: [
            Text(
              getFormattedViewCount(
                  noOfViews: searchedUser!.following!,
                  addViewText: false,
                  showZeroViews: true),
              style: TextStyle(color: blackFont, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 2),
            Text('Following'),
            SizedBox(width: 30),
            Text(
              getFormattedViewCount(
                  noOfViews: searchedUser!.followers!,
                  addViewText: false,
                  showZeroViews: true),
              style: TextStyle(color: blackFont, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 2),
            Text(
              searchedUser!.followers! > 1 ? 'Followers' : 'Follower',
            ),
          ],
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget getUserBioStringWidget() {
    print(searchedUser?.bio);
    if (searchedUser?.bio == null || searchedUser!.bio!.isEmpty)
      return SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(right: 4),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Linkify(
            onOpen: _onOpen,
            text: searchedUser?.bio == null
                ? ''
                : messageDecoderWithEmoji(searchedUser!.bio!)!,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  _onOpen(LinkableElement link) async {
    if (await canLaunchUrl(Uri.parse(link.url))) {
      await launchUrl(Uri.parse(link.url));
    } else {
      throw 'Could not launch $link';
    }
  }

  Widget getContact() {
    if (searchedUser?.userAbout?.contact != null &&
        searchedUser!.userAbout!.contact.isNotEmpty) {
      return Row(
        children: [
          Icon(
            Icons.call,
            color: blackFont,
            size: 14,
          ),
          SizedBox(width: 12),
          Expanded(child: Text(searchedUser!.userAbout!.contact)),
        ],
      );
    }
    return SizedBox.shrink();
  }

  Widget displayUserAddress() {
    return searchedUser?.userAbout?.userAddress?.addressLine1 != null &&
            searchedUser!.userAbout!.userAddress!.addressLine1!.isNotEmpty
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    SlydoAppIcon.location,
                    color: blackFont,
                    size: 12,
                  ),
                  SizedBox(width: 12),
                  GetFullAddressWidget(userAbout: searchedUser!.userAbout!)
                ],
              ),
              SizedBox(height: 8),
            ],
          )
        : SizedBox.shrink();
  }

  Widget getUserProfilePic() {
    return CircleAvatar(
      radius: 35,
      backgroundImage: CachedNetworkImageProvider(
        searchedUser!.avatar!,

        // fit: BoxFit.fill,
        // filterQuality: FilterQuality.high,
        // imageUrl: searchedUser!.avatar!,
        // errorWidget: imageErrorWidget,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: CachedNetworkImage(
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        imageUrl: searchedUser!.avatar!,
        errorWidget: imageErrorWidget,
      ),
    );
  }

  List<Widget> actionButtons() {
    return [
      getQRCodeIcon(),
      getSearchIcon(),
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
        borderRadius: BorderRadius.circular(10),
      ),
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
          if (isInRequestList) {
            UserAuth()
                .cancelOrRejectContactRequest(searchedUser!)
                .then((value) {
              if (value) {
                showToast(message: "Friend request Canceled");
              } else {
                showToast(message: "Friend request Canceled unsuccessfully");
              }
              getSearchedUser();
            });
          } else {
            UserAuth().makeContactRequest(searchedUser!).then((value) {
              if (value) {
                showToast(message: "Friend Request Sent !!");
              } else {
                showToast(message: "Request Not Sent.. ");
              }
              getSearchedUser();
            });
          }
        },
        backgroundColor: lightGrey.withOpacity(0.1),
        enableMargin: false,
      ),
    );
  }

  Widget getActionOnUsersBtn() {
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
          color: greyBorderColor,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: RoundedBackgroundIcon(
        height: 34,
        width: 34,
        icon: Icon(
          SlydoAppIcon.text_message,
          size: 16,
          color: blackFont,
        ),
        onTap: () {
          Navigator.pushNamed(context, '/chat-screen',
              arguments: {"recipientUserName": searchedUser!.userName});
        },
        backgroundColor: lightGrey.withOpacity(0.1),
        enableMargin: false,
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
        userProfileActionsSheet();
      },
      backgroundColor: lightGrey.withOpacity(0.1),
      enableMargin: true,
    );
  }

  Widget getTabUI({String title = "", @required int? tabIndex}) {
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: _tabController?.index == tabIndex ? 16 : 18,
            vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          shape: BoxShape.rectangle,
          color: _tabController?.index == tabIndex
              ? navyBlue.withOpacity(0.1)
              : Colors.white,
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.visible,
          style: TextStyle(
            color: _tabController?.index == tabIndex ? navyBlue : blackFont,
            fontSize: 14,
            fontWeight: _tabController?.index == tabIndex
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget tabViews() {
    return PageView(
      controller: pageController,
      children: getTabViewLayout(),
      onPageChanged: (int index) {
        _tabController!.index = index;
        currentIndex = index;
        if (mounted) setState(() {});
      },
    );
  }

  List<Widget> getTabs() {
    List<Widget> tabs = [];

    if (searchedUser?.type?.toLowerCase() == "user") {
      int index = 0;
      tabs.add(
        getTabUI(title: "Moments", tabIndex: index),
      );
      index++;
      if (showPostsTab) {
        tabs.add(
          getTabUI(title: "Posts", tabIndex: index),
        );
        index++;
      }

      // tabs.add(
      //   getTabUI(title: "QR code", tabIndex: index),
      // );
    } else {
      int index = 0;
      tabs.add(
        getTabUI(title: "Moments", tabIndex: index),
      );
      index++;
      // tabs.add(
      //   getTabUI(title: "QR code", tabIndex: index),
      // );
      // index++;
      // tabs.add(
      //   getTabUI(title: "Info", tabIndex: index),
      // );
      // index++;
      if (showProductTab) {
        tabs.add(
          getTabUI(title: "Products", tabIndex: index),
        );
        index++;
      }
      if (showServiceTab) {
        tabs.add(
          getTabUI(title: "Services", tabIndex: index),
        );
        index++;
      }
      if (showPostsTab) {
        tabs.add(
          getTabUI(title: "Posts", tabIndex: index),
        );
        index++;
      }
      tabs.add(
        getTabUI(title: "Reviews", tabIndex: index),
      );
      index++;
      tabs.add(
        getTabUI(title: "Hours", tabIndex: index),
      );
    }
    return tabs;
  }

  List<Widget> getTabViewLayout() {
    List<Widget> list = [];

    if (searchedUser!.type!.toLowerCase() == "user") {
      list.add(
        KeepAlivePage(
          child: MomentsTab(searchedUser: searchedUser!),
        ),
      );
      if (showPostsTab) {
        list.add(
          KeepAlivePage(
            child: UserPostList(user: searchedUser),
          ),
        );
      }
      // list.add(
      //   KeepAlivePage(
      //     child: UserQRCodeScreen(user: searchedUser),
      //   ),
      // );
    } else {
      list.add(
        KeepAlivePage(
          child: MomentsTab(searchedUser: searchedUser!),
        ),
      );
      // list.add(
      //   KeepAlivePage(
      //     child: UserQRCodeScreen(user: searchedUser),
      //   ),
      // );
      // list.add(
      //   KeepAlivePage(
      //     child: UserInfo(user: searchedUser, changeIndex: changeIndex),
      //   ),
      // );

      if (showProductTab) {
        list.add(
          KeepAlivePage(
            child: UserProductList(
              user: searchedUser,
              isOwner: isOwner,
            ),
          ),
        );
      }
      if (showServiceTab) {
        list.add(
          KeepAlivePage(
            child: UserServiceList(
              user: searchedUser,
              isOwner: isOwner,
            ),
          ),
        );
      }

      if (showPostsTab) {
        list.add(
          KeepAlivePage(
            child: UserPostList(user: searchedUser),
          ),
        );
      }

      list.add(
        KeepAlivePage(
          child: Center(child: UserReviewList(user: searchedUser)),
        ),
      );
      list.add(
        KeepAlivePage(
          child: UserAboutScreen(user: searchedUser),
        ),
      );
    }
    return list;
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          searchedUser = null;
          Navigator.pop(context);
        },
      ),
      title: isLoading
          ? SizedBox.shrink()
          : userNameWithVerifiedIcon(
              name: searchedUser!.displayName()!,
              isVerified: searchedUser!.isVerified),
    );
  }

  void userProfileActionsSheet() {
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
            var result = await Navigator.of(context).pushNamed(
                '/add-edit-user-bio',
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

    if (userBloc.user.userName != searchedUser!.userName) {
      list.addAll(
        [
          bottomSheetItem(
            title: "Message",
            iconData: SlydoAppIcon.message,
            onTap: () {
              Navigator.pop(context);
              if (!isOwner) {
                Navigator.of(context).pushNamed('/compose_message', arguments: {
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
                      arguments: <String, bool>{'isFromProfile': false});
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
                        arguments: <String, bool>{
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

    Map<String, dynamic> itemData = searchedUser!.toJsonToSendInToChat();

    listOfRecipient.forEach((recipient) {
      addUserProfileToChat(itemData: itemData, recipientUser: recipient!);
    });
  }

  void addUserProfileToChat(
      {Map<String, dynamic>? itemData,
      required ChatConversation recipientUser,
      String? url}) async {
    Map<String, dynamic> data = {
      "meta_data": jsonEncode(itemData),
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
}

class GetFullAddressWidget extends StatefulWidget {
  final UserAbout userAbout;
  const GetFullAddressWidget({Key? key, required this.userAbout})
      : super(key: key);

  @override
  _GetFullAddressWidgetState createState() => _GetFullAddressWidgetState();
}

class _GetFullAddressWidgetState extends State<GetFullAddressWidget> {
  int? stateId;
  String? stateName;
  bool isStateLoading = true;
  Map<int, String> statesMap = {};

  @override
  void initState() {
    super.initState();
    UserAbout? userAbout =
        Provider.of<UserBloc>(context, listen: false).userAbout;

    if (userAbout?.userAddress?.state != null) {
      stateId = userAbout!.userAddress!.state;
    }

    UserAuth().getStates().then((value) {
      value.forEach((element) {
        statesMap[element.id!] = element.name!;
      });

      stateName = statesMap[stateId];

      isStateLoading = false;
      if (mounted) setState(() {});
    }).catchError((e) {
      isStateLoading = false;
      if (mounted) setState(() {});
    });
  }

  String getFullAddress() {
    UserAddress? userAddress = widget.userAbout.userAddress;
    List<String> addresses = [];

    if (userAddress?.addressLine1 != null &&
        userAddress!.addressLine1!.isNotEmpty) {
      addresses.add(userAddress.addressLine1!);
    }
    if (userAddress?.addressLine2 != null &&
        userAddress!.addressLine2!.isNotEmpty) {
      addresses.add(userAddress.addressLine2!);
    }
    if (userAddress?.city != null && userAddress!.city!.isNotEmpty) {
      addresses.add(userAddress.city!);
    }
    if (stateName != null && stateName!.isNotEmpty) {
      addresses.add(stateName!);
    }

    return addresses.join(', ').replaceAll('.', '');
  }

  @override
  Widget build(BuildContext context) {
    return isStateLoading
        ? SizedBox(width: 20, height: 20, child: CircularLoadingIndicator())
        : Expanded(
            child: Text(
              getFullAddress(),
              // textAlign: TextAlign.justify,
            ),
          );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    overlapsContent = false;

    return Theme(
      data: ThemeData(
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.white)),
      child: new Container(
        padding: EdgeInsets.only(
          left: 16,
        ),
        color: Colors.white,
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class MomentsTab extends StatefulWidget {
  final CustomerProfile searchedUser;
  const MomentsTab({Key? key, required this.searchedUser}) : super(key: key);

  @override
  _MomentsTabState createState() => _MomentsTabState();
}

class _MomentsTabState extends State<MomentsTab> {
  bool isFirstTime = true;
  String? myMomentsNext = "";
  int? myMomentsCount = 0;
  bool isMyMomentsLoading = false;
  List<MomentsModel> myMomentsList = [];
  ScrollController _myMomentsScrollController = ScrollController();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    getSearchedUserMoments();
  }

  getSearchedUserMoments() async {
    if (!isMyMomentsLoading) {
      if (myMomentsNext != null && !isMyMomentsLoading) {
        if (mounted) {
          setState(() {
            isMyMomentsLoading = true;
          });
        }
        await MomentsService()
            .getMomentsWithOwnerName(ownerName: widget.searchedUser.userName!)
            .then(
          (myMomentsModelList) {
            isMyMomentsLoading = false;
            myMomentsList.addAll(myMomentsModelList);

            if (mounted) setState(() {});

            if (isFirstTime && myMomentsNext != null && myMomentsNext != "") {
              isFirstTime = false;
              getSearchedUserMoments();
            }
          },
        ).catchError(
          (error) {
            isMyMomentsLoading = false;

            if (mounted) setState(() {});

            debugPrint('ERROR GETTING MY MOMENTS -> $error');
          },
        );
      }
    }
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        _refreshPage();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  _refreshPage() {
    isFirstTime = true;
    myMomentsNext = "";
    myMomentsCount = 0;
    isMyMomentsLoading = false;
    myMomentsList = [];
    if (mounted) setState(() {});
    getSearchedUserMoments();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(
          complete: Container(),
          waterDropColor: navyBlue,
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: ListView(
          controller: _myMomentsScrollController,
          children: [
            SizedBox(height: 16),
            isMyMomentsLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: greyBorderColor,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisExtent: 300,
                      ),
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                      },
                    ),
                  )
                : SizedBox.shrink(),
            myMomentsListWidget(),
          ],
        ),
      ),
    );
  }

  bool momentClicked = false;

  Widget myMomentsListWidget() {
    if (myMomentsList.isEmpty) {
      return NoItemInList(
        msg: AppLocalization.of(context)!.noMoments,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        myMomentsNext == "" && isMyMomentsLoading
            ? SizedBox.shrink()
            : GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisExtent: 300,
                  maxCrossAxisExtent: 200,
                ),
                itemCount: myMomentsList.length,
                itemBuilder: (context, index) {
                  return ExploreMomentsCard(
                    index: index,
                    showProfileAvatar: false,
                    onTap: () {
                      if (momentClicked == true) return;
                      momentClicked = true;
                      if (mounted) setState(() {});
                      MomentsService()
                          .getSingleMoment(momentId: myMomentsList[index].id!)
                          .then((momentsModelList) {
                        momentClicked = false;
                        if (mounted) setState(() {});

                        NavigationUtil.push(
                          context,
                          screen: MomentsDetailsScreen(
                            indexOfMoment: 0,
                            // Wrapping it around a List ([]) because the moment detail screen requires a List<List<MomentModel>>
                            momentsModelList: [momentsModelList],
                          ),
                        );
                      }).catchError((e) {
                        momentClicked = false;
                        if (mounted) setState(() {});

                        showToast(message: 'ERROR -> $e');
                      });
                    },
                    exploreMomentsModelList: myMomentsList
                        .map(
                          (e) => ExploreMomentsModel(
                              owner: e.owner,
                              avatar: e.avatar,
                              moments: [myMomentsList[index]],
                              ownerName: e.ownerName),
                        )
                        .toList(),
                  );
                },
              ),
      ],
    );
  }
}
