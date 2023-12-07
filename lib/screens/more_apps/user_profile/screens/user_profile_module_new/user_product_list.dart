import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/flash_tags/flash_tag_alert_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/super_store/widget/section_products.dart';

import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:text_scroll/text_scroll.dart';

import '../../../../../widget/item_display_card.dart';
import '../../../../../widget/noItemInList.dart';

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

  String? flashTagString;
  List<FlashTagAlertModel> flashTagAlerts = [];
  String? flashTagNext = "";
  String? flashTagPrevious = "";
  int? flashTagCount = 0;
  bool isFlashTagLoading = false;
  late SharedPreferences _sharedPreferences;

  FlashTagAlertModel? flashTagAlertModel;

  @override
  void initState() {
    getNextUrl();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _sharedPreferences = await SharedPreferences.getInstance();
    });
    widget.type != null ? listOfUsersProduct() : this.getProductList();
    // if (widget.isOwner == false) {
    getAlertTagData();
    // }

    _productScrollController.addListener(() {
      if (_productScrollController.position.pixels ==
              _productScrollController.position.maxScrollExtent &&
          _productScrollController.position.pixels != 0) {
        if (widget.type == null) {
          getProductList();
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
        bool check = _sharedPreferences.getBool("showFlash") ?? false;
        if (!check) {
          showFlashTagAlertPopUp();
          _sharedPreferences.setBool("showFlash", true);
        }
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
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Card(
              elevation: 0.0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                        Icons.highlight_off_rounded,
                        size: 24,
                        color: darkGrey,
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
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              fontFamily: "Inter"),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Text(
                          flashTagAlertModel?.message?.trim() ?? "description",
                          style: TextStyle(
                              color: blackFont,
                              fontFamily: "Inter",
                              fontSize: 16,
                              height: 1.5,
                              letterSpacing: 0.6),
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

  void getProductList() async {
    if (!isProductLoading) {
      if (productNext != null && !isProductLoading) {
        isProductLoading = true;
        if (mounted) setState(() {});

        debugPrint('CALLING PRODUCT channel::: ${widget.channel!}');
        print("_______sa________________________________________$productNext");
        print("++++++++++++++++++++++++++++++++++++++++$productNext");

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
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrices = notification.metrics;
        if (metrices.pixels >= metrices.maxScrollExtent) {
          getProductList();
        }
        return true;
      },
      child: ScaffoldMessenger(
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCrawlingAlert(),
                    noProductInList
                        ? NoItemInList(
                            msg: AppLocalization.of(context)!.noResultFound
                            // msg: AppLocalization.of(context)!.noProducts,
                            )
                        : isProductLoading && productList.isEmpty
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildProductView() {
  //   if (productList.isEmpty) {
  //     return Expanded(
  //       child: NoItemInList(msg: AppLocalization.of(context)!.noResultFound
  //           // msg: AppLocalization.of(context)!.noProducts,
  //           ),
  //     );
  //   }
  //   return Expanded(
  //     child: isProductLoading
  //         ? Shimmer.fromColors(
  //             baseColor: Colors.white,
  //             highlightColor: greyBorderColor,
  //             child: GridView.builder(
  //               shrinkWrap: true,
  //               physics: NeverScrollableScrollPhysics(),
  //               gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
  //                 mainAxisExtent: 180,
  //                 mainAxisSpacing: 16,
  //                 crossAxisSpacing: 15,
  //                 maxCrossAxisExtent: 200,
  //               ),
  //               itemCount: 2,
  //               itemBuilder: (context, index) {
  //                 return Card(
  //                   color: Colors.grey,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                 );
  //               },
  //             ),
  //           )
  //         : _buildProductList(),
  //   );
  // }

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

  Widget sectionProducts() {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
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
        : Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              top: 8.0,
              bottom: 16,
            ),
            child: (widget.type != null)
                ? sectionProducts()
                : GridView.builder(
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
}
