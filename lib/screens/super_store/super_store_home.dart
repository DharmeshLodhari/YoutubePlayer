import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/super_store/find_business_list_screen.dart';
import 'package:Slydo/screens/super_store/shop_list_screen.dart';
import 'package:Slydo/screens/super_store/shop_list_screen_with_tags.dart';
import 'package:Slydo/screens/super_store/super_store.dart';
import 'package:Slydo/screens/super_store/widget/product_category_selection.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../data/state_notifier.dart';
import '../../routes/route_constants.dart';
import '../../utils/navigation_util.dart';
import '../../utils/util.dart';
import '../../widget/rounded_background_icon.dart';
import '../more_apps/shopping/models/store.dart';
import '../more_apps/yarn/widgets/yarn_tab_selection.dart';
import '../more_apps/yarn/yarn_setting_screen.dart';

class SuperStoreHome extends StatefulWidget {
  const SuperStoreHome({Key? key}) : super(key: key);

  @override
  State<SuperStoreHome> createState() => _SuperStoreHomeState();
}

class _SuperStoreHomeState extends State<SuperStoreHome> {
  int? productCount = 0;
  late BasketBloc basketBloc;
  late PageController _pageViewController;
  int currentAskTapOnHome = 0;
  bool _tabsVisible = true;
  String categoryName = '';

  @override
  void initState() {
    _pageViewController = PageController(initialPage: 0);
    super.initState();
  }

  void _showTabs(bool visible) {
    if (_tabsVisible != visible) {
      setState(() {
        _tabsVisible = visible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar() as PreferredSizeWidget,
      body: _buildBody(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        AppLocalization.of(context)!.superStore,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      centerTitle: false,
      titleSpacing: 16,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      shadowColor: greySecondaryYarn,
      actions: currentAskTapOnHome == 0
          ? _buildAppBarActionsShopList()
          : _buildAppBarActionsFindBusiness(),
      elevation: 0.5,
    );
  }

  List<Widget> _buildAppBarActionsShopList() {
    return [
      RoundedBackgroundIcon(
          backgroundColor: Colors.transparent,
          onTap: () {
            Navigator.of(context).pushNamed("/search-product");
          },
          height: 15,
          width: 15,
          icon: SvgPicture.asset(
            "yarn/search".toSVG(),
            height: 12,
            width: 12,
          )),
      SizedBox(width: 20),
      _cartBtn(),
      SizedBox(width: 20),
    ];
  }

  List<Widget> _buildAppBarActionsFindBusiness() {
    return [
      RoundedBackgroundIcon(
          backgroundColor: Colors.transparent,
          onTap: () {
            Navigator.pushNamed(context, Routes.SEARCH_NEAR_BY_BUSINESS);
          },
          height: 15,
          width: 15,
          icon: SvgPicture.asset(
            "yarn/search".toSVG(),
            height: 12,
            width: 12,
          )),
      SizedBox(width: 15),
      RoundedBackgroundIcon(
          backgroundColor: Colors.transparent,
          onTap: () {
            // NavigationUtil.push(
            //   context,
            //   screen: YarnSettingsScreen(),
            // );
          },
          height: 20,
          width: 20,
          icon: SvgPicture.asset(
            "store/location".toSVG(),
            height: 15,
            width: 15,
          )),
      SizedBox(width: 15),

      // RoundedBackgroundIcon(
      //     backgroundColor: Colors.transparent,
      //     onTap: () {
      //       // NavigationUtil.push(
      //       //   context,
      //       //   screen: YarnSettingsScreen(),
      //       // );
      //     },
      //     height: 20,
      //     width: 20,
      //     icon: SvgPicture.asset(
      //       "store/filter".toSVG(),
      //       height: 20,
      //       width: 20,
      //     )),
      // SizedBox(width: 20),
    ];
  }

  Widget _buildBody() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        /// Check if the scroll direction is horizontal
        if (scrollNotification is ScrollNotification &&
            scrollNotification.metrics.axis == Axis.horizontal) {
          // Disable horizontal scrolling
          return true;
        }

        if (scrollNotification is ScrollUpdateNotification) {
          if (scrollNotification.scrollDelta! > 0 && _tabsVisible) {
            // Scrolling down
            _showTabs(false);
          } else if (scrollNotification.scrollDelta! < 0 && !_tabsVisible) {
            // Scrolling up
            _showTabs(true);
          }
        }

        return true;
      },
      child: Column(
        children: [
          SizedBox(
            height: 16,
          ),
          // _buildCategoryAndTabs(),
          Container(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: _displayShortcutButtons(),
          ),
          specialDeals(),
          _buildPageView(),
        ],
      ),
    );
  }

