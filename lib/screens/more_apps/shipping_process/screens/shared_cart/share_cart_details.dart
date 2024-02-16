import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/locator.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shared_cart_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/basket_item_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/shopping_cart_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/utils.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SharedCartDetails extends StatefulWidget {
  @override
  State<SharedCartDetails> createState() => _SharedCartDetailsState();
}

class _SharedCartDetailsState extends State<SharedCartDetails> {
  late SharedCartBloc sharedCartBloc;
  late UserBloc userBloc;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController _sharedScrollController = new ScrollController();
  AppConfigurationModel? appConfigurationModel;
  bool isLoading = false;
  int? count = 0;
  bool noDataInList = false;
  String? next = "";
  String? previous = "";

  final GlobalKey<ScaffoldMessengerState> _cartItemScaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getCartItemsList();
    });

    _sharedScrollController.addListener(() {
      if (_sharedScrollController.position.pixels ==
              _sharedScrollController.position.maxScrollExtent &&
          _sharedScrollController.position.pixels != 0) {
        getCartItemsList();
      }
    });
  }

  Future<void> getCartItemsList() async {
    sharedCartBloc.getSharedCartModel().basketItems.clear();
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await SharedCartAuthService()
            .getCartItemDetails(
                sharedCartBloc.getSharedCartModel().id, next, previous);

        if (result == null) {
          noDataInList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            noDataInList = false;
            isLoading = false;
            String? currentUser = userBloc.user.userName;

            for (var element in tempList) {
              String type = element is Product ? "product" : "service";

              // debugPrint('Variant Data element: $element');

              if (element is Product) {
                /// varient
                List<Variant>? variantList = element.variantModels;

                /// adds on
                List<AddOns>? convertedList = element.addOnsModels;

                if (variantList != null && variantList.isNotEmpty) {
                  for (var variant in variantList) {
                    sharedCartBloc.addItemToSharedCart(
                        cart: sharedCartBloc.getSharedCartModel(),
                        item: element,
                        type: type,
                        variant: variant,
                        currentUser: currentUser,
                        withApiCall: false);
                  }
                } else if (convertedList != null && convertedList.isNotEmpty) {
                  sharedCartBloc.addItemToSharedCart(
                      cart: sharedCartBloc.getSharedCartModel(),
                      item: element,
                      type: type,
                      variant: null,
                      addOns: convertedList,
                      currentUser: currentUser,
                      withApiCall: false);
                } else {
                  sharedCartBloc.addItemToSharedCart(
                      cart: sharedCartBloc.getSharedCartModel(),
                      item: element,
                      type: type,
                      currentUser: currentUser,
                      withApiCall: false);
                }
              } else {
                sharedCartBloc.addItemToSharedCart(
                    cart: sharedCartBloc.getSharedCartModel(),
                    item: element,
                    type: type,
                    variant: null,
                    addOns: null,
                    currentUser: currentUser,
                    withApiCall: false);
              }
            }
            if (tempList.isEmpty) {
              sharedCartBloc.getSharedCartModel().basketItems.clear();
            }
          });
        }
      }
      if (sharedCartBloc.getSharedCartModel().basketItems.isEmpty) {
        if (mounted) {
          setState(() {
            noDataInList = true;
          });
        }
      } else if (next == null &&
          sharedCartBloc.getSharedCartModel().basketItems.length > 6) {
        _cartItemScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    sharedCartBloc = Provider.of<SharedCartBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: ScaffoldMessenger(
          key: _cartItemScaffoldMessengerKey,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar() as PreferredSizeWidget?,
            body: _buildBody(),
            floatingActionButton: checkoutWidget(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        sharedCartBloc.getSharedCartModel().name ?? "",
        style: TextStyle(
          fontSize: 20,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      actions: [
        InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(Routes.SHARED_CART_MEMBERS);
          },
          child: Center(
            child: followersWidget(
                userImages: sharedCartBloc
                    .getSharedCartModel()
                    .convertToUserFollowersList()),
          ),
        ),
        scanQRCodeBtn(),
        const SizedBox(
          width: 16,
        ),
      ],
      backgroundColor: white,
      elevation: 0.0,
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: navyBlue,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: _buildListOfCartItems(),
        ),
      ),
    );
  }

  Widget _buildListOfCartItems() {
    if (isLoading) {
      return Center(
        child: CircularLoadingIndicator(),
      );
    }

    return sharedCartBloc.getSharedCartModel().basketItems.isEmpty &&
            isLoading == false
        ? Center(
            child: NoItemInList(
                msg: AppLocalization.of(context)!.shoppingCartIsEmpty),
          )
        : ListView.builder(
            itemCount: sharedCartBloc.getSharedCartModel().basketItems.length,
            itemBuilder: (BuildContext context, int index) =>
                getItemTile(index),
          );
  }

  Widget getItemTile(int index) {
    final BasketItem data =
        sharedCartBloc.getSharedCartModel().basketItems[index];

    if (data.item?.isProduct ?? false) {
      return ShoppingCartTileForProduct(
        key: UniqueKey(),
        isSharedCart: true,
        basketItem: data,
        onIncreaseQty: () {
          if (data.hasAddOns) {
            confirmAddOnsDialog(data);
          } else {
            sharedCartBloc.increaseItemToSharedCart(
                sharedCartBloc.getSharedCartModel(),
                data: data);
          }
        },
        onDecreaseQty: () {
          sharedCartBloc.decreaseItemToSharedCart(
              sharedCartBloc.getSharedCartModel(),
              data: data);
        },
      );
    }
    return Container();
  }

  Widget scanQRCodeBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.qr_code,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.SCAN_QR, arguments: {'isRequest': false});
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget checkoutWidget() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      shadowColor: boxShadowTwo,
      elevation: 4,
      child: Container(
        decoration: decorateBox(),
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  AppLocalization.of(context)!.total + " : ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                    color: blackFont,
                  ),
                ),
                Text(
                  worldCurrencies[userBloc.user.currency!]!,
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: blackFont,
                  ),
                ),
                Text(
                  moneyDisplayNormalizer(int.parse(sharedCartBloc
                      .getSharedCartModel()
                      .getSharedCartTotalPrice()
                      .toString())),
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: blackFont,
                  ),
                ),
              ],
            ),
            const Expanded(
              child: SizedBox(
                width: 10,
              ),
            ),
            _buildCheckoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    return MaterialButton(
      height: 40,
      color: sharedCartBloc.getSharedCartModel().customerUsername ==
              userBloc.user.userName
          ? navyBlue
          : darkGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: const SizedBox(
        width: 66,
        child: Text(
          "Checkout",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
      ),
      onPressed: () {
        // if (appConfigurationModel?.enableCheckout == true &&
        //     sharedCartBloc.getSharedCartModel().customerUsername ==
        //         userBloc.user.userName &&
        //     sharedCartBloc.getSharedCartModel().getSharedCartTotalPrice() !=
        //         0) {
        ShippingProcessBloc shippingProcessBloc =
            Provider.of<ShippingProcessBloc>(context, listen: false);
        shippingProcessBloc.currentSelectedIndex = null;

        Navigator.of(context).pushNamed(Routes.CONFIRM_ORDER, arguments: {
          'isSharedCart': true,
          'sharedCartId': sharedCartBloc.getSharedCartModel().id
        });

        // Navigator.of(context).pushNamed(Routes.SHARED_CART_PAYMENT);
        // } else {
        //   showToast(message: 'Checkout not available now');
        // }
        // _buildCartPaymentRequestDialog(context);
      },
    );
  }

  void _buildCartPaymentRequestDialog(BuildContext context) {
    showDialogBoxWithInput(
        context: context,
        actionOneTextColor: blackFont,
        actionOneBgColor: greyBorderColor,
        actionTwoTextColor: white,
        actionTwoBgColor: navyBlue,
        actionOneText: AppLocalization.of(context)!.cancel,
        actionTwoText: AppLocalization.of(context)!.viewNow,
        firstActionPrimary: false,
        content: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 25),
          child: Column(
            children: [
              Text(AppLocalization.of(context)!.cartPaymentRequest,
                  style: TextStyle(
                      color: blackFont,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Inter",
                      fontSize: 16.0),
                  textAlign: TextAlign.center),
              Container(
                margin:
                    EdgeInsets.only(top: 25, bottom: 15, left: 20, right: 20),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'A payment request of ₦0.00 from ',
                          style: TextStyle(
                            color: blackFont,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Inter",
                            fontSize: 14.0,
                          )),
                      TextSpan(
                          text: '${sharedCartBloc.getSharedCartModel().name} ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: blackFont,
                            fontFamily: "Inter",
                            fontSize: 14.0,
                          )),
                      TextSpan(
                          text: 'shared cart?',
                          style: TextStyle(
                            color: blackFont,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Inter",
                            fontSize: 14.0,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        leftButtonOnPressed: () async {
          Navigator.pop(context);
        },
        rightButtonOnPressed: () async {
          Navigator.pop(context);
          Navigator.of(context).pushNamed(Routes.SHARED_CART_PAYMENT);
        });
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        //clear old items
        // sharedCartBloc.getSharedCartModel().basketItems.clear();
        // basketBloc.total = 0;
        //fetch items again
        count = 0;
        next = "";
        previous = "";
        noDataInList = false;
        getCartItemsList();
        // basketBloc.getTotalPrice();
        setState(() {
          // Call the callback function with the updated list
          //to pass the list back to edit product page
          // widget.onListRefreshed!(productVariantList);
          _refreshController.refreshCompleted();
        });
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  Future<void> confirmAddOnsDialog(BasketItem data) async {
    await showDialogBox(
      context: context,
      actionOneBgColor: greyBorderColor,
      actionOneTextColor: blackFont,
      actionTwoBgColor: naturalGreen,
      actionTwoTextColor: Colors.white,
      title: "Repeat last used Add-ons?",
      actionOneText: "I'll choose",
      actionTwoText: "Repeat last",
      leftButtonOnPressed: () {
        Navigator.pushNamed(context, Routes.PRODUCT, arguments: {
          "product": data.item as Product,
          "type": "changeAddons"
        });
      },
      rightButtonOnPressed: () {
        sharedCartBloc.increaseItemToSharedCart(
            sharedCartBloc.getSharedCartModel(),
            data: data);
      },
    );
  }
}
