import 'dart:convert';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/order_detail_item_tile.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/navigation_util.dart';
import '../../../payment_and_banking/payment_and_banking_auth.dart';
import '../../../user_profile/forms/user_address.dart';
import '../../shopping_auth.dart';

// ignore: must_be_immutable
class OrderDetailPage extends StatefulWidget {
  var arguments;

  OrderDetailPage({required this.arguments});

  @override
  _OrderDetailPageState createState() =>
      _OrderDetailPageState(arguments: arguments);
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  var arguments;

  _OrderDetailPageState({this.arguments});

  late BasketBloc basketBloc;
  late UserBloc userBloc;

  SlidableController? _slideController;

  String note = "";

  Order? order;
  List items = [];
  bool isLoading = true;
  final _auth = ShoppingAuthService();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? statusOfOrder = "";
  String? statusOfOrderCopy =
      ""; //This variable is used to track if the statusOfOrder has changed.

  GlobalKey _key = LabeledGlobalKey("orderDetailPagePopUpMenu");
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;

  @override
  void initState() {
    order = arguments['order'];
    statusOfOrder = order!.status!.toLowerCase();
    statusOfOrderCopy = order!.status!.toLowerCase();
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    fetchOrder(order!.id.toString());
    super.initState();
  }

  void fetchOrder(String orderId) async {
    setState(() {
      isLoading = true;
    });
    _auth.getOrder(orderId).then((value) {
      debugPrint('VALUE :: $value');
      if (mounted) {
        setState(() {
          items = value;
          isLoading = false;
        });
      }
    });
  }

