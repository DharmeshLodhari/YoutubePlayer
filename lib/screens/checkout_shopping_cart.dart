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

class ShoppingCart extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  BasketBloc basketBloc;
  CustomerProfileBloc customerProfileBloc;
  SlidableController slidableController;
  UserBloc userBloc;
  final _auth = AuthService();

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
        Navigator.pop(context);
        Navigator.pushNamed(context, '/dashboard',
            arguments: {"dashboardIndex": 5});
        return false;
      },
      child: Scaffold(
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: darkBlue(),
          title: Text("Shopping Basket"),
          actions: <Widget>[
            search(),
            addItemToBasket(),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  itemCount: basketBloc.items.length,
                  itemBuilder: (BuildContext context, int index) =>
                      getItemTile(index)),
            ),
            checkoutWidget()
          ],
        ),
      ),
    );
  }

  Widget search() {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
        Navigator.pushNamed(context, "/dashboard",
            arguments: {"dashboardIndex": 3});
      },
    );
  }

  Widget checkoutWidget() {
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Total : " +
                worldCurrencies[userBloc.user.currency] +
                basketBloc.total.toString()),
            MaterialButton(
              color: darkBlue(),
              child: Text(
                "Buy",
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

  Widget addItemToBasket() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed('/scan-qr', arguments: {'isRequest': false});
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
          icon: Icons.remove_shopping_cart,
          onTap: () async {
            removeItem(index);
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
        caption: "Buy",
        color: isValid ? Colors.green : Colors.grey[600],
        icon: Icons.send,
        onTap: isValid
            ? () {
                navigateToSendPayment(product);
              }
            : () {},
      ),
    ];
  }

  void navigateToSendPayment(Product product) async {
    customerProfileBloc.customer =
        await _auth.fetchCustomerProfile(product.seller);
    Navigator.of(context).pushNamed(
      '/send-payment',
      arguments: {
        'isFromProfile': false,
        'isRequest': false,
        'product': product,
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
