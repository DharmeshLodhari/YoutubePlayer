//TODO: APPLY APP LOCALIZATION
import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/screens/tiles/shopping_cart_tile.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import 'colors.dart';

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
  // Todo: why do we have this 2 blocks
  CustomerProfileBloc customerProfileBloc;
  UserBloc userBloc;

  SlidableController slidableController;
  PersistentBottomSheetController statusBottomSheetController;
  PersistentBottomSheetController noteBottomSheetController;
  Order order;
  List consumable = List();
  final _auth = AuthService();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var statusOfOrder = "pending";

  @override
  void initState() {
    order = arguments['order'];
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
        if (statusBottomSheetController != null &&
            noteBottomSheetController != null) {
          statusBottomSheetController.close();
          noteBottomSheetController.close();
        }

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
              child: ListView.builder(
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
        showBtmSheet();
      },
    );
  }

  Widget noteIconButton() {
    return IconButton(
      icon: Icon(Icons.event_note),
      onPressed: () {
        showNoteSheet();
      },
    );
  }

  showNoteSheet() {
    noteBottomSheetController =
        scaffoldKey.currentState.showBottomSheet((context) => Card(
              elevation: 15,
              margin: EdgeInsets.all(0),
              color: Colors.white,
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Notes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: darkBlue(),
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(24.0, 16, 24, 24),
                            child: Text(
                              order.note,
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  showBtmSheet() async {
    statusBottomSheetController =
        scaffoldKey.currentState.showBottomSheet((context) => Card(
              margin: EdgeInsets.all(0),
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
                              title: "Pending",
                              value: "pending",
                            ),
                            Divider(
                              height: 0,
                            ),
                            statusListTile(
                              title: "Processing",
                              value: "processing",
                            ),
                            Divider(
                              height: 0,
                            ),
                            statusListTile(
                              title: "Out For Delivery",
                              value: "delivery",
                            ),
                            Divider(
                              height: 0,
                            ),
                            statusListTile(
                              title: "Completed",
                              value: "completed",
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
            ));
  }

  Widget statusListTile({String title, String value}) {
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
        statusBottomSheetController.setState(() {
          updateStatus(value);
          statusOfOrder = value;
        });
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                    "Total : " + worldCurrencies[userBloc.user.currency] + " "),
                Text(
                  basketBloc.total.toString(),
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            MaterialButton(
              color: Colors.red,
              child: Text(
                "Cancle",
                style: TextStyle(color: darkBlue()),
              ),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }

  Widget getItemTile(int index) {
    debugPrint("${consumable[index]}");
    return _getSlidableWithLists(
        context,
        ShoppingCartTile(
          {"item": consumable[index], "qty": 1},
        ),
        consumable[index],
        index);
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget productTile, Product product, int index) {
    return Slidable(
      controller: slidableController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(productTile, product),
      actions: listActionSlideActions(index),
      secondaryActions: listSecondaryActions(index),
    );
  }

  List<Widget> listSecondaryActions(int index) {
    String caption = "Remove";
    return [
      IconSlideAction(
          caption: caption,
          color: Colors.red,
          icon: Icons.cancel,
          onTap: () async {
//            removeItem(index);
          }),
    ];
  }

  void removeItem(int index) {
    Map data = {
      "type": "product",
      "id": consumable[index].id,
    };
    _auth.removeItemToShoppingCart(data);
    basketBloc.removeItemFromCart(consumable[index]);
    Toast.show("Product is Removed Successfully from the cart", context,
        backgroundColor: darkBlue(),
        textColor: Colors.white,
        duration: Toast.LENGTH_LONG);
  }

  List<Widget> listActionSlideActions(int index) {
    var product = consumable[index];

    bool isValid = true;
    if (product.seller == userBloc.user.userName) {
      isValid = false;
    }
    return [
      IconSlideAction(
        caption: "Message",
        color: isValid ? Colors.green : Colors.grey[600],
        icon: Icons.message,
        onTap: isValid
            ? () {
//                navigateToSendPayment(product, index);
              }
            : () {},
      ),
    ];
  }

  void navigateToSendPayment(Product product, int index) async {
    customerProfileBloc.customer =
        await _auth.fetchCustomerProfile(product.seller);
    Navigator.of(context).pushNamed(
      '/send-payment',
      arguments: {
        'isFromProfile': false,
        'isRequest': false,
        'product': product,
        'itemIndex': index
      },
    );
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
  VerticalListItem(this.child, this.product);
  final Widget child;
  Product product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/product",
            arguments: {"product": product});
      },
      child: Container(
        color: lightBlue(),
        child: child,
      ),
    );
  }
}
