import 'package:Slydo/data/currency.dart';
import 'package:Slydo/models/store.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../colors.dart';

// ignore: must_be_immutable
class ShoppingCartTileForProduct extends StatefulWidget {
  Product item;
  String type;
  int qty;
  ShoppingCartTileForProduct(Map<String, dynamic> item) {
    type = item["type"];
    this.item = item["item"];
    qty = item["qty"];
  }
  @override
  _ShoppingCartTileForProductState createState() =>
      _ShoppingCartTileForProductState(product: item, qty: qty);
}

class _ShoppingCartTileForProductState
    extends State<ShoppingCartTileForProduct> {
  Product product;
  int qty;
  _ShoppingCartTileForProductState({this.product, this.qty});
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
    return Badge(
      animationType: BadgeAnimationType.slide,
      badgeContent: Text(
        qty.toString(),
        style: TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      badgeColor: Colors.green,
      padding: EdgeInsets.all(4),
      position: BadgePosition(right: 0, top: 0),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: product.serverImages.isNotEmpty
              ? product.serverImages.first
              : "https://homepages.cae.wisc.edu/~ece533/images/peppers.png",
          height: 50,
          width: 50,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          placeholder: (context, url) => product.serverImages.isNotEmpty
              ? Icon(Icons.widgets)
              :CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Colors.white),
            backgroundColor: lightBlue(),
          ),
        ),
      ),
    );
  }

  getHeight() {
    if (qty.toString().length == 1) {
      return 15.0;
    } else if (qty.toString().length == 2) {
      return 15.0;
    }
  }

  getWidth() {
    if (qty.toString().length == 1) {
      return 15.0;
    } else if (qty.toString().length == 2) {
      return 18.0;
    }
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              worldCurrencies[product.currency],
              style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
            Text(
              ' ' + getProductPrice(),
              style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ],
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
          style: TextStyle(
            color: Colors.grey[600],
          ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[product.currency],
          style: TextStyle(
            color: Colors.grey[600],
            fontFamily: "Roboto",
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          ' ' + getTotalPrice(),
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
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

// ignore: must_be_immutable
class ShoppingCartTileForService extends StatefulWidget {
  Service item;
  String type;
  int qty;
  ShoppingCartTileForService(Map<String, dynamic> item) {
    type = item["type"];
    this.item = item["item"];
    qty = item["qty"] ?? 0;
  }
  @override
  _ShoppingCartTileForServiceState createState() =>
      _ShoppingCartTileForServiceState(service: item, qty: qty);
}

class _ShoppingCartTileForServiceState
    extends State<ShoppingCartTileForService> {
  Service service;
  int qty;
  _ShoppingCartTileForServiceState({this.service, this.qty});
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
                    service.price.toString().length > 6 ? null : getTrailing(),
                subtitle: getSubtitle(context)),
          ),
        ],
      ),
    );
  }

  Widget getLeading() {
    return Badge(
      animationType: BadgeAnimationType.slide,
      badgeContent: Text(
        qty.toString(),
        style: TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      badgeColor: Colors.green,
      padding: EdgeInsets.all(4),
      position: BadgePosition(right: 0, top: 0),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: service.serverImages.isNotEmpty
              ? service.serverImages.first
              : "https://homepages.cae.wisc.edu/~ece533/images/peppers.png",
          height: 50,
          width: 50,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          placeholder: (context, url) => service.serverImages.isNotEmpty
              ? Icon(Icons.widgets)
              :CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Colors.white),
            backgroundColor: lightBlue(),
          ),
        ),
      ),
    );
  }

  getHeight() {
    if (qty.toString().length == 1) {
      return 15.0;
    } else if (qty.toString().length == 2) {
      return 15.0;
    }
  }

  getWidth() {
    if (qty.toString().length == 1) {
      return 15.0;
    } else if (qty.toString().length == 2) {
      return 18.0;
    }
  }

  Widget getTitle() {
    return Text(
      "${service.name.length > 17 ? service.name.substring(0, 17) : service.name}",
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getTrailing() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              worldCurrencies[service.currency],
              style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
            Text(
              ' ' + getProductPrice(),
              style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  String getProductPrice() {
    if (service.price.toString().length > 5) {
      return service.price.toString().substring(0, 5) + "..";
    }
    return service.price.toString();
  }

  String getTotalPrice() {
    var price = qty * int.parse(service.price);
    return price.toString();
  }

  Widget getSubtitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "${service.shortDescription.length > 20 ? service.shortDescription.substring(0, 20) : service.shortDescription}",
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[service.currency],
          style: TextStyle(
            color: Colors.grey[600],
            fontFamily: "Roboto",
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          ' ' + getTotalPrice(),
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget getSellerName(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          service.provider,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
