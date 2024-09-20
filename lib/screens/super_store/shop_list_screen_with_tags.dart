import 'package:Slydo/data/environment.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/super_store/super_store_industry.dart';
import 'package:Slydo/screens/super_store/widget/find_business_card.dart';
import 'package:Slydo/screens/super_store/widget/section_products.dart';
import 'package:Slydo/screens/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/profile_template/product_view_more_details.dart';
import 'package:Slydo/screens/yarn/utils/yarn_enum.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../data/state_notifier.dart';
import '../../utils/util.dart';
import '../../widget/item_display_card.dart';
import '../more_apps/shopping/models/ShoppingProduct.dart';
import '../more_apps/shopping/models/store.dart';
import '../more_apps/shopping/shopping_auth.dart';

class ShopListScreenWithTags extends StatefulWidget {
  Function(bool)? onPageRefresh;
  String? category;

  ShopListScreenWithTags({super.key, this.onPageRefresh, this.category});

  @override
  State<ShopListScreenWithTags> createState() => ShopListScreenState();
}

class ShopListScreenState extends State<ShopListScreenWithTags> {
  bool todaysDealsEmpty = false;
  bool isTodayDealLoading = false;
  double todaysDealsSizeBox = 0;
  List<ShoppingProduct> todaysDealList = [];

  bool isProductLoading = false;
  // bool noProductInList = false;
  int? productCount = 0;
  String? todayDealNext = "";
  String? productNext = "";
  String? todayDealPrevious = "";
  String? productPrevious = "";
  late BasketBloc basketBloc;
  List rowHeaders = [];
  List<Product> storeProducts = [];
  List<Product> superStoreDealOftheDay = [];
  int productHorizontalLength = 10;
  bool noItemInList = false;
  String? next = "1";
  String? previous = "";
  List<DiscountModel> itemList = [];
  int? itemCount = 0;
  bool isLoading = false;
  List<CustomerProfile> customerProfileListNearBy = [];
  int? nearByCount = 0;
  String? nearByNext = "";
  String? url = "";
  String? nearByPrevious = "";
  bool isNearbyLoading = false;
  bool dealsOfDayEmpty = false;

  final GlobalKey<ScaffoldMessengerState> _productScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final ScrollController _todayDealScrollController = ScrollController();
  final ScrollController _productScrollController = ScrollController();
  // final CarouselController _controller = CarouselController();
  String _currentCategory = '';
  late DashboardBloc _dashboardBloc;

  final CarouselController _controller = CarouselController();
  int currentIndex = 0;

  AppBar appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
      actions: const [
        // _cartBtn(),
        // SizedBox(width: 12),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.category!;
    getAllData();
    // _productScrollController.addListener(() {
    //   if (_productScrollController.position.pixels ==
    //           _productScrollController.position.maxScrollExtent &&
    //       _productScrollController.position.pixels != 0) {
    //     // getProductList(_currentCategory);
    //   }
    // });
    // _todayDealScrollController.addListener(() {
    //   if (_todayDealScrollController.position.pixels ==
    //           _todayDealScrollController.position.maxScrollExtent &&
    //       _todayDealScrollController.position.pixels != 0) {
    //     getTodaysDealProducts();
    //   }
    // });
  }

  Future<void> getAllData() async {
    getNearByBusinessList();
    await fetchParallelData();
    getSuperStoreDealOfTheDay();

    // await Future.wait([
    //   listOfSuperStores(withSetState: false),
    //   getList(withSetState: false),
    //   getNearByBusinessList(withSetState: false),
    //   getTodaysDealProducts(withSetState: false)
    // ]);
    // if (mounted) setState(() {});
  }

