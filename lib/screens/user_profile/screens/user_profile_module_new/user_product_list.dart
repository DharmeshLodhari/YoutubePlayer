import 'package:Slydo/data/environment.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/super_store/super_store_industry.dart';
import 'package:Slydo/screens/super_store/widget/explore_products.dart';
import 'package:Slydo/screens/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/profile_template/product_view_more_details.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/custom_pagination.dart';
import 'package:Slydo/widget/item_display_card.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../../super_store/shop_list_screen.dart';

// ignore: must_be_immutable
class UserProductList extends StatefulWidget {
  CustomerProfile? user;
  bool isOwner;
  bool? channel;
  String? next;
  String? type;

  UserProductList({
    required this.user,
    this.isOwner = false,
    this.channel = false,
    this.next,
    this.type,
    super.key,
  });

  @override
  State<UserProductList> createState() => _UserProductListState();
}

class _UserProductListState extends State<UserProductList> {
  // this variable responsible for product pagination
  int? productCount = 0;
  String? productNext = "";
  String? productPrevious = "";
  List<Product> productList = [];
  List sectionProductList = [];
  final ScrollController _productScrollController = ScrollController();
  final GlobalKey<ScaffoldMessengerState> _productMessengerScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final RefreshController _productsRefreshController =
      RefreshController(initialRefresh: false);
  bool isProductLoading = false;
  bool noProductInList = false;
  bool _isSnackBarShowing = false;
  int currentIndex = 0;
  bool isLoading = false;
  String? next = "";
  String? previous = "";
  List<DiscountModel> itemList = [];
  bool dealsOfDayEmpty = false;
  String url = "";
  bool isMerchantProductLoading = false;
  String? todayDealNext = "";
  String? todayDealPrevious = "";
  List<Product> productDealOfTheDayList = [];
  bool todaysDealsEmpty = false;
  double todaysDealsSizeBox = 0;
  bool noItemInList = false;
  int? itemCount = 0;
  int productHorizontalLength = 10;
  final CarouselController _controller = CarouselController();

  String selectedFilter = "all";

  List<Filter> filterList = [
    Filter(title: "All", value: "all"),
    Filter(title: "Newest", value: "newest"),
    Filter(title: "Oldest", value: "oldest"),
    Filter(title: "Highest Price", value: 'highest-price'),
    Filter(title: "Lowest Price", value: 'lowest-price'),
    Filter(title: "In stock", value: 'on-sale'),
    Filter(title: "Coming soon", value: 'coming-soon'),
    Filter(title: "Out of stock", value: 'out-of-stock'),
  ];

  @override
  void initState() {
    getNextUrl();

    fetchMerchantDiscount();
    widget.type != null ? listOfUsersProduct() : getProductList();

    _productScrollController.addListener(() {
      if (_productScrollController.position.pixels ==
              _productScrollController.position.maxScrollExtent &&
          _productScrollController.position.pixels != 0) {
        if (widget.type == null) {
          widget.type != null ? listOfUsersProduct() : getProductList();
        }
      }
    });
    getDealsOfTheDayProducts();
    super.initState();
  }

