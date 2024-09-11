import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/shipping_process/screens/normal_cart/normal_cart_screen.dart';
import 'package:Slydo/screens/shipping_process/screens/shared_cart/shared_cart_screen.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/tab_selection.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';

class ShoppingCart extends StatefulWidget {
  const ShoppingCart({super.key});

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  int currentAskTapOnHome = 0;

  GlobalKey<NormalCartScreenState> normalStateKey =
      GlobalKey<NormalCartScreenState>();
  GlobalKey<SharedCartScreenState> sharedStateKey =
      GlobalKey<SharedCartScreenState>();

  bool _tabsVisible = true;
  late PageController _pageViewController;

  @override
  void initState() {
    _pageViewController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: ScaffoldMessenger(
          child: Scaffold(
            backgroundColor: lightGrey,
            appBar: _buildAppBar() as PreferredSizeWidget?,
            body: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        const SizedBox(
          height: 8,
        ),
        _buildTabs(),
        _buildPageView(),
      ],
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        TabSelection(
          onTap: (index) {
            currentAskTapOnHome = index;
            _pageViewController.jumpToPage(currentAskTapOnHome);
            _showTabs(true);
            if (mounted) setState(() {});
          },
          currentIndex: currentAskTapOnHome,
          firstTab: 'My Cart',
          secondTab: 'Shared Cart',
        ),
        Divider(
          color: darkGrey.withOpacity(.5),
        ),
      ],
    );
  }

  void _showTabs(bool visible) {
    if (_tabsVisible != visible) {
      setState(() {
        _tabsVisible = visible;
      });
    }
  }

  void updateCurrentAskTapOnHome({required int index}) {
    setState(() {
      currentAskTapOnHome = index;
    });
  }

  Widget _buildPageView() {
    return Expanded(
      child: PageView(
        onPageChanged: (currentPage) {
          updateCurrentAskTapOnHome(index: currentPage);
        },
        controller: _pageViewController,
        children: [
          NormalCartScreen(
            key: normalStateKey,
            onPageRefresh: (bool data) {
              if (data == true) {
                _showTabs(true);
              }
            },
          ),
          // SharedCartScreen(
          //   key: sharedStateKey,
          //   onPageRefresh: (bool data) {
          //     if (data == true) {
          //       _showTabs(true);
          //     }
          //   },
          // ),
          const Center(
            child: Text(
              "Coming Soon",
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        AppLocalization.of(context)?.basket ?? "",
        style: TextStyle(
          fontSize: 20,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      actions: <Widget>[
        RoundedBackgroundIcon(
          height: 34,
          width: 34,
          icon: Icon(
            SlydoAppIcon.add,
            size: 16,
            color: blackFont,
          ),
          onTap: () async {
            showToast(message: 'Coming Soon');
            return;
            final result = await Navigator.of(context).pushNamed(
                Routes.SELECT_USER_FOR_GROUP,
                arguments: {"create": "basket"});

            if (result != null && result is bool && result == true) {
              sharedStateKey = GlobalKey<SharedCartScreenState>();
              setState(() {});
            }
          },
          backgroundColor: iconBtnGrey,
          enableMargin: true,
        ),
        const SizedBox(width: 8),
        scanQRCodeBtn(),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget scanQRCodeBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.qr_code,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.SCAN_QR, arguments: {'isRequest': false});
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }
}
