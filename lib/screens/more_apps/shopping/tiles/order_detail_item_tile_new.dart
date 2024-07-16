import 'package:Slydo/data/currency.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class OrderTileForProductNew extends StatefulWidget {
  final OrderItem? order;
  const OrderTileForProductNew({super.key, required this.order});

  @override
  State<OrderTileForProductNew> createState() => _OrderTileForProductNewState();
}

class _OrderTileForProductNewState extends State<OrderTileForProductNew> {
  Product? product;
  int? qty;

  @override
  void initState() {
    product = widget.order?.item;
    qty = widget.order?.qty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, Routes.PRODUCT, arguments: {
              "product": widget.order?.item as Product,
            });
          },
          child: Row(
            children: [
              getProductImage(),
              const SizedBox(
                width: 15,
              ),
              Expanded(child: getProductDetails()),
            ],
          ),
        ),
      );
    } catch (e, s) {
      return Container();
    }
  }

  Widget getProductImage() {
    String? image;

    image = product?.cover;

    if (product?.variantModels?.isNotEmpty ?? false) {
      image = product?.variantModels?.first.getCoverImage() ?? product?.cover;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: CachedNetworkImage(
        height: 48,
        width: 48,
        imageUrl: image ?? defaultImage,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.contain,
        errorWidget: productAndServiceErrorWidget,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => product?.cover == null
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
        const SizedBox(
          height: 3,
        ),
        getProductColorSize(),
        const SizedBox(
          height: 3,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getPriceWidget(),
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
            color: lightBlackFont,
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

  Widget getPriceWidget() {
    if (product?.variantModels?.isEmpty ?? false) {
      product?.variantModels = null;
    }
    final int productActualPrice =
        product?.getDiscountedPrice(product?.variantModels?.first) ?? 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[product?.currency]!,
          style: TextStyle(
            color: blackFont,
            fontFamily: "Inter",
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          moneyDisplayNormalizer(productActualPrice),
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.w500,
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
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: greyDarkBackground,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                messageDecoderWithEmoji(variantColor) ?? "",
                style: TextStyle(
                  fontSize: 10,
                  color: blackFont,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (variantColor.isNotEmpty && variantSize.isNotEmpty)
                Text(
                  "/",
                  style: TextStyle(
                    fontSize: 10,
                    color: blackFont,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w400,
                  ),
                ),
              Text(
                variantSize,
                style: TextStyle(
                  fontSize: 10,
                  color: blackFont,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w400,
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

class OrderTileForMultipleProductNew extends StatefulWidget {
  final List<OrderItem>? order;
  const OrderTileForMultipleProductNew({super.key, required this.order});

  @override
  State<OrderTileForMultipleProductNew> createState() =>
      _OrderTileForMultipleProductNewState();
}

class _OrderTileForMultipleProductNewState
    extends State<OrderTileForMultipleProductNew> {
  List<OrderItem>? orderItem;
  List<String> listOfUrls = [];

  @override
  void initState() {
    orderItem = widget.order;
    for (OrderItem order in orderItem ?? []) {
      if (order.item is Product) {
        final Product product = order.item;
        if (product.serverImages != null && product.serverImages!.isNotEmpty) {
          listOfUrls.add(product.serverImages!.first!);
        } else {
          print('Product has no server images');
        }
      } else if (order.item is Service) {
        final Service service = order.item;
        if (service.serverImages != null && service.serverImages!.isNotEmpty) {
          listOfUrls.add(service.serverImages!.first!);
        } else {
          print('Service has no server images');
        }
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: listOfUrls.map((String url) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    height: 70,
                    width: 70,
                    imageUrl: url,
                    colorBlendMode: BlendMode.darken,
                    fit: BoxFit.fill,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    filterQuality: FilterQuality.high,
                    placeholder: (context, url) => CircularProgressIndicator(),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    } catch (e) {
      return Container();
    }
  }
}

// ignore: must_be_immutable
class OrderTileForService extends StatefulWidget {
  Service? item;
  int? qty;

  OrderTileForService(OrderItem? order, {super.key}) {
    item = order?.item;
    qty = order?.qty;
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
