import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module/user_about_screen.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/keep_alive_page.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:sizer/sizer.dart';

import '../../user_auth.dart';
import 'user_info.dart';
import 'user_product_list.dart';
import 'user_service_list.dart';

// ignore: must_be_immutable
class UserProfile extends StatefulWidget {
  var arguments;

  UserProfile({@required this.arguments});

  @override
  _UserProfileState createState() => _UserProfileState(arguments: arguments);
}

class _UserProfileState extends State<UserProfile> {
  var arguments;

  bool isLoading = false;

  _UserProfileState({this.arguments});

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

    debugPrint("searchedUser.type ${searchedUser.type}");
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: DefaultTabController(
        length: searchedUser.type.toLowerCase() != "user" ? 4 : 1,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: appBar(),
          body: tabViews(),
        ),
      ),
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
      bottom: isLoading
          ? null
          : searchedUser.type.toLowerCase() == "user"
              ? null
              : tabBar(),
      actions: actionButtons(),
    );
  }

  Widget tabBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(50.0),
      child: TabBar(
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(),
        onTap: (int index) {
          currentIndex = index;
          setState(() {});
          pageController.animateToPage(currentIndex,
              duration: Duration(milliseconds: 100), curve: Curves.linear);
        },
        tabs: getTabs(),
      ),
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

  Widget shareProfileIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.share,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        var shareBody = "${searchedUser.fullName}\n" +
            "http://slydo.co/user/" +
            searchedUser.userName;
        Share.share(shareBody, subject: "${searchedUser.fullName}");
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  List<Widget> actionButtons() {
    return [
      !isOwner
          ? RoundedBackgroundIcon(
              height: 34,
              width: 34,
              icon: Icon(
                SlydoAppIcon.message,
                size: 16,
                color: blackFont,
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/compose_message', arguments: {
                  'recipient': searchedUser.userName,
                  'subject': "",
                });
              },
              backgroundColor: iconBtnGrey,
              enableMargin: true,
            )
          : Container(),
      !isOwner
          ? SizedBox(
              width: 8,
            )
          : Container(),
      shareProfileIcon(),
      SizedBox(
        width: 16,
      ),
    ];
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
}
