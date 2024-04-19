import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_dashboard_bloc.dart';
import 'package:Slydo/screens/super_store/find_business_list_screen.dart';
import 'package:Slydo/screens/super_store/list_category_product.dart';
import 'package:Slydo/screens/super_store/models/product_industry_model.dart';
import 'package:Slydo/screens/super_store/shop_list_screen.dart';
import 'package:Slydo/screens/super_store/widget/product_category_selection.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../data/state_notifier.dart';
import '../../routes/route_constants.dart';
import '../../utils/navigation_util.dart';
import '../../utils/util.dart';
import '../../widget/rounded_background_icon.dart';
import '../../widget/tab_selection.dart';

class SuperStore extends StatefulWidget {
  final dynamic arguments;

  SuperStore({Key? key, this.arguments}) : super(key: key);

  @override
  State<SuperStore> createState() => _SuperStoreState();
}

class _SuperStoreState extends State<SuperStore> {
  int? productCount = 0;
  late BasketBloc basketBloc;

  // late PageController _pageViewController;
  int currentAskTapOnHome = 0;
  String categoryName = '';
  String firstTabName = 'Shop';
  String secondTabName = 'Find Stores';
  String? appTitle;
  List<String> categoryList = [];
  String url = "";
  String nextUrl = "";
  dynamic categoryId = null;
  late YarnDashboardBloc yarnDashboardBloc;

