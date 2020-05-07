import 'package:Slydo/data/currency.dart';
import 'package:Slydo/models/store.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ShoppingCartTile extends StatefulWidget {
  Product product;
  ShoppingCartTile({this.product});
  @override
  _ShoppingCartTileState createState() =>
      _ShoppingCartTileState(product: product);
}

class _ShoppingCartTileState extends State<ShoppingCartTile> {
  Product product;
  _ShoppingCartTileState({this.product});
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
    return ClipOval(
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
    );
  }

  Widget getTitle() {
    return Text(
      "${product.name.length > 17 ? product.name.substring(0, 17) : product.name}",
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getTrailing() {
    return Text(
      worldCurrencies[product.currency] + ' ' + product.price.toString(),
      style: TextStyle(
          color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 15),
    );
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
        product.price.toString().length > 6 ? getTrailing() : Container(),
        getSellerName(context)
      ],
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
