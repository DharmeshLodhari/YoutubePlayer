import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_about_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_product_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_qr_code_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_review_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_service_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/keep_alive_page.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';
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
  bool showServiceTab = false;
  bool myMomentsLoading = false;
  AppConfigurationModel? appConfigurationModel;
  // final GlobalKey _flexibleSpaceBarKey = GlobalKey();
  // Size? sizeFlexibleSpaceBar;
  // bool _visible = true;

  // getSizeAndPosition() {
  //   debugPrint('CARD BOX 0 --> ${_flexibleSpaceBarKey.currentContext}');
  //
  //   RenderBox? _cardBox =
  //       _flexibleSpaceBarKey.currentContext!.findRenderObject() as RenderBox?;
  //   sizeFlexibleSpaceBar = _cardBox!.size;
  //
  //   debugPrint('CARD BOX 1 --> $_cardBox');
  //   debugPrint('CARD BOX 2 --> $sizeFlexibleSpaceBar');
  // }

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

  Future<void> getSearchedUser() async {
    late CustomerProfile user;
    searchedUserName = arguments['searchedUserName'];
    isLoading = true;
    if (mounted) setState(() {});

    try {
      user = await UserAuth().fetchCustomerProfileWithAuth(searchedUserName);
    } catch (e) {
      Navigator.pop(context);
      showToast(message: 'User not found');
    }

    searchedUser = user;

    if (searchedUser!.type!.toLowerCase() == "user") {
      isUserIsSimpleUser = true;
    }

    int tabCount = 2;

    if (searchedUser?.type?.toLowerCase() != "user") {
      tabCount = 4;
      showProductTab = await getIsShowProduct();
      showServiceTab = await getIsShowService();

      if (showProductTab) {
        tabCount++;
      }
      if (showServiceTab) {
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

  double getBgHeightOfAppBar(String text, bool hasAddress) {
    int len = text.length;
    debugPrint('GET HEIGHT LEN -> $len');
    debugPrint('GET HEIGHT ADDRESS -> $hasAddress');

    double? height;

    if (len == 0) {
      if (hasAddress) {
        height = 320;
        debugPrint('GET HEIGHT -> $height');

        return 320;
      }
      height = 300;
      debugPrint('GET HEIGHT -> $height');

      return 300;
    }

    if (len <= 50) {
      if (hasAddress) {
        height = 350;
        debugPrint('GET HEIGHT -> $height');

        return 350;
      }
      height = 320;
      debugPrint('GET HEIGHT -> $height');

      return 320;
    } else if (len <= 100) {
      if (hasAddress) {
        height = 420;
        debugPrint('GET HEIGHT -> $height');

        return 420;
      }
      height = 340;
      return 340;
    } else if (len <= 200) {
      if (hasAddress) {
        height = 480;
        debugPrint('GET HEIGHT -> $height');

        return 480;
      }
      height = 420;
      debugPrint('GET HEIGHT -> $height');

      return 420;
    }

    if (height == null) {
      height = 450;
      debugPrint('GET HEIGHT -> $height');
    }
    return height;
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

    // searchedUser?.bio =
    //     'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean m';
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
                // Visibility(
                //   visible: _visible,
                //   key: _flexibleSpaceBarKey,
                //   child: getBgWidgetForAppBar(),
                // ),
                getAppbar(context),
                // getUserBio(),
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
              ? Container(
                  child: Text(
                    searchedUser!.displayName()!,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                    getProfilePhoto(),
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
        getProfilePhoto(),
      ],
    );
  }

  Widget getUserBio() {
    return isLoading
        ? Container()
        : SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              color: Colors.white,
              child: isLoading
                  ? SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          truncateString(
                              str: searchedUser!.displayName()!,
                              lengthToTruncateAt: 53),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: blackFont),
                        ),
                        Text(
                          '@${searchedUser!.userName!}',
                          style: TextStyle(
                              fontSize: 14.0,
                              color: darkGrey,
                              fontWeight: FontWeight.w400),
                        ),
                        // InkWell(
                        //   onTap: myMomentsLoading
                        //       ? null
                        //       : () async {
                        //           getCurrentUserMoment();
                        //         },
                        //   child: Container(
                        //     margin: EdgeInsets.symmetric(vertical: 8),
                        //     padding: EdgeInsets.symmetric(
                        //         horizontal: 8, vertical: 4),
                        //     decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(50),
                        //         border:
                        //             Border.all(color: naturalGreen, width: 2)),
                        //     child: Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         myMomentsLoading
                        //             ? SizedBox(
                        //                 width: 20,
                        //                 height: 20,
                        //                 child: CircularLoadingIndicator(),
                        //               )
                        //             : Icon(
                        //                 Icons.play_circle_fill,
                        //                 color: Colors.black,
                        //                 size: 20,
                        //               ),
                        //         SizedBox(width: 6),
                        //         Text(
                        //           'Moments',
                        //           style: TextStyle(
                        //             fontSize: 14,
                        //             color: Colors.black,
                        //             fontWeight: FontWeight.w600,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
            ),
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
    if (userBloc.user.type!.toLowerCase() == "user") {
      return userBloc.user.wallpaper == ""
          ? Image.asset(
              "assets/images/default_user_wallpaper.png",
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed("/photo-viewer",
                    arguments: userBloc.user.wallpaper);
              },
              child: Container(
                color: navyBlue,
                child: CachedNetworkImage(
                  width: double.infinity,
                  height: double.infinity,
                  errorWidget: wallpaperErrorWidget,
                  imageUrl: userBloc.user.wallpaper!,
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

  Widget getProfilePhoto() {
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
                            getUserProfilePic(),
                            Positioned.fill(
                              bottom: -20,
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
                                      horizontal: 8, vertical: 5),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            searchedUser!.displayName()!,
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: blackFont),
                          ),
                          userBloc.user.isVerified != null &&
                                  userBloc.user.isVerified == true
                              ? Icon(
                                  Icons.verified_rounded,
                                  color: navyBlue,
                                  size: 18,
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                      Text(
                        '@${searchedUser!.userName!}',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: darkGrey,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(height: 4),
                      InkWell(
                        onTap: myMomentsLoading
                            ? null
                            : () async {
                                getCurrentUserMoment();
                              },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border:
                                  Border.all(color: naturalGreen, width: 2)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              myMomentsLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularLoadingIndicator(),
                                    )
                                  : Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                              SizedBox(width: 6),
                              Text(
                                'Moments',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          getUserBioStringWidget(),
          SizedBox(height: 8),
          displayUserAddress(),
          SizedBox(height: 8),
          getContact(),
        ],
      ),
    );
  }

  Widget getUserBioStringWidget() {
    print(searchedUser?.bio);
    return Container(
      margin: EdgeInsets.only(right: 4),
      width: MediaQuery.of(context).size.width,
      child: Linkify(
        onOpen: _onOpen,
        text: searchedUser?.bio == null
            ? ''
            : messageDecoderWithEmoji(searchedUser!.bio!)!,
        textAlign: TextAlign.left,
        style: TextStyle(fontSize: 16),
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
    debugPrint('CONTACT -> ${searchedUser?.userAbout?.contact}');
    if (searchedUser?.userAbout?.contact != null &&
        searchedUser!.userAbout!.contact.isNotEmpty) {
      return Row(
        children: [
          RoundedBackgroundIcon(
            height: 32,
            width: 32,
            backgroundColor: iconBtnGrey,
            icon: Icon(
              Icons.call,
              color: blackFont,
              size: 18,
            ),
          ),
          SizedBox(width: 12),
          Expanded(child: Text(searchedUser!.userAbout!.contact)),
        ],
      );
    }
    return SizedBox.shrink();
  }

  Widget displayUserAddress() {
    debugPrint(
        'USER ADDRESS -> ${searchedUser?.userAbout?.userAddress?.addressLine1}');
    return searchedUser?.userAbout?.userAddress?.addressLine1 != null &&
            searchedUser!.userAbout!.userAddress!.addressLine1!.isNotEmpty
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RoundedBackgroundIcon(
                height: 32,
                width: 32,
                backgroundColor: iconBtnGrey,
                icon: Icon(
                  SlydoAppIcon.location,
                  color: blackFont,
                  size: 14,
                ),
              ),
              SizedBox(width: 12),
              GetFullAddressWidget(userAbout: searchedUser!.userAbout!)
            ],
          )
        : SizedBox.shrink();
  }

  Widget getUserProfilePic() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        color: Colors.white,
        child: CachedNetworkImage(
          height: 88,
          width: 88,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
          imageUrl: searchedUser!.avatar!,
          errorWidget: imageErrorWidget,
        ),
      ),
    );
  }

  List<Widget> actionButtons() {
    return [
      getChatIcon(),
      getSearchIcon(),
      menuIcon(),
      SizedBox(
        width: 16,
      ),
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

  Widget chatIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.text_message,
        size: 16,
        color: Colors.white,
      ),
      onTap: () {
        Navigator.pushNamed(context, '/chat-screen',
            arguments: {"recipientUserName": searchedUser!.userName});
      },
      backgroundColor: lightGrey.withOpacity(0.1),
      enableMargin: false,
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

  List<Widget> getTabs() {
    List<Widget> tabs = [];

    if (searchedUser?.type?.toLowerCase() == "user") {
      int index = 0;
      tabs.add(
        getTabUI(title: "QR code", tabIndex: index),
      );
      index++;

      tabs.add(
        getTabUI(title: "Posts", tabIndex: index),
      );
    } else {
      int index = 0;
      tabs.add(
        getTabUI(title: "QR code", tabIndex: index),
      );
      index++;
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
      tabs.add(
        getTabUI(title: "Posts", tabIndex: index),
      );
      index++;
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

  List<Widget> getTabViewLayout() {
    List<Widget> list = [];

    if (searchedUser!.type!.toLowerCase() == "user") {
      list.add(
        KeepAlivePage(
          child: UserQRCodeScreen(user: searchedUser),
        ),
      );
      list.add(
        KeepAlivePage(
          child: UserPostList(user: searchedUser),
        ),
      );
    } else {
      list.add(
        KeepAlivePage(
          child: UserQRCodeScreen(user: searchedUser),
        ),
      );
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
      list.add(
        KeepAlivePage(
          child: UserPostList(user: searchedUser),
        ),
      );
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
      title: Text(
        isLoading ? "" : searchedUser!.displayName()!,
        style: TextStyle(
            color: blackFont, fontSize: 22, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
    );
  }

  Widget getUserName() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 8,
        ),
        Text(
          isLoading ? "" : searchedUser!.displayName()!,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
          ),
        ),
        Text(
          isLoading ? "" : searchedUser!.userName!,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.0,
          ),
        )
      ],
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
        child: Center(child: _tabBar),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
