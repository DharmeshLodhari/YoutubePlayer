import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/locator.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/basket_item_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/shopping_cart_tile.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NormalCartScreen extends StatefulWidget {
  const NormalCartScreen({
    super.key,
    this.onPageRefresh,
  });

  final Function(bool)? onPageRefresh;

  @override
  State<NormalCartScreen> createState() => NormalCartScreenState();
}

class NormalCartScreenState extends State<NormalCartScreen> {
  late BasketBloc basketBloc;
  late CustomerProfileBloc customerProfileBloc;
  late UserBloc userBloc;

  // List<int?> orders = [];
  // final _auth = PaymentAndBankingAuth();

  final GlobalKey<ScaffoldMessengerState> _normalCartScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final ScrollController _normalScrollController = ScrollController();
  AppConfigurationModel? appConfigurationModel;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initializeShoppingCart();
    });

    _normalScrollController.addListener(() {
      if (_normalScrollController.position.pixels ==
              _normalScrollController.position.maxScrollExtent &&
          _normalScrollController.position.pixels != 0) {
        initializeShoppingCart();
      }
    });
  }

  @override
  void dispose() {
    _normalScrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> initializeShoppingCart() async {
    isLoading = true;
    await basketBloc.resetShoppingCart(context);
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    userBloc = Provider.of<UserBloc>(context);

    return ScaffoldMessenger(
      key: _normalCartScaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: lightGrey,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildBodyOfCart(),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyOfCart() {
    return Stack(
      children: [
        SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: navyBlue,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: _buildCartItemList(),
        ),
        Positioned(
          bottom: 40, // Adjust the distance from the bottom as needed
          right: 0,
          left: 0,
          child: checkoutWidget(),
        ),
      ],
    );
  }

  Widget _buildCartItemList() {
    if (isLoading) {
      return Center(
        child: CircularLoadingIndicator(),
      );
    }

    return basketBloc.basketItems.isEmpty && isLoading == false
        ? Center(
            child: NoItemInList(
                msg: AppLocalization.of(context)!.shoppingCartIsEmpty),
          )
        : ListView.builder(
            itemCount: basketBloc.basketItems.length,
            itemBuilder: (BuildContext context, int index) =>
                getItemTile(index),
          );
  }

  Widget checkoutWidget() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      shadowColor: boxShadowTwo,
      elevation: 4,
      child: Container(
        decoration: decorateBox(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      "${AppLocalization.of(context)?.total} : ",
                      style: TextStyle(fontSize: 14, color: blackFont),
                    ),
                    Text(
                      worldCurrencies[userBloc.user.currency] ?? "",
                      style: const TextStyle(
                          fontFamily: "Inter",
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      moneyDisplayNormalizer(basketBloc.getTotalPrice()),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Expanded(
                  child: SizedBox(
                    width: 10,
                  ),
                ),
                _buildCheckoutButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return MaterialButton(
      height: 40,
      color: navyBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: const Text(
        "Checkout",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          fontFamily: "Inter",
        ),
      ),
      onPressed: () {
        if (appConfigurationModel?.enableCheckout == true &&
            basketBloc.getTotalPrice() != 0) {
          final ShippingProcessBloc shippingProcessBloc =
              Provider.of<ShippingProcessBloc>(context, listen: false);
          shippingProcessBloc.currentSelectedIndex = null;

          Navigator.of(context).pushNamed(Routes.CONFIRM_ORDER,
              arguments: {'isSharedCart': false, 'sharedCartId': ''});
        } else {
          showToast(message: 'Checkout not available now');
        }
      },
    );
  }

  Widget getItemTile(int index) {
    final BasketItem data = basketBloc.basketItems[index];

    if (data.item?.isProduct ?? false) {
      return ShoppingCartTileForProduct(
        key: UniqueKey(),
        isSharedCart: false,
        basketItem: data,
        onIncreaseQty: () {
          if (data.hasAddOns) {
            confirmAddOnsDialog(data);
          } else {
            basketBloc.increaseQty(
              data: data,
              currentUser: userBloc.user.convertToUser(),
            );
          }
        },
        onDecreaseQty: () {
          basketBloc.decreaseQty(
            data: data,
            currentUser: userBloc.user.convertToUser(),
          );
        },
      );
    }
    return Container();
  }

  void removeVariantItem(int index, int variantId) async {
    final String type =
        basketBloc.items[index]["item"] is Product ? "product" : "service";

    final Product selectedProduct = basketBloc.items[index]["item"];
    basketBloc.removeOrReduceVariant(selectedProduct.id.toString(), variantId);

    final Map<String, dynamic> dataInfo =
        getUpdatedCartItem(type, basketBloc.items[index]["item"].id);

    // debugPrint('fola chat one fourrrr::: $dataInfo');

    //close pop up if quantity to reduce is 1 currently
    if (dataInfo["variants"] == null) {
      basketBloc.removeItemFromCart(basketBloc.items[index]["item"]);

      final Map<String, dynamic> data = {
        "id": ["productId"],
        "type": dataInfo["type"],
        "qty": 0,
      };
      await ShoppingAuthService().removeItemFromShoppingCart(data);
    } else {
      await ShoppingAuthService().addOrUpdateItemToShoppingCart(dataInfo);
    }
  }

  Map<String, dynamic> getUpdatedCartItem(String type, String productId) {
    Map<String, dynamic> dataInfo = {};

    for (var element in basketBloc.items) {
      final Product item = element["item"];
      int totalVariantQuantity = 0;

      if (item.variantModels != null && productId == item.id) {
        final List<Variant> variantsList = item.variantModels ?? [];

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
          final List<Map<String, dynamic>> variantDataList = [];

          // Iterate through the variants and add each variant to the variantDataList
          for (var variant in variantsList) {
            if (variant.id != null) {
              final int variantId = int.parse(variant.id.toString());
              final int? variantQuantity = variant.quantity;

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

  int getTotalVariantQuantity(List<dynamic>? variantsList) {
    int totalQuantity = 0;

    if (variantsList!.isNotEmpty) {
      // Iterate through the productView and add them to dataInfo
      for (var variant in variantsList) {
        final int variantQuantity = int.parse(variant['quantity'].toString());
        totalQuantity += variantQuantity;
      }
    }

    return totalQuantity;
  }

  void addItem(int index) async {
    final String type =
        basketBloc.items[index]["item"] is Product ? "product" : "service";

    basketBloc.addItemToCart(
      item: basketBloc.items[index]["item"],
      type: type,
      currentUser: userBloc.user.convertToUser(),
    );

    late var mapData;
    for (var element in basketBloc.items) {
      if (element["item"].id == basketBloc.items[index]["item"].id) {
        mapData = element;
        continue;
      }
    }
    final Map<String, dynamic> data = {
      "type": type,
      "id": mapData["item"].id,
      "qty": mapData["qty"],
    };
    // debugPrint("Data From increasing the  item : $data");
    await ShoppingAuthService().addOrUpdateItemToShoppingCart(data);
  }

  void addVariantItem(int index, int variantId) async {
    final String type =
        basketBloc.items[index]["item"] is Product ? "product" : "service";

    // debugPrint('fola cart:::: ${variantId}');
    final Product selectedProduct = basketBloc.items[index]["item"];

    basketBloc.increaseVariantQuantity(
        selectedProduct.id.toString(), variantId);

    final Map<String, dynamic> dataInfo =
        getUpdatedCartItem(type, basketBloc.items[index]["item"].id);

    await ShoppingAuthService().addOrUpdateItemToShoppingCart(dataInfo);
  }

  void removeItem(int index) async {
    final String type =
        basketBloc.items[index]["item"] is Product ? "product" : "service";

    late var mapData;
    for (var element in basketBloc.items) {
      if (element["item"].id == basketBloc.items[index]["item"].id) {
        mapData = element;
        continue;
      }
    }
    final Map data = {
      "type": type,
      "id": mapData["item"].id,
      "qty": mapData["qty"] - 1,
    };

    // debugPrint("Data send From Remove Button : $data");
    basketBloc.removeItemFromCart(basketBloc.items[index]["item"]);
    await ShoppingAuthService().removeItemFromShoppingCart(data);
  }

  void addItemAddOn(int index) async {
    late var mapData;
    final String type =
        basketBloc.items[index]["item"] is Product ? "product" : "service";
    for (var element in basketBloc.items) {
      if (element["item"].id == basketBloc.items[index]["item"].id) {
        element['qty'] = int.parse(element['qty'].toString()) + 1;
        mapData = element;
        continue;
      }
    }
    if (mounted) setState(() {});
    //update to server
    final addOn = mapData['add_ons'];

    final List<dynamic> transformedList = addOn?.map((item) {
          final List<dynamic> options = item['options']?.map((option) {
                return {"id": option['id'], "quantity": option['quantity']};
              })?.toList() ??
              [];

          return {"id": item['id'], "options": options};
        })?.toList() ??
        [];

    final Map<String, dynamic> data = {
      "type": type,
      "id": mapData["item"].id,
      "qty": mapData["qty"],
      "add_ons": transformedList,
    };
    // debugPrint("Data From increasing the  item : $data");
    await ShoppingAuthService().addOrUpdateItemToShoppingCart(data);
  }

  void removeItemAddOn(int index) async {
    late var mapData;
    final String type =
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
      final Map<String, dynamic> data = {
        "type": type,
        "id": mapData["item"].id,
        "qty": mapData["qty"],
      };
      basketBloc.removeItemFromCart(basketBloc.items[index]["item"]);
      await ShoppingAuthService().removeItemFromShoppingCart(data);
    } else {
      //update to server is qty is not zero
      // debugPrint('add-on add mapData qty not 0/-1::: ${mapData['qty']}');
      if (mapData['qty'] != 0) {
        // debugPrint('add-on add three::: ${mapData['add_ons']}');

        final addOn = mapData['add_ons'];

        final List<dynamic> transformedList = addOn?.map((item) {
              final List<dynamic> options = item['options']?.map((option) {
                    return {"id": option['id'], "quantity": option['quantity']};
                  })?.toList() ??
                  [];

              return {"id": item['id'], "options": options};
            })?.toList() ??
            [];

        final Map<String, dynamic> data = {
          "type": type,
          "id": mapData["item"].id,
          "qty": mapData["qty"],
          "add_ons": transformedList,
        };
        // debugPrint("Data From increasing the  item : $data");
        await ShoppingAuthService().addOrUpdateItemToShoppingCart(data);
      }
    }
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      //clear old items
      basketBloc.items.clear();
      basketBloc.total = 0;
      //fetch items again
      initializeShoppingCart();
      basketBloc.getTotalPrice();
      setState(() {
        // Call the callback function with the updated list
        //to pass the list back to edit product page
        // widget.onListRefreshed!(productVariantList);
        _refreshController.refreshCompleted();
      });
    } else {
      _refreshController.refreshCompleted();
    }
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
        Navigator.pushNamed(context, Routes.PRODUCT_DETAIL_PAGE, arguments: {
          "product": data.item as Product,
          "type": "changeAddons"
        });
      },
      rightButtonOnPressed: () {
        basketBloc.increaseQty(
          data: data,
          currentUser: userBloc.user.convertToUser(),
        );
      },
    );
  }
}
