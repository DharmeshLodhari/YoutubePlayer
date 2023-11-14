import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/currency.dart';
import '../../data/state_notifier.dart';
import '../../utils/util.dart';
import '../../widget/item_display_card.dart';
import '../more_apps/shopping/models/ShoppingProduct.dart';
import '../more_apps/shopping/models/store.dart';
import '../more_apps/shopping/shopping_auth.dart';

class ShopListScreen extends StatefulWidget {
  Function(bool)? onPageRefresh;
  String? category;
  final String industry;
  final String? nextUrl;

  ShopListScreen({Key? key, this.onPageRefresh, this.category, required this.industry, this.nextUrl}) : super(key: key);

  @override
  State<ShopListScreen> createState() => ShopListScreenState();
}

class ShopListScreenState extends State<ShopListScreen> {
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
  GlobalKey<ScaffoldMessengerState>();

  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  final ScrollController _todayDealScrollController = ScrollController();
  final ScrollController _productScrollController = ScrollController();
  String _currentCategory = '';
  late DashboardBloc _dashboardBloc;

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Text(
        'Deal of the day',
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        // _cartBtn(),
        // SizedBox(width: 12),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.category!;

    getProductList(_currentCategory);

    getTodaysDealProducts();
    _productScrollController.addListener(() {
      if (_productScrollController.position.pixels ==
          _productScrollController.position.maxScrollExtent &&
          _productScrollController.position.pixels != 0) {
        getProductList(_currentCategory);
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

  @override
  void didUpdateWidget(ShopListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.category != _currentCategory) {
      _currentCategory = widget.category!;
      debugPrint('CALLING OTHER ::: $_currentCategory');
      // _refreshPage(); // Reload shop list when category changes
    }
  }


  void getProductList(String category) async {
    productNext = widget.nextUrl != null ? widget.nextUrl : "";
    if (!isProductLoading) {
      if (productNext != null && !isProductLoading) {
        isProductLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfProduct(productNext, productPrevious, _currentCategory, false, otherDeals: true);

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
          duration: const Duration(milliseconds: 500),
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

    getProductList(_currentCategory);
    getTodaysDealProducts();
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    _dashboardBloc = Provider.of<DashboardBloc>(context);

    /// check if super store bottom navigation is clicked
    /// scroll back to the top of the page
    if (_dashboardBloc.topYarn == true) {
      _dashboardBloc.topYarn = false;
      if (_productScrollController.hasClients) {
        final position = _productScrollController.position.minScrollExtent;
        _productScrollController.animateTo(
          position,
          duration: Duration(milliseconds: 1),
          curve: Curves.easeOut,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_productScrollController.position.pixels == 0) {
        // Scroll controller is at the top
        widget.onPageRefresh!(true);
        if (mounted) setState(() {});
      }

    });


    return ScaffoldMessenger(
      key: _productScaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: lightGrey,
        // appBar: appBar(),
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

                  SizedBox(height: todaysDealsSizeBox),
                  todaysDealsEmpty ? const SizedBox.shrink() : getTodaysDealList(),
                  todaysDealsEmpty ? const SizedBox.shrink() : const SizedBox(height: 20),
                  superStoreProducts(),
                  const SizedBox(height: 16),
                  isProductLoading
                      ? Shimmer.fromColors(
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
                      : const SizedBox.shrink(),
                  Visibility(
                    visible: !isProductLoading &&
                        !isTodayDealLoading &&
                        todaysDealList.isEmpty &&
                        productList.isEmpty,
                    child: Center(
                      child: NoItemInList(
                        msg: AppLocalization.of(context)!.noResultFound,
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
        noProductInList
            ? const SizedBox.shrink()
            : todaysDealsEmpty
            ? const SizedBox.shrink()
            : Text(
          "Other deals",
          style: TextStyle(
            fontSize: 18,
            color: blackFont,
            fontWeight: FontWeight.w700,
          ),
        ),
        noProductInList ? const SizedBox.shrink() : const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
            ? const SizedBox.shrink()
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
            padding: const EdgeInsets.only(bottom: 6),
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
                      physics: const NeverScrollableScrollPhysics(),
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
                    : const SizedBox.shrink();
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
          margin: const EdgeInsets.only(top: 20, right: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
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
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10),
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
                    const SizedBox(height: 5),
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

}

class SuperStoreSingleCard extends StatelessWidget {
  final Product product;
  const SuperStoreSingleCard({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DisplayProduct(product: product, giveRightPadding: false);
  }
}
