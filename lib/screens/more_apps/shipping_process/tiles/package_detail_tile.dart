import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/package_details_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/basket_item_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/utils.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class PackageDetailTile extends StatelessWidget {
  PackageDetailTile({
    super.key,
    required this.packageDetailsModel,
    required this.index,
    this.basketItem,
    this.product,
    this.onIncreaseQty,
    this.onDecreaseQty,
    this.isSharedCart,
  });

  final PackageDetailsModel packageDetailsModel;
  final int index;
  late ShippingProcessBloc shippingProcessBloc;
  late UserBloc userBloc;
  late BasketBloc basketBloc;
  late BasketItem? basketItem;
  late Product? product;
  final Function()? onIncreaseQty;
  final Function()? onDecreaseQty;
  final bool? isSharedCart;
  String noteDetails = "";

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
            // decoration: decorateBox(),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: GestureDetector(
              onTap: () {
                // if (shippingProcessBloc
                //         .packagesList[index].isShippingProcessCompleted ==
                //     true) {
                _buildConfirmOrderDetailsBottomSheet(context);
                // }
              },
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
                  const SizedBox(height: 20),
                  _buildDeliveryBy(),
                  const SizedBox(height: 10),
                  _buildNotes(context),
                  const SizedBox(height: 10),
                  _buildTotal(),
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

  Widget _buildDeliveryBy() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Delivery By",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: black,
                fontFamily: "Inter",
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: black,
              size: 15,
            )
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 110,
          padding: const EdgeInsets.only(bottom: 5, left: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 0.2,
                offset: const Offset(0, 0.5), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: _buildImageDelivery(),
                title: _buildDeliveryTitle(),
                subtitle: _buildDescription(),
                trailing: _buildPriceWidget(),
              ),
              Text(
                "Delivery Time 2-3 days",
                style: TextStyle(
                  fontSize: 14,
                  color: black,
                  fontFamily: "Inter",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotes(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalization.of(context)?.note ?? "",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: blackFont,
                fontFamily: "Inter",
              ),
            ),
            // if (userBloc.user.userName != order?.merchant)
            GestureDetector(
              onTap: () {
                showEditNoteDialog(context);
              },
              child: SvgPicture.asset(
                'edit_icon'.toSVG(),
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 100,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: darkGrey.withOpacity(
                    .4,
                  ),
                  width: .5)),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    getOrderNote(context),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: blackFont,
                      fontFamily: "Inter",
                    ),
                    maxLines: 5,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String getOrderNote(BuildContext context) {
    if (shippingProcessBloc.packagesList.first.note == "") {
      return "${AppLocalization.of(context)?.noSpecialNoteAttached} !!";
    }
    return shippingProcessBloc.packagesList.first.note ?? "";
  }

  Future<void> showEditNoteDialog(BuildContext context) async {
    final result = await showDialogBoxWithInput(
        context: context,
        actionOneTextColor: blackFont,
        actionOneBgColor: greyBorderColor,
        actionTwoTextColor: white,
        actionTwoBgColor: navyBlue,
        actionOneText: AppLocalization.of(context)!.cancel,
        actionTwoText: AppLocalization.of(context)!.save,
        firstActionPrimary: false,
        content: Column(
          children: [
            Text("Edit Note",
                style: TextStyle(
                  color: blackFont,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  fontFamily: "Inter",
                ),
                textAlign: TextAlign.center),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: CustomizedTextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                labelText: 'Note',
                onChanged: (val) {
                  noteDetails = val;
                },
              ),
            ),
          ],
        ),
        leftButtonOnPressed: () async {
          Navigator.pop(context);
          return;
        },
        rightButtonOnPressed: () async {
          addNote(context);
          return;
        });
    if (result != null && result == true) {
      Navigator.of(context).pop(true);
    }
  }

  void addNote(BuildContext context) async {
    shippingProcessBloc.packagesList.first.note = noteDetails;
    Navigator.pop(context);
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

  Widget getTrailing() {
    return Container(
      width: 100,
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
            "${basketItem?.getQty()}",
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

  Widget _buildPackageDetail(BuildContext context) {
    return ListTile(
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
