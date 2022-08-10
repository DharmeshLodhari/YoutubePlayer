import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../data/currency.dart';
import '../../routes/route_constants.dart';
import '../../utils/util.dart';
import '../../widget/LoadingIndicator.dart';
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
  List<ShoppingProduct> todaysDeal = [];

  List<Product> productList = [];
  bool isProductLoading = false;
  bool noProductInList = false;
  int? productCount = 0;
  String? productNext = "";
  String? productPrevious = "";

  final GlobalKey<ScaffoldState> _productScaffoldKey =
      new GlobalKey<ScaffoldState>();

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
      title: Text(
        AppLocalization.of(context)!.superStore,
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
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
  }

  void getProductList() async {
    if (!isProductLoading) {
      if (productNext != null && !isProductLoading) {
        isProductLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfProduct(productNext, productPrevious,
                otherDeals: true);

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
        _productScaffoldKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  void getTodaysDealProducts() async {
    isTodayDealLoading = true;
    todaysDeal.clear();
    if (mounted) setState(() {});

    ShoppingAuthService().getProductList("", "", todaysDeal: true).then(
      (value) {
        isTodayDealLoading = false;

        todaysDeal = value!;

        if (todaysDeal.isEmpty) {
          todaysDealsEmpty = true;
        }
        if (mounted) setState(() {});

        debugPrint('TODAYS DEAL ---> $todaysDeal');
      },
    ).catchError((e) {
      todaysDealsEmpty = true;
      isTodayDealLoading = false;
      if (mounted) setState(() {});
    });
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
    if (mounted) setState(() {});
    getProductList();
    getTodaysDealProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: appBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                todaysDealsEmpty ? SizedBox.shrink() : getTodaysDealList(),
                const SizedBox(height: 38),
                // Image.asset('assets/images/super_store_ad.png'),

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
                            maxCrossAxisExtent: 200,
                            mainAxisExtent: 300,
                          ),
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            );
                          },
                        ),
                      )
                    : SizedBox.shrink(),
                Visibility(
                  visible: !isProductLoading &&
                      !isTodayDealLoading &&
                      todaysDeal.isEmpty &&
                      productList.isEmpty,
                  child: Center(
                    child: Column(
                      children: [
                        Lottie.asset('assets/lottie/no_moment_lottie.json'),
                        SizedBox(height: 20),
                        Text('No items at the moment'),
                      ],
                    ),
                  ),
                ),
              ],
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
                  : Text(
                      "Other deals",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: blackFont,
                      ),
                    ),
              noProductInList ? SizedBox.shrink() : SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisExtent: 270,
                  mainAxisSpacing: 16,
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
    return isTodayDealLoading
        ? Container(
            height: 140,
            child: Center(
              child: CircularLoadingIndicator(),
            ),
          )
        : Column(
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
                        GestureDetector(
                          child: Row(
                            children: [
                              Text(
                                "See all",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: navyBlue),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios_sharp,
                                  size: 14, color: navyBlue),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed("/shopping-category");
                          },
                        ),
                      ],
                    ),
              Container(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: todaysDeal
                      .map(
                        (product) => productPoster(product: product),
                      )
                      .toList(),
                ),
              ),
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
      child: Container(
        height: 130,
        width: 200,
        margin: EdgeInsets.only(top: 20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: product.cover!,
                fit: BoxFit.fitWidth,
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
}

class SuperStoreSingleCard extends StatelessWidget {
  final bool dealsOfTheDay;
  final Product product;
  const SuperStoreSingleCard(
      {Key? key, required this.product, this.dealsOfTheDay = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.PRODUCT,
              arguments: {"product": product},
            );
          },
          child: Card(
            elevation: 12,
            color: Colors.white,
            shadowColor: lightGrey.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    height: 170,
                    width: double.infinity,
                    errorWidget: productAndServiceBigErrorWidget,
                    imageUrl: product.serverImages![0]!,
                    fit: BoxFit.cover,
                    memCacheHeight:
                        (MediaQuery.of(context).size.height * 0.6).toInt(),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  truncateString(str: product.name!, lengthToTruncateAt: 15),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: worldCurrencies[product.currency!]!,
                            style: TextStyle(
                                fontSize: 16.0,
                                color: navyBlue,
                                fontWeight: FontWeight.bold),
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
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getRating(
                          numberOfRating: product.rating!.toInt(),
                          starSize: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
