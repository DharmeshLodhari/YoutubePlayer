import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/variant_overlay.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/colors.dart';

// ignore: must_be_immutable
class ShoppingCartTileForProduct extends StatefulWidget {
  Product? item;
  String? type;
  int? qty;
  int? index;
  Function? onIncreaseQty;
  Function? onDecreaseQty;
  Function(int variantIndex)? onIncreaseVariantQty;
  Function(int variantIndex)? onDecreaseVariantQty;
  List<Map<String, dynamic>>? variant;

  ShoppingCartTileForProduct(Map<String, dynamic> item,
      {this.onIncreaseQty, this.onDecreaseQty, this.index,
        this.onIncreaseVariantQty, this.onDecreaseVariantQty}) {
    type = item["type"];
    this.item = item["item"];
    qty = item["qty"];
    variant = item["variant"];
  }

  @override
  _ShoppingCartTileForProductState createState() =>
      _ShoppingCartTileForProductState();
}

class _ShoppingCartTileForProductState
    extends State<ShoppingCartTileForProduct> {
  late BasketBloc basketBloc;

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
          shadowColor: boxShadowTwo,
          elevation: 0,
          child: Container(
            decoration: decorateBox(),
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

                      bool hasVariantId = widget.variant?.any((item) => item['id'] != null && item['id'].isNotEmpty) ?? false;

                      if(hasVariantId){
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Opacity(
                              opacity: 0.9, // Set the opacity level for the background (semi-transparent)
                              child: FractionallySizedBox(
                                // widthFactor: 0.75,
                                heightFactor: 0.60,
                                child: VariantOverlay(
                                  variant: widget.variant,
                                  currency: widget.item!.currency!,
                                  onClose: () {
                                    Navigator.of(context).pop(); // Close the overlay
                                  },
                                  onAdd: (val){
                                    onAddVariant(val);
                                    if(mounted)setState(() {});
                                    },
                                  onSubtract: (val){
                                    onSubtractVariant(val);
                                    if(mounted)setState(() {});
                                    },
                                ),
                              ),
                            );
                          },
                        );

                      }else{
                        Navigator.pushNamed(context, Routes.PRODUCT,
                            arguments: {"product": widget.item});
                      }


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

  void onAddVariant(int variantIndex) {
    widget.onIncreaseVariantQty!(variantIndex);
  }

  void onSubtractVariant(int variantIndex) {
    widget.onDecreaseVariantQty!(variantIndex);
  }

  Widget getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        height: 48,
        width: 48,
        imageUrl: widget.item?.cover ?? defaultImage,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        errorWidget: productAndServiceErrorWidget,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => widget.item?.cover == null
            ? Icon(Icons.widgets)
            : CircularLoadingIndicator(),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      "${widget.item!.name}",
      maxLines: 1,
      style: TextStyle(
          color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget getTrailing() {
    //check if item has variant with id or not
    bool hasVariantId = widget.variant?.any((item) => item['id'] != null && item['id'].isNotEmpty) ?? false;

    return Container(
      width: 100,
      color: Colors.transparent,
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            hasVariantId == false ? RoundedBackgroundIcon(
                backgroundColor: iconBtnGrey,
                icon: Icon(
                  SlydoAppIcon.minus,
                  color: blackFont,
                  size: 2,
                ),
                onTap: widget.onDecreaseQty) : const SizedBox.shrink(),
            Expanded(
              child: SizedBox(
                width: 10,
              ),
            ),
            Text(
              basketBloc.items[widget.index!]["qty"].toString(),
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: blackFont),
            ),
            Expanded(
              child: SizedBox(
                width: 10,
              ),
            ),
            hasVariantId == false ?RoundedBackgroundIcon(
                backgroundColor: iconBtnGrey,
                icon: Icon(
                  SlydoAppIcon.plus,
                  color: blackFont,
                  size: 16,
                ),
                onTap: widget.onIncreaseQty) : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  String getProductPrice() {
    if (widget.item!.price.toString().length > 5) {
      return widget.item!.price.toString().substring(0, 5) + "..";
    }
    return widget.item!.price.toString();
  }


  String getTotalPrice() {
    var totalPrice =
        basketBloc.items[widget.index!]["qty"] * int.parse(widget.item!.price!);

    bool hasVariantId = widget.variant?.any((item) => item['id'] != null && item['id'].isNotEmpty) ?? false;

    if(hasVariantId && widget.variant != null && widget.variant!.isNotEmpty){

      totalPrice = 0;
      widget.variant?.forEach((variant) {

        totalPrice += int.parse(variant['quantity'].toString()) * int.parse(variant['current_price'].toString());
      });
    }

    return totalPrice.toString();
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
          worldCurrencies[widget.item!.currency!]!,
          style: TextStyle(
              color: blackFont,
              fontFamily: "Roboto",
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
      widget.item!.seller!,
      style: TextStyle(fontSize: 10, color: darkGrey),
    );
  }
}

// ignore: must_be_immutable
class ShoppingCartTileForService extends StatefulWidget {
  Service? item;
  String? type;
  int? qty;
  int? index;
  Function? onIncreaseQty;
  Function? onDecreaseQty;

  ShoppingCartTileForService(Map<String, dynamic> item,
      {this.onDecreaseQty, this.onIncreaseQty, this.index}) {
    type = item["type"];
    this.item = item["item"];
    qty = item["qty"] ?? 0;
  }

  @override
  _ShoppingCartTileForServiceState createState() =>
      _ShoppingCartTileForServiceState();
}

class _ShoppingCartTileForServiceState
    extends State<ShoppingCartTileForService> {
  late BasketBloc basketBloc;

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
          shadowColor: boxShadowTwo,
          elevation: 0,
          child: Container(
            decoration: decorateBox(),
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
                      Navigator.pushNamed(context, Routes.SERVICE_DETAIL,
                          arguments: {"service": widget.item});
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
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.PHOTO_VIEWER, arguments: widget.item?.cover);
      },
      child: ClipOval(
        child: CachedNetworkImage(
          height: 48,
          width: 48,
          imageUrl: widget.item?.cover ?? defaultImage,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.cover,
          errorWidget: productAndServiceErrorWidget,
          filterQuality: FilterQuality.high,
          placeholder: (context, url) => widget.item?.cover == null
              ? Icon(Icons.widgets)
              : CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  backgroundColor: navyBlue,
                ),
        ),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      "${widget.item!.name}",
      maxLines: 1,
      style: TextStyle(
          color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget getTrailing() {
    int? qty = basketBloc.items[widget.index!]["qty"] != 0
        ? basketBloc.items[widget.index!]["qty"]
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
    if (widget.item!.price.toString().length > 5) {
      return widget.item!.price.toString().substring(0, 5) + "..";
    }
    return widget.item!.price.toString();
  }

  String getTotalPrice() {
    var price =
        basketBloc.items[widget.index!]["qty"] * int.parse(widget.item!.price!);
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
          worldCurrencies[widget.item!.currency!]!,
          style: TextStyle(
              color: blackFont,
              fontFamily: "Roboto",
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
      widget.item!.provider!,
      style: TextStyle(fontSize: 10, color: darkGrey),
    );
  }
}
