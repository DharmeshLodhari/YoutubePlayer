import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/order_detail_item_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../shopping_auth.dart';

// ignore: must_be_immutable
class OrderDetailPage extends StatefulWidget {
  var arguments;

  OrderDetailPage({@required this.arguments});

  @override
  _OrderDetailPageState createState() =>
      _OrderDetailPageState(arguments: arguments);
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  var arguments;

  _OrderDetailPageState({this.arguments});

  BasketBloc basketBloc;
  UserBloc userBloc;

  SlidableController _slideController;

  String note = "";

  Order order;
  List consumable = List();
  bool isLoading = true;
  final _auth = ShoppingAuthService();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var statusOfOrder = "";

  GlobalKey _key = LabeledGlobalKey("orderDetailPagePopUpMenu");
  CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;

  @override
  void initState() {
    order = arguments['order'];
    statusOfOrder = order.status.toLowerCase();
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    fetchOrder(order.id.toString());
    super.initState();
  }

  void fetchOrder(String orderId) async {
    _auth.getOrder(orderId).then((value) {
      if (mounted) {
        setState(() {
          consumable = value;
          isLoading = false;
        });
      }
    });
  }

  void menuItemSelectionChange(String value, int index) {
    if (userBloc.user.userName == order.merchant) {
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
          appBar: appBar(),
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
        noteSheetBtn(),
        SizedBox(
          width: 10.0,
        ),
        changeOrderStatusSheetBtn(),
        // popUpMenuButton(),
        SizedBox(
          width: 16,
        ),
      ],
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

  Widget scaffoldBody() {
    return Column(
      children: <Widget>[
        Expanded(
          child: isLoading
              ? Center(
                  child: CircularLoadingIndicator(),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  itemCount: consumable.length,
                  itemBuilder: (BuildContext context, int index) =>
                      getItemTile(index)),
        ),
        checkoutWidget(),
        SizedBox(
          height: 20,
        )
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
                        AppLocalization.of(context).note,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: darkBlue(),
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
    bool result = order.note == "" && order.customer == userBloc.user.userName;
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
        cursorColor: darkBlue(),
        decoration: InputDecoration(
          isDense: true,
          labelText: AppLocalization.of(context).enterYourNoteHere,
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
    await _auth.updateOrderNote(note, order.id.toString()).then((value) {
      if (value) {
        setState(() {
          order.note = note;
          Navigator.pop(context);
        });
      }
    });
  }

  getOrderNote() {
    if (order.note == "") {
      return AppLocalization.of(context).noSpecialNoteAttached + " !!";
    }
    return order.note;
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
                        AppLocalization.of(context).status,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: darkBlue(),
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
                              title: AppLocalization.of(context).newOrder,
                              value: "new order",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title:
                                  AppLocalization.of(context).awaitingPayment,
                              value: "awaiting payment",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context).canceled,
                              value: "canceled",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context).completed,
                              value: "complete",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context).onHold,
                              value: "on hold",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context).pending,
                              value: "pending",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context).processing,
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

  Widget statusListTile({String title, String value, StateSetter setState}) {
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
      onChanged: (value) {
        if (userBloc.user.userName == order.merchant) {
          setState(() {
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
                Text(
                  AppLocalization.of(context).total + " : ",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                Text(
                  worldCurrencies[order.currency],
                  style: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  order.totalPrice.toString(),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
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
      consumable[index],
      index,
    );
  }

  getItemTileUi(int index) {
    if (consumable[index]["type"] == "product") {
      return OrderTileForProduct(
        consumable[index],
      );
    }
    return OrderTileForService(
      consumable[index],
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
    var item = consumable[index];
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
                  Toast.show(
                    "You can not send message to yourself!!",
                    context,
                    backgroundColor: blackFont,
                    textColor: Colors.white,
                  );
                },
          title: AppLocalization.of(context).message,
          slideController: _slideController),
    ];
  }

  void removeItem(int index) {
    var item = consumable[index];
    Map data = {
      "type": item["type"],
      "id": item.conversationId,
    };

    _auth.removeItemToShoppingCart(data);
    basketBloc.removeItemFromCart(item);
    Toast.show(
        AppLocalization.of(context).itemIsRemovedSuccessfullyFromCart, context,
        backgroundColor: darkBlue(),
        textColor: Colors.white,
        duration: Toast.LENGTH_LONG);
  }

  List<Widget> listActionSlideActions(int index) {
    return [];
  }

  void navigateToComposeMessage(var conditionForUser, int index) async {
    Navigator.of(context).pushNamed('/compose_message', arguments: {
      'recipient': conditionForUser.toString(),
      'subject': consumable[index]["item"].name.toString(),
    });
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}

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
    _auth.updateOrderStatus(value, order.id.toString());
  }
}

// ignore: must_be_immutable
class VerticalListItem extends StatelessWidget {
  Widget child;
  var item;
  String type;

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
          Product product = item;
          Navigator.pushNamed(context, "/product",
              arguments: {"product": product});
        }
        if (type == "service") {
          Service service = item;
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
