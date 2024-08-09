import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/package_details_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PackageDetailTile extends StatelessWidget {
  PackageDetailTile(
      {super.key, required this.packageDetailsModel, required this.index});

  final PackageDetailsModel packageDetailsModel;
  final int index;
  late ShippingProcessBloc shippingProcessBloc;
  late UserBloc userBloc;
  late BasketBloc basketBloc;

  @override
  Widget build(BuildContext context) {
    shippingProcessBloc = Provider.of<ShippingProcessBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    product = basketItem?.item as Product?;
    try {
      return GestureDetector(
        onTap: () {
          shippingProcessBloc.currentSelectedIndex = index;
        },
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          shadowColor: boxShadowTwo,
          elevation: 0,
          child: Container(
            decoration: shippingProcessBloc.currentSelectedIndex == index &&
                    shippingProcessBloc.isPaymentSuccessful == false
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: navyBlue,
                      width: 1,
                    ),
                  )
                : decorateBox(),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              children: [
                _buildPackageDetail(context),
                const SizedBox(
                  height: 5.0,
                ),
                if (shippingProcessBloc.isPaymentSuccessful == false)
                  _buildShippingDetail(context),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      return Container();
    }
  }

  void _buildConfirmOrderDetailsBottomSheet(BuildContext context) async {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: Container(
            color: lightGrey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildOrderName()),
                      _buildCloseIcon(context),
                    ],
                  ),
                  _buildItemCount(),
                  _getConfirmOrderDetails(context),
                  // const SizedBox(height: 20),
                  // _buildTotal(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCloseIcon(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _getConfirmOrderDetails(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: getLeading(),
          title: getTitle(),
          subtitle: getSubtitle(context),
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
        ),
      ],
    );
  }

  Widget _buildItemCount() {
    return Text(
      "${packageDetailsModel.totalItems} Item",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: black,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildTotal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          softWrap: true,
          text: TextSpan(
            text: 'Total :',
            style: TextStyle(
              color: blackFont,
              fontSize: 16,
              fontFamily: "Inter",
            ),
            children: [
              const WidgetSpan(
                child: SizedBox(width: 10),
              ),
              TextSpan(
                text:
                    'Add ${worldCurrencies[product?.currency] ?? "NGN"}${_getFormattedPrice()}',
                style: TextStyle(
                  color: blackFont,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: "Inter",
                ),
              ),
            ],
          ),
        ),
        // Text("Total"),
        _buildSaveButton(),
      ],
    );
  }

  String _getFormattedPrice() {
    if (product?.variantModels != null &&
        (product?.variantModels?.isNotEmpty ?? false)) {
      return moneyDisplayNormalizer(
          int.parse(product?.variantModels?.first.price ?? "0"));
    } else {
      return moneyDisplayNormalizer(int.parse(getTotalPrice()));
    }
  }

  Widget _buildSaveButton() {
    return TextButton(
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 22),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(deepBlue),
      ),
      onPressed: () {},
      child: Text(
        "Save",
        style: TextStyle(
          color: white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget getLeading() {
    String? image;

    image = product?.cover;

    if (basketItem?.hasVariant ?? false) {
      image = basketItem?.variants?.first.getCoverImage() ?? product?.cover;
    }

    return isSharedCart == false
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CachedNetworkImage(
              height: 50,
              width: 50,
              imageUrl: image ?? defaultImage,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.contain,
              errorWidget: productAndServiceErrorWidget,
              filterQuality: FilterQuality.high,
              placeholder: (context, url) => product?.cover == null
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
                    placeholder: (context, url) => product?.cover == null
                        ? const Icon(Icons.widgets)
                        : CircularLoadingIndicator(),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: getMembersWidget(
                    userImages: product?.variantModels?.isNotEmpty == true
                        ? basketItem?.variants?.first
                            .convertToUserFollowersList()
                        : product?.convertToUserFollowersList()),
              )
            ],
          );
  }

  Widget getTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          messageDecoderWithEmoji(appendStringDot(product?.name ?? "", 12)) ??
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

  String getTotalPrice() {
    int totalPrice = 0;
    int addOnTotal = 0;
    if (product?.isProduct ?? false) {
      if (basketItem?.addOns != null) {
        for (AddOns itemAddOn in basketItem?.addOns ?? []) {
          for (var option in itemAddOn.options!) {
            addOnTotal += int.parse(option.price.toString()) * option.quantity;
          }
        }
        final int priceQuantity =
            (basketItem?.qty ?? 0) * (product?.getProductRealPrice() ?? 0);
        totalPrice += addOnTotal + priceQuantity;
      } else {
        totalPrice = (basketItem?.qty ?? 0) *
            (product?.getDiscountedPrice(basketItem?.variants?.first) ?? 0);
      }
    }

    return totalPrice.toString();
  }

  Widget getSubtitle(BuildContext context) {
    String color = '';
    String size = '';

    if (basketItem?.variants != null &&
        (basketItem?.variants?.isNotEmpty ?? false)) {
      final String variantColor = basketItem?.variants?.first.colour ?? '';
      final String variantSize = basketItem?.variants?.first.value ?? '';

      if (variantColor.isNotEmpty) {
        color = variantColor;
      }

      if (variantSize.isNotEmpty) {
        size = variantSize;
      }
    }

    final List<String> names = [];

    if (basketItem?.hasAddOns ?? false) {
      for (AddOns addOn in basketItem?.addOns ?? []) {
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
        if (color.isNotEmpty) getColor(color),
        if (size.isNotEmpty) getSize(size),
        getProductPriceWidget(),
        getProductLinePriceWidget(),
        if ((product?.discountedPrice != null &&
                product?.discountedPrice != 0) ||
            (product?.pricePercentageChange != null &&
                    product?.pricePercentageChange != 0.0 ||
                basketItem?.variants != null))
          _buildPricePercentageChanges(),
        if (concatenatedText.isNotEmpty) ...[
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
          worldCurrencies[product?.currency] ?? "",
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
          worldCurrencies[product?.currency] ?? "",
          style: TextStyle(
              color: blackFont,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              fontSize: 12),
        ),
        Text(
          moneyDisplayNormalizer(
              product?.getDiscountedPrice(basketItem?.variants?.first) ?? 0),
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
      product?.seller ?? "",
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
    if (basketItem?.variants?.first != null) {
      if ((product!.checkVariantDiscount(basketItem?.variants?.first))) {
        return Row(
          children: [
            Text(
              worldCurrencies[product?.currency] ?? "NGN",
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
                  int.parse(basketItem?.variants?.first.price ?? "0")),
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
    } else if (product?.checkProductDiscount() ?? false) {
      return Row(
        children: [
          Text(
            worldCurrencies[product?.currency] ?? "NGN",
            style: TextStyle(
              fontFamily: "Inter",
              fontWeight: FontWeight.w400,
              fontSize: 12.8,
              color: black,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            moneyDisplayNormalizer(product?.price),
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
    if (basketItem?.variants != null) {
      if (product!.checkVariantDiscount(basketItem?.variants?.first)) {
        return Text(
          "-${basketItem?.variants?.first.discountType == "percentage" ? "${basketItem?.variants?.first.discountValue}% off" : worldCurrencies[basketItem?.variants?.first.currency ?? ""]! + moneyDisplayNormalizer(basketItem?.variants?.first.discountValue?.toInt()).toString()}",
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
    } else if (product?.discountedPrice != null &&
        product?.discountedPrice != 0) {
      if (product?.checkProductDiscount() ?? false) {
        return Text(
          "-${product?.discountType == "percentage" ? "${product?.discountValue}% off" : worldCurrencies[product?.currency ?? ""]! + moneyDisplayNormalizer(product?.discountValue?.toInt()).toString()}",
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
    } else if (product?.pricePercentageChange != 0.0) {
      return Text(
        "${product?.pricePercentageChange!.toInt()}% off",
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

  List getShoppingCartItemByAddressId(String addressId) {
    final cartItems = [];
    for (var item in basketBloc.basketItems) {
      if (item.item?.isProduct ?? false) {
        if ((item.item as Product).addressId == addressId) {
          cartItems.add(item);
        }
      } else {
        // if((item.item as Service).addressId == addressId) {
        //   cartItems.add(item);
        // }
      }
    }
    return cartItems;
  }

  // List getShoppingCartItemByAddressId(String addressId) {
  //   var cartItems = [];
  //   for (var item in basketBloc.basketItems) {
  //     if (item.item?.isProduct ?? false) {
  //       if ((item.item as Product).addressId == addressId) {
  //         cartItems.add(item);
  //       }
  //     } else {
  //       // if((item.item as Service).addressId == addressId) {
  //       //   cartItems.add(item);
  //       // }
  //     }
  //   }
  //   return cartItems;
  // }

  Widget _buildPackageDetail(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // getShoppingCartItemByAddressId("AD-I44QNOKY8EUF9MHU");
      },
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: _buildImage(),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              packageDetailsModel.merchant ?? "",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: black,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
        subtitle: Text(
          "Package ${index + 1} (${packageDetailsModel.totalItems} item)",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: black,
            fontFamily: "Inter",
          ),
        ),
        trailing: SizedBox(
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (shippingProcessBloc
                      .packagesList[index].isShippingProcessCompleted ==
                  true)
                Checkbox(
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  checkColor: Colors.white,
                  activeColor: navyBlue,
                  value: true,
                  shape: const CircleBorder(),
                  onChanged: (bool? value) {},
                ),
              Row(
                children: [
                  Text(
                    "${worldCurrencies[userBloc.user.currency]}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: black,
                      fontFamily: "Inter",
                    ),
                  ),
                  Text(
                    moneyDisplayNormalizer(packageDetailsModel.totalPrice ?? 0),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: black,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    return GestureDetector(
      onTap: () {
        // getShoppingCartItemByAddressId(packageDetailsModel.addressId ?? "");
        _buildConfirmOrderDetailsBottomSheet(context);
      },
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: _buildImage(),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              packageDetailsModel.merchant ?? "",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: black,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
        subtitle: Text(
          "Package 1 (${packageDetailsModel.totalItems} item)",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: black,
            fontFamily: "Inter",
          ),
        ),
        trailing: SizedBox(
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (shippingProcessBloc
                      .packagesList[index].isShippingProcessCompleted ==
                  true)
                Checkbox(
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  checkColor: Colors.white,
                  activeColor: navyBlue,
                  value: true,
                  shape: const CircleBorder(),
                  onChanged: (bool? value) {},
                ),
              Row(
                children: [
                  Text(
                    "${worldCurrencies[userBloc.user.currency]}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: black,
                      fontFamily: "Inter",
                    ),
                  ),
                  Text(
                    moneyDisplayNormalizer(packageDetailsModel.totalPrice ?? 0),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: black,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderName() {
    return Text(
      packageDetailsModel.merchant ?? "",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: black,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildShippingDetail(BuildContext context) {
    Widget child;

    if (shippingProcessBloc.packagesList[index].isShippingProcessCompleted ==
        false) {
      child = Text(
        "Select delivery option",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: navyBlue,
          fontFamily: "Inter",
        ),
      );
    } else {
      switch (packageDetailsModel.deliveryOption!) {
        case DeliveryOptions.shipping:
          child = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Shipping: ",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: black,
                      fontFamily: "Inter",
                    ),
                  ),
                  Text(
                    "${worldCurrencies[shippingProcessBloc.packagesList[index].shippingOption?.currency]}${moneyDisplayNormalizer(shippingProcessBloc.packagesList[index].shippingOption?.price)}",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: black,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                shippingProcessBloc.packagesList[index].getDeliveryTime() ?? "",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: darkGrey,
                  fontFamily: "Inter",
                ),
              ),
              //
            ],
          );
          break;
        case DeliveryOptions.eatIn:
          child = Text(
            "In Store/Eat In",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: blackFont,
              fontFamily: "Inter",
            ),
          );
          break;
        case DeliveryOptions.pickUp:
          child = Text(
            "PickUp",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: blackFont,
              fontFamily: "Inter",
            ),
          );
          break;
      }
    }

    return GestureDetector(
      onTap: () {
        shippingProcessBloc.currentSelectedIndex = index;
        shippingProcessBloc.isUseCartProcess(true);
        Navigator.of(context).pushNamed(Routes.DELIVERY_OPTION);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: child),
          const Padding(
            padding: EdgeInsets.only(right: 7.0),
            child: Icon(
              Icons.keyboard_arrow_right_outlined,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (packageDetailsModel.deliveryOption == null) {
      return Image.asset(
        "assets/images/package.png",
        width: 48,
      );
    }
    switch (packageDetailsModel.deliveryOption!) {
      case DeliveryOptions.shipping:
        return Image.asset(
          "assets/images/package.png",
          width: 48,
        );
      case DeliveryOptions.eatIn:
        return Image.asset(
          "assets/images/eatin_logo.png",
          fit: BoxFit.fill,
        );
      case DeliveryOptions.pickUp:
        return Image.asset(
          "assets/images/pickup_logo.png",
          fit: BoxFit.fill,
        );
    }
  }

  Widget _buildImageDelivery() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: CachedNetworkImage(
        height: 50,
        width: 50,
        imageUrl:
            shippingProcessBloc.packagesList.first.variants?.getCoverImage() ??
                defaultImage,
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

  Widget _buildDeliveryTitle() {
    return Text(
      "DHL",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: black,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      "Delivery Time 2-3 days",
      style: TextStyle(
        fontSize: 14,
        color: black,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildPriceWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          " ${worldCurrencies[product?.currency] ?? ""}${shippingProcessBloc.packagesList.first.variants?.price ?? "0"}",
          style: TextStyle(
            fontSize: 14,
            color: black,
            fontFamily: "Inter",
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: greyBorderColor,
          ),
          child: Text(
            "No Tracking activity",
            style: TextStyle(
              color: black,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
            ),
          ),
        ),
      ],
    );
  }
}