  void fetchMerchantDiscount() async {
    if (!isLoading) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      final Map<String, dynamic>? result = await ShoppingAuthService()
          .listOfMerchantDiscounts(next, previous, widget.user);
      if (result == null) {
        isLoading = false;
        noItemInList = true;
        return;
      }
      itemList = [];
      itemCount = result['count'];
      next = result['next'];
      previous = result['previous'];
      final tempList = result['results'];

      itemList.addAll(tempList);

      if (mounted) {
        setState(() {
          isLoading = false;
          noItemInList = false;
        });
      }

      if (itemList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && itemList.length > 6) {
        _productMessengerScaffoldKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  void getDealsOfTheDayProducts() async {
    if (!isMerchantProductLoading) {
      if (todayDealNext != null && !isMerchantProductLoading) {
        isMerchantProductLoading = true;
        if (mounted) setState(() {});
        url =
            "${AppConfig.baseUrl}/api/v1/products/?today_deals=true&merchant=${widget.user?.userName}";
        final Map<String, dynamic>? response =
            await ShoppingAuthService().getProductsDeals(
          todayDealNext,
          todayDealPrevious,
          url: url,
        );

        if (response == null) {
          todaysDealsEmpty = true;
          todaysDealsSizeBox = 22;
          isMerchantProductLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        todayDealNext = response['next'];
        todayDealPrevious = response['previous'];
        final tempList = response['results'];

        todaysDealsEmpty = false;
        isMerchantProductLoading = false;
        productDealOfTheDayList.addAll(tempList);

        if (mounted) setState(() {});
      }
      if (productDealOfTheDayList.isEmpty) {
        if (mounted) {
          setState(() {
            todaysDealsEmpty = true;
          });
        }
      }
    }
  }

  void getNextUrl() {
    setState(() {
      if (widget.next != null) {
        if (widget.next?.contains("custom_category") ?? false) {
          if (selectedFilter == "all") selectedFilter = "";
          productNext = "${widget.next}&sort_by=$selectedFilter";
        } else {
          productNext = widget.next;
        }
      }
    });
  }

  void _onProductRefresh() async {
    if (await checkConnection(context)) {
      productCount = 0;
      productNext = "";
      productPrevious = "";
      productList = [];
      // debugPrint("Refresh called on products!!  ");
      getNextUrl();
      widget.type != null ? listOfUsersProduct() : getProductList();
      _productsRefreshController.refreshCompleted();
    } else {
      _productsRefreshController.refreshCompleted();
    }
  }

  Future<void> getProductList() async {
    if (!isProductLoading) {
      if (productNext != null && !isProductLoading) {
        isProductLoading = true;
        if (mounted) setState(() {});

        // debugPrint('CALLING PRODUCT channel::: ${widget.channel!}');

        if (selectedFilter == "all") selectedFilter = "";
        final Map<String, dynamic>? result =
            await ShoppingAuthService().listOfProduct(
          productNext,
          productPrevious,
          "",
          widget.channel!,
          userName: widget.channel == false
              ? widget.user!.userName
              : widget.user!.nickName,
          selectedFilter: selectedFilter,
        );

        if (result == null) {
          isProductLoading = false;
          noProductInList = true;
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
      } else if (productNext == null &&
          productList.length > 6 &&
          !_isSnackBarShowing) {
        _isSnackBarShowing = true;
        _productMessengerScaffoldKey.currentState
            ?.showSnackBar(SnackBar(
              content: Text(
                  AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
              duration: const Duration(milliseconds: 500),
            ))
            .closed
            .then((_) {
          _isSnackBarShowing = false;
        });
      }
    }
  }

  void listOfUsersProduct() async {
    if (!isProductLoading) {
      if (productNext != null && !isProductLoading) {
        isProductLoading = true;
        if (mounted) setState(() {});

        // debugPrint('CALLING PRODUCT channel::: ${widget.channel!}');

        final Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfUsersProduct(
                sectionUrl: productNext, name: widget.user!.userName);

        if (result == null) {
          isProductLoading = false;
          noProductInList = true;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        final tempList = result['sectionProducts'];
        if (mounted) {
          setState(() {
            noProductInList = false;
            isProductLoading = false;
            sectionProductList = tempList;
          });
        }
      }
      if (sectionProductList.isEmpty) {
        if (mounted) {
          setState(() {
            noProductInList = true;
          });
        }
      } else if (productNext == null &&
          productList.length > 6 &&
          !_isSnackBarShowing) {
        _isSnackBarShowing = true;
        _productMessengerScaffoldKey.currentState
            ?.showSnackBar(SnackBar(
              content: Text(
                  AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
              duration: const Duration(milliseconds: 500),
            ))
            .closed
            .then((_) {
          _isSnackBarShowing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.type != null
        ? _buildProductView()
        : CustomPagination(
            onScrollEnd: () async {
              widget.type != null
                  ? listOfUsersProduct()
                  : await getProductList();
            },
            child: _buildProductView(),
          );
  }

  void menuItemSelectionChange(String value) {
    switch (value) {
      case "all":
        setState(() {
          selectedFilter = "all";
          _onProductRefresh();
        });
        break;
      case "newest":
        setState(() {
          selectedFilter = "newest";
          _onProductRefresh();
        });
        break;
      case "oldest":
        setState(() {
          selectedFilter = "oldest";
          _onProductRefresh();
        });
        break;
      case "highest-price":
        setState(() {
          selectedFilter = "highest-price";
          _onProductRefresh();
        });
        break;
      case "lowest-price":
        setState(() {
          selectedFilter = "lowest-price";
          _onProductRefresh();
        });
        break;
      case "on-sale":
        setState(() {
          selectedFilter = "on-sale";
          _onProductRefresh();
        });
        break;
      case "coming-soon":
        setState(() {
          selectedFilter = "coming-soon";
          _onProductRefresh();
        });
        break;
      case "out-of-stock":
        setState(() {
          selectedFilter = "out-of-stock";
          _onProductRefresh();
        });
        break;
      default:
        break;
    }
    setState(() {});
    // debugPrint('menuItemSelectionChange--->');
    // _onRefresh();
  }

  Widget _buildProductView() {
    return ScaffoldMessenger(
      key: _productMessengerScaffoldKey,
      child: Container(
        color: lightGrey,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: navyBlue,
          ),
          controller: _productsRefreshController,
          onRefresh: _onProductRefresh,
          child: _buildList(),
        ),
      ),
    );
  }

  void showFilterProductSheet() {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        enableDrag: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter bottomSheetSetState) =>
                Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Filter",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w700,
                          color: blackFont),
                    ),
                    const SizedBox(height: 40),
                    SingleChildScrollView(
                      child: Column(
                        children: filterList.map<Widget>((filter) {
                          if (selectedFilter == "") selectedFilter = "all";
                          if (selectedFilter == filter.value) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  filter.title ?? "",
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: TextStyle(
                                      color: navyBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                trailing: Icon(
                                  SlydoAppIcon.checked,
                                  color: navyBlue,
                                  size: 12,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  menuItemSelectionChange(filter.value ?? "");
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              filter.title ?? "",
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context);
                              menuItemSelectionChange(filter.value ?? "");
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildList() {
    return SingleChildScrollView(
      child: isProductLoading && productList.isEmpty
          ? Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: greyBorderColor,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisExtent: 180,
                  mainAxisSpacing: 16,
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
          : _buildProductList(),
    );
  }

  Widget sectionProducts() {
    return Column(
      children: [
        if (itemList.isNotEmpty) _buildMerchantDiscount(),
        if (productDealOfTheDayList.isNotEmpty) _buildDealOfTheDay(),
        const SizedBox(
          height: 15,
        ),
        ...sectionProductList.map((headers) => ExploreProducts(
              headers: headers,
            ))
      ],
    );
  }

  Widget _buildViewMoreStore(BuildContext context) {
    return InkWell(
      onTap: () {
        // for (final product in productDealOfTheDayList) {
        NavigationUtil.push(
          context,
          screen: ProductViewMoreDetails(
            merchantId: "${widget.user?.userName}",
            // appTitle: product.name,
          ),
        );
        // }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "View more",
            style: TextStyle(
              color: navyBlue,
              fontSize: 12,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios_sharp,
            color: navyBlue,
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildDealOfTheDay() {
    final bool showViewMoreButton =
        productDealOfTheDayList.length > productHorizontalLength;

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
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
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
            children: productDealOfTheDayList
                .take(showViewMoreButton
                    ? productHorizontalLength
                    : productDealOfTheDayList.length)
                .map(
                  (element) => Padding(
                    padding: const EdgeInsets.only(right: 7.0),
                    child: SuperStoreSingleCard(
                      product: element,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  void onPageFunction(int index, CarouselPageChangedReason reason) {
    currentIndex = index;
    setState(() {});
  }

  Widget _buildMerchantDiscount() {
    return SizedBox(
      height: 151,
      child: Column(
        children: [
          Expanded(
            child: itemList.length > 1
                ? CarouselSlider(
                    carouselController: _controller,
                    options: CarouselOptions(
                        height: 150,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 1,
                        aspectRatio: 16 / 9,
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
                                  appTitle: e.name ?? "",
                                  searchQuery: {"discount": e.id ?? ""},
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
                            ),
                          ),
                        )
                        .toList(),
                  )
                : itemList.isNotEmpty
                    ? InkWell(
                        onTap: () {
                          final String url =
                              "${AppConfig.baseUrl}/api/v1/products/products-by-discount/${itemList[0].id}";
                          NavigationUtil.push(
                            context,
                            screen: SuperStoreIndustry(
                              next: url,
                              appTitle: itemList[0].name ?? "",
                              searchQuery: {"discount": itemList[0].id ?? ""},
                              isShowDiscountPage: true,
                            ),
                          );
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 150,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: getImage(itemList[0]),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
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
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget getImage(DiscountModel item) {
    if (item.poster != null) {
      return CachedNetworkImage(
        imageUrl: item.poster ?? "",
        errorWidget: imageErrorWidget,
        fit: BoxFit.fill,
      );
    } else {
      return Image.asset(
          "assets/images/default_image/discount_defualt_image.jpeg",
          fit: BoxFit.fill);
    }
  }

  Widget _buildProductList() {
    return productNext == "" && isProductLoading
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.type == null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Found $productCount products",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: "Inter",
                        color: blackFont,
                      ),
                    ),
                    popUpMenuButton(),
                  ],
                ),
              const SizedBox(height: 10),
              if (noProductInList)
                Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 2),
                  child: NoItemInList(
                      msg: AppLocalization.of(context)!.noResultFound
                      // msg: AppLocalization.of(context)!.noProducts,
                      ),
                )
              else
                widget.type != null ? sectionProducts() : _buildGridView(),
            ],
          );
  }

  Widget _buildGridView() {
    return isProductLoading && productList.isEmpty
        ? buildLoadingIndicator(isLoading: isProductLoading)
        : CustomScrollView(
            physics: const ScrollPhysics(),
            controller: _productScrollController,
            shrinkWrap: true,
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Calculate indices for the row items
                    final int startIndex = index * 2;
                    final int endIndex = startIndex + 2;

                    // Get the items for this row
                    final List<Product> rowItems = productList.sublist(
                      startIndex,
                      endIndex > productList.length
                          ? productList.length
                          : endIndex,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First Item
                          Expanded(
                            child: DisplayProduct(
                              product: rowItems[0],
                              onProductRefresh: _onProductRefresh,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          // Second Item
                          if (rowItems.length == 2)
                            Expanded(
                              child: DisplayProduct(
                                product: rowItems[1],
                                onProductRefresh: _onProductRefresh,
                              ),
                            ),
                          // Add an empty widget if there is only one item
                          if (rowItems.length == 1)
                            const Expanded(
                              child: SizedBox.shrink(),
                            ),
                        ],
                      ),
                    );
                  },
                  childCount: (productList.length / 2).ceil(), // Number of rows
                ),
                // (c, i) => DisplayProduct(
                //   product: productList[i],
                //   onProductRefresh: () {
                //     _onProductRefresh();
                //   },
                // ),
                // childCount: productList.length,
                // ),
                // gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                //   mainAxisSpacing: 8,
                //   mainAxisExtent: 365,
                //   crossAxisSpacing: 8,
                //   maxCrossAxisExtent: 300,
                // ),
              ),
              SliverToBoxAdapter(
                child:
                    buildJumpingLoadingIndicator(isLoading: isProductLoading),
              ),
            ],
          );
  }

  Widget popUpMenuButton() {
    return GestureDetector(
      onTap: () async {
        await Future.delayed(const Duration(milliseconds: 100))
            .then((value) => showFilterProductSheet());
      },
      child: Icon(
        Icons.filter_alt_rounded,
        size: 20,
        color: navyBlue,
        // size: 20,
      ),
    );
  }

  Widget getOutOfStockTag(int index) {
    if (!productList[index].isProductAvailableNow()) {
      if (widget.isOwner) {
        return Positioned(
          left: 38,
          top: 14,
          child: getColoredLabeledWidget(
              text: AppLocalization.of(context)!.outOfStock, color: starYellow),
        );
      } else {
        return Positioned(
          left: 8,
          top: 8,
          child: getColoredLabeledWidget(
              text: AppLocalization.of(context)!.outOfStock, color: starYellow),
        );
      }
    }
    return const SizedBox.shrink();
  }
}

class Filter {
  String? title;
  String? value;

  Filter({this.title, this.value});
}

extension ListExtension<E> on List<E> {
  /// Adds an item to the list if the condition is true.
  void addIf(bool condition, E element) {
    if (condition) {
      add(element);
    }
  }
}
