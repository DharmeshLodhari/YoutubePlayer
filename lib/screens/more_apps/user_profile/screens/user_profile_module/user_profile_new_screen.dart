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
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
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
class UserProfileNewScreen extends StatefulWidget {
  var arguments;
  UserProfileNewScreen({@required this.arguments});

  @override
  _UserProfileNewScreenState createState() =>
      _UserProfileNewScreenState(arguments: arguments);
}

class _UserProfileNewScreenState extends State<UserProfileNewScreen> {
  var arguments;

  bool isLoading = false;
  bool isSearchedUserAboutLoading = false;

  _UserProfileNewScreenState({this.arguments});

  int currentIndex = 0;
  CustomerProfile searchedUser;
  String searchedUserName;
  UserAbout searchedUserAbout;

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

    isSearchedUserAboutLoading = true;
    if (mounted) setState(() {});

    searchedUserAbout =
        await UserAuth().fetchUserAboutInfo(userName: searchedUser.userName);
    debugPrint("===> ${searchedUserAbout.toJson()}");

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

    return Scaffold(
      body: DefaultTabController(
        length: searchedUser.type.toLowerCase() != "user" ? 4 : 1,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return getAppBarList();
          },
          body: tabViews(),
        ),
      ),
    );
  }

  List<Widget> getAppBarList() {
    List<Widget> list = [
      SliverAppBar(
        expandedHeight: 180.0,
        floating: false,
        pinned: true,
        actions: actionButtons(),
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () {
            searchedUser = null;
            Navigator.pop(context);
          },
        ),
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsetsDirectional.only(
            start: 50.0,
            bottom: 16.0,
          ),
          collapseMode: CollapseMode.parallax,
          title: isShrink
              ? Container(
                  padding: EdgeInsets.only(right: 100),
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
          background: getProfileCover(),
        ),
      ),
    ];

    if (!isLoading && searchedUser.type.toLowerCase() != "user") {
      list.add(
        SliverPersistentHeader(
          floating: true,
          delegate: _SliverAppBarDelegate(
            TabBar(
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
          pinned: true,
        ),
      );
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
                color: currentIndex == 0 ? navyBlue : blackFont,
                fontSize: 12.0.sp,
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
              "Products",
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: currentIndex == 1 ? navyBlue : blackFont,
                fontSize: 12.0.sp,
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
              "Services",
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: currentIndex == 2 ? navyBlue : blackFont,
                fontSize: 12.0.sp,
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
              "Hours",
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: currentIndex == 3 ? navyBlue : blackFont,
                fontSize: 12.0.sp,
                fontWeight:
                    currentIndex == 3 ? FontWeight.w600 : FontWeight.w400,
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
              KeepAlivePage(child: UserAboutScreen(user: searchedUser)),
            ],
            onPageChanged: (int index) {
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

  Widget getProfileCover() {
    Color borderColor = getUserTypeColor(user: searchedUser);

    return Stack(
      children: [
        isSearchedUserAboutLoading
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
                            CircularLoadingIndicator(),
                        color: blackFont.withOpacity(0.4),
                        colorBlendMode: BlendMode.darken,
                        filterQuality: FilterQuality.high,
                      ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Card(
                    child: Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          60,
                        ),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: searchedUser.avatar,
                          colorBlendMode: BlendMode.darken,
                          errorWidget: imageErrorWidget,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                          placeholder: (context, url) =>
                              CircularLoadingIndicator(),
                        ),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                    color: Colors.white,
                    elevation: 10,
                    borderOnForeground: true,
                    shadowColor: blackFont,
                    clipBehavior: Clip.hardEdge,
                    margin: EdgeInsets.zero,
                  ),
                  Container(
                    width: 8,
                  ),
                  getUserName(),
                ],
              ),
              Container(
                height: 16,
              ),
            ],
          ),
        ),
      ],
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
            fontSize: 20.0.sp,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                color: blackFont,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        Text(
          isLoading ? "" : searchedUser.userName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0.sp,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: blackFont,
                offset: Offset(1, 1),
                blurRadius: 2,
              )
            ],
          ),
        ),
        SizedBox(
          height: 6,
        ),
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
            title: "Receive",
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
    return new Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
