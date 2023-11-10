import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/flash_tags/flash_tag_alert_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';

import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:text_scroll/text_scroll.dart';

import '../../../../../widget/item_display_card.dart';
import '../../../../../widget/noItemInList.dart';

// ignore: must_be_immutable
class UserProductList extends StatefulWidget {
  CustomerProfile? user;
  bool isOwner;
  bool? channel;

  UserProductList({
    required this.user,
    this.isOwner = false,
    this.channel = false,
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
  ScrollController _productScrollController = new ScrollController();
  final GlobalKey<ScaffoldState> _productScaffoldKey =
      new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _productMessengerScaffoldKey =
      new GlobalKey<ScaffoldMessengerState>();
  RefreshController _productsRefreshController =
      RefreshController(initialRefresh: false);
  bool isProductLoading = false;
  bool noProductInList = false;

  String? flashTagString;
  List<FlashTagAlertModel> flashTagAlerts = [];
  String? flashTagNext = "";
  String? flashTagPrevious = "";
  int? flashTagCount = 0;
  bool isFlashTagLoading = false;

  FlashTagAlertModel? flashTagAlertModel;

  @override
  void initState() {
    this.getProductList();

    // if (widget.isOwner == false) {
    getAlertTagData();
    // }

    _productScrollController.addListener(() {
      if (_productScrollController.position.pixels ==
              _productScrollController.position.maxScrollExtent &&
          _productScrollController.position.pixels != 0) {
        getProductList();
      }
    });

    super.initState();
  }

  Future<void> getAlertTagData() async {
    print("============================>");
    if (flashTagNext != null && !isFlashTagLoading) {
      isFlashTagLoading = true;
      if (mounted) setState(() {});

      Map<String, dynamic>? result = await ShoppingAuthService()
          .listOfFlashTags(
              flashTagNext, flashTagPrevious, widget.user?.userName);

      if (result == null) {
        isFlashTagLoading = false;

        if (mounted) {
          setState(() {});
        }
        return;
      }

      flashTagCount = result['count'];
      flashTagNext = result['next'];
      flashTagPrevious = result['previous'];
      var tempList = result['results'];

      isFlashTagLoading = false;
      flashTagAlerts.addAll(tempList);
      if (flashTagNext != null) {
        await getAlertTagData();
        return;
      }
    }

    if (flashTagAlerts.isNotEmpty) {
      flashTagString = flashTagAlerts
          .map((e) => e.message)
          .toList()
          .join(".                         ");
      try {
        flashTagAlertModel = flashTagAlerts
            .where((element) =>
                element.type?.toValue() == FlashTagCategory("Pop-up").toValue())
            .toList()
            .first;
        showFlashTagAlertPopUp();
      } catch (error) {
        debugPrint("No Pop-up Element");
      }
      if (mounted) setState(() {});
    }
  }

  void showFlashTagAlertPopUp() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16),
          contentPadding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Card(
            margin: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      size: 24,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flashTagAlertModel?.title?.trim() ?? "Important Info",
                        style: TextStyle(
                          color: blackFont,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        flashTagAlertModel?.message?.trim() ?? "description",
                        style: TextStyle(
                          color: blackFont,
                        ),
                      ),
                      SizedBox(
                        height: 48,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
      } else if (productNext == null && productList.length > 6) {
        _productMessengerScaffoldKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _productMessengerScaffoldKey,
      child: Scaffold(
        key: _productScaffoldKey,
        body: Container(
          color: lightGrey,
          // padding: EdgeInsets.symmetric(horizontal: 4),
          child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _productsRefreshController,
            onRefresh: _onProductRefresh,
            child: Column(
              children: [
                _buildCrawlingAlert(),
                noProductInList
                    ? Expanded(
                        child: NoItemInList(
                            msg: AppLocalization.of(context)!.noResultFound
                            // msg: AppLocalization.of(context)!.noProducts,
                            ),
                      )
                    : Expanded(
                        child: isProductLoading
                            ? Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor: greyBorderColor,
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
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
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCrawlingAlert() {
    if (flashTagString != null && flashTagString != "") {
      return Container(
        color: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 14),
        child: TextScroll(
          flashTagString!,
          style: TextStyle(color: white, fontWeight: FontWeight.w600),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildProductList() {
    return productNext == "" && isProductLoading
        ? SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              top: 8.0,
              bottom: 16,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 4),
              controller: _productScrollController,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisSpacing: 8,
                mainAxisExtent: 274,
                crossAxisSpacing: 15,
                maxCrossAxisExtent: 200,
              ),
              itemCount: productList.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  child: DisplayProduct(
                    product: productList[index],
                    onProductRefresh: () {
                      _onProductRefresh();
                    },
                  ),
                );
              },
            ),
          );
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
