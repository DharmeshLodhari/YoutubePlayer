import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/flash_tags/flash_tag_alert_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/item_display_product_for_discount.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class UserProductListForDiscount extends StatefulWidget {
  DiscountModel item;

  UserProductListForDiscount({
    required this.item,
    Key? key,
  }) : super(key: key);

  @override
  _UserProductListForDiscountState createState() =>
      _UserProductListForDiscountState();
}

class _UserProductListForDiscountState
    extends State<UserProductListForDiscount> {
  // this variable responsible for product pagination
  int? productCount = 0;
  String? productNext = "";
  String? productPrevious = "";
  List<Product> productList = [];
  final ScrollController _productScrollController = ScrollController();
  final GlobalKey<ScaffoldState> _productScaffoldKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _productMessengerScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final RefreshController _productsRefreshController =
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

  late UserBloc userBloc;

  bool isSelectAll = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      userBloc = Provider.of<UserBloc>(context, listen: false);
      this.getProductList();
    });

    _productScrollController.addListener(() {
      if (_productScrollController.position.pixels ==
              _productScrollController.position.maxScrollExtent &&
          _productScrollController.position.pixels != 0) {
        getProductList();
      }
    });

    super.initState();
  }

  void toggleSelectAll() {
    isSelectAll = !isSelectAll;

    for (var element in productList) {
      element.isChecked = isSelectAll;
    }
    if (mounted) setState(() {});
  }

  void _onProductRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
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
    if (productNext != null && !isProductLoading) {
      isProductLoading = true;
      if (mounted) setState(() {});

      final Map<String, dynamic>? result;
      if (widget.item.id != null) {
        result = await ShoppingAuthService().listOfDiscountedProduct(
            productNext, productPrevious, widget.item.id);
      } else {
        result = await ShoppingAuthService().listOfProduct(
            productNext, productPrevious, "", false,
            userName: userBloc.user.userName);
      }

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
          productList.addAll(tempList);

          noProductInList = false;
          isProductLoading = false;
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
      _productMessengerScaffoldKey.currentState?.showSnackBar(SnackBar(
        content:
            Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        duration: const Duration(milliseconds: 500),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _productMessengerScaffoldKey,
      child: Scaffold(
        backgroundColor: lightGrey,
        key: _productScaffoldKey,
        appBar: appBar() as PreferredSizeWidget,
        body: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: navyBlue,
          ),
          controller: _productsRefreshController,
          onRefresh: _onProductRefresh,
          child: _buildBody(),
        ),
        floatingActionButton: floatingActionBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget floatingActionBar() {
    return Card(
      elevation: 50,
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 15.0),
        child: getSubmitButton(),
      ),
    );
  }

  Widget _buildBody() {
    return noProductInList
        ? NoItemInList(msg: AppLocalization.of(context)!.noResultFound
            // msg: AppLocalization.of(context)!.noProducts,
            )
        : _buildProductList();
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: () async {
        final List<Product> selectedProducts =
            productList.where((e) => e.isChecked).toList();

        final Map<String, dynamic> items = {
          "products": selectedProducts,
          "ids": selectedProducts.map((e) => e.id).toList(),
          "isSelectAll": isSelectAll
        };
        Navigator.pop(context, items);
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Save",
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: blackFont,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Product",
            style: TextStyle(
                color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            "${productList.where((e) => e.isChecked == true).toList().length} Selected",
            style: TextStyle(
                color: blackFont, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      shadowColor: greySecondaryYarn,
      actions: [
        InkWell(
          onTap: () {
            toggleSelectAll();
          },
          child: Center(
            child: Text(
              "Select All",
              style: TextStyle(
                  color: isSelectAll ? navyBlue : blackFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.filter_list,
              color: blackFont,
            ))
      ],
    );
  }

  Widget _buildProductList() {
    return isProductLoading && productList.isEmpty
        ? Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: greyBorderColor,
            child: ListView.builder(
              // shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
              itemCount: 5,
              itemBuilder: (context, index) {
                return CustomBoxShadow(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: CustomBoxShadow(
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        margin: EdgeInsets.zero,
                        shadowColor: boxShadowTwo,
                        color: lightGrey,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 10,
                                        width: 50,
                                        color: Colors.blueGrey,
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Container(
                                        height: 8,
                                        width: 50,
                                        color: Colors.blueGrey,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 10,
                                  width: 50,
                                  color: Colors.blueGrey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        : ListView.builder(
            controller: _productScrollController,
            itemCount: productList.length + 1,
            itemBuilder: (context, index) {
              if (index == productList.length) {
                return buildJumpingLoadingIndicator(
                    isLoading: isProductLoading);
              } else {
                return DisplayProductForDiscount(
                  product: productList[index],
                  onChange: (bool value) {
                    productList[index].isChecked = value;
                    if (mounted) setState(() {});
                  },
                  isSelected: productList[index].isChecked,
                );
              }
            },
          );
  }

  Widget getOutOfStockTag(int index) {
    if (!productList[index].isProductAvailableNow()) {
      return Positioned(
        left: 38,
        top: 14,
        child: getColoredLabeledWidget(
            text: AppLocalization.of(context)!.outOfStock, color: starYellow),
      );
    }
    return const SizedBox.shrink();
  }

  String? getDisplayImage(int index, List<Product> productList) {
    return productList[index].serverImages![0];
  }
}