  void menuItemSelectionChange(String value, int index) {
    if (userBloc.user.userName == order!.merchant) {
      selectedMenuItemIndex = index;
      updateStatus(value);
      statusOfOrder = value;
      setState(() {});
    }
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    userBloc = Provider.of<UserBloc>(context);

    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      children: [
        CustomizedPopUpMenuItem(title: "New order", value: "new order"),
        CustomizedPopUpMenuItem(
            title: "Awaiting payment", value: "awaiting payment"),
        CustomizedPopUpMenuItem(title: "Canceled", value: "canceled"),
        CustomizedPopUpMenuItem(title: "Completed", value: "completed"),
        CustomizedPopUpMenuItem(title: "On hold", value: "on hold"),
        CustomizedPopUpMenuItem(title: "Pending", value: "pending"),
        CustomizedPopUpMenuItem(title: "Processing", value: "processing"),
      ],
      selectedIndex: selectedMenuItemIndex,
      right: 16,
    );
    menu.onChange = menuItemSelectionChange;
    menu.menuState = menuStateChange;

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          appBar: appBar() as PreferredSizeWidget?,
          body: scaffoldBody()),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
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
      centerTitle: false,
      title: Text(
        "Order details",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        locationBtn(),
        SizedBox(width: 10.0),
        noteSheetBtn(),
        SizedBox(width: 10.0),
        changeOrderStatusSheetBtn(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget locationBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.location,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        // showNoteAndroidSheet();
        NavigationUtil.push(
          context,
          screen: UserAddress(customerName: order!.customerName),
        );
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget noteSheetBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.note,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        showNoteAndroidSheet();
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget popUpMenuButton() {
    return SizedBox(
      key: _key,
      height: 34,
      width: 34,
      child: Card(
        color: isPopMenuOpen ? navyBlue : iconBtnGrey,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: Icon(
            Icons.settings,
            color: isPopMenuOpen ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () {
            if (menu.isMenuOpen) {
              menu.closeMenu();
            } else {
              menu.openMenu();
            }
          },
        ),
      ),
    );
  }

  Widget changeOrderStatusSheetBtn() {
    if (userBloc.user.userName == order!.merchant) {
      return RoundedBackgroundIcon(
        height: 34,
        width: 34,
        icon: Icon(
          SlydoAppIcon.settings,
          size: 16,
          color: blackFont,
        ),
        onTap: () {
          showChangeStatusAndroidSheet();
        },
        backgroundColor: iconBtnGrey,
        enableMargin: true,
      );
    }
    return SizedBox.shrink();
  }

  Widget scaffoldBody() {
    bool canPay = order!.status == 'Awaiting Payment' &&
        userBloc.user.userName != order!.merchant;

    return Column(
      children: <Widget>[
        Expanded(
          child: isLoading
              ? Center(
                  child: CircularLoadingIndicator(),
                )
              : Column(
                  children: [
                    getOrderDetail(),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) =>
                            getItemTile(index),
                      ),
                    ),
                    canPay
                        ? Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: CurvedButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (dialogLoadingContext) =>
                                            LoadingIndicator());

                                    var data = {
                                      "orders": [order!.id]
                                    };
                                    PaymentAndBankingAuth()
                                        .makePaymentForCartOrder(data)
                                        .then(
                                      (response) {
                                        Navigator.pop(context);
                                        if (response.statusCode == 200) {
                                          Navigator.pop(context, true);

                                          showToast(
                                              message: 'Payment successful');
                                        } else if (response.statusCode == 500) {
                                          showToast(
                                              message:
                                                  AppLocalization.of(context)!
                                                      .serverError);
                                        } else {
                                          showToast(
                                              message:
                                                  jsonDecode(response.body)[0]
                                                      ['errors']);
                                        }
                                      },
                                    );
                                  },
                                  text: 'Pay Now',
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget statusIconButton() {
    return IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {
        showChangeStatusAndroidSheet();
      },
    );
  }

  Widget getOrderDetail() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          checkoutWidget(),
        ],
      ),
    );
  }

  Widget noteIconButton() {
    return IconButton(
      icon: Icon(Icons.event_note),
      onPressed: () {
        showNoteAndroidSheet();
      },
    );
  }

  void showNoteAndroidSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                height: MediaQuery.of(context).size.height / 2 +
                    MediaQuery.of(context).viewInsets.bottom,
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        AppLocalization.of(context)!.note,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: blackFont,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    getBodyOfNoteBottomSheet()
                  ],
                ),
              ));
        });
  }

  Widget getBodyOfNoteBottomSheet() {
    bool result =
        order!.note == "" && order!.customerName == userBloc.user.userName;
    if (!result) {
      return Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Text(
                    getOrderNote(),
                    style: TextStyle(
                        fontSize: 14,
                        color: blackFont,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        getNoteAddTextField(),
        SizedBox(
          height: 20,
        ),
        addNoteBtn(),
      ],
    ));
  }

  Widget getNoteAddTextField() {
    return Container(
      child: TextFormField(
        maxLines: 8,
        onFieldSubmitted: (val) {
          addNote();
        },
        cursorColor: blackFont,
        decoration: InputDecoration(
          isDense: true,
          labelText: AppLocalization.of(context)!.enterYourNoteHere,
          labelStyle: TextStyle(color: darkGrey),
          alignLabelWithHint: true,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: greyBorderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: greyBorderColor, width: 1),
          ),
        ),
        onChanged: (val) {
          note = val;
        },
      ),
    );
  }

  Widget addNoteBtn() {
    return CurvedButton(
        backgroundColor: navyBlue,
        text: "Add note",
        textColor: Colors.white,
        onPressed: addNote);
  }

  void addNote() async {
    await _auth.updateOrderNote(note, order!.id.toString()).then((value) {
      if (value) {
        setState(() {
          order!.note = note;
          Navigator.pop(context);
        });
      }
    });
  }

  getOrderNote() {
    if (order!.note == "") {
      return AppLocalization.of(context)!.noSpecialNoteAttached + " !!";
    }
    return order!.note;
  }

  void showChangeStatusAndroidSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                color: Colors.white,
                margin: EdgeInsets.zero,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        AppLocalization.of(context)!.status,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: blackFont,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: ListView(
                          children: <Widget>[
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.newOrder,
                              value: "new order",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title:
                                  AppLocalization.of(context)!.awaitingPayment,
                              value: "awaiting payment",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.canceled,
                              value: "canceled",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.completed,
                              value: "complete",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.onHold,
                              value: "on hold",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.pending,
                              value: "pending",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.processing,
                              value: "processing",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ));
          });
        });
  }

  Widget statusListTile(
      {required String title, String? value, StateSetter? setState}) {
    return RadioListTile(
      activeColor: navyBlue,
      title: Text(
        title,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: blackFont,
          fontSize: 16.0,
        ),
      ),
      value: value,
      onChanged: (dynamic value) {
        if (userBloc.user.userName == order!.merchant) {
          setState!(() {
            updateStatus(value);
            statusOfOrder = value;
          });
        }
      },
      groupValue: statusOfOrder,
    );
  }

  Widget checkoutWidget() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: navyBlue,
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: navyBlue),
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 18,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    AppLocalization.of(context)!.total + " : ",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        worldCurrencies[order!.currency!]!,
                        style: TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        moneyDisplayNormalizer(order!.totalPrice),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: Text("Order No:- ",
                        style: TextStyle(fontSize: 14, color: Colors.white))),
                Expanded(
                    child: Text(
                  "${"Ref # :" + (order?.id ?? "")}",
                  style: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                )),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: Text("Order Status:- ",
                        style: TextStyle(fontSize: 14, color: Colors.white))),
                Expanded(
                    child: Text(
                  "${order?.status ?? ""}",
                  style: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                )),
              ],
            ),
            SizedBox(
              height: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget getItemTile(int index) {
    return _getSlidableWithLists(
      context,
      getItemTileUi(index),
      items[index],
      index,
    );
  }

  getItemTileUi(int index) {
    if (items[index]["type"] == "product") {
      return OrderTileForProduct(
        items[index],
      );
    }
    return OrderTileForService(
      items[index],
    );
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget itemTile, var item, int index) {
    return Slidable(
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(itemTile, item),
      actions: listActionSlideActions(index),
      secondaryActions: listSecondaryActions(index),
    );
  }

  List<Widget> listSecondaryActions(int index) {
    var item = items[index];
    var conditionForUser =
        item["type"] == "product" ? item["item"].seller : item["item"].provider;

    bool isValid = true;
    if (conditionForUser == userBloc.user.userName) {
      isValid = false;
    }

    return [
      SlideActionButton(
          backgroundColor: isValid ? naturalGreen : Colors.grey[600],
          icon: SlydoAppIcon.text_message,
          onTap: isValid
              ? () {
                  navigateToComposeMessage(conditionForUser, index);
                }
              : () {
                  showToast(message: "You can not send message to yourself!!");
                },
          title: AppLocalization.of(context)!.message,
          slideController: _slideController),
    ];
  }

  void removeItem(int index) {
    var item = items[index];
    Map data = {
      "type": item["type"],
      "id": item.conversationID,
    };

    _auth.removeItemToShoppingCart(data);
    basketBloc.removeItemFromCart(item);
    showToast(
        message:
            AppLocalization.of(context)!.itemIsRemovedSuccessfullyFromCart);
  }

  List<Widget> listActionSlideActions(int index) {
    return [];
  }

  void navigateToComposeMessage(var conditionForUser, int index) async {
    Navigator.of(context).pushNamed('/compose_message', arguments: {
      'recipient': conditionForUser.toString(),
      'subject': items[index]["item"].name.toString(),
    });
  }

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}

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

  void updateStatus(value) {
    showDialog(
        context: context,
        builder: (dialogLoadingContext) => LoadingIndicator());

    _auth.updateOrderStatus(value, order!.id.toString()).then((updated) {
      if (updated) {
        Navigator.pop(context); // Dismiss the loader.
        Navigator.pop(context); // Dismiss bottom-sheet.
        Navigator.pop(context,
            true); //Dismiss the order details page and reload the order list page.
        showToast(message: 'Status updated successfully');
      } else {
        showToast(message: 'Something went wrong while updating status.');
      }
    });
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
          Navigator.pushNamed(context, "/product",
              arguments: {"product": product});
        }
        if (type == "service") {
          Service? service = item;
          Navigator.pushNamed(context, "/service-detail",
              arguments: {"service": service});
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: child,
      ),
    );
  }
}
