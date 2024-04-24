import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/super_store/widget/section_products.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/custom_pagination.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../widget/item_display_card.dart';
import '../../../../../widget/no_item_in_list.dart';

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
    Key? key,
  }) : super(key: key);

  @override
  _UserProductListState createState() => _UserProductListState();
}

class _UserProductListState extends State<UserProductList> {
  // this variable responsible for product pagination
  int? productCount = 0;
  String? productNext = "";
  String? productPrevious = "";
  List<Product> productList = [];
  List sectionProductList = [];
  ScrollController _productScrollController = new ScrollController();
  final GlobalKey<ScaffoldState> _productScaffoldKey =
      new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _productMessengerScaffoldKey =
      new GlobalKey<ScaffoldMessengerState>();
  RefreshController _productsRefreshController =
      RefreshController(initialRefresh: false);
  bool isProductLoading = false;
  bool noProductInList = false;
  bool _isSnackBarShowing = false;

  @override
  void initState() {
    getNextUrl();

    widget.type != null ? listOfUsersProduct() : this.getProductList();

    _productScrollController.addListener(() {
      if (_productScrollController.position.pixels ==
              _productScrollController.position.maxScrollExtent &&
          _productScrollController.position.pixels != 0) {
        if (widget.type == null) {
          widget.type != null ? listOfUsersProduct() : this.getProductList();
        }
      }
    });

    super.initState();
  }

  getNextUrl() {
    setState(() {
      if (widget.next != null) {
        productNext = widget.next;
      }
    });
  }

  void _onProductRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        productCount = 0;
        productNext = "";
        productPrevious = "";
        productList = [];
        debugPrint("Refresh called on products!!  ");
        getNextUrl();
        widget.type != null ? listOfUsersProduct() : getProductList();
        _productsRefreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _productsRefreshController.refreshCompleted();
      }
    });
  }

  Future<void> getProductList() async {
    if (!isProductLoading) {
      if (productNext != null && !isProductLoading) {
        isProductLoading = true;
        if (mounted) setState(() {});

        debugPrint('CALLING PRODUCT channel::: ${widget.channel!}');

        Map<String, dynamic>? result = await ShoppingAuthService()
            .listOfProduct(productNext, productPrevious, "", widget.channel!,
                userName: widget.channel == false
                    ? widget.user!.userName
                    : widget.user!.nickName);

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
      } else if (productNext == null &&
          productList.length > 6 &&
          !_isSnackBarShowing) {
        _isSnackBarShowing = true;
        _productMessengerScaffoldKey.currentState
            ?.showSnackBar(SnackBar(
              content: Text(
                  AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
              duration: Duration(milliseconds: 500),
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

        debugPrint('CALLING PRODUCT channel::: ${widget.channel!}');
        print("_______________________________________________$productNext");
        print("++++++++++++++++++++++++++++++++++++++++$productNext");

        Map<String, dynamic>? result = await ShoppingAuthService()
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

        var tempList = result['sectionProducts'];
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
              duration: Duration(milliseconds: 500),
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

  Widget _buildProductView() {
    return ScaffoldMessenger(
      key: _productMessengerScaffoldKey,
      child: Scaffold(
        key: _productScaffoldKey,
        body: Container(
          color: lightGrey,
          padding: EdgeInsets.all(16),
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
      ),
    );
  }

  Widget _buildList() {
    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: noProductInList
          ? Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height / 2),
              child:
                  NoItemInList(msg: AppLocalization.of(context)!.noResultFound
                      // msg: AppLocalization.of(context)!.noProducts,
                      ),
            )
          : isProductLoading && productList.isEmpty
              ? Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: greyBorderColor,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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
        ...sectionProductList
            .map((headers) => SectionProducts(headers: headers))
            .toList()
      ],
    );
  }

  Widget _buildProductList() {
    return productNext == "" && isProductLoading
        ? SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.type == null)
                Text(
                  "Found ${productCount} products",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    fontFamily: "Inter",
                    color: blackFont,
                  ),
                ),
              SizedBox(height: 10),
              (widget.type != null) ? sectionProducts() : _buildGridView(),
            ],
          );
  }

  Widget _buildGridView() {
    return isProductLoading && productList.isEmpty
        ? buildLoadingIndicator(isLoading: isProductLoading)
        : CustomScrollView(
            physics: ScrollPhysics(),
            controller: _productScrollController,
            shrinkWrap: true,
            slivers: <Widget>[
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (c, i) => SizedBox(
                    child: DisplayProduct(
                      product: productList[i],
                      onProductRefresh: () {
                        _onProductRefresh();
                      },
                    ),
                  ),
                  childCount: productList.length,
                ),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisSpacing: 8,
                  mainAxisExtent: 274,
                  crossAxisSpacing: 15,
                  maxCrossAxisExtent: 200,
                ),
              ),
              SliverToBoxAdapter(
                child:
                    buildJumpingLoadingIndicator(isLoading: isProductLoading),
              ),
            ],
          );
    // return GridView.builder(
    //   shrinkWrap: true,
    //   padding: EdgeInsets.symmetric(horizontal: 4),
    //   controller: _productScrollController,
    //   physics: NeverScrollableScrollPhysics(),
    //   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    //     mainAxisSpacing: 8,
    //     mainAxisExtent: 274,
    //     crossAxisSpacing: 15,
    //     maxCrossAxisExtent: 200,
    //   ),
    //   itemCount: productList.length + 1,
    //   itemBuilder: SizedBox(
    //         child: DisplayProduct(
    //           product: productList[index],
    //           onProductRefresh: () {
    //             _onProductRefresh();
    //           },
    //         ),
    //       );
    //   },
    // );
  }

  Widget productTile(int index) {
    return CustomBoxShadow(
      child: SizedBox(
        height: 250,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: DisplayProduct(
            product: productList[index],
          ),
        ),
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
    return SizedBox.shrink();
  }
}
