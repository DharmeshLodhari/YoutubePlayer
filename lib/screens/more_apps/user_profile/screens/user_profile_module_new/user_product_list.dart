import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../routes/route_constants.dart';
import '../../../../../widget/item_display_card.dart';
import '../../../../../widget/noItemInList.dart';

// ignore: must_be_immutable
class UserProductList extends StatefulWidget {
  CustomerProfile? user;
  bool isOwner;

  UserProductList({required this.user, this.isOwner = false});

  @override
  _UserProductListState createState() => _UserProductListState();
}

class _UserProductListState extends State<UserProductList> {
  // this variable responsible for product pagination
  int? productCount = 0;
  String? productNext = "";
  String? productPrevious = "";
  List<Product> productList = [];
  ScrollController _productScrollController = new ScrollController();
  final GlobalKey<ScaffoldState> _productScaffoldKey =
      new GlobalKey<ScaffoldState>();
  RefreshController _productsRefreshController =
      RefreshController(initialRefresh: false);
  bool isProductLoading = false;
  bool noProductInList = false;

  Product? product;

  @override
  void initState() {
    this.getProductList();
    _productScrollController.addListener(() {
      if (_productScrollController.position.pixels ==
              _productScrollController.position.maxScrollExtent &&
          _productScrollController.position.pixels != 0) {
        getProductList();
      }
    });

    super.initState();
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
        getProductList();
        _productsRefreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _productsRefreshController.refreshCompleted();
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
                userName: widget.user!.userName);

        if (result == null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _productScaffoldKey,
      body: Container(
        color: lightGrey,
        padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: navyBlue,
          ),
          controller: _productsRefreshController,
          onRefresh: _onProductRefresh,
          child: ListView(
            children: [
              _buildProductList(),
              isProductLoading
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
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    if (productList.isEmpty) {
      return SizedBox.shrink();
    }

    if (noProductInList) {
      return NoItemInList(
        msg: AppLocalization.of(context)!.noProducts,
      );
    }

    return productNext == "" && isProductLoading
        ? SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GridView.builder(
              shrinkWrap: true,
              controller: _productScrollController,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisSpacing: 8,
                mainAxisExtent: 180,
                crossAxisSpacing: 15,
                maxCrossAxisExtent: 200,
              ),
              itemCount: productList.length,
              itemBuilder: (context, index) {
                return DisplayProduct(
                  product: productList[index],
                  onProductRefresh: () {
                    _onProductRefresh();
                  },
                );
              },
            ),
          );

    ListView.builder(
      itemCount: productList.length + 1,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      controller: _productScrollController,
      itemBuilder: (context, index) {
        if (index == productList.length) {
          return _buildProductIndicator();
        } else {
          return CustomBoxShadow(
            child: SizedBox(
              height: 250,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: DisplayProduct(
                  product: productList[index],
                  onProductRefresh: () {
                    _onProductRefresh();
                  },
                ),
              ),
            ),
          );
          return productTile(index);
        }
      },
    );
    // StaggeredGridView.countBuilder(
    //   physics: ClampingScrollPhysics(),
    //   controller: _productScrollController,
    //   crossAxisCount: 2,
    //   shrinkWrap: true,
    //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    //   mainAxisSpacing: 20,
    //   itemCount: productList.length + 1,
    //   itemBuilder: (BuildContext context, int index) {
    //     if (index == productList.length) {
    //       return _buildProductIndicator();
    //     } else {
    //       return productTile(index);
    //     }
    //   },
    //   staggeredTileBuilder: (int index) =>
    //   new StaggeredTile.count(2, 1.2),
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

    return CustomBoxShadow(
      child: SizedBox(
        height: 300,
        child: Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(vertical: 10.0),
          shadowColor: boxShadowTwo,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      InkWell(
                        child: CachedNetworkImage(
                          width: double.infinity,
                          errorWidget: productAndServiceBigErrorWidget,
                          imageUrl: getDisplayImage(index, productList)!,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                        onTap: () async {
                          var result = await Navigator.pushNamed(
                            context,
                            Routes.PRODUCT,
                            arguments: {"product": productList[index]},
                          );

                          if (result != null) {
                            if (result is String) {
                              if (result == "delete_item" ||
                                  result == "update_item") {
                                _onProductRefresh();
                              }
                            }
                          }
                        },
                      ),
                      widget.isOwner
                          ? Positioned(
                              left: 8,
                              top: 8,
                              child: RoundedBackgroundIcon(
                                  height: 28,
                                  width: 28,
                                  backgroundColor: Colors.white,
                                  icon: Icon(
                                    Icons.print,
                                    color: blackFont,
                                    size: 16,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      '/print-qr',
                                      arguments: {
                                        "imageUrl": productList[index].qrCode,
                                        "itemName": productList[index].name
                                      },
                                    );
                                  }),
                            )
                          : Container(),
                      widget.isOwner
                          ? Positioned(
                              right: 8,
                              top: 8,
                              child: RoundedBackgroundIcon(
                                  height: 28,
                                  width: 28,
                                  backgroundColor: Colors.white,
                                  icon: Icon(
                                    SlydoAppIcon.edit,
                                    color: blackFont,
                                    size: 12,
                                  ),
                                  onTap: () async {
                                    var result =
                                        await Navigator.of(context).pushNamed(
                                      '/edit-product',
                                      arguments: {
                                        "productId":
                                            productList[index].id.toString(),
                                      },
                                    );

                                    if (result != null) {
                                      if (result is String) {
                                        if (result == "delete_item" ||
                                            result == "update_item") {
                                          _onProductRefresh();
                                        }
                                      }
                                    }
                                  }),
                            )
                          : Container(),
                      getOutOfStockTag(index),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: getRating(
                            numberOfRating: productList[index].rating?.toInt()),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          messageDecoderWithEmoji(productList[index].name!) ??
                              "",
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: blackFont),
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ],
                  ),
                  subtitle: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: worldCurrencies[productList[index].currency!],
                            style: TextStyle(
                                fontFamily: "Roboto",
                                color: navyBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        TextSpan(
                            text: moneyDisplayNormalizer(
                                int.parse(productList[index].price.toString())),
                            style: TextStyle(
                              color: navyBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ))
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

  Widget getOutOfStockTag(int index) {
    if (!productList[index].isAvailable!) {
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

  Widget _buildProductIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
            opacity: isProductLoading ? 1.0 : 00,
            child: isProductLoading ? CircularLoadingIndicator() : Container()),
      ),
    );
  }

  String? getDisplayImage(int index, List<Product> productList) {
    return productList[index].serverImages![0];
  }
}
