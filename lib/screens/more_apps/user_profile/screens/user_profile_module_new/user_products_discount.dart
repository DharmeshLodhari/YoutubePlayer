import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/item_display_product_for_discount.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class UserProductDiscount extends StatefulWidget {
  DiscountModel item;

  UserProductDiscount({
    required this.item,
    super.key,
  });

  @override
  _UserProductsDiscountState createState() => _UserProductsDiscountState();
}

class _UserProductsDiscountState extends State<UserProductDiscount> {
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

    productList.forEach((element) {
      element.isChecked = isSelectAll;
    });
    if (mounted) setState(() {});
  }

  void _onProductRefresh() async {
    if (await checkConnection(context)) {
      productCount = 0;
      productNext = "";
      productPrevious = "";
      productList = [];
      debugPrint("Refresh called on products!!  ");
      getProductList();
      _productsRefreshController.refreshCompleted();
    } else {
      _productsRefreshController.refreshCompleted();
    }
  }

  void getProductList() async {
    if (!isProductLoading) {
      if (productNext != null && !isProductLoading) {
        if (mounted) {
          setState(() {
            isProductLoading = true;
          });
        }

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
        _productMessengerScaffoldKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _productMessengerScaffoldKey,
      child: Scaffold(
        backgroundColor: lightGrey,
        key: _productScaffoldKey,
        body: _buildBody(),
        floatingActionButton: floatingActionBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        if (!noProductInList && !isProductLoading && productList.isNotEmpty)
          _buildSelectedData(),
        const SizedBox(
          height: 5,
        ),
        Expanded(
          child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _productsRefreshController,
            onRefresh: _onProductRefresh,
            child: noProductInList
                ? NoItemInList(msg: AppLocalization.of(context)!.noResultFound)
                : _buildProductList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedData() {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Checkbox(
                value: isSelectAll,
                onChanged: (bool? value) {
                  setState(() {
                    // isSelectAll = value ?? false;
                    toggleSelectAll();
                  });
                },
                activeColor: navyBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              Text(
                'Select All',
                style: TextStyle(
                  color: black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Inter",
                ),
              )
            ],
          ),
          Text(
            "${productList.where((e) => e.isChecked == true).toList().length} products selected",
            style: TextStyle(
              color: deepPink,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
            ),
          ),
        ],
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

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: () async {
        final List<Product> selectedProducts =
            productList.where((e) => e.isChecked).toList();

        final Map<String, dynamic> items = {
          "products": selectedProducts,
          "ids": selectedProducts.map((e) => e.id).toList(),
          "isAllProductSelected": isSelectAll
        };
        Navigator.pop(context, items);
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Save",
    );
  }

  Widget _buildProductList() {
    return isProductLoading && productList.isEmpty
        ? Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: greyBorderColor,
            child: ListView.builder(
              shrinkWrap: true,
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
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _productScrollController,
            shrinkWrap: true,
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
}
