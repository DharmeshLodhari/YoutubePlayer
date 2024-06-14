import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class OrderTileForProductNew extends StatefulWidget {
  final Map<String, dynamic> item;
  const OrderTileForProductNew({super.key, required this.item});

  @override
  State<OrderTileForProductNew> createState() => _OrderTileForProductNewState();
}

class _OrderTileForProductNewState extends State<OrderTileForProductNew> {
  Product? product;
  String? type;
  int? qty;

  @override
  void initState() {
    type = widget.item["type"];
    product = widget.item["item"];
    qty = widget.item["qty"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            getProductImage(),
            const SizedBox(
              width: 15,
            ),
            Expanded(child: getProductDetails()),
          ],
        ),
      );
    } catch (e) {
      return Container();
    }
  }

  Widget getProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        height: 80,
        width: 80,
        imageUrl: product!.serverImages!.isNotEmpty
            ? product!.serverImages!.first!
            : defaultImage,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fill,
        errorWidget: productAndServiceErrorWidget,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => product!.serverImages!.isNotEmpty
            ? const Icon(Icons.widgets)
            : CircularLoadingIndicator(),
      ),
    );
  }

  Widget getProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTitle(),
        getProductColorSize(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getTotalPriceWidget(),
            getProductCount(),
          ],
        ),
      ],
    );
  }

  Widget getTitle() {
    return Text(
      messageDecoderWithEmoji(product?.name) ?? "",
      maxLines: 1,
      style: TextStyle(
        color: blackFont,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        fontFamily: "Inter",
      ),
    );
  }

  Widget getProductCount() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "X$qty",
          style: TextStyle(
            color: darkGrey,
            fontFamily: "Inter",
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String getProductPrice() {
    if (product!.price.toString().length > 5) {
      return "${product!.price.toString().substring(0, 5)}..";
    }
    return product!.price.toString();
  }

  Widget getTotalPriceWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[product?.currency!]!,
          style: TextStyle(
            color: blackFont,
            fontFamily: "Inter",
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          moneyDisplayNormalizer(product?.price!),
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget getProductColorSize() {
    if (product!.variantModels!.isNotEmpty) {
      final String variantColor = product?.variantModels?.first.colour ?? '';
      final String variantSize = product?.variantModels?.first.value ?? '';
      if (variantColor.isNotEmpty || variantSize.isNotEmpty) {
        return MaterialButton(
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          visualDensity: VisualDensity.compact,
          color: lightGrey,
          onPressed: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                variantColor,
                style: TextStyle(
                  fontSize: 12,
                  color: darkGrey,
                ),
              ),
              if (variantColor.isNotEmpty && variantSize.isNotEmpty)
                Text(
                  "/",
                  style: TextStyle(
                    fontSize: 12,
                    color: darkGrey,
                  ),
                ),
              Text(
                variantSize,
                style: TextStyle(
                  fontSize: 12,
                  color: darkGrey,
                ),
              ),
            ],
          ),
        );
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }
}

// ignore: must_be_immutable
class OrderTileForService extends StatefulWidget {
  Service? item;
  String? type;
  int? qty;

  OrderTileForService(Map<String, dynamic> item, {super.key}) {
    type = item["type"];
    this.item = item["item"];
    qty = item["qty"] ?? 0;
  }

  @override
  State<OrderTileForService> createState() =>
      _OrderTileForServiceState(service: item, qty: qty);
}

class _OrderTileForServiceState extends State<OrderTileForService> {
  Service? service;
  int? qty;

  _OrderTileForServiceState({this.service, this.qty});

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
                        arguments: {"service": service});
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
        qty.toString(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          color: Colors.white,
          fontFamily: "Inter",
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
        padding: qty.toString().isEmpty
            ? const EdgeInsets.all(0)
            : const EdgeInsets.all(4),
        elevation: 0,
      ),
      // ignore: required onPressed
      child: ClipOval(
        child: CachedNetworkImage(
          height: 48,
          width: 48,
          imageUrl: service!.serverImages!.isNotEmpty
              ? service!.serverImages!.first!
              : defaultImage,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.fill,
          errorWidget: productAndServiceErrorWidget,
          filterQuality: FilterQuality.high,
          placeholder: (context, url) => service!.serverImages!.isNotEmpty
              ? const Icon(Icons.widgets)
              : CircularLoadingIndicator(),
        ),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      messageDecoderWithEmoji(service?.name) ?? "",
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
          worldCurrencies[service!.currency!]!,
          style: TextStyle(
              color: blackFont,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(int.parse(service!.price!)),
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
    if (service!.price.toString().length > 5) {
      return "${service!.price.toString().substring(0, 5)}..";
    }
    return service!.price.toString();
  }

  String getTotalPrice() {
    final price = qty! * int.parse(service!.price!);
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
          worldCurrencies[service!.currency!]!,
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
      service!.provider!,
      style: TextStyle(fontSize: 12, color: darkGrey),
    );
  }
}
