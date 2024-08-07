import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/basket_item_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/utils.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class ShoppingCartTileForProduct extends StatelessWidget {
  late Product product;

  late BasketItem basketItem;

  final Function() onIncreaseQty;
  final Function() onDecreaseQty;
  final bool isSharedCart;
  List<UserFollowers>? membersDetails;

  ShoppingCartTileForProduct({
    super.key,
    required this.basketItem,
    required this.onIncreaseQty,
    required this.onDecreaseQty,
    required this.isSharedCart,
  });

  @override
  Widget build(BuildContext context) {
    product = basketItem.item as Product;
    try {
      return Container(
        color: Colors.white,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 5),
          shadowColor: boxShadowTwo,
          elevation: 0,
          child: Container(
            decoration: decorateBox(),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: getLeading(),
                  title: getTitle(),
                  subtitle: getSubtitle(context),
                  trailing: getTrailing(),
                  onTap: () {
                    Navigator.pushNamed(context, Routes.PRODUCT,
                        arguments: {"product": product});
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    Text(
                      "Subtotal",
                      style: TextStyle(
                        fontSize: 12,
                        color: darkGrey,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Inter",
                      ),
                    ),
                    const SizedBox(width: 60),
                    getSubTotalPriceWidget(),
                  ],
                )
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
    String? image;

    image = product.cover;

    if (basketItem.hasVariant) {
      image = basketItem.variants?.first.getCoverImage() ?? product.cover;
    }

    return isSharedCart == false
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CachedNetworkImage(
              height: 48,
              width: 48,
              imageUrl: image ?? defaultImage,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.contain,
              errorWidget: productAndServiceErrorWidget,
              filterQuality: FilterQuality.high,
              placeholder: (context, url) => product.cover == null
                  ? const Icon(Icons.widgets)
                  : CircularLoadingIndicator(),
            ),
          )
        : Stack(
            children: [
              Container(
                height: 100,
                padding: const EdgeInsets.only(top: 10, right: 25),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CachedNetworkImage(
                    height: 50,
                    width: 50,
                    // imageUrl: widget.variant != null && widget.image!.isNotEmpty ? widget.image! : widget.item?.cover ?? defaultImage,
                    imageUrl: image ?? defaultImage,
                    colorBlendMode: BlendMode.darken,
                    fit: BoxFit.contain,
                    errorWidget: productAndServiceErrorWidget,
                    filterQuality: FilterQuality.high,
                    placeholder: (context, url) => product.cover == null
                        ? const Icon(Icons.widgets)
                        : CircularLoadingIndicator(),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: getMembersWidget(
                    userImages: product.variantModels?.isNotEmpty == true
                        ? basketItem.variants?.first
                            .convertToUserFollowersList()
                        : product.convertToUserFollowersList()),
              )
            ],
          );
  }

  Widget getTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          messageDecoderWithEmoji(appendStringDot(product.name ?? "", 12)) ??
              "",
          maxLines: 1,
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget getTrailing() {
    return Container(
      width: 110,
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RoundedBackgroundIcon(
            backgroundColor: iconBtnGrey,
            icon: Icon(
              SlydoAppIcon.minus,
              color: blackFont,
              size: 2,
            ),
            onTap: onDecreaseQty,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            basketItem.getQty().toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: blackFont,
              fontFamily: "Inter",
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          RoundedBackgroundIcon(
            backgroundColor: iconBtnGrey,
            icon: Icon(
              SlydoAppIcon.plus,
              color: blackFont,
              size: 14, // Adjust the size as needed
            ),
            onTap: onIncreaseQty,
          ),
        ],
      ),
    );
  }

  String getTotalPrice() {
    int totalPrice = 0;
    int addOnTotal = 0;
    if (product.isProduct) {
      if (basketItem.addOns != null) {
        for (AddOns itemAddOn in basketItem.addOns ?? []) {
          for (var option in itemAddOn.options!) {
            addOnTotal += int.parse(option.price.toString()) * option.quantity;
          }
        }
        final int priceQuantity =
            (basketItem.qty ?? 0) * product.getProductRealPrice();
        totalPrice += addOnTotal + priceQuantity;
      } else {
        totalPrice = (basketItem.qty ?? 0) *
            (product.getDiscountedPrice(basketItem.variants?.first) ?? 0);
      }
    }

    return totalPrice.toString();
  }

  Widget getSubtitle(BuildContext context) {
    String color = '';
    String size = '';

    if (basketItem.variants?.first != null) {
      final String variantColor = basketItem.variants?.first.colour ?? '';
      final String variantSize = basketItem.variants?.first.value ?? '';

      if (variantColor.isNotEmpty) {
        color = variantColor;
      }

      if (variantSize.isNotEmpty) {
        size = variantSize;
      }
    }
    final List<String> names = [];

    if (basketItem.hasAddOns) {
      for (AddOns addOn in basketItem.addOns ?? []) {
        final List<String>? optionName =
            addOn.options?.map((e) => e.name ?? "").toList();
        names.addAll(optionName ?? []);
      }
    }

    final concatenatedText = names.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        getSellerName(context),
        if (color.isNotEmpty) ...[
          const SizedBox(
            height: 2,
          ),
          getColor(color),
        ],
        if (size.isNotEmpty) ...[
          const SizedBox(
            height: 2,
          ),
          getSize(size)
        ],
        const SizedBox(
          height: 2,
        ),
        getProductPriceWidget(),
        const SizedBox(
          height: 2,
        ),
        getProductLinePriceWidget(),
        const SizedBox(
          height: 2,
        ),
        if ((product.discountedPrice != null && product.discountedPrice != 0) ||
            (product.pricePercentageChange != null &&
                    product.pricePercentageChange != 0.0 ||
                basketItem.variants != null))
          _buildPricePercentageChanges(),
        const SizedBox(
          height: 2,
        ),
        if (concatenatedText != "") ...[
          Text(
            "Adds-ons : $concatenatedText",
            maxLines: 3,
            style: TextStyle(
                fontSize: 10,
                color: blackFont,
                fontWeight: FontWeight.w400,
                fontFamily: "Inter"),
          ),
        ],
      ],
    );
  }

  Widget getSubTotalPriceWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[product.currency]!,
          style: TextStyle(
              color: blackFont,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(int.parse(getTotalPrice())),
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

  Widget getProductPriceWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[product.currency!]!,
          style: TextStyle(
              color: blackFont,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              fontSize: 12),
        ),
        Text(
          moneyDisplayNormalizer(
              product.getDiscountedPrice(basketItem.variants?.first) ?? 0),
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget getSellerName(BuildContext context) {
    return Text(
      product.seller!,
      style: TextStyle(
        fontSize: 12,
        color: darkGrey,
        fontWeight: FontWeight.w500,
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
          "Color : $color",
          style: TextStyle(
            fontSize: 10,
            color: blackFont,
            fontWeight: FontWeight.w400,
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
          "Size : ${messageDecoderWithEmoji(size)}",
          style: TextStyle(
            fontSize: 10,
            color: blackFont,
            fontWeight: FontWeight.w400,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget getProductLinePriceWidget() {
    if (basketItem.variants?.isNotEmpty ?? false) {
      if ((product.checkVariantDiscount(basketItem.variants?.first))) {
        return Row(
          children: [
            Text(
              worldCurrencies[product.currency] ?? "NGN",
              style: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: black,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            Text(
              moneyDisplayNormalizer(
                  int.parse(basketItem.variants?.first.price ?? "0")),
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: black,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    } else if (product.checkProductDiscount()) {
      return Row(
        children: [
          Text(
            worldCurrencies[product.currency] ?? "NGN",
            style: TextStyle(
              fontFamily: "Inter",
              fontWeight: FontWeight.w400,
              fontSize: 12.8,
              color: black,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            moneyDisplayNormalizer(product.price),
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: black,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildPricePercentageChanges() {
    if (basketItem.variants?.isNotEmpty ?? false) {
      if (product.checkVariantDiscount(basketItem.variants?.first)) {
        return Text(
          "-${basketItem.variants?.first.discountType == "percentage" ? "${basketItem.variants?.first.discountValue}% off" : worldCurrencies[basketItem.variants?.first.currency ?? ""]! + moneyDisplayNormalizer(basketItem.variants?.first.discountValue?.toInt()).toString()}",
          style: TextStyle(
            color: naturalGreen,
            fontSize: 11,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        );
      } else {
        return const SizedBox();
      }
    } else if (product.discountedPrice != null &&
        product.discountedPrice != 0) {
      if (product.checkProductDiscount()) {
        return Text(
          "-${product.discountType == "percentage" ? "${product.discountValue}% off" : worldCurrencies[product.currency ?? ""]! + moneyDisplayNormalizer(product.discountValue?.toInt()).toString()}",
          style: TextStyle(
            color: naturalGreen,
            fontSize: 11,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        );
      } else {
        return const SizedBox();
      }
    } else if (product.pricePercentageChange != 0.0) {
      return Text(
        "${product.pricePercentageChange!.toInt()}% off",
        style: TextStyle(
          color: naturalGreen,
          fontSize: 11,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      return const SizedBox();
    }
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
      {super.key, this.onDecreaseQty, this.onIncreaseQty, this.index}) {
    type = item.type;
    this.item = item.item as Service;
    qty = item.qty ?? 0;
  }

  @override
  State<ShoppingCartTileForService> createState() =>
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
              ? const Icon(Icons.widgets)
              : CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  backgroundColor: navyBlue,
                ),
        ),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      messageDecoderWithEmoji(widget.item?.name) ?? "",
      maxLines: 1,
      style: TextStyle(
          color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget getTrailing() {
    final int? qty = basketBloc.items[widget.index!]["qty"] != 0
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
            const Expanded(
              child: SizedBox(
                width: 10,
              ),
            ),
            Text(
              qty.toString(),
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: blackFont),
            ),
            const Expanded(
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
      return "${widget.item!.price.toString().substring(0, 5)}..";
    }
    return widget.item!.price.toString();
  }

  String getTotalPrice() {
    final price =
        basketBloc.items[widget.index!]["qty"] * int.parse(widget.item!.price!);
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
