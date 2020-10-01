import 'package:Slydo/data/currency.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';

// ignore: must_be_immutable
class OrderTileForProduct extends StatefulWidget {
  Product item;
  String type;
  int qty;

  OrderTileForProduct(Map<String, dynamic> item) {
    type = item["type"];
    this.item = item["item"];
    qty = item["qty"];
  }

  @override
  _OrderTileForProductState createState() =>
      _OrderTileForProductState(product: item, qty: qty);
}

class _OrderTileForProductState extends State<OrderTileForProduct> {
  Product product;
  int qty;

  _OrderTileForProductState({this.product, this.qty});

  @override
  Widget build(BuildContext context) {
    try {
      return Container(
        color: Colors.white,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          shadowColor: boxShadowTwo,
          elevation: 3,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: iconBtnGrey, width: 1)),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: getLeading(),
                    title: getTitle(),
                    trailing: getTrailing(),
                    subtitle: getSubtitle(context),
                    onTap: () {
                      Navigator.pushNamed(context, "/product",
                          arguments: {"product": product});
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      return Container();
    }
  }

  Widget getLeading() {
    return Badge(
      badgeColor: naturalGreen,
      animationType: BadgeAnimationType.slide,
      badgeContent: Text(
        qty.toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          color: Colors.white,
        ),
      ),
      padding:
          qty.toString().length == 0 ? EdgeInsets.all(0) : EdgeInsets.all(4),
      position: BadgePosition(right: -6, top: -6),
      // ignore: required onPressed
      child: Container(
        height: 57,
        width: 57,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: product.serverImages.isNotEmpty
                ? product.serverImages.first
                : "https://homepages.cae.wisc.edu/~ece533/images/peppers.png",
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fitWidth,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => product.serverImages.isNotEmpty
                ? Icon(Icons.widgets)
                : CircularLoadingIndicator(),
          ),
        ),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      "${product.name}",
      maxLines: 1,
      style: TextStyle(
          color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget getTrailing() {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            worldCurrencies[product.currency],
            style: TextStyle(
                color: blackFont,
                fontFamily: "Roboto",
                fontWeight: FontWeight.w600,
                fontSize: 14),
          ),
          Text(
            product.price,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
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
              color: blackFont,
              fontFamily: "Roboto",
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
        Text(
          getTotalPrice(),
          style: TextStyle(
              color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget getSellerName(BuildContext context) {
    return Text(
      product.seller,
      style: TextStyle(fontSize: 12, color: darkGrey),
    );
  }
}

// ignore: must_be_immutable
class OrderTileForService extends StatefulWidget {
  Service item;
  String type;
  int qty;

  OrderTileForService(Map<String, dynamic> item) {
    type = item["type"];
    this.item = item["item"];
    qty = item["qty"] ?? 0;
  }

  @override
  _OrderTileForServiceState createState() =>
      _OrderTileForServiceState(service: item, qty: qty);
}

class _OrderTileForServiceState extends State<OrderTileForService> {
  Service service;
  int qty;

  _OrderTileForServiceState({this.service, this.qty});

  @override
  Widget build(BuildContext context) {
    try {
      return Container(
        color: Colors.white,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          shadowColor: boxShadowTwo,
          elevation: 3,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: iconBtnGrey, width: 1)),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: getLeading(),
                    title: getTitle(),
                    trailing: getTrailing(),
                    subtitle: getSubtitle(context),
                    onTap: () {
                      Navigator.pushNamed(context, "/service-detail",
                          arguments: {"service": service});
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      return Container();
    }
  }

  Widget getLeading() {
    return Badge(
      badgeColor: naturalGreen,
      animationType: BadgeAnimationType.slide,
      badgeContent: Text(
        qty.toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          color: Colors.white,
        ),
      ),
      padding:
          qty.toString().length == 0 ? EdgeInsets.all(0) : EdgeInsets.all(4),
      position: BadgePosition(right: -6, top: -6),
      // ignore: required onPressed
      child: Container(
        height: 57,
        width: 57,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: service.serverImages.isNotEmpty
                ? service.serverImages.first
                : "https://homepages.cae.wisc.edu/~ece533/images/peppers.png",
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => service.serverImages.isNotEmpty
                ? Icon(Icons.widgets)
                : CircularLoadingIndicator(),
          ),
        ),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      "${service.name}",
      maxLines: 1,
      style: TextStyle(
          color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget getTrailing() {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            worldCurrencies[service.currency],
            style: TextStyle(
                color: blackFont,
                fontFamily: "Roboto",
                fontWeight: FontWeight.w600,
                fontSize: 14),
          ),
          Text(
            service.price,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String getServicePrice() {
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
              color: blackFont,
              fontFamily: "Roboto",
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
        Text(
          getTotalPrice(),
          style: TextStyle(
              color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget getSellerName(BuildContext context) {
    return Text(
      service.provider,
      style: TextStyle(fontSize: 12, color: darkGrey),
    );
  }
}
