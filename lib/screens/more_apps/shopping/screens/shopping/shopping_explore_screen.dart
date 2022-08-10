import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/shopping/shopping_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../models/ShoppingProduct.dart';
import 'shopping_tile.dart';

class ShoppingExploreScreen extends StatefulWidget {
  @override
  _ShoppingExploreScreenState createState() => _ShoppingExploreScreenState();
}

class _ShoppingExploreScreenState extends State<ShoppingExploreScreen> {
  CarouselController _carouselController = CarouselController();

  late ShoppingDashboardBloc shoppingDashboardBloc;

  late BasketBloc basketBloc;

  List<ShoppingProduct> sliderList = [];
  bool isSliderLoading = false;

  List<ShoppingProduct> todayDeal = [];
  bool isTodayDealLoading = false;

  List<ShoppingProduct> trendingProduct = [];
  bool isTrendingProductLoading = false;

  List<ShoppingProduct> discountProductList = [];
  bool isDiscountProductListLoading = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() async {
    getSliderProducts();
    getTodayDealProducts();
    getTrendingProducts();
    getDiscountProducts();
  }

  void getSliderProducts() async {
    isSliderLoading = true;
    sliderList.clear();
    if (mounted) setState(() {});

    sliderList = (await ShoppingAuthService().getProductList("", ""))!;

    isSliderLoading = false;
    if (mounted) setState(() {});
  }

  void getTodayDealProducts() async {
    isTodayDealLoading = true;
    todayDeal.clear();
    if (mounted) setState(() {});

    todayDeal = (await ShoppingAuthService().getProductList("", ""))!;

    isTodayDealLoading = false;
    if (mounted) setState(() {});
  }

  void getTrendingProducts() async {
    isTrendingProductLoading = true;
    trendingProduct.clear();
    if (mounted) setState(() {});

    trendingProduct = (await ShoppingAuthService().getProductList("", ""))!;

    isTrendingProductLoading = false;
    if (mounted) setState(() {});
  }