  @override
  void initState() {
    // _pageViewController = PageController(initialPage: 0);
    updateAppSetup(widget.arguments['industry']);
    getIndustryUrls(widget.arguments['industry']);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context);
  }

  @override
  void dispose() {
    yarnDashboardBloc.refreshProductCategories();
    super.dispose();
  }

  void getIndustryUrls(ProductIndustryResults industry) {
    setState(() {
      url = AppConfig.baseUrl +
          "/api/v1/products/categories/?industry=${industry.id}";
      nextUrl = AppConfig.baseUrl +
          "/api/v1/products/super-store-industry/?industry=${industry.id}";
    });
  }

  void updateAppSetup(ProductIndustryResults industry) {
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
          fontFamily: "Inter",
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
            final ProductIndustryResults industryQuery =
                widget.arguments['industry'];
            Navigator.of(context).pushNamed("/search-product",
                arguments: {"industry": industryQuery.id});
          },
          height: 15,
          width: 15,
          icon: SvgPicture.asset(
            "yarn/search".toSVG(),
            height: 12,
            width: 12,
          )),
      const SizedBox(width: 20),
      _cartBtn(),
      const SizedBox(width: 20),
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
      const SizedBox(width: 15),
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
      const SizedBox(width: 15),

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
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: _buildCategoryAndTabs(),
        ),
      ],
      body: _buildPageView(),
      // Container(
      //   height: 500,
      //   color: Colors.blue,
      //   width: double.infinity,
      // ),

      // _buildCategoryAndTabs(),
      // _buildPageView(),
    );
  }

  Widget _buildCategoryAndTabs() {
    final ProductIndustryResults productUrl = widget.arguments['industry'];
    return Column(
      children: [
        const SizedBox(
          height: 16,
        ),
        Column(
          children: [
            TabSelection(
              onTap: (index) {
                currentAskTapOnHome = index;
                // _pageViewController.jumpToPage(currentAskTapOnHome);
                if (mounted) setState(() {});
              },
              currentIndex: currentAskTapOnHome,
              firstTab: firstTabName,
              secondTab: secondTabName,
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
        if (currentAskTapOnHome == 0) ...[
          Container(
            alignment: Alignment.centerLeft,
            child: ProductCategorySelection(
                callback: (category, id, val) {
                  categoryName = category;
                  categoryId = id;
                  if (id == "") {
                    nextUrl = AppConfig.baseUrl +
                        "/api/v1/products/super-store-industry/?industry=${productUrl.id}";
                  } else {
                    nextUrl = AppConfig.baseUrl +
                        "/api/v1/products/?industry=${productUrl.id}&category=$id";
                  }
                  if (mounted) setState(() {});
                },
                categoryName: categoryName,
                next_url: AppConfig.baseUrl +
                    "/api/v1/products/categories/?industry=${productUrl.id}"),
          ),
          const SizedBox(height: 14),
          Divider(
            height: 0,
            thickness: 0.5,
            color: greySecondaryYarn,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildPageView() {
    final ProductIndustryResults industry = widget.arguments['industry'];
    return IndexedStack(
      index: currentAskTapOnHome,
      children: [
        if (categoryId == null || categoryId == "")
          ShopListScreen(
              onPageRefresh: (bool data) {
                if (data == true) {
                  // _showTabs(true);
                }
              },
              category: categoryName,
              industry: appTitle!,
              nextUrl: nextUrl,
              type: categoryId == null || categoryId == "" ? "sessions" : null)
        else
          ListCategoryProduct(
              key: ValueKey("$nextUrl$categoryName"),
              nextUrl: nextUrl,
              categoryName: categoryName),
        FindBusinessListScreen(
            onPageRefresh: (bool data) {
              if (data == true) {
                // _showTabs(true);
              }
            },
            category: categoryName,
            // industry: appTitle)
            industry: industry.name)
      ],
    );

    // return PageView(
    //   onPageChanged: (currentPage) {
    //     updateCurrentAskTapOnHome(index: currentPage);
    //   },
    //   controller: _pageViewController,
    //   children: [
    //     categoryId == null || categoryId == ""
    //         ? ShopListScreen(
    //             onPageRefresh: (bool data) {
    //               if (data == true) {
    //                 // _showTabs(true);
    //               }
    //             },
    //             category: categoryName,
    //             industry: appTitle!,
    //             nextUrl: nextUrl,
    //             type:
    //                 categoryId == null || categoryId == "" ? "sessions" : null)
    //         : FutureBuilder(
    //             future: getProducts(),
    //             builder: (context, snapshot) {
    //               print(snapshot.data);
    //               print("_________________________");
    //               if (snapshot.hasData) {
    //                 List<Product> result = snapshot.data as List<Product>;
    //                 return result.isEmpty
    //                     ? Center(
    //                         child: NoItemInList(
    //                           msg: AppLocalization.of(context)!.noResultFound,
    //                         ),
    //                       )
    //                     : ListView(children: [
    //                         superStoreProducts(result)
    //                         // Text("data"),
    //                       ]);
    //               } else if (snapshot.hasError) {
    //                 return SizedBox();
    //               } else {
    //                 return Shimmer.fromColors(
    //                   baseColor: Colors.white,
    //                   highlightColor: greyBorderColor,
    //                   child: GridView.builder(
    //                     shrinkWrap: true,
    //                     physics: const NeverScrollableScrollPhysics(),
    //                     gridDelegate:
    //                         const SliverGridDelegateWithMaxCrossAxisExtent(
    //                       mainAxisSpacing: 14,
    //                       mainAxisExtent: 180,
    //                       crossAxisSpacing: 15,
    //                       maxCrossAxisExtent: 200,
    //                     ),
    //                     itemCount: 2,
    //                     itemBuilder: (context, index) {
    //                       return Card(
    //                         color: Colors.grey,
    //                         shape: RoundedRectangleBorder(
    //                           borderRadius: BorderRadius.circular(12),
    //                         ),
    //                       );
    //                     },
    //                   ),
    //                 );
    //               }
    //             }),
    //     FindBusinessListScreen(
    //         onPageRefresh: (bool data) {
    //           if (data == true) {
    //             // _showTabs(true);
    //           }
    //         },
    //         category: categoryName,
    //         industry: appTitle)
    //   ],
    // );
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
        badgeAnimation: const badges.BadgeAnimation.rotation(
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
              ? const EdgeInsets.all(0)
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
      style: const TextStyle(
        fontSize: 10,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontFamily: "Inter",
      ),
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
