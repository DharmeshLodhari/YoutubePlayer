import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_about_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_info.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_product_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_qr_code_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_review_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_service_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/keep_alive_page.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../../../locale/app_localization.dart';

// ignore: must_be_immutable
class UserProfileScreen extends StatefulWidget {
  final arguments;
  User? user;
  UserProfileScreen({required this.arguments, this.user});

  @override
  _UserProfileScreenState createState() =>
      _UserProfileScreenState(arguments: arguments);
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  var arguments;

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
  late UserBloc userBloc;
  double? top;

  // pageview controller
  PageController? pageController;

  late CustomerProfileBloc customerProfileBloc;

  ScrollController? _scrollController;
  bool appBarStatus = true;

  bool isUserIsSimpleUser = false;
  bool showProductTab = false;
  bool showServiceTab = false;

  @override
  void initState() {
    initializeVariables();

    super.initState();
  }

  void initializeVariables() async {
    await getSearchedUser();
    currentIndex = arguments['index'] ?? 0;
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
    searchedUserName = arguments['searchedUserName'];
    isLoading = true;
    if (mounted) setState(() {});

    CustomerProfile user =
        await UserAuth().fetchCustomerProfileWithAuth(searchedUserName);
    searchedUser = user;
    debugPrint("searchUserName===>${searchedUser!.nickName}");

    if (searchedUser!.type!.toLowerCase() == "user") {
      isUserIsSimpleUser = true;
    }

    int tabCount = 2;

    if (searchedUser?.type?.toLowerCase() != "user") {
      tabCount = 5;
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
    Map<String, dynamic>? data;
    try {
      data = await ShoppingAuthService()
          .listOfProduct("", "", userName: searchedUser?.userName);
    } catch (error) {}
    if (data != null) {
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
                getUserBio(),
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
    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverSafeArea(
        top: false,
        bottom: false,
        sliver: SliverAppBar(
          forceElevated: false,
          expandedHeight: 240,
          elevation: 0,
          stretch: true,
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
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Container(),
          titleSpacing: 0,
          backgroundColor: navyBlue,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: <StretchMode>[
              StretchMode.zoomBackground,
              StretchMode.blurBackground
            ],
            background: isLoading
                ? SizedBox.shrink()
                : Stack(
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
                      // Container(height: 50, color: Colors.black),

                      /// Banner image
                      getProfileCover(),

                      /// UserModel avatar, message icon, profile edit
                      getProfilePhoto(),
                    ],
                  ),
          ),
        ),
      ),
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
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          searchedUser!.displayName()!.length <= 53
                              ? searchedUser!.displayName()!
                              : '${searchedUser!.displayName()!.substring(0, 54)}...',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: blackFont),
                        ),
                        Text(
                          searchedUser!.userName!,
                          style: TextStyle(
                              fontSize: 14.0,
                              color: darkGrey,
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
            ),
          );
  }

  Widget getProfileCover() {
    return Container(
      height: 206,
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
              : searchedUser!.userAbout!.wallpaper == ""
                  ? Image.asset(
                      "assets/images/home_screen_background.png",
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
                    ),
    );
  }

  Widget getProfilePhoto() {
    Color borderColor = getUserTypeColor(user: searchedUser!);
    return Container(
      padding: EdgeInsets.only(bottom: 16),
      alignment: Alignment.bottomLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 3),
                shape: BoxShape.circle),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed("/photo-viewer",
                    arguments: searchedUser!.avatar);
              },
              child: searchedUser?.type?.toLowerCase() != "user" &&
                      searchedUser?.rating != 0.0
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        getUserProfilePic(),
                        Positioned.fill(
                          bottom: -14,
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
                                  numberOfRating: searchedUser?.rating.toInt()),
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
    );
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
        Navigator.of(context).pushNamed("/user-product-and-service-search",
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
        getTabUI(title: "Post", tabIndex: index),
      );
    } else {
      int index = 0;
      tabs.add(
        getTabUI(title: "QR code", tabIndex: index),
      );
      index++;
      tabs.add(
        getTabUI(title: "Info", tabIndex: index),
      );
      index++;
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
        getTabUI(title: "Post", tabIndex: index),
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
      list.add(
        KeepAlivePage(
          child: UserInfo(user: searchedUser, changeIndex: changeIndex),
        ),
      );
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
      list.add(bottomSheetItem(
        title: AppLocalization.of(context)!.createAPost,
        icon: Icons.add_circle_outlined,
        onTap: () {
          Navigator.pop(context);
          Navigator.of(context).pushNamed('/create-blog');
        },
      ));

      list.add(
        bottomSheetItem(
          title: "Edit bio",
          icon: SlydoAppIcon.edit,
          onTap: () async {
            Navigator.pop(context);
            var result = await Navigator.of(context).pushNamed(
                '/add-edit-user-bio',
                arguments: {"searchedUser": searchedUser});

            if (result != null) {
              if (result is Map) {
                searchedUser!.userAbout = result["userAbout"];
                searchedUser!.avatar = result["user_avatar"];
              }

              if (mounted) setState(() {});
            }
          },
        ),
      );
      list.add(
        bottomSheetItem(
          title: "Change Password",
          icon: Icons.lock,
          onTap: () async {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/change-password');
          },
        ),
      );
    }

    if (searchedUser?.type?.toLowerCase() != "user") {
      list.add(
        bottomSheetItem(
          title: "Terms and Condition",
          icon: Icons.insert_link_sharp,
          onTap: () async {
            Navigator.pop(context);
            String termsAndConditionUrl =
                "https://slydo.co/store/terms-and-conditions/${searchedUser?.userName}/";
            try {
              if (!await launch(termsAndConditionUrl))
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
        icon: SlydoAppIcon.share,
        onTap: () {
          Navigator.pop(context);
          var shareBody = "https://slydo.co/" + searchedUser!.userName!;
          Share.share(shareBody, subject: "${searchedUser!.displayName()}");
        },
      ),
    );

    list.add(
      bottomSheetItem(
        title: "Share in Chat",
        icon: SlydoAppIcon.text_message,
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
            icon: SlydoAppIcon.star,
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
      list.addAll([
        bottomSheetItem(
          title: "Message",
          icon: SlydoAppIcon.message,
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
          icon: SlydoAppIcon.send,
          onTap: () {
            UserAuth()
                .fetchCustomerProfile(searchedUserName)
                .then((fetchedUser) {
              customerProfileBloc.customer = fetchedUser;
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/send-payment',
                  arguments: <String, bool>{'isFromProfile': false});
            });
          },
        ),
        bottomSheetItem(
            title: "Request",
            icon: SlydoAppIcon.receive,
            isLast: true,
            onTap: () {
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
            }),
      ]);
    }

    return list;
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
