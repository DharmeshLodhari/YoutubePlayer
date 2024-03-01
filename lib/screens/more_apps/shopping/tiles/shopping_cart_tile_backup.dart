import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/basket_item_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class ShoppingCartTileForProduct extends StatefulWidget {
  Product? item;
  String? type;
  String? image;
  int? qty;
  int? index;
  Function? onIncreaseQty;
  Function? onDecreaseQty;
  Function(int variantIndex)? onIncreaseVariantQty;
  Function(int variantIndex)? onDecreaseVariantQty;
  Function? onIncreaseAddOnQty;
  Function? onDecreaseAddOnQty;

  Variant? variant;
  List? addOn;
  List<Map<String, dynamic>?> variantList = [];

  ShoppingCartTileForProduct(Map<String, dynamic> item,
      {this.onIncreaseQty,
      this.onDecreaseQty,
      this.index,
      this.onIncreaseVariantQty,
      this.onDecreaseVariantQty,
      this.onIncreaseAddOnQty,
      this.onDecreaseAddOnQty}) {
    type = item["type"];
    this.item = item["item"];
    qty = item["qty"];
    variant = item["variant"];
    addOn = item["addOn"];
    image = item["image"];
  }

  @override
  _ShoppingCartTileForProductState createState() =>
      _ShoppingCartTileForProductState();
}

