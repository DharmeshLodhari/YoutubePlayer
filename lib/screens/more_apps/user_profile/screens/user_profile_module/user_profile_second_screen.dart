import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/UserAbout.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module/user_about_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module/user_info.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module/user_product_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module/user_service_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/common.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/expandable_text.dart';
import 'package:Slydo/widget/keep_alive_page.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:sizer/sizer.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class UserProfileSecondScreen extends StatefulWidget {
  var arguments;
  UserProfileSecondScreen({@required this.arguments});

  @override
  _UserProfileSecondScreenState createState() =>
      _UserProfileSecondScreenState(arguments: arguments);
}

class _UserProfileSecondScreenState extends State<UserProfileSecondScreen>
    with SingleTickerProviderStateMixin {
  var arguments;

  bool isLoading = false;

  TabController _tabController;

  _UserProfileSecondScreenState({this.arguments});

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

  UserAbout searchedUserAbout;
  bool isSearchedUserAboutLoading = false;

  @override
  void initState() {
    getSearchedUser();

    currentIndex = arguments['index'] ?? 0;
    pageController = PageController(initialPage: currentIndex);
    if (mounted) {
      setState(() {});
    }

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  void getSearchedUser() async {
    searchedUser = arguments['searchedUser'] ?? null;
    if (searchedUser == null) {
      searchedUserName = arguments['searchedUserName'];
      isLoading = true;
      if (mounted) setState(() {});

      await UserAuth().fetchCustomerProfile(searchedUserName).then((user) {
        searchedUser = user;
        isLoading = false;
        if (mounted) setState(() {});
      });
    }

    _tabController = TabController(
        length: searchedUser.type.toLowerCase() == "user" ? 1 : 4, vsync: this);

    isSearchedUserAboutLoading = true;
    if (mounted) setState(() {});

    searchedUserAbout =
        await UserAuth().fetchUserAboutInfo(userName: searchedUser.userName);

    isSearchedUserAboutLoading = false;
    if (mounted) setState(() {});
  }

  void _scrollListener() {
    if (isShrink != appBarStatus) {
      setState(() {
        appBarStatus = isShrink;
      });
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
      child: Scaffold(
        body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
              return <Widget>[
                getAppbar(context),
                getUserBio(),
                searchedUser.type.toLowerCase() == "user"
                    ? SliverToBoxAdapter(
                        child: Container(),
                      )
                    : SliverPersistentHeader(
                        floating: true,
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: _tabController,
                            labelPadding: EdgeInsets.zero,
                            indicator: BoxDecoration(),
                            onTap: (int index) {
                              currentIndex = index;
                              setState(() {});
                              pageController.animateToPage(currentIndex,
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.linear);
                            },
                            tabs: getTabs(),
                          ),
                        ),
                      ),
              ];
            },
            body: SafeArea(bottom: false, top: false, child: tabViews())),
      ),
    );
  }

  Widget getAppbar(var context) {
    Color borderColor = getUserTypeColor(user: searchedUser);

    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverSafeArea(
        top: false,
        bottom: true,
        sliver: SliverAppBar(
          forceElevated: false,
          expandedHeight: 200,
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
                      fontSize: 18.0.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Container(),
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
                          padding: EdgeInsets.only(top: 50),
                          height: 30,
                          color: Colors.white,
                        ),
                      ),
                      // Container(height: 50, color: Colors.black),

                      /// Banner image
                      getProfileCover(),

                      /// UserModel avatar, message icon, profile edit
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 500),
                                padding: EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: borderColor, width: 2),
                                    shape: BoxShape.circle),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                    color: Colors.white,
                                    child: CachedNetworkImage(
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.fill,
                                      filterQuality: FilterQuality.high,
                                      imageUrl: searchedUser.avatar,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            getEditBioBtn()
                          ],
                        ),
                      )
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
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              color: Colors.white,
              child: isSearchedUserAboutLoading
                  ? SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          searchedUser.fullName,
                          style: TextStyle(
                              fontSize: 22.0.sp,
                              fontWeight: FontWeight.w600,
                              color: blackFont),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          searchedUser.userName,
                          style: TextStyle(fontSize: 14.0.sp, color: darkGrey),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: getUserAboutSection(),
                        ),
                      ],
                    ),
            ),
          );
  }

  Widget getProfileCover() {
    return Container(
      height: 180,
      child: isSearchedUserAboutLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
                backgroundColor: Colors.transparent,
              ),
            )
          : searchedUserAbout == null
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: Colors.transparent,
                  ),
                )
              : searchedUserAbout.wallpaper == ""
                  ? Image.asset(
                      "assets/images/home_screen_background.png",
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      width: double.infinity,
                      height: double.infinity,
                      imageUrl: searchedUserAbout.wallpaper,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Center(child: CircularLoadingIndicator()),
                      color: blackFont.withOpacity(0.4),
                      colorBlendMode: BlendMode.darken,
                      filterQuality: FilterQuality.high,
                    ),
    );
  }

  List<Widget> getUserAboutSection() {
    List<Widget> list = [];

    if (searchedUserAbout.bio != null) {
      list.addAll([
        ExpandableText(searchedUserAbout.bio),
        SizedBox(
          height: 16,
        ),
      ]);
    }

    if (searchedUserAbout.address != null) {
      list.addAll([
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Text(
                searchedUserAbout.address,
                // textAlign: TextAlign.justify,
              ),
            )
          ],
        ),
        SizedBox(
          height: 8,
        ),
      ]);
    }

    if (searchedUserAbout.contact != null) {
      list.addAll([
        Row(
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
            SizedBox(
              width: 12,
            ),
            Expanded(child: Text(searchedUserAbout.contact))
          ],
        )
      ]);
    }

    return list;
  }

  List<Widget> actionButtons() {
    return [
      isSearchedUserAboutLoading
          ? Container()
          : searchedUser.userName == userBloc.user.userName
              ? editProfileCoverIcon()
              : Container(),
      isSearchedUserAboutLoading
          ? Container()
          : searchedUser.userName == userBloc.user.userName
              ? SizedBox(
                  width: 8,
                )
              : Container(),
      menuIcon(),
      SizedBox(
        width: 16,
      ),
    ];
  }

  Widget editProfileCoverIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.image,
        size: 16,
        color: Colors.white,
      ),
      onTap: () {
        pickImage();
      },
      backgroundColor: lightGrey.withOpacity(0.1),
      enableMargin: true,
    );
  }

  void pickImage() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text(
                AppLocalization.of(context).selectTheImageSource,
                style: TextStyle(fontSize: 18, color: blackFont),
              ),
              actions: <Widget>[
                MaterialButton(
                  child: Text(
                    AppLocalization.of(context).camera,
                    style: TextStyle(fontSize: 16, color: blackFont),
                  ),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text(
                    "Gallery",
                    style: TextStyle(fontSize: 16, color: blackFont),
                  ),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));

    if (imageSource != null) {
      final file =
          await ImagePicker().getImage(source: imageSource, imageQuality: 70);
      if (file != null) {
        try {
          isSearchedUserAboutLoading = true;
          if (mounted) setState(() {});

          searchedUserAbout.wallpaper = file.path;

          searchedUserAbout = await UserAuth()
              .addOrUpdateUserBio(searchedUserAbout)
              .catchError((error) {
            debugPrint("Cannot Update Cover : " + error.toString());
            isSearchedUserAboutLoading = false;
            if (mounted) setState(() {});
          });

          userBloc.userAbout = searchedUserAbout;

          isSearchedUserAboutLoading = false;
          if (mounted) setState(() {});
        } catch (err) {
          isSearchedUserAboutLoading = false;
          if (mounted) setState(() {});
          Toast.show(err.toString(), context,
              backgroundColor: blackFont, textColor: Colors.white);
          debugPrint("Cannot Update Cover : " + err.toString());
        }
      }
    }
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
    if (searchedUser.type.toLowerCase() != "user") {
      tabs = [
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
                color: currentIndex == 0 ? navyBlue : darkGrey,
                fontSize: 12.0.sp,
                fontWeight:
                    currentIndex == 0 ? FontWeight.w700 : FontWeight.w600,
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
              "Products",
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: currentIndex == 1 ? navyBlue : darkGrey,
                fontSize: 12.0.sp,
                fontWeight:
                    currentIndex == 1 ? FontWeight.w700 : FontWeight.w600,
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
              "Services",
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: currentIndex == 2 ? navyBlue : darkGrey,
                fontSize: 12.0.sp,
                fontWeight:
                    currentIndex == 2 ? FontWeight.w700 : FontWeight.w600,
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
              "Hours",
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: currentIndex == 3 ? navyBlue : darkGrey,
                fontSize: 12.0.sp,
                fontWeight:
                    currentIndex == 3 ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ];
    } else {
      tabs = [
        Tab(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              shape: BoxShape.rectangle,
              color:
                  currentIndex == 0 ? navyBlue.withOpacity(0.1) : Colors.white,
            ),
            child: Text(
              "Info",
              style: TextStyle(
                color: currentIndex == 0 ? navyBlue : blackFont,
                fontSize: 14,
                fontWeight:
                    currentIndex == 0 ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ];
    }
    return tabs;
  }

  Widget tabViews() {
    return searchedUser.type.toLowerCase() == "user"
        ? KeepAlivePage(child: UserInfo(user: searchedUser))
        : PageView(
            controller: pageController,
            children: [
              KeepAlivePage(child: UserInfo(user: searchedUser)),
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
                  child: UserAboutScreen(
                      user: searchedUser,
                      searchedUserAbout: searchedUserAbout)),
            ],
            onPageChanged: (int index) {
              _tabController.index = currentIndex;
              currentIndex = index;
              setState(() {});

            },
          );
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
            color: blackFont, fontSize: 16.0.sp, fontWeight: FontWeight.bold),
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

  List<Widget> generateBottomSheetItem() {
    List<Widget> list = [
      bottomSheetItem(
        title: "Share",
        isLast: userBloc.user.userName == searchedUser.userName,
        icon: SlydoAppIcon.share,
        onTap: () {
          Navigator.pop(context);
          var shareBody = "${searchedUser.fullName}\n" +
              "http://slydo.co/user/" +
              searchedUser.userName;
          Share.share(shareBody, subject: "${searchedUser.fullName}");
        },
      ),
    ];

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

  Widget getEditBioBtn() {
    return isSearchedUserAboutLoading
        ? Container()
        : userBloc.user.userName == searchedUser.userName
            ? Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 20, right: 20),
                      child: GestureDetector(
                        onTap: () async {
                          var result = await Navigator.of(context).pushNamed(
                              '/add-edit-user-bio',
                              arguments: {"userAbout": searchedUserAbout});

                          if (result != null) {
                            if (result is UserAbout) {
                              searchedUserAbout = result;
                              if (mounted) setState(() {});
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: navyBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              color: navyBlue,
                              fontSize: 15.0.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container();
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

    return new Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