  Future<void> listOfSuperStores({bool withSetState = true}) async {
    isProductLoading = true;
    if (mounted && withSetState) {
      setState(() {});
    }
    final Map<String, dynamic>? result =
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
      // debugPrint('CALLING OTHER ::: $_currentCategory');
      // _refreshPage(); // Reload shop list when category changes
    }
  }

  Future<void> fetchParallelData() async {
    if (!isLoading && next != null) {
      try {
        isLoading = true;
        if (mounted) {
          setState(() {});
        }

        // Make parallel API calls using Future.wait
        final List<Future<Map<String, dynamic>?>> apiCalls = [
          ShoppingAuthService().listOfSuperStores(),
          ShoppingAuthService()
              .listOfDiscounts(next, previous, activeDiscount: true),

          // ShoppingAuthService().getProductListForSuperStore(
          //     todayDealNext, todayDealPrevious,
          //     todaysDeal: true),
          // ShoppingAuthService().listOfMerchant(
          //     nearByNext, nearByPrevious, _currentCategory,
          //     nearBy: true),
        ];
        final List<Map<String, dynamic>?> results = await Future.wait(apiCalls);

        // Handle each API call result
        for (int i = 0; i < results.length; i++) {
          final result = results[i];
          if (result == null) {
            isLoading = false;
            noItemInList = true;
            if (mounted) {
              setState(() {});
            }
            return;
          }

          if (i == 0) {
            rowHeaders = result['store'];
          } else if (i == 1) {
            itemCount = result['count'];
            next = result['next'];
            previous = result['previous'];
            final tempList = result['results'];
            itemList.addAll(tempList);
          } else if (i == 2) {
            todayDealNext = result['next'];
            todayDealPrevious = result['previous'];
            final tempList2 = result['results'];
            todaysDealList.addAll(tempList2);
          }
          // else if (i == 3) {
          //   nearByCount = result['count'];
          //   nearByNext = result['next'];
          //   nearByPrevious = result['previous'];
          //   var tempList1 = result['results'];
          //   customerProfileListNearBy.addAll(tempList1);
          // }
        }

        noItemInList = false;
        isLoading = false;

        if (mounted) {
          setState(() {});
        }

        // if (itemList.isEmpty) {
        //   noItemInList = true;
        //   if (mounted) {
        //     setState(() {});
        //   }
        // } else if (next == null && itemList.length > 6) {
        //   _productScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        //     content: Text(
        //         AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        //     duration: Duration(milliseconds: 500),
        //   ));
        // }
      } catch (error) {
        debugPrint('Error in getData: $error');
        // Handle errors as needed
      }
    }
  }

  Future<void> getList({bool withSetState = true}) async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted && withSetState) {
          setState(() {});
        }
        final Map<String, dynamic>? result = await ShoppingAuthService()
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
        final tempList = result['results'];

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
        _productScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  void getSuperStoreDealOfTheDay() async {
    if (!isLoading) {
      if (todayDealNext != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});
        url = "${AppConfig.baseUrl}/api/v1/products/?today_deals=true";
        final Map<String, dynamic>? response = await ShoppingAuthService()
            .getProductsStoreDeal(todayDealNext, todayDealPrevious, url ?? "");
        if (response == null) {
          todaysDealsEmpty = true;
          todaysDealsSizeBox = 22;
          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        todayDealNext = response['next'];
        todayDealPrevious = response['previous'];
        final tempList = response['results'];

        todaysDealsEmpty = false;
        isLoading = false;
        superStoreDealOftheDay.addAll(tempList);
        if (mounted) setState(() {});
      }
      if (superStoreDealOftheDay.isEmpty) {
        if (mounted) {
          setState(() {
            todaysDealsEmpty = true;
          });
        }
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

        final Map<String, dynamic>? result = await ShoppingAuthService()
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
        final tempList = result['results'];

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

  Future<void> getNearByBusinessList({bool withSetState = true}) async {
    if (!isNearbyLoading) {
      if (nearByNext != null && !isNearbyLoading) {
        isNearbyLoading = true;
        if (mounted && withSetState) {
          setState(() {});
        }

        final Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfMerchant(nearByNext, nearByPrevious, _currentCategory,
                nearBy: true);

        if (result == null) {
          // noNearByInList = true;

          isNearbyLoading = false;
          if (mounted && withSetState) {
            setState(() {});
          }
          return;
        }

        nearByCount = result['count'];
        nearByNext = result['next'];
        nearByPrevious = result['previous'];
        final tempList = result['results'];

        // noNearByInList = false;
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
        // noNearByInList = true;
        if (mounted && withSetState) {
          setState(() {});
        }
      } else if (nearByNext == null && customerProfileListNearBy.length > 6) {
        // _findBusinessScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        //   content:
        //       Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        //   duration: const Duration(milliseconds: 500),
        // ));
      }
    }
  }

  void _refreshPage() {
    productNext = "";
    productCount = 0;
    productPrevious = "";
    isProductLoading = false;

    todayDealNext = "";
    todayDealPrevious = "";
    isTodayDealLoading = false;
    todaysDealList = [];
    getAllData();
    // listOfSuperStores();
    // getList();
    // getTodaysDealProducts();
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      _refreshPage();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
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
          duration: const Duration(milliseconds: 1),
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
        body: SafeArea(
          child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              controller: _productScrollController,
              children: [
                if (itemList.isNotEmpty) specialDeals(),
                if (superStoreDealOftheDay.isNotEmpty) _buildDealOfTheDay(),
                SizedBox(height: todaysDealsSizeBox),
                if (customerProfileListNearBy.isNotEmpty) nearByBuildView(),
                sessionProducts(),
                const SizedBox(height: 16),
                if (isLoading)
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget specialDeals() {
    return SizedBox(
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
                        final String url =
                            "${AppConfig.baseUrl}/api/v1/products/products-by-discount/${e.id}";
                        NavigationUtil.push(
                          context,
                          screen: SuperStoreIndustry(
                            next: url,
                            appTitle: e.name!,
                            searchQuery: {"discount": e.id!},
                            isShowDiscountPage: true,
                          ),
                        );
                      },
                      child: SizedBox(
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
              final int index = itemList.indexOf(url);
              return Container(
                width: 5.0,
                height: 5.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == index ? navyBlue : navyBlueLight,
                ),
              );
            }).toList(),
          )
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
      return Image.asset(
        "assets/images/default_image/discount_defualt_image.jpeg",
        fit: BoxFit.fill,
      );
    }
  }

  Widget sessionProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
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
              .values,
      ],
    );
  }

  Future<List<Product>> getRowTitle(headers) async {
    final List<Product> result = [];
    for (var item in headers['results']) {
      final Product product = ShoppingAuthService().createProduct(item);
      result.add(product);
    }
    return result;
  }

  Widget _buildDealOfTheDay() {
    final bool showViewMoreButton =
        superStoreDealOftheDay.length > productHorizontalLength;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dealsOfDayEmpty)
          const SizedBox.shrink()
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                AppLocalization.of(context)?.newArrivals ?? "",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: "Inter",
                  color: blackFont,
                ),
              ),
              _buildViewMoreStore(context),
            ],
          ),
        const SizedBox(
          height: 15,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: superStoreDealOftheDay
                .take(showViewMoreButton
                    ? productHorizontalLength
                    : todaysDealList.length)
                .map(
                  (element) => Padding(
                    padding: const EdgeInsets.only(right: 7.0),
                    child: SuperStoreSingleCard(
                      product: element,
                      // next: headers['next_url']
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildViewMoreStore(BuildContext context) {
    return InkWell(
      onTap: () {
        // for (final product in superStoreDealOftheDay) {
        NavigationUtil.push(
          context,
          screen: const ProductViewMoreDetails(
              // appTitle: product.name,
              ),
        );
        // }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          Icon(
            Icons.chevron_right_outlined,
            color: navyBlue,
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  Widget nearByBuildView() {
    return Column(
      children: [
        const SizedBox(height: 15.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Nearby Businesses",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                fontFamily: "Inter",
                color: black,
              ),
            ),
            GestureDetector(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  Icon(
                    Icons.chevron_right_outlined,
                    color: navyBlue,
                  ),
                  const SizedBox(width: 5),
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
        const SizedBox(height: 10.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var item in customerProfileListNearBy)
                Container(
                  width: 250,
                  // height: 200,
                  margin: const EdgeInsets.only(right: 16),
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
                        final List<CustomerProfile> customerProfileListEdit =
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
    );
  }

  Widget rowTitle(headers, {bool isLast = false}) {
    return SectionProducts(headers: headers, isLast: isLast);
  }

  void onPageFunction(int index, CarouselPageChangedReason reason) {
    currentIndex = index;
    setState(() {});
  }
}

class SuperStoreSingleCard extends StatelessWidget {
  final Product product;
  final bool isProductShowIcon;

  // final String? next;
  const SuperStoreSingleCard(
      {super.key, required this.product, this.isProductShowIcon = false});

  @override
  Widget build(BuildContext context) {
    return DisplayProduct(
      product: product,
      giveRightPadding: false,
      isProductShowIcon: isProductShowIcon,
    );
  }
}