class _ShoppingCartTileForProductState
    extends State<ShoppingCartTileForProduct> {
  late BasketBloc basketBloc;

  List<AddOnOption> addOnOptionList = [];

  @override
  void initState() {
    if (widget.addOn != null) {
      // debugPrint('add-on addOnOption:::: ${widget.addOn}');

      for (var item in widget.addOn!) {
        // debugPrint('add-on addOnOption 2:::: ${item['options']}');

        for (var option in item['options']) {
          AddOnOption addOnOption = AddOnOption(
            id: option['id'],
            picture: option['picture'],
            name: option['name'],
            description: option['description'],
            merchant: option['merchant'],
            currency: option['currency'],
            price: option['price'].toString(),
          );
          addOnOptionList.add(addOnOption);
        }
      }

      // debugPrint('add-on addOnOption 3:::: ${addOnOptionList}');

    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);

    try {
      // if (int.parse(getTotalPrice()) == 0) {
      //   return Container();
      // } else {
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
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: getLeading(),
                    title: getTitle(),
                    trailing: getTrailing(),
                    subtitle: getSubtitle(context),
                    onTap: () {
                      Navigator.pushNamed(context, Routes.PRODUCT,
                          arguments: {"product": widget.item});
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      // }
    } catch (e) {
      return Container();
    }
  }

  Widget getLeading() {
    String image = "";
    if (widget.addOn != null) {
      image = widget.item!.serverImages!.first!;
      // debugPrint('add-on image:::: ${widget.item!.serverImages}');
    } else if (widget.variant != null) {
      // image = widget.image!;
      image = widget.item!.serverImages!.first!;
    } else {
      image = widget.item?.cover ?? "";
    }

    return ClipOval(
      child: CachedNetworkImage(
        height: 48,
        width: 48,
        // imageUrl: widget.variant != null && widget.image!.isNotEmpty ? widget.image! : widget.item?.cover ?? defaultImage,
        imageUrl: image != "" ? image : defaultImage,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.contain,
        errorWidget: productAndServiceErrorWidget,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => widget.item?.cover == null
            ? Icon(Icons.widgets)
            : CircularLoadingIndicator(),
      ),
    );
  }

  Widget getTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          appendStringDot("${widget.item!.name}", 10),
          maxLines: 1,
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

  Widget getTrailing() {
    // Check if the item has a variant and is not empty

    int variantId = 0;
    int variantQuantity = 0;

    if (widget.variant != null) {
      String variant = widget.variant!.id.toString();

      if (variant.isNotEmpty) {
        variantId = int.parse(widget.variant!.id.toString());
        variantQuantity = int.parse(widget.variant!.quantity.toString());
      }
    }

    return Container(
      width: 110,
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
              // onTap: widget.variant == null ? widget.onDecreaseQty : () => widget.onDecreaseVariantQty!(variantId),
              onTap: widget.variant == null
                  ? widget.onDecreaseQty
                  : (widget.addOn != null
                      ? widget.onDecreaseQty
                      : () => widget.onDecreaseVariantQty!(variantId)),
            ),
            Expanded(
              child: SizedBox(
                width: 10,
              ),
            ),
            Text(
              widget.variant != null
                  ? variantQuantity.toString()
                  : widget.qty.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: blackFont,
                fontFamily: "Inter",
              ),
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
                size: 14, // Adjust the size as needed
              ),
              // onTap: widget.variant == null ? widget.onIncreaseQty : () => widget.onIncreaseVariantQty!(variantId),
              onTap: widget.variant == null
                  ? widget.onIncreaseQty
                  : (widget.addOn != null
                      ? widget.onIncreaseQty
                      : () => widget.onIncreaseVariantQty!(variantId)),
            ),
          ],
        ),
      ),
    );
  }

  String getProductPrice() {
    var totalPrice = widget.item!.price!;

    if (widget.variant != null) {
      totalPrice = 0;
      totalPrice = int.parse(widget.variant!.price.toString());
    }

    return totalPrice.toString();
  }

  String getTotalPrice() {
    var totalPrice =
        (basketBloc.basketItems[widget.index!].qty ?? 0) * widget.item!.price!;

    // Check if the item has a variant and is not empty
    if (widget.variant != null) {
      totalPrice = 0;
      totalPrice += int.parse(widget.variant!.quantity.toString()) *
          int.parse(widget.variant!.price.toString());
    }

    if (widget.addOn != null && widget.addOn!.isNotEmpty) {
      totalPrice = 0;
      totalPrice = (basketBloc.basketItems[widget.index!].qty ?? 0) *
          widget.item!.price!;

      var totalPrices = 0;

      for (var option in addOnOptionList) {
        totalPrices += int.parse(option.price!);
      }
      totalPrice = totalPrice + totalPrices;
    }

    return totalPrice.toString();
  }

  Widget getSubtitle(BuildContext context) {
    String color = '';
    String size = '';

    if (widget.variant != null) {
      String variantColor = widget.variant!.colour ?? '';
      String variantSize = widget.variant!.value ?? '';

      if (variantColor.isNotEmpty) {
        color = variantColor;
      }

      if (variantSize.isNotEmpty) {
        size = variantSize;
      }
    }
    List<String> names = [];

    if (widget.addOn != null) {
      for (var option in addOnOptionList) {
        names.add(option.name!);
      }
    }

    final concatenatedText = names.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 2,
        ),
        getSellerName(context),
        if (color.isNotEmpty) ...[
          SizedBox(
            height: 2,
          ),
          getColor(color),
        ],
        if (size.isNotEmpty) ...[
          SizedBox(
            height: 2,
          ),
          getSize(size)
        ],
        SizedBox(
          height: 2,
        ),
        getSubTotalPriceWidget(),
        if (widget.addOn != null && widget.addOn!.isNotEmpty) ...[
          Text(
            "Add-ons: $concatenatedText",
            maxLines: 3,
            style: TextStyle(
                fontSize: 12, color: darkGrey, fontWeight: FontWeight.w600),
          ),
        ],
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Subtotal",
              style: TextStyle(
                fontSize: 12,
                color: darkGrey,
                fontWeight: FontWeight.w500,
                fontFamily: "Inter",
              ),
            ),
            getTotalPriceWidget(),
          ],
        ),
        // getTotalPriceWidget(),
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
              fontFamily: "Inter",
              fontWeight: FontWeight.w500,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(int.parse(getTotalPrice())),
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w500,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget getSubTotalPriceWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[widget.item!.currency!]!,
          style: TextStyle(
              color: black,
              fontFamily: "Inter",
              fontWeight: FontWeight.w500,
              fontSize: 14),
        ),
        Text(
          // moneyDisplayNormalizer(int.parse(getProductPrice())),
          appendStringDot(
              moneyDisplayNormalizer(int.parse(getProductPrice())), 6),
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

  Widget getSellerName(BuildContext context) {
    return Text(
      widget.item!.seller!,
      style: TextStyle(
        fontSize: 12,
        color: darkGrey,
        fontWeight: FontWeight.w600,
        fontFamily: "Inter",
      ),
    );
  }

  Widget getColor(String color) {
    return Row(
      children: [
        // Text(
        //   "Color: ",
        //   style: TextStyle(fontSize: 10, color: darkGrey),
        // ),
        Text(
          color,
          style: TextStyle(
            fontSize: 12,
            color: black,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget getSize(String size) {
    return Row(
      children: [
        // Text(
        //   "Size: ",
        //   style: TextStyle(fontSize: 10, color: darkGrey),
        // ),
        Text(
          size,
          style: TextStyle(
            fontSize: 12,
            color: black,
            fontWeight: FontWeight.w500,
            fontFamily: "Inter",
          ),
        ),
      ],
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

  ShoppingCartTileForService(BasketItem item,
      {this.onDecreaseQty, this.onIncreaseQty, this.index}) {
    type = item.type;
    this.item = item.item as Service;
    qty = item.qty ?? 0;
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
      width: 110,
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
      widget.item!.provider!,
      style: TextStyle(fontSize: 10, color: darkGrey),
    );
  }
}
