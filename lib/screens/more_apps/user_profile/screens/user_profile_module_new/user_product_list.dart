import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _productScaffoldKey,
      body: Container(
        color: lightGrey,
        padding: EdgeInsets.fromLTRB(4, 34, 4, 4),
        child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _productsRefreshController,
            onRefresh: _onProductRefresh,
            child: _buildProductList()),
      ),
    );
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

  Widget _buildProductList() {
    return noProductInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noProducts,
          )
        : StaggeredGridView.countBuilder(
            physics: ClampingScrollPhysics(),
            controller: _productScrollController,
            crossAxisCount: 2,
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            mainAxisSpacing: 20,
            itemCount: productList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == productList.length) {
                return _buildProductIndicator();
              } else {
                return productTile(index);
              }
            },
            staggeredTileBuilder: (int index) =>
                new StaggeredTile.count(2, 1.2),
          );
  }

  Widget productTile(int index) {
    return CustomBoxShadow(
      child: Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.zero,
          shadowColor: boxShadowTwo,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(children: <Widget>[
                    InkWell(
                      child: CachedNetworkImage(
                        width: double.infinity,
                        errorWidget: productAndServiceBigErrorWidget,
                        imageUrl: getDisplayImage(index, productList)!,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/product',
                            arguments: {"product": productList[index]});
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
                        : Container()
                  ]),
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
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text:
                                  worldCurrencies[productList[index].currency!],
                              style: TextStyle(
                                  fontFamily: "Roboto",
                                  color: navyBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          TextSpan(
                              text: moneyDisplayNormalizer(int.parse(
                                  productList[index].price.toString())),
                              style: TextStyle(
                                color: navyBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ))
                        ]),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          messageDecoderWithEmoji(
                                  productList[index].shortDescription) ??
                              "",
                          maxLines: 1,
                          style: TextStyle(fontSize: 14, color: darkGrey),
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      (productList[index].rating ?? 0.0) != 0.0
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  SlydoAppIcon.star,
                                  color: starYellow,
                                  size: 11,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  productList[index].rating?.toString() ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
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
