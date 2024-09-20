import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/shopping/shopping_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../models/shopping_product_model.dart';
import 'shopping_tile.dart';

class ShoppingExploreScreen extends StatefulWidget {
  const ShoppingExploreScreen({super.key});

  @override
  State<ShoppingExploreScreen> createState() => _ShoppingExploreScreenState();
}

class _ShoppingExploreScreenState extends State<ShoppingExploreScreen> {
  final CarouselController _carouselController = CarouselController();

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

  final RefreshController _refreshController =
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
    if (await checkConnection(context)) {
      getResult();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    shoppingDashboardBloc = Provider.of<ShoppingDashboardBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    return Scaffold(
      backgroundColor: lightGrey,
      resizeToAvoidBottomInset: true,
      appBar: appBar() as PreferredSizeWidget?,
      body: scaffoldBody(),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget goToCartWidget() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: badges.Badge(
        badgeContent: getBadgeContent(),
        position: badges.BadgePosition.topEnd(end: 0, top: 0),
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
            padding: basketBloc.basketItems.isEmpty
                ? const EdgeInsets.all(0)
                : const EdgeInsets.all(4)),
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
    if (basketBloc.basketItems.isEmpty) {
      return null;
    }
    return Text(
      getBadgeCount().toString(),
      style: const TextStyle(
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  String getBadgeCount() {
    int totalItem = 0;
    for (var element in basketBloc.basketItems) {
      totalItem = totalItem + int.parse(element.qty.toString());
    }
    return totalItem > 99 ? '99+' : totalItem.toString();
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
            const SizedBox(
              height: 6,
            ),
            searchBox(),
            const SizedBox(
              height: 32,
            ),
            productCarouselSlider(),
            const SizedBox(
              height: 40,
            ),
            getTodayDealList(),
            const SizedBox(
              height: 16,
            ),
            trendingProductList(),
            const SizedBox(
              height: 16,
            ),
            getDiscountDealList(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget productCarouselSlider() {
    return isSliderLoading
        ? SizedBox(
            height: 180,
            child: Center(
              child: CircularLoadingIndicator(),
            ),
          )
        : CarouselSlider(
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
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Center(
                          child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
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
          );
  }

  Widget trendingProductList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
              ? Center(
                  child: CircularLoadingIndicator(),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: trendingProduct
                          .map(
                            (product) => Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: productNameCard(product: product),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
        )
      ],
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
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  messageDecoderWithEmoji(product.name) ?? "",
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: blackFont,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: isTodayDealLoading
              ? SizedBox(
                  height: 140,
                  child: Center(
                    child: CircularLoadingIndicator(),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: todayDeal
                          .map((product) => Container(
                                margin: const EdgeInsets.only(right: 12),
                                child: productPoster(product: product),
                              ))
                          .toList(),
                    ),
                  ),
                ),
        )
      ],
    );
  }

  Widget getDiscountDealList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
        if (isDiscountProductListLoading)
          SizedBox(
            height: 200,
            child: Center(
              child: CircularLoadingIndicator(),
            ),
          )
        else
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  children: [
                    SizedBox(
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
                                        imageUrl:
                                            discountProductList.first.cover!,
                                        fit: BoxFit.fill,
                                        errorWidget:
                                            productAndServiceErrorWidget,
                                        memCacheHeight: (MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.6)
                                            .toInt(),
                                      ),
                                      onTap: () {
                                        ShoppingAuthService()
                                            .getProduct(
                                                discountProductList.first.id!)
                                            .then((value) {
                                          Navigator.pushNamed(
                                              context, '/product',
                                              arguments: {"product": value});
                                        });
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                messageDecoderWithEmoji(
                                                        discountProductList
                                                            .first.name) ??
                                                    "",
                                                softWrap: false,
                                                overflow: TextOverflow.fade,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: blackFont,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              Text(
                                                messageDecoderWithEmoji(
                                                        discountProductList
                                                            .first
                                                            .shortDescription) ??
                                                    "",
                                                // softWrap: false,
                                                // overflow:
                                                //     TextOverflow.fade,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: darkGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 60,
                                          child: Center(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
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
                                                    fontWeight: FontWeight.w700,
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
                    const SizedBox(
                      height: 12,
                    ),
                    Column(
                      children: discountProductList
                          .map((product) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () {
                                    ShoppingAuthService()
                                        .getProduct(product.id!)
                                        .then((value) {
                                      Navigator.pushNamed(context, '/product',
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
      child: SizedBox(
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
                messageDecoderWithEmoji(product.name) ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(
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
