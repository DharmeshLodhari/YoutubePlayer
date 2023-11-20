import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/yarn_enum.dart';
import 'package:Slydo/screens/super_store/super_store_home.dart';
import 'package:Slydo/screens/super_store/super_store_industry.dart';
import 'package:Slydo/screens/super_store/widget/section_products.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/currency.dart';
import '../../data/environment.dart';
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

  List<Product> productList = [];
  List<Product> productListz = [];
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
    listOfSuperStores();
    getProductList(_currentCategory);
    getList();
    getNearByBusinessList();
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

  listOfSuperStores() async {
    Map<String, dynamic>? result =
        await ShoppingAuthService().listOfSuperStores();
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

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfDiscounts(next, previous, activeDiscount: true);

        if (result == null) {
          isLoading = false;
          noItemInList = true;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        itemCount = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            noItemInList = false;
            isLoading = false;
            itemList.addAll(tempList);
          });
        }
      }
      if (itemList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
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

  getProductList(String category,
      {String tag = "", String nearby = "", bool otherDeals: true}) async {
    if (!isProductLoading) {
      if (productNext != null && !isProductLoading) {
        isProductLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfProduct(
                productNext, productPrevious, _currentCategory, false,
                otherDeals: otherDeals, page_size: 5, tag: tag, nearby: nearby);

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
      } else if (productNext == null && productList.length > 6 && tag.isEmpty) {
        _productScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
      return productList;
    }
  }

  getProductTags(String category,
      {String tag = "", String nearby = "", bool otherDeals: false}) async {
    Map<String, dynamic>? result = await ShoppingAuthService().listOfProduct(
        "", "", "", false,
        otherDeals: otherDeals, page_size: 5, tag: tag, nearby: nearby);

    if (result == null) {
      return productListz;
    }

    var tempList = result['results'];
    if (mounted) {
      setState(() {
        productListz.addAll(tempList);
      });
    }

    return productListz;
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

  void getNearByBusinessList() async {
    if (!isNearbyLoading) {
      if (nearByNext != null && !isNearbyLoading) {
        isNearbyLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfMerchant(nearByNext, nearByPrevious, _currentCategory,
                nearBy: true);

        if (result == null) {
          noNearByInList = true;

          isNearbyLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        nearByCount = result['count'];
        nearByNext = result['next'];
        nearByPrevious = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            noNearByInList = false;
            isNearbyLoading = false;
            customerProfileListNearBy.addAll(tempList);
          });
        }

        // for(var item in customerProfileListNearBy){
        //   debugPrint('Fola near by:::: ${item.toJson()}');
        // }

      }
      if (customerProfileListNearBy.isEmpty) {
        if (mounted) {
          setState(() {
            noNearByInList = true;
          });
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
                  if (itemList.isNotEmpty)
                  specialDeals(),
                  SizedBox(height: todaysDealsSizeBox),
                  if(customerProfileListNearBy.isNotEmpty)
                  nearByBuildView(),
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

  Widget specialDeals() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 35, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
         Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 151,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: ScrollPhysics(),
              children: [
                ...itemList
                    .map(
                      (e) => e.poster == null
                          ? SizedBox()
                          : InkWell(
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
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(e.poster!),
                                  ),
                                ),
                              ),
                            ),
                    )
                    .toList()
              ],
            ),
          ),
        ),
      ],
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
                      : SizedBox.shrink(),
              noProductInList
                  ? const SizedBox.shrink()
                  : const SizedBox(height: 16),
              SizedBox(height: 8),
              if(rowHeaders.isNotEmpty)
              ...rowHeaders.map((headers) => rowTitle(headers)).toList(),
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
                          fontFamily: "Open Sans",
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

  Widget rowTitle(headers) {
    return SectionProducts(headers: headers);
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
  // final String? next;
  const SuperStoreSingleCard({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DisplayProduct(product: product, giveRightPadding: false);
  }
}
