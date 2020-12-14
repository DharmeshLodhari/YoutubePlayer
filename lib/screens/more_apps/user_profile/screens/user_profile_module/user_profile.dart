import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

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

  _UserProfileState({this.arguments});

  int currentIndex = 0;
  CustomerProfile searchedUser;

  // this variable will responsible for is the user is owner of the products and add
  // edit button on the product if user is owner
  bool isOwner = false;
  UserBloc userBloc;
  double top;

  // pageview controller
  PageController pageController;

  @override
  void initState() {
    searchedUser = arguments['searchedUser'];

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

    if (userBloc.user.userName == searchedUser.userName) {
      isOwner = true;
    }

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: DefaultTabController(
        length: 3,
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
        searchedUser.fullName,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
      bottom: tabBar(),
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
              duration: Duration(milliseconds: 500), curve: Curves.linear);
        },
        tabs: [
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 0
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                "Information",
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 1
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                "Products",
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 2
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                "Services",
                style: TextStyle(
                  color: currentIndex == 2 ? navyBlue : blackFont,
                  fontSize: 14,
                  fontWeight:
                      currentIndex == 2 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                SlydoAppIcon.text_message,
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
    return PageView(
      controller: pageController,
      children: [
        UserInfo(user: searchedUser),
        UserProductList(
          user: searchedUser,
          isOwner: isOwner,
        ),
        UserServiceList(
          user: searchedUser,
          isOwner: isOwner,
        ),
      ],
      onPageChanged: (int index) {
        currentIndex = index;
        setState(() {});
      },
    );
  }
}
