import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;
import '../../data/currency.dart';
import '../../data/state_notifier.dart';
import '../../routes/route_constants.dart';
import '../../utils/navigation_util.dart';
import '../../utils/util.dart';
import '../../widget/item_display_card.dart';
import '../../widget/rounded_background_icon.dart';
import '../more_apps/shopping/models/ShoppingProduct.dart';
import '../more_apps/shopping/models/store.dart';
import '../more_apps/shopping/shopping_auth.dart';

class SuperStore extends StatefulWidget {
  const SuperStore({Key? key}) : super(key: key);

  @override
  State<SuperStore> createState() => _SuperStoreState();
}

class _SuperStoreState extends State<SuperStore> {
  bool todaysDealsEmpty = false;
  bool isTodayDealLoading = false;
  double todaysDealsSizeBox = 0;
  List<ShoppingProduct> todaysDealList = [];

  List<Product> productList = [];
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

  ScrollController _todayDealScrollController = new ScrollController();
  ScrollController _productScrollController = new ScrollController();

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Text(
        AppLocalization.of(context)!.superStore,
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        _cartBtn(),
        SizedBox(width: 12),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getProductList();

    getTodaysDealProducts();
    _productScrollController.addListener(() {
      if (_productScrollController.position.pixels ==
              _productScrollController.position.maxScrollExtent &&
          _productScrollController.position.pixels != 0) {
        getProductList();
      }
    });
    _todayDealScrollController.addListener(() {
      if (_todayDealScrollController.position.pixels ==
              _todayDealScrollController.position.maxScrollExtent &&
          _todayDealScrollController.position.pixels != 0) {
        getTodaysDealProducts();
      }
    });
  }

  void getProductList() async {
    if (!isProductLoading) {
      if (productNext != null && !isProductLoading) {
        isProductLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfProduct(productNext, productPrevious, otherDeals: true);

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
        var tempList = result['results'];
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
        _productScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  void getTodaysDealProducts() async {
    if (!isTodayDealLoading) {
      if (todayDealNext != null && !isTodayDealLoading) {
        isTodayDealLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await ShoppingAuthService()
            .getProductListForSuperStore(todayDealNext, todayDealPrevious,
                todaysDeal: true);

        if (result == null) {
          todaysDealsEmpty = true;
          todaysDealsSizeBox = 22;
          isTodayDealLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        todayDealNext = result['next'];
        todayDealPrevious = result['previous'];
        var tempList = result['results'];

        todaysDealsEmpty = false;
        isTodayDealLoading = false;
        todaysDealList.addAll(tempList);

        if (mounted) setState(() {});
      }
      if (todaysDealList.isEmpty) {
        if (mounted) {
          setState(() {
            todaysDealsEmpty = true;
          });
        }
      }
    }
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
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
    todaysDealList = [];

    getProductList();
    getTodaysDealProducts();
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
                  SizedBox(height: 16),
                  SizedBox(height: todaysDealsSizeBox),
                  todaysDealsEmpty ? SizedBox.shrink() : getTodaysDealList(),
                  todaysDealsEmpty ? SizedBox.shrink() : SizedBox(height: 20),
                  superStoreProducts(),
                  const SizedBox(height: 16),
                  isProductLoading
                      ? Shimmer.fromColors(
                          baseColor: Colors.white,
                          highlightColor: greyBorderColor,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
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
                      : SizedBox.shrink(),
                  Visibility(
                    visible: !isProductLoading &&
                        !isTodayDealLoading &&
                        todaysDealList.isEmpty &&
                        productList.isEmpty,
                    child: NoItemInList(
                      msg: AppLocalization.of(context)!.noResultFound,
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
      return SizedBox.shrink();
    }
    return productNext == "" && isProductLoading
        ? SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              noProductInList
                  ? SizedBox.shrink()
                  : todaysDealsEmpty
                      ? SizedBox.shrink()
                      : Text(
                          "Other deals",
                          style: TextStyle(
                            fontSize: 18,
                            color: blackFont,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
              noProductInList ? SizedBox.shrink() : SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisSpacing: 22,
                  mainAxisExtent: 274,
                  crossAxisSpacing: 15,
                  maxCrossAxisExtent: 200,
                ),
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  return SuperStoreSingleCard(
                    product: productList[index],
                  );
                },
              ),
            ],
          );
  }

  Widget getTodaysDealList() {
    return Column(
      children: [
        todaysDealsEmpty
            ? SizedBox.shrink()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                        "Today's deal",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: blackFont,
                        ),
                      ),
                      Icon(
                        Icons.bolt_rounded,
                        color: mateRed,
                      ),
                    ],
                  ),
                  // GestureDetector(
                  //   child: Row(
                  //     children: [
                  //       Text(
                  //         "See all",
                  //         style: TextStyle(
                  //             fontWeight: FontWeight.w600,
                  //             fontSize: 14,
                  //             color: navyBlue),
                  //       ),
                  //       SizedBox(width: 8),
                  //       Icon(Icons.arrow_forward_ios_sharp,
                  //           size: 14, color: navyBlue),
                  //     ],
                  //   ),
                  //   onTap: () {
                  //     Navigator.of(context).pushNamed("/shopping-category");
                  //   },
                  // ),
                ],
              ),
        Container(
          height: 280,
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 6),
            scrollDirection: Axis.horizontal,
            controller: _todayDealScrollController,
            itemCount: todaysDealList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == todaysDealList.length) {
                return isTodayDealLoading
                    ? Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: greyBorderColor,
                        child: SizedBox(
                          height: 100,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: 160,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : SizedBox.shrink();
              } else {
                ShoppingProduct shoppingProduct = todaysDealList[index];
                return DisplayProduct(
                  giveRightPadding: true,
                  product: Product(
                      id: shoppingProduct.id,
                      name: shoppingProduct.name,
                      price: shoppingProduct.price.toString(),
                      currency: shoppingProduct.currency,
                      cover: shoppingProduct.cover,
                      isAvailable: shoppingProduct.isAvailable,
                      seller: shoppingProduct.seller,
                      sellerFullName: shoppingProduct.sellerFullname,
                      shortDescription: shoppingProduct.shortDescription),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget todaysDealWidget({required ShoppingProduct product}) {
    return GestureDetector(
      onTap: () {
        ShoppingAuthService().getProduct(product.id!).then((value) {
          Navigator.pushNamed(context, '/product',
              arguments: {"product": value});
        });
      },
      child: SizedBox(
        width: 160,
        child: Card(
          elevation: 12,
          color: Colors.white,
          shadowColor: lightGrey.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.only(top: 20, right: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.cover!,
                      errorWidget: productAndServiceErrorWidget,
                      memCacheHeight:
                          (MediaQuery.of(context).size.height * 0.6).toInt(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(left: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      product.name!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: blackFont,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 5),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: worldCurrencies[product.currency!]!,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: blackFont,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: truncateString(
                              str: moneyDisplayNormalizer(
                                  int.parse(product.price.toString())),
                              lengthToTruncateAt: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            Navigator.of(context).pushNamed("/search-product");
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
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                prefix: Padding(
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
      totalItem = totalItem + element['qty'] as int;
    });
    return totalItem > 99 ? '99+' : totalItem.toString();
  }
}

class SuperStoreSingleCard extends StatelessWidget {
  final Product product;
  const SuperStoreSingleCard({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DisplayProduct(product: product, giveRightPadding: false);
    // return Stack(
    //   children: [
    //     InkWell(
    //       onTap: () {
    //         Navigator.pushNamed(
    //           context,
    //           Routes.PRODUCT,
    //           arguments: {"product": product},
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
