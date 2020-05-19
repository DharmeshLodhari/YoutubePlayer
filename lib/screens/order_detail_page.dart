//TODO: APPLY APP LOCALIZATION
import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/screens/tiles/shopping_cart_tile.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import 'colors.dart';

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
  CustomerProfileBloc customerProfileBloc;
  UserBloc userBloc;

  SlidableController slidableController;

  String note = "";

  Order order;
  List consumable = List();
  bool isLoading = true;
  final _auth = AuthService();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var statusOfOrder = "";

  @override
  void initState() {
    order = arguments['order'];
    statusOfOrder = order.status.toLowerCase();
    slidableController = SlidableController(
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

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: darkBlue(),
          title: Text("Order Detail"),
          actions: <Widget>[noteIconButton(), statusIconButton()],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
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
        ),
      ),
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
        enableDrag: true,
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Card(
            elevation: 15,
            margin: EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white,
            child: Container(
              height: MediaQuery.of(context).size.height / 2 +
                  MediaQuery.of(context).viewInsets.bottom,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Notes',
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
            ),
          );
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
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                  child: Text(
                    getOrderNote(),
                    style: TextStyle(fontSize: 14),
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
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        maxLines: 6,
        onFieldSubmitted: (val) {
          addNote();
        },
        cursorColor: darkBlue(),
        decoration: InputDecoration(
          isDense: true,
          labelText: "Enter Your Note Here",
          labelStyle: TextStyle(color: Colors.grey[600]),
          alignLabelWithHint: true,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: darkBlue(), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: darkBlue(), width: 1),
          ),
        ),
        onChanged: (val) {
          note = val;
        },
      ),
    );
  }

  Widget addNoteBtn() {
    return FlatButton(
        color: darkBlue(),
        child: Text(
          'Add',
          style: TextStyle(color: Colors.white),
        ),
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
      return "No Special Note Atteched !!";
    }
    return order.note;
  }

  void showChangeStatusAndroidSheet() {
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Card(
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 20),
                elevation: 15,
                child: Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Status',
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
                              ),
                              statusListTile(
                                title: "New Order",
                                value: "new order",
                                setState: setState,
                              ),
                              Divider(
                                height: 0,
                              ),
                              statusListTile(
                                title: "Awaiting Payment",
                                value: "awaiting payment",
                                setState: setState,
                              ),
                              Divider(
                                height: 0,
                              ),
                              statusListTile(
                                title: "Canceled",
                                value: "canceled",
                                setState: setState,
                              ),
                              Divider(
                                height: 0,
                              ),
                              statusListTile(
                                title: "Completed",
                                value: "complete",
                                setState: setState,
                              ),
                              Divider(
                                height: 0,
                              ),
                              statusListTile(
                                title: "On Hold",
                                value: "on hold",
                                setState: setState,
                              ),
                              Divider(
                                height: 0,
                              ),
                              statusListTile(
                                title: "Pending",
                                value: "pending",
                                setState: setState,
                              ),
                              Divider(
                                height: 0,
                              ),
                              statusListTile(
                                title: "Processing",
                                value: "processing",
                                setState: setState,
                              ),
                              Divider(
                                height: 0,
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
        });
  }

  Widget statusListTile({String title, String value, StateSetter setState}) {
    return RadioListTile(
      activeColor: darkBlue(),
      title: Text(
        title,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: darkBlue(),
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
      elevation: 5,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                Text("Total"),
                Text(
                  " : " + worldCurrencies[order.currency] + " ",
                  style: TextStyle(
                    fontFamily: "Roboto",
                  ),
                ),
                Text(
                  order.totalPrice.toString(),
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            SizedBox(
              height: 10,
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
    debugPrint("${consumable[index]["item"].serverImages}");
    if (consumable[index]["type"] == "product") {
      return ShoppingCartTileForProduct(
        consumable[index],
      );
    }
    return ShoppingCartTileForService(consumable[index]);
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget itemTile, var item, int index) {
    return Slidable(
      controller: slidableController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(itemTile, item),
      actions: listActionSlideActions(index),
      secondaryActions: listSecondaryActions(index),
    );
  }

  List<Widget> listSecondaryActions(int index) {
    return [];
  }

  void removeItem(int index) {
    var item = consumable[index];
    Map data = {
      "type": item["type"],
      "id": item.id,
    };

    _auth.removeItemToShoppingCart(data);
    basketBloc.removeItemFromCart(item);
    Toast.show("Product is Removed Successfully from the cart", context,
        backgroundColor: darkBlue(),
        textColor: Colors.white,
        duration: Toast.LENGTH_LONG);
  }

  List<Widget> listActionSlideActions(int index) {
    var item = consumable[index];
    var conditionForUser =
        item["type"] == "product" ? item["item"].seller : item["item"].provider;

    bool isValid = true;
    if (conditionForUser == userBloc.user.userName) {
      isValid = false;
    }
    return [
      IconSlideAction(
        caption: "Message",
        color: isValid ? Colors.green : Colors.grey[600],
        icon: Icons.message,
        onTap: isValid
            ? () {
                navigateToComposeMessage(conditionForUser, index);
              }
            : () {},
      ),
    ];
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
        color: lightBlue(),
        child: child,
      ),
    );
  }
}
