import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_about_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_info.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_product_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_qr_code_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_service_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/common.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/keep_alive_page.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class UserProfileScreen extends StatefulWidget {
  final arguments;
  UserProfileScreen({@required this.arguments});

  @override
  _UserProfileScreenState createState() =>
      _UserProfileScreenState(arguments: arguments);
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  var arguments;

  bool isLoading = true;

  TabController _tabController;

  _UserProfileScreenState({this.arguments});

  int currentIndex = 0;
  CustomerProfile searchedUser;
  String searchedUserName;

  // this variable will responsible for is the user is owner of the products and add
  // edit button on the product if user is owner
  bool isOwner = false;
  UserBloc userBloc;
  double top;

  // pageview controller
  PageController pageController;

  CustomerProfileBloc customerProfileBloc;

  ScrollController _scrollController;
  bool appBarStatus = true;

  bool isUserIsSimpleUser = false;

  @override
  void initState() {
    initializeVariables();

    super.initState();
  }

  void initializeVariables() async {
    await getSearchedUser();
    currentIndex = arguments['index'] ?? 0;
    pageController = PageController(initialPage: currentIndex);
    if (mounted) {
      setState(() {});
    }

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> getSearchedUser() async {
    searchedUserName = arguments['searchedUserName'];
    isLoading = true;
    if (mounted) setState(() {});

    CustomerProfile user =
        await UserAuth().fetchCustomerProfileWithAuth(searchedUserName);
    searchedUser = user;
    isLoading = false;
    if (searchedUser.type.toLowerCase() == "user") {
      isUserIsSimpleUser = true;
    }

    if (mounted) setState(() {});

    _tabController = TabController(
        length: searchedUser.type.toLowerCase() == "user" ? 1 : 5, vsync: this);

    if (mounted) setState(() {});
  }

  void _scrollListener() {
    if (isShrink != appBarStatus) {
      appBarStatus = isShrink;
      if (mounted) setState(() {});
    }
  }

  bool get isShrink {
    return _scrollController.hasClients &&
        _scrollController.offset > (150 - kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);

    if (isLoading) {
      return Scaffold(
        appBar: appBar(),
        body: Center(
          child: CircularLoadingIndicator(),
        ),
      );
    }

    if (userBloc.user.userName == searchedUser.userName) {
      isOwner = true;
    }

    return WillPopScope(
      onWillPop: () async {
        return await Future.value(true);
      },
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          body: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
                return <Widget>[
                  getAppbar(context),
                  getUserBio(),
                  SliverPersistentHeader(
                    floating: true,
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        isScrollable: searchedUser.type.toLowerCase() == "user"
                            ? false
                            : true,
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
              body: SafeArea(bottom: false, top: false, child: tabViews())),
        ),
      ),
    );
  }

  void changeIndex(int index) {
    currentIndex = index;
    if (mounted) setState(() {});
    pageController.jumpToPage(currentIndex);
  }

  Widget getAppbar(var context) {
    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverSafeArea(
        top: false,
        bottom: false,
        sliver: SliverAppBar(
          forceElevated: false,
          expandedHeight: 250,
          elevation: 0,
          stretch: true,
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
                    searchedUser.fullName,
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
                          searchedUser.nickname ?? searchedUser.fullName,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: blackFont),
                        ),
                        Text(
                          "@" + searchedUser.userName,
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
          : searchedUser.userAbout == null
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: Colors.transparent,
                  ),
                )
              : searchedUser.userAbout.wallpaper == ""
                  ? Image.asset(
                      "assets/images/home_screen_background.png",
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed("/photo-viewer",
                            arguments: searchedUser.userAbout.wallpaper);
                      },
                      child: CachedNetworkImage(
                        width: double.infinity,
                        height: double.infinity,
                        imageUrl: searchedUser.userAbout.wallpaper,
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

  Widget getProfilePhoto() {
    Color borderColor = getUserTypeColor(user: searchedUser);

    return Container(
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
                Navigator.of(context)
                    .pushNamed("/photo-viewer", arguments: searchedUser.avatar);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  color: Colors.white,
                  child: CachedNetworkImage(
                    height: 88,
                    width: 88,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    imageUrl: searchedUser.avatar,
                  ),
                ),
              ),
            ),
          ),
        ],
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
    return searchedUser.conversationId != ""
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
    return searchedUser.type.toLowerCase() != "user"
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
            arguments: {"recipientUserName": searchedUser.userName});
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

  List<Widget> getTabs() {
    List<Widget> tabs = [];

    if (searchedUser.type.toLowerCase() == "user") {
      tabs.add(Tab(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: currentIndex == 0 ? 14 : 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            shape: BoxShape.rectangle,
            color: currentIndex == 0 ? navyBlue.withOpacity(0.1) : Colors.white,
          ),
          child: Text(
            "QR code",
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: currentIndex == 0 ? navyBlue : blackFont,
              fontSize: 14,
              fontWeight: currentIndex == 0 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ));
    } else {
      tabs.addAll([
        Tab(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: currentIndex == 0 ? 14 : 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              shape: BoxShape.rectangle,
              color:
                  currentIndex == 0 ? navyBlue.withOpacity(0.1) : Colors.white,
            ),
            child: Text(
              "Info",
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: currentIndex == 0 ? navyBlue : blackFont,
                fontSize: 14,
                fontWeight:
                    currentIndex == 0 ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
        Tab(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: currentIndex == 1 ? 14 : 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              shape: BoxShape.rectangle,
              color:
                  currentIndex == 1 ? navyBlue.withOpacity(0.1) : Colors.white,
            ),
            child: Text(
              "QR code",
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: currentIndex == 1 ? navyBlue : blackFont,
                fontSize: 14,
                fontWeight:
                    currentIndex == 1 ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
        Tab(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: currentIndex == 2 ? 14 : 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              shape: BoxShape.rectangle,
              color:
                  currentIndex == 2 ? navyBlue.withOpacity(0.1) : Colors.white,
            ),
            child: Text(
              "Products",
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: currentIndex == 2 ? navyBlue : blackFont,
                fontSize: 14,
                fontWeight:
                    currentIndex == 2 ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
        Tab(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: currentIndex == 3 ? 14 : 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              shape: BoxShape.rectangle,
              color:
                  currentIndex == 3 ? navyBlue.withOpacity(0.1) : Colors.white,
            ),
            child: Text(
              "Services",
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: currentIndex == 3 ? navyBlue : blackFont,
                fontSize: 14,
                fontWeight:
                    currentIndex == 3 ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
        Tab(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: currentIndex == 4 ? 14 : 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              shape: BoxShape.rectangle,
              color:
                  currentIndex == 4 ? navyBlue.withOpacity(0.1) : Colors.white,
            ),
            child: Text(
              "Hours",
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: currentIndex == 4 ? navyBlue : blackFont,
                fontSize: 14,
                fontWeight:
                    currentIndex == 4 ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        )
      ]);
    }

    return tabs;
  }

  Widget tabViews() {
    return PageView(
      controller: pageController,
      children: getTabViewLayout(),
      onPageChanged: (int index) {
        _tabController.index = index;
        currentIndex = index;
        debugPrint("currentIndex:- $currentIndex");
        if (mounted) setState(() {});
      },
    );
  }

  List<Widget> getTabViewLayout() {
    List<Widget> list = [];

    if (searchedUser.type.toLowerCase() == "user") {
      list.add(KeepAlivePage(
        child: UserQRCodeScreen(user: searchedUser),
      ));
    } else {
      list.addAll([
        KeepAlivePage(
          child: UserInfo(user: searchedUser, changeIndex: changeIndex),
        ),
        KeepAlivePage(
          child: UserQRCodeScreen(user: searchedUser),
        ),
        KeepAlivePage(
          child: UserProductList(
            user: searchedUser,
            isOwner: isOwner,
          ),
        ),
        KeepAlivePage(
          child: UserServiceList(
            user: searchedUser,
            isOwner: isOwner,
          ),
        ),
        KeepAlivePage(
          child: UserAboutScreen(user: searchedUser),
        ),
      ]);
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
        isLoading ? "" : searchedUser.fullName,
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
          isLoading ? "" : searchedUser.fullName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
          ),
        ),
        Text(
          isLoading ? "" : searchedUser.userName,
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

    if (searchedUser.userName == userBloc.user.userName) {
      list.add(
        bottomSheetItem(
          title: "Edit",
          icon: SlydoAppIcon.edit,
          onTap: () async {
            Navigator.pop(context);
            var result = await Navigator.of(context).pushNamed(
                '/add-edit-user-bio',
                arguments: {"searchedUser": searchedUser});

            if (result != null) {
              if (result is Map) {
                searchedUser.userAbout = result["userAbout"];
                searchedUser.avatar = result["user_avatar"];
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

    list.add(
      bottomSheetItem(
        title: "Share",
        icon: SlydoAppIcon.share,
        onTap: () {
          Navigator.pop(context);
          var shareBody = "${searchedUser.fullName}\n" +
              "http://slydo.co/user/" +
              searchedUser.userName;
          Share.share(shareBody, subject: "${searchedUser.fullName}");
        },
      ),
    );

    list.add(
      bottomSheetItem(
        title: "Share in Chat",
        isLast: userBloc.user.userName == searchedUser.userName,
        icon: SlydoAppIcon.text_message,
        onTap: () async {
          Navigator.pop(context);
          sendProfileToUsersInChat();
        },
      ),
    );

    if (userBloc.user.userName != searchedUser.userName) {
      list.addAll([
        bottomSheetItem(
          title: "Message",
          icon: SlydoAppIcon.message,
          onTap: () {
            Navigator.pop(context);
            if (!isOwner) {
              Navigator.of(context).pushNamed('/compose_message', arguments: {
                'recipient': searchedUser.userName,
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
    List<ChatConversation> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    Map<String, dynamic> itemData = searchedUser.toJsonToSendInToChat();

    listOfRecipient.forEach((recipient) {
      addUserProfileToChat(itemData: itemData, recipientUser: recipient);
    });
  }

  void addUserProfileToChat(
      {Map<String, dynamic> itemData,
      ChatConversation recipientUser,
      String url}) async {
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
      data: ThemeData(accentColor: Colors.white),
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
