import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shared_cart_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/shopping_cart_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/utils.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
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
  late BasketBloc basketBloc;
  late SharedCartBloc sharedCartBloc;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getCartItemsList();
    });
  }

  Future<void> getCartItemsList() async {
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

        basketBloc.items.clear();
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            noDataInList = false;
            isLoading = false;
            // basketBloc.items.addAll(tempList);
            tempList.forEach((element) {
              String type = element is Product ? "product" : "service";
              basketBloc.addItemToCart(item: element, type: type);
            });
          });
        }
      }
      if (basketBloc.items.isEmpty) {
        if (mounted) {
          setState(() {
            noDataInList = true;
          });
        }
      } else if (next == null && basketBloc.items.length > 6) {
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
    basketBloc = Provider.of<BasketBloc>(context);
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
                userImages: sharedCartBloc.getSharedCartModel().membersDetails),
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
          // child: Container(),
        ),
      ),
    );
  }

  Widget _buildListOfCartItems() {
    // return int.parse(getTotalPrice().toString()) == 0
    //     ? Center(
    //         child: NoItemInList(
    //             msg: AppLocalization.of(context)!.shoppingCartIsEmpty),
    //       )
    //     :
    return ListView.builder(
        itemCount: basketBloc.items.length,
        itemBuilder: (BuildContext context, int index) => getItemTile(index));
  }

  Widget getItemTile(int index) {
    List<Widget> itemWidgets = []; // Create an empty list to hold widgets

    if (basketBloc.items.length > index) {
      final data = basketBloc.items[index];
      final item = data["item"];

      if (item is Product) {
        Product product = item;

        List<Variant>? variants = product.variantModels;
        List<AddOns>? addOn = product.addOnsModels;

        if (variants != null && variants.isNotEmpty) {
          for (var variant in variants) {
            Map<String, dynamic> variant1 = {
              "id": variant.id,
              "quantity": variant.quantity,
              "price": variant.price,
              "colour": variant.colour,
              "value": variant.value,
              "type": variant.type,
            };

            String image = variant.localImages.toString();
            Variant single = Variant.fromJson(variant1);

            itemWidgets.add(
              ShoppingCartTileForProduct(
                {
                  "type": data["type"],
                  "item": product,
                  "qty": variants.isEmpty ? data['quantity'] : single.quantity,
                  "variant": single,
                  "image": image,
                  "addOn": null,
                },
                index: index,
                onDecreaseVariantQty: (val) {
                  removeVariantItem(index, val);
                  // if (mounted) setState(() {});
                },
                onIncreaseVariantQty: (val) {
                  addVariantItem(index, val);
                  // if (mounted) setState(() {});
                },
              ),
            );
          }
        } else if (addOn != null && addOn.isNotEmpty) {
          debugPrint('fola cart:::: ${addOn}');

          itemWidgets.add(
            ShoppingCartTileForProduct(
              {
                "type": data["type"],
                "item": product,
                "qty": data['qty'],
                "addOn": addOn,
                "variant": null,
                "image": "",
              },
              index: index,
              onDecreaseQty: () {
                removeItemAddOn(index);
              },
              onIncreaseQty: () {
                addItemAddOn(index);
              },
            ),
          );
        } else {
          itemWidgets.add(
            ShoppingCartTileForProduct(
              {
                "type": data["type"],
                "item": product,
                "qty": data['qty'],
                "variant": null,
                "addOn": null,
                "image": "",
              },
              index: index,
              onDecreaseQty: () {
                removeItem(index);
                // if (mounted) setState(() {});
              },
              onIncreaseQty: () {
                addItem(index);
                // if (mounted) setState(() {});
              },
            ),
          );
        }
      } else {
        itemWidgets.add(
          ShoppingCartTileForService(
            data,
            index: index,
            onDecreaseQty: () {
              index != null ? removeItem(index) : SizedBox.shrink();
            },
            onIncreaseQty: () {
              index != null ? addItem(index) : SizedBox.shrink();
            },
          ),
        );
      }
    } else {
      return Container(); // Return an empty container if index is out of bounds
    }

    return Column(
      children: itemWidgets,
    );
  }

  void removeItem(int index) async {
    String type =
        basketBloc.items[index]["item"] is Product ? "product" : "service";

    late var mapData;
    basketBloc.items.forEach((element) {
      if (element["item"].id == basketBloc.items[index]["item"].id) {
        mapData = element;
        return;
      }
    });
    Map data = {
      "type": type,
      "id": mapData["item"].id,
      "qty": mapData["qty"] - 1,
    };

    debugPrint("Data send From Remove Button : ${mapData["item"].id}");
    basketBloc.removeItemFromCart(basketBloc.items[index]["item"]);
    await SharedCartAuthService()
        .removeItemFromSharedCart(sharedCartBloc.getSharedCartModel().id, data);
  }

  void addItem(int index) async {
    String type =
        basketBloc.items[index]["item"] is Product ? "product" : "service";

    basketBloc.addItemToCart(item: basketBloc.items[index]["item"], type: type);

    late var mapData;
    basketBloc.items.forEach((element) {
      if (element["item"].id == basketBloc.items[index]["item"].id) {
        mapData = element;
        return;
      }
    });
    Map data = {
      "type": type,
      "id": mapData["item"].id,
      "qty": mapData["qty"],
    };
    debugPrint("Data From increasing the  item : $data");
    await SharedCartAuthService()
        .addItemToSharedCart(sharedCartBloc.getSharedCartModel().id, data);
  }

  void removeVariantItem(int index, int variantId) async {
    String type =
        basketBloc.items[index]["item"] is Product ? "product" : "service";

    Product selectedProduct = basketBloc.items[index]["item"];
    basketBloc.removeOrReduceVariant(selectedProduct.id.toString(), variantId);

    Map<String, dynamic> dataInfo =
        getUpdatedCartItem(type, basketBloc.items[index]["item"].id);

    debugPrint('fola chat one fourrrr::: ${dataInfo}');

    //close pop up if quantity to reduce is 1 currently
    if (dataInfo["variants"] == null) {
      basketBloc.removeItemFromCart(basketBloc.items[index]["item"]);

      Map<String, dynamic> data = {
        "id": ["productId"],
        "type": dataInfo["type"],
        "qty": 0,
      };
      await SharedCartAuthService().removeItemFromSharedCart(
          sharedCartBloc.getSharedCartModel().id, data);
    } else {
      await SharedCartAuthService().addItemToSharedCart(
          sharedCartBloc.getSharedCartModel().id, dataInfo);
    }
  }

  Map<String, dynamic> getUpdatedCartItem(String type, String productId) {
    Map<String, dynamic> dataInfo = {};

    for (var element in basketBloc.items) {
      Product item = element["item"];
      int totalVariantQuantity = 0;

      if (item.variantModels != null && productId == item.id) {
        List<Variant> variantsList = item.variantModels ?? [];

        // debugPrint("Data From Product Page v-id 5 : ${variantsList}");
        // debugPrint("Data From Product Page v-id 6 : ${element["item"].variant}");
        // debugPrint("Data From Product Page v-id 7 : ${item['variants']}");

        // Initialize dataInfo with common information
        dataInfo = {
          "id": productId,
          "type": type,
        };

        // Check if variantsList is not empty
        if (variantsList.isNotEmpty) {
          List<Map<String, dynamic>> variantDataList = [];

          // Iterate through the variants and add each variant to the variantDataList
          for (var variant in variantsList) {
            if (variant.id != null) {
              int variantId = int.parse(variant.id.toString());
              int? variantQuantity = variant.quantity;

              variantDataList.add({
                "id": variantId,
                "quantity": variantQuantity,
              });
            }
          }

          // debugPrint("Data From Product Page v-id 5 : ${variantDataList}");

          // Add the variantDataList to dataInfo["variants"]
          dataInfo["variants"] = variantDataList;

          // Calculate the totalVariantQuantity based on variantDataList
          totalVariantQuantity = variantDataList.fold<int>(
              0,
              (sum, variant) =>
                  sum + int.parse(variant['quantity'].toString()));
        }

        // Set the total quantity in dataInfo
        dataInfo["qty"] =
            variantsList.isNotEmpty ? totalVariantQuantity : item.quantity;
      } else {
        dataInfo = {
          "id": item.id,
          "qty": element['qty'],
          "type": type,
          "variants": [],
        };
      }
    }
    return dataInfo;
  }

  void addVariantItem(int index, int variantId) async {
    String type =
        basketBloc.items[index]["item"] is Product ? "product" : "service";

    // debugPrint('fola cart:::: ${variantId}');
    Product selectedProduct = basketBloc.items[index]["item"];

    basketBloc.increaseVariantQuantity(
        selectedProduct.id.toString(), variantId);

    Map<String, dynamic> dataInfo =
        getUpdatedCartItem(type, basketBloc.items[index]["item"].id);

    await SharedCartAuthService()
        .addItemToSharedCart(sharedCartBloc.getSharedCartModel().id, dataInfo);
  }

  void removeItemAddOn(int index) async {
    late var mapData;
    String type =
        basketBloc.items[index]["item"] is Product ? "product" : "service";
    basketBloc.items.forEach((element) async {
      if (element["item"].id == basketBloc.items[index]["item"].id) {
        element['qty'] = int.parse(element['qty'].toString()) - 1;
        mapData = element;
        return;
      }
    });
    if (mounted) setState(() {});

    if (mapData['qty'] == 0 || mapData['qty'] == -1) {
      //remove item from cart and local
      Map data = {
        "type": type,
        "id": mapData["item"].id,
        "qty": mapData["qty"],
      };
      basketBloc.removeItemFromCart(basketBloc.items[index]["item"]);
      await SharedCartAuthService().removeItemFromSharedCart(
          sharedCartBloc.getSharedCartModel().id, data);
    } else {
      //update to server is qty is not zero
      debugPrint('add-on add mapData qty not 0/-1::: ${mapData['qty']}');
      if (mapData['qty'] != 0) {
        // debugPrint('add-on add three::: ${mapData['add_ons']}');

        var addOn = mapData['add_ons'];

        List<dynamic> transformedList = addOn?.map((item) {
              List<dynamic> options = item['options']?.map((option) {
                    return {"id": option['id'], "quantity": option['quantity']};
                  })?.toList() ??
                  [];

              return {"id": item['id'], "options": options};
            })?.toList() ??
            [];

        Map data = {
          "type": type,
          "id": mapData["item"].id,
          "qty": mapData["qty"],
          "add_ons": transformedList,
        };
        debugPrint("Data From increasing the  item : $data");
        await SharedCartAuthService()
            .addItemToSharedCart(sharedCartBloc.getSharedCartModel().id, data);
      }
    }
  }

  void addItemAddOn(int index) async {
    late var mapData;
    String type =
        basketBloc.items[index]["item"] is Product ? "product" : "service";
    basketBloc.items.forEach((element) {
      if (element["item"].id == basketBloc.items[index]["item"].id) {
        element['qty'] = int.parse(element['qty'].toString()) + 1;
        mapData = element;
        return;
      }
    });
    if (mounted) setState(() {});
    //update to server
    var addOn = mapData['add_ons'];

    List<dynamic> transformedList = addOn?.map((item) {
          List<dynamic> options = item['options']?.map((option) {
                return {"id": option['id'], "quantity": option['quantity']};
              })?.toList() ??
              [];

          return {"id": item['id'], "options": options};
        })?.toList() ??
        [];

    Map data = {
      "type": type,
      "id": mapData["item"].id,
      "qty": mapData["qty"],
      "add_ons": transformedList,
    };
    debugPrint("Data From increasing the  item : $data");
    await SharedCartAuthService()
        .addItemToSharedCart(sharedCartBloc.getSharedCartModel().id, data);
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
                  // worldCurrencies[userBloc.user.currency!]!,
                  '₦',
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: blackFont,
                  ),
                ),
                Text(
                  // moneyDisplayNormalizer(int.parse(getTotalPrice().toString())),
                  '0.00',
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
      color: navyBlue,
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
        _buildCartPaymentRequestDialog(context);
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
                child: Text(
                    'A payment request of ₦0.00 from ${sharedCartBloc.getSharedCartModel().name} shared cart?',
                    style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Inter",
                        fontSize: 14.0),
                    textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
        leftButtonOnPressed: () async {
          Navigator.pop(context);
        },
        rightButtonOnPressed: () async {
          Navigator.pop(context);
          Navigator.of(context).pushNamed(Routes.SHARED_CARD_CONFIRM_ORDER);
        });
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        basketBloc.items = [];
        if (mounted) setState(() {});
        getCartItemsList();
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
}
