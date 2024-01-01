import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/share_cart_details.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/shopping_cart_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_stacked_image.dart';
import 'package:Slydo/screens/more_apps/yarn/trending_list_screen.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_tab_selection.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_list_screen.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../locator.dart';
import '../../../../services/app_config_bloc.dart';
import '../../payment_and_banking/payment_and_banking_auth.dart';
import '../../user_profile/user_auth.dart';
import '../shopping_auth.dart';

class ShoppingCart extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  late BasketBloc basketBloc = BasketBloc();
  late CustomerProfileBloc customerProfileBloc;
  late UserBloc userBloc;
  List<int?> orders = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _auth = PaymentAndBankingAuth();
  late PageController _pageViewController;
  int currentAskTapOnHome = 0;
  String? selectedCategoryId;

  GlobalKey<YarnListScreenState> topicViewStateKey =
      GlobalKey<YarnListScreenState>();
  GlobalKey<TrendingListScreenState> latestViewStateKey =
      GlobalKey<TrendingListScreenState>();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        //clear old items
        basketBloc.items.clear();
        basketBloc.total = 0;
        //fetch items again
        initializeShoppingCart();
        getTotalPrice();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  void initializeShoppingCart() async {
    basketBloc.resetShoppingCart();
  }

  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController(initialPage: 0);
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: appBar() as PreferredSizeWidget?,
      body: // if (_tabsVisible) ...[
          Column(
        children: [
          YarnTabSelection(
            onTap: (index) {
              currentAskTapOnHome = index;
              _pageViewController.jumpToPage(currentAskTapOnHome);
              // _showTabs(true);
              if (mounted) setState(() {});
            },
            currentIndex: currentAskTapOnHome,
            firstTab: 'My Cart',
            secondTab: 'Shared Cart',
          ),
          _buildPageView()
        ],
      ),
      // SizedBox(
      //   height: 16,
      // ),
      // ],
      floatingActionButton:
          int.parse(getTotalPrice().toString()) == 0 ? null : checkoutWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void updateCurrentAskTapOnHome({required int index}) {
    setState(() {
      currentAskTapOnHome = index;
    });
  }

  Widget _buildPageView() {
    return Expanded(
      child: PageView(
        onPageChanged: (currentPage) {
          updateCurrentAskTapOnHome(index: currentPage);
        },
        controller: _pageViewController,
        children: [
          SmartRefresher(
            key: topicViewStateKey,
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: _buildBodyOfCart(),
          ),
          ListView(
            key: latestViewStateKey,
            children: [
              InkWell(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => SharedCartDetails())),
                child: Card(
                  margin: EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("My Birthday Hangout"),
                            SizedBox(height: 10),
                            buildMultipleFollowersWidget()
                          ],
                        ),
                        Spacer(),
                        Text("N100"),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMultipleFollowersWidget(
      {double radiusSize: 32,
      double radiusShift: 10,
      double radiusHeight: 32,
      radiusWidth: 32}) {
    return Padding(
      padding: EdgeInsets.only(right: 12),
      child: StackedWidgets(
        size: radiusSize,
        xShift: radiusShift,
        items: [
          ...List.generate(4, (index) => CircleAvatar()),
        ],
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
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
        AppLocalization.of(context)!.basket,
        style: TextStyle(
            color: blackFont, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      actions: <Widget>[
        RoundedBackgroundIcon(
          height: 34,
          width: 34,
          icon: Icon(
            SlydoAppIcon.add,
            size: 16,
            color: blackFont,
          ),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.SELECT_USER_FOR_GROUP,
                arguments: {"create": "basket"});
          },
          backgroundColor: iconBtnGrey,
          enableMargin: true,
        ),
        SizedBox(width: 8),
        scanQRCodeBtn(),
        const SizedBox(
          width: 16,
        ),
      ],
    );
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

  Widget _buildBodyOfCart() {
    return int.parse(getTotalPrice().toString()) == 0
        ? Center(
            child: NoItemInList(
                msg: AppLocalization.of(context)!.shoppingCartIsEmpty),
          )
        : ListView.builder(
            itemCount: basketBloc.items.length,
            itemBuilder: (BuildContext context, int index) =>
                getItemTile(index));
  }

  Widget checkoutWidget() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                      AppLocalization.of(context)!.total + " : ",
                      style: TextStyle(fontSize: 14, color: blackFont),
                    ),
                    Text(
                      worldCurrencies[userBloc.user.currency!]!,
                      style: const TextStyle(
                          fontFamily: "Inter",
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      moneyDisplayNormalizer(
                          int.parse(getTotalPrice().toString())),
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
                MaterialButton(
                  height: 40,
                  color: navyBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: const SizedBox(
                    width: 66,
                    child: Text(
                      "Checkout",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                  ),
                  onPressed: () {
                    if (appConfigurationModel?.enableCheckout == true) {
                      // NavigationUtil.push(
                      //   context,
                      //   screen: const CheckoutScreen(),
                      // );
                      Navigator.of(context).pushNamed(Routes.CONFIRM_ORDER);
                      // Navigator.of(context).pushNamed(
                      //   Routes.DISPATCH_ADDRESS,
                      //   arguments: {
                      //     "isForSelection": true,
                      //     "onShippingAddressChange": (address) {
                      //       shippingAddress = address;
                      //       setState(() {});
                      //     }
                      //   },
                      // );
                    } else {
                      showToast(message: 'Checkout not available now');
                    }

                    // if (basketBloc.items.length != 0) {
                    //   addNoteDialog();
                    // } else {
                    //   showToast(
                    //       message: AppLocalization.of(context)!
                    //           .pleaseAddSomeItemsFirst);
                    // }
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getItemTile(int index) {
    return getItemTileUI(index);
  }

  Widget getItemTileUI(int index) {
    List<Widget> itemWidgets = []; // Create an empty list to hold widgets

    if (basketBloc.items.length > index) {
      final data = basketBloc.items[index];
      final item = data["item"];

      if (item is Product) {
        final product = item as Product;

        List? variants = data['item'].variant;
        List? addOn = item.addOns;

        if (variants != null && variants.isNotEmpty) {
          for (var variant in variants) {
            Map<String, dynamic> variant1 = {
              "id": variant!["id"],
              "quantity": variant['quantity'].toString(),
              "price": variant['price'],
              "colour": variant['colour'],
              "value": variant['value'],
              "type": variant['type']
            };

            String image = variant!["image"].toString();
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

  Widget addItemToBasket() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed(Routes.SCAN_QR, arguments: {'isRequest': false});
        },
        child: Image.asset(
          'assets/images/qr_code.png',
          height: 24.0,
          width: 24.0,
          color: Colors.white,
        ),
      ),
    );
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
    await ShoppingAuthService().addItemToShoppingCart(data);
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
      await ShoppingAuthService().removeItemFromShoppingCart(data);
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
        await ShoppingAuthService().addItemToShoppingCart(data);
      }
    }
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
    await ShoppingAuthService().addItemToShoppingCart(data);
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

    await ShoppingAuthService().addItemToShoppingCart(dataInfo);
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

    debugPrint("Data send From Remove Button : $data");
    basketBloc.removeItemFromCart(basketBloc.items[index]["item"]);
    await ShoppingAuthService().removeItemFromShoppingCart(data);
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
      await ShoppingAuthService().removeItemFromShoppingCart(data);
    } else {
      await ShoppingAuthService().addItemToShoppingCart(dataInfo);
    }
  }

  Map<String, dynamic> getUpdatedCartItem(String type, String productId) {
    Map<String, dynamic> dataInfo = {};

    for (var element in basketBloc.items) {
      final item = element["item"];
      int totalVariantQuantity = 0;

      if (element["variants"] != null &&
          element.containsKey("variants") &&
          productId == item.id) {
        // List variantsList = element["variants"];
        List variantsList = element['item'].variant;

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
            if (variant.containsKey("id") && variant["id"] != null) {
              int variantId = int.parse(variant["id"].toString());
              int variantQuantity = int.parse(variant["quantity"].toString());

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

  int getTotalVariantQuantity(List<dynamic>? variantsList, id) {
    int totalQuantity = 0;

    if (variantsList!.isNotEmpty) {
      // Iterate through the productView and add them to dataInfo
      for (var variant in variantsList) {
        int variantQuantity = int.parse(variant['quantity'].toString());
        totalQuantity += variantQuantity;
      }
    }

    return totalQuantity;
  }

  int getTotalPrice() {
    int totalPrice = 0;

    for (var item in basketBloc.items) {
      int itemTotal = 0;
      int AddOnTotal = 0;
      var product = item["item"];

      if (product is Product) {
        if (product.addOns != null) {
          if (product.addOns!.isNotEmpty) {
            for (var itemAddOn in product.addOns!) {
              if (itemAddOn.containsKey('options')) {
                List<Map<String, dynamic>> options =
                    List<Map<String, dynamic>>.from(itemAddOn['options']);

                for (var option in options) {
                  int AddOnOptionPrice =
                      int.parse(option['price'].toString()) ?? 0;
                  int quantity = int.parse(option['quantity'].toString()) ?? 0;
                  AddOnTotal += AddOnOptionPrice * quantity;
                }

                int price = int.parse(product.price.toString()) ?? 0;
                int quantity = int.parse(item['qty'].toString()) ?? 0;
                int priceQuantity = price * quantity;
                totalPrice += AddOnTotal + priceQuantity;
              }
            }
          }
        }

        if (product.variant != null) {
          // If the variant list is not empty, calculate the total price using variants
          if (product.variant!.isNotEmpty) {
            for (var variant in product.variant!) {
              // if(variant['quantity'] != null || variant['price'] != null){
              int variantPrice = int.parse(variant['price'].toString()) ?? 0;
              int quantity = int.parse(variant['quantity'].toString()) ?? 0;
              itemTotal += variantPrice * quantity;
              // }

            }
          }
          totalPrice += itemTotal;
        }

        if (product.addOns != null && product.variant != null) {
          int normalTotal = 0;
          normalTotal = int.parse(product.price.toString()) *
              int.parse(item['qty'].toString());
          totalPrice += normalTotal;
        }
      } else if (product is Service) {
        itemTotal = int.parse(product.price.toString());
        totalPrice += itemTotal;
      } else {
        itemTotal = int.parse(product.price.toString()) *
            int.parse(product?.quantity?.toString() ?? "1");
        totalPrice += itemTotal;
      }

      // totalPrice += itemTotal;
    }
    basketBloc.orderTotal = totalPrice;
    if (mounted) setState(() {});

    return totalPrice;
  }

  List<Map<String, dynamic>> convertDynamicList(List<dynamic> dynamicList) {
    List<Map<String, dynamic>> resultList = [];

    for (dynamic item in dynamicList) {
      if (item is Map<String, dynamic>) {
        resultList.add(item); // If the element is already a Map, add it as is
      } else if (item is Map) {
        // If the element is a Map with dynamic values, convert it to Map<String, dynamic>
        Map<String, dynamic> typedMap = Map<String, dynamic>.from(item);
        resultList.add(typedMap);
      } else {
        // Handle other cases as needed, e.g., converting non-Map items
        // into a map or skipping them.
        // For simplicity, we'll just skip them here.
      }
    }

    return resultList;
  }

  List<Widget> listActionSlideActions(int index) {
    String caption1 = AppLocalization.of(context)!.remove;

    return [
      IconSlideAction(
          caption: caption1,
          color: Colors.red,
          icon: Icons.remove,
          onTap: () {
            removeItem(index);
          }),
    ];
  }

  void navigateToSendPayment(Product product, int index) async {
    customerProfileBloc.customer =
        await UserAuth().fetchCustomerProfile(product.seller);
    Navigator.of(context).pushNamed(
      Routes.SEND_PAYMENT,
      arguments: {
        'isFromProfile': false,
        'product': product,
        'itemIndex': index
      },
    );
  }

  Product getProduct(String productId) {
    Product product = Product();
    product.id = productId;
    product.name = "";
    product.shortDescription = "";
    product.description = "";
    product.condition = "";
    product.currency = userBloc.user.currency;
    product.price = "0";
    product.availableFrom = DateTime.now();
    product.isAvailable = false;
    product.qrCode = "";
    product.seller = "";
    product.manufacturer = "";
    product.serverImages = [];
    return product;
  }

  addNoteDialog() {
    showMaterialDialog<String>(
      context: context,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, 'cancel');
          return false;
        },
        child: AlertDialog(
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            AppLocalization.of(context)!.confirmation,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: blackFont),
          ),
          content: Container(
            child: Text(
              AppLocalization.of(context)!.areYouSureWantToPlaceThisOrderFor +
                  '(${worldCurrencies[userBloc.user.currency!]} ${moneyDisplayNormalizer(basketBloc.total)})?',
              style: TextStyle(
                fontSize: 16,
                color: blackFont,
                fontFamily: "Inter",
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalization.of(context)!.cancel,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context, 'cancel');
              },
            ),
            TextButton(
              child: Text(
                AppLocalization.of(context)!.place,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context, 'place');
              },
            ),
          ],
        ),
      ),
    );
  }

  void showMaterialDialog<T>({required BuildContext context, Widget? child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child!,
    ).then<void>((T? value) async {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
        var data = {"note": value};
        if (value != "cancel") {
          BottomSheetPassCode(
              context: context,
              isValidCallback: () async {
                showDialog(
                  context: context,
                  builder: (context) => Center(
                    child: CircularLoadingIndicator(),
                  ),
                );

                await checkAccountBalance();

                // Create the orders
                var userOrder =
                    await ShoppingAuthService().placeOrderOfShoppingCart(data);

                if (userOrder != null) {
                  basketBloc.items.clear(); // Shopping cart
                  basketBloc.total = 0; // clearing the total amount

                  // Send the list of of orders for payment processing
                  for (int i = 0; i < userOrder.length; i++) {
                    orders.add(userOrder[i]["id"]);
                  }
                  var response =
                      await _auth.makePaymentForCartOrder({"orders": orders});
                  Navigator.popUntil(
                      context, ModalRoute.withName(Routes.DASHBOARD));
                  if (response.statusCode == 200) {
                    Navigator.pushNamed(context, Routes.ORDERS_LIST);
                  } else if (response.statusCode == 500) {
                    showToast(
                        message: AppLocalization.of(context)!.serverError);
                  }

                  // else if (response.statusCode == 800) {
                  //   Navigator.pop(context);
                  //   Navigator.pushNamed(
                  //     context,
                  //     "/add-document",
                  //   );
                  // }
                  else {
                    debugPrint(
                      "MakePaymentForCartOrder Unsuccessful",
                    );
                  }
                } else {
                  debugPrint(
                    "Could Not Place The Order",
                  );
                }
              },
              cancelCallBack: () {
                Navigator.pop(context);
              });
        }
      }
    });
  }

  Future<void> checkAccountBalance() async {
    BankAccountBloc bankAccountBloc =
        Provider.of<BankAccountBloc>(context, listen: false);
    if (bankAccountBloc.bankAccount == null ||
        bankAccountBloc.bankAccount!.bankName == null) {
      Navigator.popUntil(context, ModalRoute.withName(Routes.DASHBOARD));
      showToast(message: "Please add bank account first !!");
    } else {
      double accountBalance = await getAccountBalance();
      Navigator.popUntil(context, ModalRoute.withName(Routes.DASHBOARD));
      debugPrint("accountBalance:- $accountBalance");
      double spendingAmount = basketBloc.total / 100;
      debugPrint("spendingAmount:- $spendingAmount");
      if (spendingAmount > accountBalance) {
        showToast(message: "You don't have enough money in Slydo account!!");
        return;
      }
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}

// ignore: must_be_immutable
class VerticalListItem extends StatelessWidget {
  Widget? child;
  var item;
  String? type;

  VerticalListItem(Widget child, var item) {
    this.child = child;
    this.type = item["type"];
    this.item = item["item"];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (type == "product") {
          Product? product = item;
          Navigator.pushNamed(context, Routes.PRODUCT,
              arguments: {"product": product});
        }
        if (type == "service") {
          Service? service = item;
          Navigator.pushNamed(context, Routes.SERVICE_DETAIL,
              arguments: {"service": service});
        }
      },
      child: child,
    );
  }
}
