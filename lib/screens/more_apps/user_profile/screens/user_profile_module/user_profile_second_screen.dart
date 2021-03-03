import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module/user_about_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module/user_info.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module/user_product_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module/user_service_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/keep_alive_page.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:sizer/sizer.dart';

// ignore: must_be_immutable
class UserProfileSecondScreen extends StatefulWidget {
  var arguments;
  UserProfileSecondScreen({@required this.arguments});

  @override
  _UserProfileSecondScreenState createState() =>
      _UserProfileSecondScreenState(arguments: arguments);
}

class _UserProfileSecondScreenState extends State<UserProfileSecondScreen> {
  var arguments;

  bool isLoading = false;

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

  @override
  void initState() {
    searchedUser = arguments['searchedUser'] ?? null;
    if (searchedUser == null) {
      searchedUserName = arguments['searchedUserName'];
      isLoading = true;
      if (mounted) setState(() {});
      UserAuth().fetchCustomerProfile(searchedUserName).then((user) {
        searchedUser = user;
        isLoading = false;
        if (mounted) setState(() {});
      });
    }

    currentIndex = arguments['index'] ?? 0;
    pageController = PageController(initialPage: currentIndex);
    if (mounted) {
      setState(() {});
    }
    super.initState();
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
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
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
                title: getUserName(),
                background: getProfileCover(),
              ),
            ),
            SliverPersistentHeader(
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
            // SliverList(delegate: SliverChildListDelegate([tabViews()]))
          ],
        ),
      ),
    );
  }

  List<Widget> actionButtons() {
    return [
      shareProfileIcon(),
      SizedBox(
        width: 16,
      ),
    ];
  }

  Widget shareProfileIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.menu,
        size: 16,
        color: Colors.white,
      ),
      onTap: () {
        profileAndroidSheet();
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
              "About",
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
              "Products",
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
              "Services",
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
        )
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
              KeepAlivePage(child: UserAboutScreen(user: searchedUser)),
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
    if (searchedUser.profileCover != "") {
      return CachedNetworkImage(
          imageUrl: searchedUser.profileCover, fit: BoxFit.cover);
    }

    return Image.asset(
      "assets/images/home_screen_background.png",
      fit: BoxFit.cover,
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

  void profileAndroidSheet() {
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
                  children: <Widget>[
                    bottomSheetItem(
                      title: "Share",
                      icon: SlydoAppIcon.share,
                      onTap: () {
                        Navigator.pop(context);
                        var shareBody = "${searchedUser.fullName}\n" +
                            "http://slydo.co/user/" +
                            searchedUser.userName;
                        Share.share(shareBody,
                            subject: "${searchedUser.fullName}");
                      },
                    ),
                    bottomSheetItem(
                      title: "Message",
                      icon: SlydoAppIcon.message,
                      onTap: () {
                        Navigator.pop(context);
                        if (!isOwner) {
                          Navigator.of(context)
                              .pushNamed('/compose_message', arguments: {
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
                          Navigator.of(context).pushNamed('/send-payment',
                              arguments: <String, bool>{
                                'isFromProfile': false
                              });
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
                            Navigator.of(context).pushNamed('/request-payment',
                                arguments: <String, bool>{
                                  'isFromProfile': false,
                                  'isRequest': true
                                });
                          });
                        }),
                  ],
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