  void getDiscountProducts() async {
    isDiscountProductListLoading = true;
    discountProductList.clear();
    if (mounted) setState(() {});

    discountProductList = (await ShoppingAuthService().getProductList("", ""))!;

    isDiscountProductListLoading = false;
    if (mounted) setState(() {});
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        getResult();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    shoppingDashboardBloc = Provider.of<ShoppingDashboardBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: appBar() as PreferredSizeWidget?,
      body: scaffoldBody(),
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
          shoppingDashboardBloc.index = 0;
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Shopping",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: [
        goToCartWidget(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget goToCartWidget() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Badge(
        badgeColor: naturalGreen,
        animationType: BadgeAnimationType.slide,
        badgeContent: getBadgeContent(),
        padding: basketBloc.items.length == 0
            ? EdgeInsets.all(0)
            : EdgeInsets.all(4),
        position: BadgePosition(end: 0, top: 0),
        child: Icon(
          SlydoAppIcon.cart,
          size: 16,
          color: blackFont,
        ),
      ),
      onTap: () {
        // _dashboardBloc.index = 3;
        // Navigator.popUntil(context, ModalRoute.withName("/dashboard"));
        Navigator.of(context).pushNamed("/mix-cart-item");
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget? getBadgeContent() {
    if (basketBloc.items.length == 0) {
      return null;
    }
    return Text(
      getBadgeCount().toString(),
      style: TextStyle(
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  int getBadgeCount() {
    int totalItem = 0;
    basketBloc.items.forEach((element) {
      totalItem = totalItem + element['qty'] as int;
    });
    return totalItem;
  }

  Widget scaffoldBody() {
    return SmartRefresher(
      enablePullDown: true,
      header: WaterDropHeader(
        complete: Container(),
        waterDropColor: navyBlue,
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 6,
            ),
            searchBox(),
            SizedBox(
              height: 32,
            ),
            productCarouselSlider(),
            SizedBox(
              height: 40,
            ),
            getTodayDealList(),
            SizedBox(
              height: 16,
            ),
            trendingProductList(),
            SizedBox(
              height: 16,
            ),
            getDiscountDealList(),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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

  Widget productCarouselSlider() {
    return isSliderLoading
        ? Container(
            height: 180,
            child: Center(
              child: CircularLoadingIndicator(),
            ),
          )
        : Container(
            child: CarouselSlider(
              carouselController: _carouselController,
              options: CarouselOptions(
                viewportFraction: 0.9,
                enlargeCenterPage: false,
                autoPlay: true,
                aspectRatio: 2,
                initialPage: 0,
              ),
              items: sliderList
                  .map(
                    (product) => GestureDetector(
                      onTap: () {
                        ShoppingAuthService()
                            .getProduct(product.id!)
                            .then((value) {
                          Navigator.pushNamed(context, '/product',
                              arguments: {"product": value});
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Center(
                            child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: CachedNetworkImage(
                            imageUrl: product.cover!,
                            fit: BoxFit.fill,
                            height: double.infinity,
                            width: double.infinity,
                            errorWidget: productAndServiceErrorWidget,
                            memCacheHeight:
                                (MediaQuery.of(context).size.height * 0.6)
                                    .toInt(),
                          ),
                        )),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
  }

  Widget trendingProductList() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Trending Products",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: blackFont,
                  ),
                ),
                GestureDetector(
                  child: Text(
                    "See all",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: navyBlue),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed("/shopping-category");
                  },
                ),
              ],
            ),
          ),
          Container(
            height: 210,
            color: Colors.white,
            child: isTrendingProductLoading
                ? Container(
                    child: Center(
                      child: CircularLoadingIndicator(),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: EdgeInsets.only(left: 16),
                      child: Row(
                        children: trendingProduct
                            .map(
                              (product) => Container(
                                margin: EdgeInsets.only(right: 12),
                                child: productNameCard(product: product),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
          )
        ],
      ),
    );
  }

  Widget productNameCard({required ShoppingProduct product}) {
    return GestureDetector(
      onTap: () {
        ShoppingAuthService().getProduct(product.id!).then((value) {
          Navigator.pushNamed(context, '/product',
              arguments: {"product": value});
        });
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          width: 160,
          decoration: decorateBox(borderColor: selectedListItemBackgroundBlue),
          child: Container(
            padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  product.name!,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: blackFont,
                  ),
                  maxLines: 1,
                ),
                SizedBox(
                  height: 12,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: product.cover!,
                    height: 130,
                    width: 130,
                    fit: BoxFit.fill,
                    errorWidget: productAndServiceErrorWidget,
                    memCacheHeight:
                        (MediaQuery.of(context).size.height * 0.6).toInt(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getTodayDealList() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Today's deal",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: blackFont,
                  ),
                ),
                GestureDetector(
                  child: Text(
                    "See all",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: navyBlue),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed("/shopping-category");
                  },
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            child: isTodayDealLoading
                ? Container(
                    height: 140,
                    child: Center(
                      child: CircularLoadingIndicator(),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: EdgeInsets.only(left: 16),
                      child: Row(
                        children: todayDeal
                            .map((product) => Container(
                                  margin: EdgeInsets.only(right: 12),
                                  child: productPoster(product: product),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
          )
        ],
      ),
    );
  }

  Widget getDiscountDealList() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Deal's upto 75% off",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: blackFont,
                  ),
                ),
                GestureDetector(
                  child: Text(
                    "See all",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: navyBlue),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed("/shopping-category");
                  },
                ),
              ],
            ),
          ),
          isDiscountProductListLoading
              ? Container(
                  height: 200,
                  child: Center(
                    child: CircularLoadingIndicator(),
                  ),
                )
              : Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Column(
                        children: [
                          Container(
                            height: 244,
                            child: CustomBoxShadow(
                              child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  margin: EdgeInsets.zero,
                                  shadowColor: boxShadowTwo,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          child: InkWell(
                                            child: CachedNetworkImage(
                                              width: double.infinity,
                                              imageUrl: discountProductList
                                                  .first.cover!,
                                              fit: BoxFit.fill,
                                              errorWidget:
                                                  productAndServiceErrorWidget,
                                              memCacheHeight:
                                                  (MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.6)
                                                      .toInt(),
                                            ),
                                            onTap: () {
                                              ShoppingAuthService()
                                                  .getProduct(
                                                      discountProductList
                                                          .first.id!)
                                                  .then((value) {
                                                Navigator.pushNamed(
                                                    context, '/product',
                                                    arguments: {
                                                      "product": value
                                                    });
                                              });
                                            },
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      discountProductList
                                                          .first.name!,
                                                      softWrap: false,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14,
                                                        color: blackFont,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 2,
                                                    ),
                                                    Text(
                                                      discountProductList.first
                                                          .shortDescription!,
                                                      // softWrap: false,
                                                      // overflow:
                                                      //     TextOverflow.fade,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: darkGrey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: 60,
                                                child: Center(
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        SlydoAppIcon.naira,
                                                        color: navyBlue,
                                                        size: 10,
                                                      ),
                                                      Text(
                                                        discountProductList
                                                            .first.price
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 14,
                                                          color: navyBlue,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Column(
                            children: discountProductList
                                .map((product) => Container(
                                      margin: EdgeInsets.only(bottom: 12),
                                      child: InkWell(
                                        onTap: () {
                                          ShoppingAuthService()
                                              .getProduct(product.id!)
                                              .then((value) {
                                            Navigator.pushNamed(
                                                context, '/product',
                                                arguments: {"product": value});
                                          });
                                        },
                                        child: ShoppingTile(
                                          product: product,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget productPoster({required ShoppingProduct product}) {
    return GestureDetector(
      onTap: () {
        ShoppingAuthService().getProduct(product.id!).then((value) {
          Navigator.pushNamed(context, '/product',
              arguments: {"product": value});
        });
      },
      child: Container(
        height: 132,
        width: 218,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                height: double.infinity,
                width: double.infinity,
                color: Colors.black12,
                colorBlendMode: BlendMode.darken,
                imageUrl: product.cover!,
                fit: BoxFit.fill,
                errorWidget: productAndServiceErrorWidget,
                memCacheHeight:
                    (MediaQuery.of(context).size.height * 0.6).toInt(),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                product.name!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.white),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
