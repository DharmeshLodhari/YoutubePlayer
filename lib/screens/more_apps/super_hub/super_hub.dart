import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:badges/badges.dart' as badges;
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../../routes/route_constants.dart';
import '../../../widget/item_display_card.dart';
import '../../../widget/rounded_background_icon.dart';

class SuperHub extends StatefulWidget {
  const SuperHub({Key? key}) : super(key: key);

  @override
  State<SuperHub> createState() => _SuperHubState();
}

class _SuperHubState extends State<SuperHub> {
  bool todaysDealsEmpty = false;
  bool isTodayDealLoading = false;

  List<Service> productList = [];
  bool isProductLoading = false;
  bool noProductInList = false;
  int? productCount = 0;
  String? todayDealNext = "";
  String? productNext = "";
  String? todayDealPrevious = "";
  String? productPrevious = "";
  late BasketBloc basketBloc;

  final GlobalKey<ScaffoldMessengerState> _productScaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  ScrollController _productScrollController = new ScrollController();

  AppBar appBar() {
    return AppBar(
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
        "Service Hub",
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        _cartBtn(),
        const SizedBox(width: 12),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getProductList();
  }

  void getProductList() async {
    if (!isProductLoading) {
      if (productNext != null && !isProductLoading) {
        isProductLoading = true;
        if (mounted) setState(() {});

        final Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfServices(productNext, productPrevious, otherDeals: true);

        if (result == null) {
          noProductInList = true;

          isProductLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        productCount = result['count'];
        productNext = result['next'];
        productPrevious = result['previous'];
        final tempList = result['results'];
        if (mounted) {
          setState(() {
            noProductInList = false;
            isProductLoading = false;
            productList.addAll(tempList);
          });
        }
      }
      if (productList.isEmpty) {
        if (mounted) {
          setState(() {
            noProductInList = true;
          });
        }
      } else if (productNext == null && productList.length > 6) {
        _productScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        _refreshPage();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  _refreshPage() {
    productNext = "";
    productCount = 0;
    productPrevious = "";
    isProductLoading = false;
    productList = [];

    todayDealNext = "";
    todayDealPrevious = "";
    isTodayDealLoading = false;
    //todaysDealList = [];

    getProductList();
    //getTodaysDealProducts();
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);

    return ScaffoldMessenger(
      key: _productScaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: appBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SmartRefresher(
              enablePullDown: true,
              header: WaterDropHeader(
                complete: Container(),
                waterDropColor: navyBlue,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: ListView(
                controller: _productScrollController,
                children: [
                  searchBox(),
                  const SizedBox(height: 22),
                  superStoreProducts(),
                  const SizedBox(height: 16),
                  if (isProductLoading)
                    Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: greyBorderColor,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          mainAxisSpacing: 14,
                          mainAxisExtent: 180,
                          crossAxisSpacing: 15,
                          maxCrossAxisExtent: 200,
                        ),
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          return Card(
                            color: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Visibility(
                    visible: !isProductLoading &&
                        !isTodayDealLoading &&
                        productList.isEmpty,
                    child: Center(
                      child: Column(
                        children: [
                          Lottie.asset('assets/lottie/no_moment_lottie.json'),
                          const SizedBox(height: 20),
                          const Text('No items at the moment'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget superStoreProducts() {
    if (productList.isEmpty) {
      return const SizedBox.shrink();
    }
    return productNext == "" && isProductLoading
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisSpacing: 22,
                  mainAxisExtent: 260,
                  crossAxisSpacing: 15,
                  maxCrossAxisExtent: 200,
                ),
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  return SuperStoreSingleCard(
                    service: productList[index],
                  );
                },
              ),
            ],
          );
  }

  // Widget getTodaysDealList() {
  //   return Column(
  //     children: [
  //       todaysDealsEmpty
  //           ? SizedBox.shrink()
  //           : Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: <Widget>[
  //                 Row(
  //                   children: [
  //                     Text(
  //                       "Today's deal",
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.w700,
  //                         fontSize: 18,
  //                         color: blackFont,
  //                       ),
  //                     ),
  //                     Icon(
  //                       Icons.bolt_rounded,
  //                       color: mateRed,
  //                     ),
  //                   ],
  //                 ),
  //                 // GestureDetector(
  //                 //   child: Row(
  //                 //     children: [
  //                 //       Text(
  //                 //         "See all",
  //                 //         style: TextStyle(
  //                 //             fontWeight: FontWeight.w600,
  //                 //             fontSize: 14,
  //                 //             color: navyBlue),
  //                 //       ),
  //                 //       SizedBox(width: 8),
  //                 //       Icon(Icons.arrow_forward_ios_sharp,
  //                 //           size: 14, color: navyBlue),
  //                 //     ],
  //                 //   ),
  //                 //   onTap: () {
  //                 //     Navigator.of(context).pushNamed("/shopping-category");
  //                 //   },
  //                 // ),
  //               ],
  //             ),
  //       // Container(
  //       //   height: 180,
  //       //   child: ListView.builder(
  //       //     padding: EdgeInsets.only(bottom: 6),
  //       //     scrollDirection: Axis.horizontal,
  //       //     controller: _todayDealScrollController,
  //       //     itemCount: todaysDealList.length + 1,
  //       //     itemBuilder: (BuildContext context, int index) {
  //       //       if (index == todaysDealList.length) {
  //       //         return isTodayDealLoading
  //       //             ? Shimmer.fromColors(
  //       //                 baseColor: Colors.white,
  //       //                 highlightColor: greyBorderColor,
  //       //                 child: SizedBox(
  //       //                   height: 100,
  //       //                   child: ListView.builder(
  //       //                     shrinkWrap: true,
  //       //                     scrollDirection: Axis.horizontal,
  //       //                     physics: NeverScrollableScrollPhysics(),
  //       //                     itemCount: 3,
  //       //                     itemBuilder: (context, index) {
  //       //                       return SizedBox(
  //       //                         width: 160,
  //       //                         child: Card(
  //       //                           shape: RoundedRectangleBorder(
  //       //                             borderRadius: BorderRadius.circular(12),
  //       //                           ),
  //       //                         ),
  //       //                       );
  //       //                     },
  //       //                   ),
  //       //                 ),
  //       //               )
  //       //             : SizedBox.shrink();
  //       //       } else {
  //       //         ShoppingProduct shoppingProduct = todaysDealList[index];
  //       //         return DisplayProduct(
  //       //           giveRightPadding: true,
  //       //           product: Product(
  //       //             id: shoppingProduct.id,
  //       //             name: shoppingProduct.name,
  //       //             price: shoppingProduct.price.toString(),
  //       //             currency: shoppingProduct.currency,
  //       //             cover: shoppingProduct.cover,
  //       //             isAvailable: shoppingProduct.isAvailable,
  //       //             seller: shoppingProduct.seller,
  //       //             sellerFullName: shoppingProduct.sellerFullname,
  //       //           ),
  //       //         );
  //       //       }
  //       //     },
  //       //   ),
  //       // ),
  //     ],
  //   );
  // }

  // Widget todaysDealWidget({required ShoppingProduct product}) {
  //   return GestureDetector(
  //     onTap: () {
  //       ShoppingAuthService().getProduct(product.id!).then((value) {
  //         Navigator.pushNamed(context, '/product',
  //             arguments: {"product": value});
  //       });
  //     },
  //     child: SizedBox(
  //       width: 160,
  //       child: Card(
  //         elevation: 12,
  //         color: Colors.white,
  //         shadowColor: lightGrey.withOpacity(0.4),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         margin: EdgeInsets.only(top: 20, right: 14),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             Expanded(
  //               child: Padding(
  //                 padding: EdgeInsets.all(16),
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.only(
  //                     topLeft: Radius.circular(10),
  //                     topRight: Radius.circular(10),
  //                   ),
  //                   child: CachedNetworkImage(
  //                     imageUrl: product.cover!,
  //                     errorWidget: productAndServiceErrorWidget,
  //                     memCacheHeight:
  //                         (MediaQuery.of(context).size.height * 0.6).toInt(),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 10),
  //             Padding(
  //               padding: EdgeInsets.only(left: 10, bottom: 10),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.stretch,
  //                 children: [
  //                   Text(
  //                     product.name!,
  //                     textAlign: TextAlign.center,
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.w400,
  //                       fontSize: 14,
  //                       color: blackFont,
  //                     ),
  //                     maxLines: 2,
  //                   ),
  //                   SizedBox(height: 5),
  //                   RichText(
  //                     textAlign: TextAlign.center,
  //                     text: TextSpan(
  //                       text: worldCurrencies[product.currency!]!,
  //                       style: TextStyle(
  //                         fontSize: 16.0,
  //                         color: blackFont,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                       children: [
  //                         TextSpan(
  //                           text: truncateString(
  //                             str: moneyDisplayNormalizer(
  //                                 int.parse(product.price.toString())),
  //                             lengthToTruncateAt: 16,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget searchBox() {
    return Container(
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: navyBlue,
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(Routes.SEARCH_SERVICES);
          },
          child: IgnorePointer(
            ignoring: true,
            child: TextFormField(
              readOnly: true,
              style: TextStyle(
                fontSize: 16,
                color: blackFont,
                fontWeight: FontWeight.w600,
              ),
              cursorWidth: 1.5,
              cursorColor: navyBlue,
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkGrey,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    SlydoAppIcon.search,
                    color: darkGrey,
                    size: 14,
                  ),
                  onPressed: () {},
                ),
                hintText: "Search",
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: dividerColor,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: navyBlue,
                    width: 1.0,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: dividerColor,
                    width: 1.0,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: dividerColor,
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cartBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: badges.Badge(
        badgeContent: getBadgeContent(),
        position: badges.BadgePosition.topEnd(
            end: getBadgeCount().length == 1 ? -5 : -10, top: 0),
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
        Navigator.pushNamed(context, Routes.SHOPPING_CART);
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
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  String getBadgeCount() {
    int totalItem = 0;
    basketBloc.basketItems.forEach((element) {
      totalItem = totalItem + int.parse(element.qty.toString());
    });
    return totalItem > 99 ? '99+' : totalItem.toString();
  }
}

class SuperStoreSingleCard extends StatelessWidget {
  final Service service;
  const SuperStoreSingleCard({Key? key, required this.service})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DisplayService(
      service: service,
      giveRightPadding: false,
    );
    // return Stack(
    //   children: [
    //     InkWell(
    //       onTap: () {
    //         Navigator.pushNamed(
    //           context,
    //           Routes.PRODUCT,
    //           arguments: {"product": service},
    //         );
    //       },
    //       child: Card(
    //         elevation: 12,
    //         color: Colors.white,
    //         shadowColor: lightGrey.withOpacity(0.4),
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(12),
    //         ),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: [
    //             Padding(
    //               padding: const EdgeInsets.all(16.0),
    //               child: ClipRRect(
    //                 borderRadius: BorderRadius.only(
    //                   topLeft: Radius.circular(12),
    //                   topRight: Radius.circular(12),
    //                 ),
    //                 child: CachedNetworkImage(
    //                   height: 150,
    //                   width: double.infinity,
    //                   errorWidget: productAndServiceBigErrorWidget,
    //                   imageUrl: product.serverImages![0]!,
    //                   memCacheHeight:
    //                       (MediaQuery.of(context).size.height * 0.6).toInt(),
    //                 ),
    //               ),
    //             ),
    //             const SizedBox(height: 6),
    //             Text(
    //               truncateString(str: product.name!, lengthToTruncateAt: 15),
    //               style: TextStyle(
    //                 fontSize: 16,
    //                 fontWeight: FontWeight.w400,
    //               ),
    //             ),
    //             Padding(
    //               padding: const EdgeInsets.symmetric(vertical: 6.0),
    //               child: Row(
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: <Widget>[
    //                   Expanded(
    //                     child: RichText(
    //                       textAlign: TextAlign.center,
    //                       text: TextSpan(
    //                         text: worldCurrencies[product.currency!]!,
    //                         style: TextStyle(
    //                             fontSize: 16.0,
    //                             color: navyBlue,
    //                             fontWeight: FontWeight.bold),
    //                         children: [
    //                           TextSpan(
    //                             text: truncateString(
    //                               str: moneyDisplayNormalizer(
    //                                   int.parse(product.price.toString())),
    //                               lengthToTruncateAt: 16,
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             Align(
    //               alignment: Alignment.center,
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   getRating(
    //                       numberOfRating: product.rating!.toInt(),
    //                       starSize: 14),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }
}
