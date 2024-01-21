import 'package:Slydo/data/environment.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/yarn_enum.dart';
import 'package:Slydo/screens/super_store/super_store_industry.dart';
import 'package:Slydo/screens/super_store/widget/section_products.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
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

class ShopListScreenWithTags extends StatefulWidget {
  Function(bool)? onPageRefresh;
  String? category;

  ShopListScreenWithTags({Key? key, this.onPageRefresh, this.category})
      : super(key: key);

  @override
  State<ShopListScreenWithTags> createState() => ShopListScreenState();
}

class ShopListScreenState extends State<ShopListScreenWithTags> {
  bool todaysDealsEmpty = false;
  bool isTodayDealLoading = false;
  double todaysDealsSizeBox = 0;
  List<ShoppingProduct> todaysDealList = [];

  bool isProductLoading = false;
  bool noProductInList = false;
  int? productCount = 0;
  String? todayDealNext = "";
  String? productNext = "";
  String? todayDealPrevious = "";
  String? productPrevious = "";
  late BasketBloc basketBloc;
  List rowHeaders = [];
  List<Product> storeProducts = [];
  bool noItemInList = false;
  String? next = "1";
  String? previous = "";
  List<DiscountModel> itemList = [];
  int? itemCount = 0;
  bool isLoading = false;
  List<CustomerProfile> customerProfileListNearBy = [];
  int? nearByCount = 0;
  String? nearByNext = "";
  String? nearByPrevious = "";
  bool isNearbyLoading = false;
  bool noNearByInList = false;

  final GlobalKey<ScaffoldMessengerState> _productScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final ScrollController _todayDealScrollController = ScrollController();
  final ScrollController _productScrollController = ScrollController();
  // final CarouselController _controller = CarouselController();
  String _currentCategory = '';
  late DashboardBloc _dashboardBloc;

  CarouselController _controller = CarouselController();
  int currentIndex = 0;

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
    getAllListData();
    _productScrollController.addListener(() {
      if (_productScrollController.position.pixels ==
              _productScrollController.position.maxScrollExtent &&
          _productScrollController.position.pixels != 0) {
        // getProductList(_currentCategory);
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

  Future<void> getAllListData() async {
    await Future.wait([
      listOfSuperStores(withSetState: false),
      getList(withSetState: false),
      getNearByBusinessList(withSetState: false),
      getTodaysDealProducts(withSetState: false)
    ]);
    if (mounted) setState(() {});
  }

  Future<void> listOfSuperStores({bool withSetState = true}) async {
    isProductLoading = true;
    if (mounted && withSetState) {
      setState(() {});
    }
    Map<String, dynamic>? result =
        await ShoppingAuthService().listOfSuperStores();
    isProductLoading = false;
    if (mounted && withSetState) {
      setState(() {});
    }
    // setState(() {
    rowHeaders = result!['store'];
  }

  @override
  void didUpdateWidget(ShopListScreenWithTags oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.category != _currentCategory) {
      _currentCategory = widget.category!;
      debugPrint('CALLING OTHER ::: $_currentCategory');
      // _refreshPage(); // Reload shop list when category changes
    }
  }

  Future<void> getList({bool withSetState = true}) async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted && withSetState) {
          setState(() {});
        }
        Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfDiscounts(next, previous, activeDiscount: true);

        if (result == null) {
          isLoading = false;
          noItemInList = true;
          if (mounted && withSetState) {
            setState(() {});
          }
          return;
        }

        itemCount = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];

