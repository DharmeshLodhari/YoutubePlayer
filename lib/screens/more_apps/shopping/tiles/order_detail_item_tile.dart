import 'package:Slydo/data/currency.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class OrderTileForProduct extends StatefulWidget {
  Product? product;
  String? type;
  int? qty;

  OrderTileForProduct(Map<String, dynamic> item, {super.key}) {
    type = item["type"];
    product = item["item"];
    qty = item["qty"];
  }

  @override
  State<OrderTileForProduct> createState() => _OrderTileForProductState();
}

class _OrderTileForProductState extends State<OrderTileForProduct> {
  @override
  Widget build(BuildContext context) {
    try {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        shadowColor: boxShadowTwo,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: getLeading(),
                  title: getTitle(),
                  trailing: getTrailing(),
                  subtitle: getSubtitle(context),
                  onTap: () {
                    Navigator.pushNamed(context, Routes.PRODUCT,
                        arguments: {"product": widget.product});
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return Container();
    }
  }

  Widget getLeading() {
    return badges.Badge(
      badgeContent: Text(
        widget.qty.toString(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          color: Colors.white,
        ),
      ),
      position: badges.BadgePosition.topEnd(end: -6, top: -6),
      badgeAnimation: const badges.BadgeAnimation.rotation(
        animationDuration: Duration(seconds: 1),
        colorChangeAnimationDuration: Duration(seconds: 1),
        loopAnimation: false,
        curve: Curves.fastOutSlowIn,
        colorChangeAnimationCurve: Curves.easeInCubic,
      ),
      badgeStyle: badges.BadgeStyle(
        shape: badges.BadgeShape.circle,
        badgeColor: naturalGreen,
        padding: widget.qty.toString().isEmpty
            ? const EdgeInsets.all(0)
            : const EdgeInsets.all(4),
        elevation: 0,
      ),
      // ignore: required onPressed
      child: ClipOval(
        child: CachedNetworkImage(
          height: 48,
          width: 48,
          imageUrl: widget.product!.serverImages!.isNotEmpty
              ? widget.product!.serverImages!.first!
              : defaultImage,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.fitWidth,
          errorWidget: productAndServiceErrorWidget,
          filterQuality: FilterQuality.high,
          placeholder: (context, url) =>
              widget.product!.serverImages!.isNotEmpty
                  ? const Icon(Icons.widgets)
                  : CircularLoadingIndicator(),
        ),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      messageDecoderWithEmoji(widget.product?.name) ?? "",
      maxLines: 1,
      style: TextStyle(
          color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget getTrailing() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[widget.product!.currency!]!,
          style: TextStyle(
              color: blackFont,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(int.parse(widget.product!.price.toString())),
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String getProductPrice() {
    if (widget.product!.price.toString().length > 5) {
      return "${widget.product!.price.toString().substring(0, 5)}..";
    }
    return widget.product!.price.toString();
  }

  String getTotalPrice() {
    final price = widget.qty! * widget.product!.price!;
    return price.toString();
  }

  Widget getSubtitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
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
          worldCurrencies[widget.product!.currency!]!,
          style: TextStyle(
              color: blackFont,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(int.parse(getTotalPrice())),
          style: TextStyle(
              color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget getSellerName(BuildContext context) {
    return Text(
      widget.product!.seller!,
      style: TextStyle(fontSize: 12, color: darkGrey),
    );
  }
}

// ignore: must_be_immutable
class OrderTileForService extends StatefulWidget {
  Service? service;
  String? type;
  int? qty;

  OrderTileForService(Map<String, dynamic> item, {super.key}) {
    type = item["type"];
    service = item["item"];
    qty = item["qty"] ?? 0;
  }

  @override
  State<OrderTileForService> createState() => _OrderTileForServiceState();
}

class _OrderTileForServiceState extends State<OrderTileForService> {
  @override
  Widget build(BuildContext context) {
    try {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        shadowColor: boxShadowTwo,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: getLeading(),
                  title: getTitle(),
                  trailing: getTrailing(),
                  subtitle: getSubtitle(context),
                  onTap: () {
                    Navigator.pushNamed(context, "/service-detail",
                        arguments: {"service": widget.service});
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return Container();
    }
  }

  Widget getLeading() {
    return badges.Badge(
      badgeContent: Text(
        widget.qty.toString(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          color: Colors.white,
        ),
      ),
      position: badges.BadgePosition.topEnd(end: -6, top: -6),
      badgeAnimation: const badges.BadgeAnimation.rotation(
        animationDuration: Duration(seconds: 1),
        colorChangeAnimationDuration: Duration(seconds: 1),
        loopAnimation: false,
        curve: Curves.fastOutSlowIn,
        colorChangeAnimationCurve: Curves.easeInCubic,
      ),
      badgeStyle: badges.BadgeStyle(
        shape: badges.BadgeShape.circle,
        badgeColor: naturalGreen,
        padding: widget.qty.toString().isEmpty
            ? const EdgeInsets.all(0)
            : const EdgeInsets.all(4),
        elevation: 0,
      ),
      // ignore: required onPressed
      child: ClipOval(
        child: CachedNetworkImage(
          height: 48,
          width: 48,
          imageUrl: widget.service!.serverImages!.isNotEmpty
              ? widget.service!.serverImages!.first!
              : defaultImage,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.fill,
          errorWidget: productAndServiceErrorWidget,
          filterQuality: FilterQuality.high,
          placeholder: (context, url) =>
              widget.service!.serverImages!.isNotEmpty
                  ? const Icon(Icons.widgets)
                  : CircularLoadingIndicator(),
        ),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      messageDecoderWithEmoji(widget.service?.name) ?? "",
      maxLines: 1,
      style: TextStyle(
          color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget getTrailing() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[widget.service!.currency!]!,
          style: TextStyle(
              color: blackFont,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(int.parse(widget.service!.price!)),
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String getServicePrice() {
    if (widget.service!.price.toString().length > 5) {
      return "${widget.service!.price.toString().substring(0, 5)}..";
    }
    return widget.service!.price.toString();
  }

  String getTotalPrice() {
    final price = widget.qty! * int.parse(widget.service!.price!);
    return price.toString();
  }

  Widget getSubtitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
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
          worldCurrencies[widget.service!.currency!]!,
          style: TextStyle(
              color: blackFont,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(int.parse(getTotalPrice())),
          style: TextStyle(
              color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget getSellerName(BuildContext context) {
    return Text(
      widget.service!.provider!,
      style: TextStyle(fontSize: 12, color: darkGrey),
    );
  }
}
