import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/super_store/models/product_industry_model.dart';
import 'package:Slydo/screens/super_store/shop_list_screen_with_tags.dart';
import 'package:Slydo/screens/super_store/super_store.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../data/state_notifier.dart';
import '../../routes/route_constants.dart';
import '../../utils/navigation_util.dart';
import '../../utils/util.dart';
import '../../widget/rounded_background_icon.dart';

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
  List<ProductIndustryResults> industries = [];
  bool isLoading = false;

  @override
  void initState() {
    _pageViewController = PageController(initialPage: 0);
    getProductIndustries();
    super.initState();
  }

  getProductIndustries() async {
    isLoading = true;
    if (mounted) setState(() {});
    var result = await ShoppingAuthService().listOfIndustries();
    industries = result!["product"];
    isLoading = false;
    setState(() {});
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
      backgroundColor: whiteBackground,
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
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      centerTitle: false,
      titleSpacing: 16,
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
            height: 8,
          ),
          // _buildCategoryAndTabs(),
          if (industries.isNotEmpty)
            Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: isLoading
                  ? Container(
                      height: 100.0,
                      child: Shimmer.fromColors(
                          baseColor: Colors.white,
                          highlightColor: greyBorderColor,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return Card(
                                color: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              );
                            },
                          )),
                    )
                  : _displayShortcutButtons(industries),
            ),
          _buildPageView(),
        ],
      ),
    );
  }

  String getImagePath(String imgKey) {
    Map<String, String> imagePathData = {
      'Restaurant': 'store/restaurant',
      'Drinks': 'store/drinks',
      'Groceries': 'store/groceries',
      'Retail': 'store/retail',
      'Pharmacy': 'store/pharmacy',
      'Electronics': 'store/electronics',
      'Home & Office': 'store/homeandoffice',
    };
    return imagePathData[imgKey]!;
  }

  Widget _displayShortcutButtons(List<ProductIndustryResults> industries) {
    return Container(
      height: 80.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: <Widget>[
          for (final shortcut in industries)
            Padding(
              padding: const EdgeInsets.all(4.0), // Add padding between items
              child: GestureDetector(
                  // key: showTutorial(shortcut['title']),
                  onTap: () {
                    NavigationUtil.push(
                      context,
                      screen: SuperStore(
                        arguments: {"industry": shortcut},
                      ),
                    );
                  },
                  child: shortcutView(shortcut)),
            ),
        ],
      ),
    );
  }

  Widget shortcutView(ProductIndustryResults data) {
    switch (data.name) {
      case 'Electronics Store':
        return industryView(getImagePath(data.alias), data.alias!);
      case 'Furniture':
        return industryView(getImagePath(data.alias), data.name!);
      case 'Grocery Store':
        return industryView(getImagePath(data.alias), data.alias!);
      case 'Liquor Store':
        return industryView(getImagePath(data.alias), data.alias!);
      case 'Pharmaceutical':
        return industryView(getImagePath(data.alias), data.alias!);
      case 'Restaurant/Cafe':
        return industryView(getImagePath(data.alias), data.alias!);
      case 'Retail':
        return industryView(getImagePath(data.alias), data.alias!);
      default:
        return industryView(getImagePath(data.alias), data.alias!);
    }
  }

  Widget industryView(String imagePath, String title) {
    return Container(
      width: 75,
      height: 75,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            imagePath.toSVG(),
            height: 32,
            width: 32,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
                color: black),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return Expanded(
      child: ShopListScreenWithTags(
        onPageRefresh: (bool data) {
          if (data == true) {
            _showTabs(true);
          }
        },
        category: categoryName,
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
          padding: basketBloc.basketItems.length == 0
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
    if (basketBloc.basketItems.length == 0) {
      return null;
    }
    return Text(
      getBadgeCount(),
      style: TextStyle(
          fontSize: 10,
          fontFamily: "Inter",
          color: Colors.white,
          fontWeight: FontWeight.bold),
    );
  }

  String getBadgeCount() {
    int totalItem = 0;
    basketBloc.basketItems.forEach((element) {
      totalItem = totalItem + int.parse(element.qty.toString());
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
