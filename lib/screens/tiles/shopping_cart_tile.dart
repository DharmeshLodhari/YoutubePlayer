import 'package:Slydo/data/currency.dart';
import 'package:Slydo/models/store.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ShoppingCartTile extends StatefulWidget {
  Product product;
  int qty;
  ShoppingCartTile(Map<String, dynamic> item) {
    product = item["item"];
    qty = item["qty"];
  }
  @override
  _ShoppingCartTileState createState() =>
      _ShoppingCartTileState(product: product, qty: qty);
}

class _ShoppingCartTileState extends State<ShoppingCartTile> {
  Product product;
  int qty;
  _ShoppingCartTileState({this.product, this.qty});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
                leading: getLeading(),
                title: getTitle(),
                trailing:
                    product.price.toString().length > 6 ? null : getTrailing(),
                subtitle: getSubtitle(context)),
          ),
        ],
      ),
    );
  }

  Widget getLeading() {
    return Stack(children: [
      ClipOval(
        child: CachedNetworkImage(
          imageUrl: product.serverImages.isNotEmpty
              ? product.serverImages.first
              : "https://homepages.cae.wisc.edu/~ece533/images/peppers.png",
          height: 50,
          width: 50,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          placeholder: (context, url) => product.serverImages[0] == ""
              ? Icon(Icons.person)
              : CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
        ),
      ),
      Positioned(
        right: 0,
        child: ClipOval(
          child: Container(
            height: 15,
            width: 15,
            color: Colors.green,
            child: Center(
                child: Text(
              qty.toString(),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )),
          ),
        ),
      )
    ]);
  }

  Widget getTitle() {
    return Text(
      "${product.name.length > 17 ? product.name.substring(0, 17) : product.name}",
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getTrailing() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          worldCurrencies[product.currency] + ' ' + getProductPrice(),
          style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
      ],
    );
  }

  String getProductPrice() {
    if (product.price.toString().length > 5) {
      return product.price.toString().substring(0, 5) + "..";
    }
    return product.price.toString();
  }

  String getTotalPrice() {
    var price = qty * int.parse(product.price);
    return price.toString();
  }

  Widget getSubtitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "${product.shortDescription.length > 20 ? product.shortDescription.substring(0, 20) : product.shortDescription}",
          style: TextStyle(color: Colors.grey[600]),
        ),
        SizedBox(
          height: 2,
        ),
        getSellerName(context),
        getTotalPriceWidget(),
      ],
    );
  }

  Widget getTotalPriceWidget() {
    return Text(
      worldCurrencies[product.currency] + ' ' + getTotalPrice(),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
      ),
    );
  }

  Widget getSellerName(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          product.seller,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
