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
  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  BasketBloc basketBloc;
  CustomerProfileBloc customerProfileBloc;
  SlidableController slidableController;
  UserBloc userBloc;
  PersistentBottomSheetController persistentBottomSheetController;
  final _auth = AuthService();
  GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    super.initState();
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
              child: ListView.builder(
                  itemCount: basketBloc.items.length,
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
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'Notes',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 16.0,
                    ),
                  ),
                  Text(
                      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum"),
                ],
              ),
            ),
          );
        });
  }

  showBtmSheet() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: <Widget>[
                  Text("Status"),
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        RadioListTile(
                          title: Text(
                            'Pending',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 16.0,
                            ),
                          ),
                          onChanged: (value) {
                            updateStatus(value);
                          },
                        ),
                        RadioListTile(
                          title: Text(
                            'Pending',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        RadioListTile(
                          title: Text(
                            'Pending',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        RadioListTile(
                          title: Text(
                            'Pending',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget checkoutWidget() {
    return Card(
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
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }

  Widget getItemTile(int index) {
    return _getSlidableWithLists(
        context,
        ShoppingCartTile(
          product: basketBloc.items[index],
        ),
        basketBloc.items[index],
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
      "id": basketBloc.items[index].id,
    };
    _auth.removeItemToShoppingCart(data);
    basketBloc.removeItemFromCart(basketBloc.items[index]);
    Toast.show("Product is Removed Successfully from the cart", context,
        backgroundColor: darkBlue(),
        textColor: Colors.white,
        duration: Toast.LENGTH_LONG);
  }

  List<Widget> listActionSlideActions(int index) {
    var product = basketBloc.items[index];

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
    _auth.updateOrderStatus(value);
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
