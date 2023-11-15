import 'package:Slydo/data/environment.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/super_store/find_business_list_screen.dart';
import 'package:Slydo/screens/super_store/models/product_industry_model.dart';
import 'package:Slydo/screens/super_store/shop_list_screen.dart';
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

class SuperStore extends StatefulWidget {
  var arguments;
  SuperStore({Key? key, this.arguments}) : super(key: key);

  @override
  State<SuperStore> createState() => _SuperStoreState();
}

class _SuperStoreState extends State<SuperStore> {
  int? productCount = 0;
  late BasketBloc basketBloc;
  late PageController _pageViewController;
  int currentAskTapOnHome = 0;
  bool _tabsVisible = true;
  String categoryName = '';
  String firstTabName = 'Shop';
  String secondTabName = 'Find Stores';
  String? appTitle;
  List<String> categoryList = [];
   String url = "";

  @override
  void initState() {
    _pageViewController = PageController(initialPage: 0);
    updateAppSetup(widget.arguments['industry']);
    getIndustryCategories(widget.arguments['industry']);
    super.initState();
  }

  void _showTabs(bool visible) {
    if (_tabsVisible != visible) {
      setState(() {
        _tabsVisible = visible;
      });
    }
  }
  getIndustryCategories(ProductIndustryResults industry){
    setState(() {
        url = AppConfig.baseUrl +
          "/api/v1/products/categories/?industry=${industry.id}";

    });
  }
  updateAppSetup(ProductIndustryResults industry) {
    switch (industry.name) {
      case 'Restaurant/Cafe':
        setState(() {
          secondTabName = 'Find Restaurants';
          appTitle = industry.name;
          categoryList = [];
        });
        return;
      case 'Liquor Store':
        setState(() {
          appTitle = industry.name;
          categoryList = [];
        });
        return;
      case 'Grocery Store':
        setState(() {
          appTitle = industry.name;
          categoryList = [];
        });
        return;
      case 'Retail':
        setState(() {
          appTitle = industry.name;
          categoryList = [];
        });
        return;
      case 'Pharmaceutical':
        setState(() {
          appTitle = industry.name;
          categoryList = [];
        });
        return;
      case 'Electronics Store':
        setState(() {
          appTitle = industry.name;
          categoryList = [];
        });
        return;
      case 'Furniture':
        setState(() {
          appTitle = industry.name;
          categoryList = [];
        });
        return;
      default:
        setState(() {
          appTitle = "";
        });
        return;
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
        appTitle!,
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
          _buildCategoryAndTabs(),
          _buildPageView(),
        ],
      ),
    );
  }

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
            firstTab: firstTabName,
            secondTab: secondTabName,
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
            next_url:  url

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
    ProductIndustryResults productUrl= widget.arguments['industry'];
    return Expanded(
      child: PageView(
        onPageChanged: (currentPage) {
          updateCurrentAskTapOnHome(index: currentPage);
        },
        controller: _pageViewController,
        children: [
          ShopListScreen(
            onPageRefresh: (bool data) {
              if (data == true) {
                _showTabs(true);
              }
            },
            category: categoryName,
            industry: appTitle!,
            nextUrl:  AppConfig.baseUrl + "/api/v1/products/categories/?industry=${productUrl.id}",
          ),
          FindBusinessListScreen(
            onPageRefresh: (bool data) {
              if (data == true) {
                _showTabs(true);
              }
            },
            category: categoryName,
            industry: appTitle
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