  List<String> banner = ["meal", "meal"];

  Widget specialDeals() {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(left: 18.0, right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Special Deal",
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Inter"),
            textAlign: TextAlign.left,
          ),
          SizedBox(
            height: 8,
          )
        ],
      ),
    );
  }

  Widget _displayShortcutButtons() {
    final List<Map<String, String>> shortcuts = [
      {
        'imagePath': 'store/restaurant',
        'title': 'Restaurant',
      },
      {
        'imagePath': 'store/drinks',
        'title': 'Drinks',
      },
      {
        'imagePath': 'store/groceries',
        'title': 'Groceries',
      },
      {
        'imagePath': 'store/retail',
        'title': 'Retail',
      },
      {
        'imagePath': 'store/pharmacy',
        'title': 'Pharmacy',
      },
      {
        'imagePath': 'store/electronics',
        'title': 'Electronics',
      },
      {
        'imagePath': 'store/homeandoffice',
        'title': 'Home & Office',
      },
    ];

    return Container(
      height: 100.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: <Widget>[
          for (final shortcut in shortcuts)
            Padding(
              padding: const EdgeInsets.all(10.0), // Add padding between items
              child: GestureDetector(
                  // key: showTutorial(shortcut['title']),
                  onTap: () {
                    NavigationUtil.push(context, screen: SuperStore(arguments: {"industry": shortcut['title']},), );
                  },
                  child: shortcutView(shortcut['imagePath']!, shortcut['title']!)),
            ),
        ],
      ),
    );
  }

  Widget shortcutView(String imagePath, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset(
          imagePath.toSVG(), height: 32, width: 32,
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, fontFamily: "Inter"),
        ),
      ],
    );
  }

  // void onClickShortcut(String? shortcut) {
  //   switch (shortcut) {
  //     case 'Send':
  //       hideBalance();
  //       Navigator.of(context).pushNamed(Routes.SEND_PAYMENT,
  //           arguments: <String, bool>{'isFromProfile': true});
  //       break;
  //     case 'Transaction':
  //       hideBalance();
  //       BottomSheetPassCode(
  //           context: context,
  //           isValidCallback: () {
  //             Navigator.of(context)
  //                 .pushNamed(Routes.TRANSACTIONS, arguments: {'page': 0});
  //           },
  //           cancelCallBack: () {
  //             Navigator.pop(context);
  //           });
  //       break;
  //     case 'Request':
  //       hideBalance();
  //       Navigator.pushNamed(context, Routes.ACCOUNTS);
  //       break;
  //     case 'Yarn':
  //       hideBalance();
  //       NavigationUtil.push(context, screen: YarnDashboard());
  //       break;
  //     case 'Moment':
  //       hideBalance();
  //       NavigationUtil.push(context, screen: MomentsScreen());
  //       break;
  //     case 'Services':
  //       hideBalance();
  //       Navigator.pushNamed(context, Routes.SUPER_HUB);
  //       break;
  //     case 'Blog':
  //       hideBalance();
  //       if (appConfigurationModel?.enableSuperBlog == true) {
  //         NavigationUtil.push(
  //           context,
  //           screen: const SuperBlog(),
  //         );
  //       } else {
  //         showToast(message: 'Feature not available at the moment');
  //       }
  //       break;
  //     default:
  //       // Handle the default case (if any)
  //       print('Tapped on an unknown shortcut');
  //   }
  // }

  Widget _buildCategoryAndTabs() {
    return Column(
      children: [
        if (_tabsVisible) ...[
          YarnTabSelection(
            onTap: (index) {
              currentAskTapOnHome = index;
              _pageViewController.jumpToPage(currentAskTapOnHome);
              _showTabs(true);
              if (mounted) setState(() {});
            },
            currentIndex: currentAskTapOnHome,
            firstTab: 'Shop',
            secondTab: 'Find Businesses',
          ),
          SizedBox(
            height: 16,
          ),
        ],
        if (_tabsVisible) ...[
          ProductCategorySelection(
            callback: (category, val) {
              categoryName = category;
              if (mounted) setState(() {});
            },
          ),
          SizedBox(height: 14),
          Divider(
            height: 0,
            thickness: 0.5,
            color: greySecondaryYarn,
          ),
          SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildPageView() {
    return Expanded(
      child: PageView(
        onPageChanged: (currentPage) {
          updateCurrentAskTapOnHome(index: currentPage);
        },
        controller: _pageViewController,
        children: [
          ShopListScreenWithTags(
            onPageRefresh: (bool data) {
              if (data == true) {
                _showTabs(true);
              }
            },
            category: categoryName,
          ),
          FindBusinessListScreen(
            onPageRefresh: (bool data) {
              if (data == true) {
                _showTabs(true);
              }
            },
            category: categoryName,
          )
        ],
      ),
    );
  }

  void updateCurrentAskTapOnHome({required int index}) {
    setState(() {
      currentAskTapOnHome = index;
    });
  }

  Widget _cartBtn() {
    return RoundedBackgroundIcon(
      height: 30,
      width: 30,
      icon: badges.Badge(
        badgeContent: getBadgeContent(),
        badgeAnimation: badges.BadgeAnimation.rotation(
          animationDuration: Duration(seconds: 1),
          colorChangeAnimationDuration: Duration(seconds: 1),
          loopAnimation: false,
          curve: Curves.fastOutSlowIn,
          colorChangeAnimationCurve: Curves.easeInCubic,
        ),
        badgeStyle: badges.BadgeStyle(
          shape: badges.BadgeShape.circle,
          badgeColor: naturalGreen,
          padding: basketBloc.items.length == 0
              ? EdgeInsets.all(0)
              : EdgeInsets.only(
                  left: getBadgeCount().length == 1 ? 6 : 8,
                  right: 6,
                  top: 4,
                  bottom: 4),
          elevation: 0,
        ),
        child: Center(
          child: Icon(
            SlydoAppIcon.cart,
            size: 16,
            color: blackFont,
          ),
        ),
      ),
      onTap: () {
        NavigationUtil.pushNamed(context, routeName: Routes.SHOPPING_CART);
      },
      backgroundColor: blackFont.withOpacity(0.1),
      enableMargin: true,
    );
  }

  Widget? getBadgeContent() {
    if (basketBloc.items.length == 0) {
      return null;
    }
    return Text(
      getBadgeCount(),
      style: TextStyle(
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  String getBadgeCount() {
    int totalItem = 0;
    basketBloc.items.forEach((element) {
      totalItem = totalItem + int.parse(element['qty'].toString());
    });
    // for (var item in basketBloc.items) {
    //
    //   if (item['item'] is Product) {
    //     var product = item['item'] as Product;
    //
    //     if (product.variant!.isEmpty && product.variant != null) {
    //       // If the variant list is empty, add the quantity to the total
    //       totalItem += int.parse(item['qty'].toString());
    //     } else {
    //       // If there are variants, calculate the total quantity from variants
    //       for(var variant in product.variant!){
    //         var vProduct = Variant.fromJson(variant);
    //         totalItem += int.parse(vProduct.quantity.toString());
    //       }
    //     }
    //
    //   } else if (item['item'] is Service) {
    //     totalItem += int.parse(item['qty'].toString());
    //   }
    // }
    return totalItem > 99 ? '99+' : totalItem.toString();
  }
}