        noItemInList = false;
        isLoading = false;
        itemList.addAll(tempList);
        if (mounted && withSetState) {
          setState(() {});
        }
      }
      if (itemList.isEmpty) {
        noItemInList = true;
        if (mounted && withSetState) {
          setState(() {});
        }
      } else if (next == null && itemList.length > 6) {
        _productScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  Future<void> getTodaysDealProducts({bool withSetState = true}) async {
    if (!isTodayDealLoading) {
      if (todayDealNext != null && !isTodayDealLoading) {
        isTodayDealLoading = true;
        if (mounted && withSetState) {
          setState(() {});
        }

        Map<String, dynamic>? result = await ShoppingAuthService()
            .getProductListForSuperStore(todayDealNext, todayDealPrevious,
                todaysDeal: true);

        if (result == null) {
          todaysDealsEmpty = true;
          todaysDealsSizeBox = 22;
          isTodayDealLoading = false;
          if (mounted && withSetState) {
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

        if (mounted && withSetState) {
          setState(() {});
        }
      }
      if (todaysDealList.isEmpty) {
        todaysDealsEmpty = true;
        if (mounted && withSetState) {
          setState(() {});
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

  Future<void> getNearByBusinessList({bool withSetState = true}) async {
    if (!isNearbyLoading) {
      if (nearByNext != null && !isNearbyLoading) {
        isNearbyLoading = true;
        if (mounted && withSetState) {
          setState(() {});
        }

        Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfMerchant(nearByNext, nearByPrevious, _currentCategory,
                nearBy: true);

        if (result == null) {
          noNearByInList = true;

          isNearbyLoading = false;
          if (mounted && withSetState) {
            setState(() {});
          }
          return;
        }

        nearByCount = result['count'];
        nearByNext = result['next'];
        nearByPrevious = result['previous'];
        var tempList = result['results'];

        noNearByInList = false;
        isNearbyLoading = false;
        customerProfileListNearBy.addAll(tempList);
        if (mounted && withSetState) {
          setState(() {});
        }

        // for(var item in customerProfileListNearBy){
        //   debugPrint('Fola near by:::: ${item.toJson()}');
        // }

      }
      if (customerProfileListNearBy.isEmpty) {
        noNearByInList = true;
        if (mounted && withSetState) {
          setState(() {});
        }
      } else if (nearByNext == null && customerProfileListNearBy.length > 6) {
        // _findBusinessScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
        //   content:
        //       Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        //   duration: const Duration(milliseconds: 500),
        // ));
      }
    }
  }

  _refreshPage() {
    productNext = "";
    productCount = 0;
    productPrevious = "";
    isProductLoading = false;

    todayDealNext = "";
    todayDealPrevious = "";
    isTodayDealLoading = false;
    todaysDealList = [];
    listOfSuperStores();
    getList();
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
        // appBar: appBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
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
                  if (itemList.isNotEmpty) specialDeals(),
                  SizedBox(height: todaysDealsSizeBox),
                  if (customerProfileListNearBy.isNotEmpty) nearByBuildView(),
                  sessionProducts(),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget specialDeals() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 15, bottom: 8),
            alignment: Alignment.bottomLeft,
            child: Text(
              "Special Deal",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Inter",
                  color: black),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(
            height: 151,
            child: Column(
              children: [
                Expanded(
                  child: CarouselSlider(
                    carouselController: _controller,
                    options: CarouselOptions(
                        height: 150,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 1,
                        aspectRatio: 16 / 9,
                        // onPageChanged: (index, reason) {
                        //   setState(() {
                        //     _current = index;
                        //   });
                        // }),
                        // enableInfiniteScroll: false,
                        // viewportFraction: 1.0,
                        // enlargeCenterPage: true,
                        // autoPlay: true,
                        // aspectRatio: 1.7,
                        onPageChanged: onPageFunction),
                    items: itemList
                        .map(
                          (e) => InkWell(
                            onTap: () {
                              String url = AppConfig.baseUrl +
                                  "/api/v1/products/products-by-discount/${e.id}";
                              NavigationUtil.push(context,
                                  screen: SuperStoreIndustry(
                                      next: url,
                                      appTitle: e.name!,
                                      searchQuery: {"discount": e.id!}));
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 8),
                              width: MediaQuery.of(context).size.width,
                              height: 150,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: getImage(e),
                              ),
                              // decoration: BoxDecoration(
                              //   borderRadius: BorderRadius.circular(10),
                              //   image: DecorationImage(
                              //     fit: BoxFit.fill,
                              //     image: getImage(e),
                              //   ),
                              // ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: itemList.map((url) {
                    int index = itemList.indexOf(url);
                    return Container(
                      width: 5.0,
                      height: 5.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentIndex == index ? navyBlue : navyBlueLight,
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getImage(DiscountModel item) {
    if (item.poster != null) {
      return CachedNetworkImage(
        imageUrl: item.poster!,
        errorWidget: imageErrorWidget,
        fit: BoxFit.fill,
      );
    } else {
      return Image.asset(defaultProductAndServiceImage);
    }
  }

  Widget sessionProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        // if (rowHeaders.isNotEmpty)
        //   ...rowHeaders.map((headers) => rowTitle(headers)).toList(),

        if (rowHeaders.isNotEmpty)
          ...rowHeaders
              .asMap()
              .map(
                (i, headers) => MapEntry(
                  i,
                  rowTitle(headers, isLast: i == rowHeaders.length - 1),
                ),
              )
              .values
              .toList(),
      ],
    );
  }

  getRowTitle(headers) async {
    List<Product> result = [];
    for (var item in headers['results']) {
      Product product = await ShoppingAuthService().createProduct(item);
      result.add(product);
    }
    return result;
  }

  Widget nearByBuildView() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      margin: EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Nearby Businesses",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFamily: "Inter",
                  color: black,
                ),
              ),
              GestureDetector(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "View more",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          fontFamily: "Inter",
                          color: navyBlue),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios_sharp,
                        size: 12, color: navyBlue),
                  ],
                ),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(Routes.NEAR_BY_LIST_SCREEN, arguments: {
                    "customerProfile": customerProfileListNearBy,
                    "count": nearByCount,
                    "next": nearByNext
                  });
                },
              ),
            ],
          ),
          const SizedBox(
            height: 11.0,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var item in customerProfileListNearBy)
                  Container(
                    width: 200,
                    // height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.USER_PROFILE,
                            arguments: {"searchedUserName": item.userName});
                      },
                      child: FindBusiness(
                        customerProfile: item,
                        tileRenderPlace: TileRenderPlace.Thiny,
                        callback: (username, value) {
                          //create a list to edit
                          List<CustomerProfile> customerProfileListEdit =
                              customerProfileListNearBy;

                          // modify customerProfileList for the username and refresh the list
                          // set the isFollowing for that particular user
                          for (var customer in customerProfileListEdit) {
                            if (customer.userName == username) {
                              customer.isFollowing =
                                  value; // Modify the isFollowing property
                            }
                          }

                          customerProfileListNearBy = [];
                          customerProfileListNearBy = customerProfileListEdit;

                          if (mounted) setState(() {});
                        },
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget rowTitle(headers, {bool isLast = false}) {
    return SectionProducts(headers: headers, isLast: isLast);
  }

  Widget getTodaysDealList() {
    return Column(
      children: [
        todaysDealsEmpty
            ? const SizedBox.shrink()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Row(
                  //   children: [
                  //     Text(
                  //       "Today's deal",
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.w700,
                  //         fontSize: 18,
                  //         color: blackFont,
                  //       ),
                  //     ),
                  //     Icon(
                  //       Icons.bolt_rounded,
                  //       color: mateRed,
                  //     ),
                  //   ],
                  // ),
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
                    shortDescription: shoppingProduct.shortDescription,
                    discountValue: shoppingProduct.discountValue,
                    discountIsActive: shoppingProduct.discountIsActive,
                    discountType: shoppingProduct.discountType,
                    discountedPrice: shoppingProduct.discountedPrice,
                  ),
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
                        fontFamily: "Inter",
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
                          fontFamily: "Inter",
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
                fontFamily: "Inter",
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

  onPageFunction(int index, CarouselPageChangedReason reason) {
    currentIndex = index;
    setState(() {});
  }
}

class SuperStoreSingleCard extends StatelessWidget {
  final Product product;

  // final String? next;
  const SuperStoreSingleCard({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DisplayProduct(product: product, giveRightPadding: false);
  }
}
