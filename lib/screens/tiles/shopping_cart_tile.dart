import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';

// ignore: must_be_immutable
class ShoppingCartTileForProduct extends StatefulWidget {
  Product item;
  String type;
  int qty;
  int index;
  Function onIncreaseQty;
  Function onDecreaseQty;

  ShoppingCartTileForProduct(Map<String, dynamic> item,
      {this.onIncreaseQty, this.onDecreaseQty, this.index}) {
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
  BasketBloc basketBloc;

  _ShoppingCartTileForProductState({this.product, this.qty});

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    try {
      return Container(
        color: Colors.white,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          shadowColor: iconBtnGrey,
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
    return Container(
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
              : CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  backgroundColor: lightBlue(),
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
      width: 100,
      color: Colors.transparent,
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            RoundedBackgroundIcon(
                backgroundColor: iconBtnGrey,
                icon: Icon(
                  SlydoAppIcon.minus,
                  color: blackFont,
                  size: 2,
                ),
                onTap: widget.onDecreaseQty),
            Expanded(
              child: SizedBox(
                width: 10,
              ),
            ),
            Text(
              basketBloc.items[widget.index]["qty"].toString(),
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: blackFont),
            ),
            Expanded(
              child: SizedBox(
                width: 10,
              ),
            ),
            RoundedBackgroundIcon(
                backgroundColor: iconBtnGrey,
                icon: Icon(
                  SlydoAppIcon.plus,
                  color: blackFont,
                  size: 16,
                ),
                onTap: widget.onIncreaseQty),
          ],
        ),
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
    var price =
        basketBloc.items[widget.index]["qty"] * int.parse(product.price);
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
      style: TextStyle(fontSize: 10, color: darkGrey),
    );
  }
}

// ignore: must_be_immutable
class ShoppingCartTileForService extends StatefulWidget {
  Service item;
  String type;
  int qty;
  int index;
  Function onIncreaseQty;
  Function onDecreaseQty;

  ShoppingCartTileForService(Map<String, dynamic> item,
      {this.onDecreaseQty, this.onIncreaseQty, this.index}) {
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
  BasketBloc basketBloc;

  _ShoppingCartTileForServiceState({this.service, this.qty});

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    try {
      return Container(
        color: Colors.white,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          shadowColor: iconBtnGrey,
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
    return Container(
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
          placeholder: (context, url) =>
          service.serverImages.isNotEmpty
              ? Icon(Icons.widgets)
              : CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Colors.white),
            backgroundColor: lightBlue(),
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
    int qty = basketBloc.items[widget.index]["qty"] != 0
        ? basketBloc.items[widget.index]["qty"]
        : 0;
    return Container(
      width: 100,
      color: Colors.transparent,
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            RoundedBackgroundIcon(
                backgroundColor: iconBtnGrey,
                icon: Icon(
                  SlydoAppIcon.minus,
                  color: blackFont,
                  size: 2,
                ),
                onTap: widget.onDecreaseQty),
            Expanded(
              child: SizedBox(
                width: 10,
              ),
            ),
            Text(
              qty.toString(),
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: blackFont),
            ),
            Expanded(
              child: SizedBox(
                width: 10,
              ),
            ),
            RoundedBackgroundIcon(
              backgroundColor: iconBtnGrey,
              icon: Icon(
                SlydoAppIcon.plus,
                color: blackFont,
                size: 16,
              ),
              onTap: widget.onIncreaseQty,
            )
          ],
        ),
      ),
    );
  }

  String getServicePrice() {
    if (service.price
        .toString()
        .length > 5) {
      return service.price.toString().substring(0, 5) + "..";
    }
    return service.price.toString();
  }

  String getTotalPrice() {
    var price =
        basketBloc.items[widget.index]["qty"] * int.parse(service.price);
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
      style: TextStyle(fontSize: 10, color: darkGrey),
    );
  }
}
