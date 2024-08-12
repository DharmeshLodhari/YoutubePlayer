import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/package_details_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PackageDetailTile extends StatelessWidget {
  PackageDetailTile({
    super.key,
    required this.packageDetailsModel,
    required this.index,
    this.isSharedCart,
  });

  final PackageDetailsModel packageDetailsModel;
  final int index;
  late ShippingProcessBloc shippingProcessBloc;
  late UserBloc userBloc;
  final bool? isSharedCart;
  List<Product> productList = [];
  bool listEmpty = false;
  bool productListLoading = false;
  String? productNext = "";
  String? productPrevious = "";
  int? productCount = 0;

  @override
  Widget build(BuildContext context) {
    shippingProcessBloc = Provider.of<ShippingProcessBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
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
    return Expanded(
      child: ListView.builder(
          itemCount: productList.length,
          itemBuilder: (context, index) {
            return Column(children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: getLeading(index),
                title: getTitle(index),
                subtitle: getSubtitle(context, index),
                onTap: () {
                  Navigator.pushNamed(context, Routes.PRODUCT,
                      arguments: {"product": productList[index]});
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
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
                    getSubTotalPriceWidget(index),
                  ],
                ),
              ),
            ]);
          }),
    );
  }

  Widget _buildItemCount() {
    return Text(
      "${getItemCount()} Item",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: black,
        fontFamily: "Inter",
      ),
    );
  }

  Widget getLeading(int index) {
    String? image;

    image = productList[index].cover;

    if (productList[index].variantModels?.isNotEmpty ?? false) {
      image = productList[index].variantModels?.first.getCoverImage() ??
          productList[index].cover;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: CachedNetworkImage(
        height: 50,
        width: 50,
        imageUrl: image ?? defaultImage,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.contain,
        errorWidget: productAndServiceErrorWidget,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => productList[index].cover == null
            ? const Icon(Icons.widgets)
            : CircularLoadingIndicator(),
      ),
    );
  }

  Widget getTitle(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          messageDecoderWithEmoji(
                  appendStringDot(productList[index].name ?? "", 12)) ??
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

  String getTotalPrice(int index) {
    int totalPrice = 0;
    int addOnTotal = 0;
    if (productList[index].isProduct) {
      if (productList[index].addOnsModels != null) {
        for (AddOns itemAddOn in productList[index].addOnsModels ?? []) {
          for (var option in itemAddOn.options!) {
            addOnTotal += int.parse(option.price.toString()) * option.quantity;
          }
        }
        final int priceQuantity = (productList[index].quantity ?? 0) *
            getProductPrice(productList[index]);
        totalPrice += addOnTotal + priceQuantity;
      } else if (productList[index].variantModels != null) {
        totalPrice = (productList[index].variantModels?.first.quantity ?? 0) *
            (getProductDiscountPrice(productList[index]) ?? 0);
      } else {
        totalPrice = (productList[index].quantity ?? 0) *
            (getProductDiscountPrice(productList[index]) ?? 0);
      }
    }

    return totalPrice.toString();
  }

  Widget getSubtitle(BuildContext context, int index) {
    String color = '';
    String size = '';

    if (productList[index].variantModels?.isNotEmpty ?? false) {
      final String variantColor =
          productList[index].variantModels?.first.colour ?? '';
      final String variantSize =
          productList[index].variantModels?.first.value ?? '';

      if (variantColor.isNotEmpty) {
        color = variantColor;
      }

      if (variantSize.isNotEmpty) {
        size = variantSize;
      }
    }
    final List<String> names = [];

    if (productList[index].addOnsModels?.isNotEmpty ?? false) {
      for (AddOns addOn in productList[index].addOnsModels ?? []) {
        final List<String>? optionName =
            addOn.options?.map((e) => e.name ?? "").toList();
        names.addAll(optionName ?? []);
      }
    }

    final concatenatedText = names.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        getSellerName(context, index),
        if (color.isNotEmpty) getColor(color, index),
        if (size.isNotEmpty) getSize(size, index),
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
        getProductPriceWidget(index),
        getProductLinePriceWidget(index),
        if ((productList[index].discountedPrice != null &&
                productList[index].discountedPrice != 0) ||
            (productList[index].pricePercentageChange != null &&
                    productList[index].pricePercentageChange != 0.0 ||
                productList[index].variantModels != null))
          _buildPricePercentageChanges(index),
      ],
    );
  }

  Widget getSubTotalPriceWidget(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[productList[index].currency] ?? "",
          style: TextStyle(
              color: blackFont,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(int.parse(getTotalPrice(index))),
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

  Widget getProductPriceWidget(int index) {
    final currency = worldCurrencies[productList[index].currency] ?? "";
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "$currency${moneyDisplayNormalizer(getProductDiscountPrice(productList[index]) ?? 0)}",
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            fontFamily: "Inter",
          ),
        ),
        Text(
          " * ${getProductCount(productList[index])}",
          style: TextStyle(
              color: blackFont,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              fontSize: 12),
        ),
      ],
    );
  }

  Widget getSellerName(BuildContext context, int index) {
    return Text(
      productList[index].seller ?? "",
      style: TextStyle(
        fontSize: 12,
        color: darkGrey,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Widget getColor(String color, int index) {
    return Row(
      children: [
        Text(
          "Color : ${messageDecoderWithEmoji(color)}",
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

  Widget getSize(String size, int index) {
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

  Widget getProductLinePriceWidget(int index) {
    if (productList[index].variantModels?.isNotEmpty ?? false) {
      if (checkProductVariantDiscount(
          productList[index].variantModels?.first)) {
        return Row(
          children: [
            Text(
              worldCurrencies[productList[index].currency] ?? "NGN",
              style: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: black,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            Text(
              moneyDisplayNormalizer(int.parse(
                  productList[index].variantModels?.first.price ?? "0")),
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
    } else if (checkProductDiscountOrNot(productList[index])) {
      return Row(
        children: [
          Text(
            worldCurrencies[productList[index].currency] ?? "NGN",
            style: TextStyle(
              fontFamily: "Inter",
              fontWeight: FontWeight.w400,
              fontSize: 12.8,
              color: black,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            moneyDisplayNormalizer(productList[index].price),
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

  Widget _buildPricePercentageChanges(int index) {
    if (productList[index].variantModels?.isNotEmpty ?? false) {
      if (checkProductVariantDiscount(
          productList[index].variantModels?.first)) {
        return Text(
          "-${productList[index].variantModels?.first.discountType == "percentage" ? "${productList[index].variantModels?.first.discountValue}% off" : worldCurrencies[productList[index].variantModels?.first.currency ?? ""]! + moneyDisplayNormalizer(productList[index].variantModels?.first.discountValue?.toInt()).toString()}",
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
    } else if (productList[index].discountedPrice != null &&
        productList[index].discountedPrice != 0) {
      if (checkProductDiscountOrNot(productList[index])) {
        return Text(
          "-${productList[index].discountType == "percentage" ? "${productList[index].discountValue}% off" : worldCurrencies[productList[index].currency ?? ""]! + moneyDisplayNormalizer(productList[index].discountValue?.toInt()).toString()}",
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
    } else if (productList[index].pricePercentageChange != 0.0) {
      return Text(
        "${productList[index].pricePercentageChange!.toInt()}% off",
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
    return GestureDetector(
      onTap: () async {
        await getSuperStoreDealProducts();
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
            color: Colors.white,
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
                  const SizedBox(
                    height: 10,
                  ),
                  _getConfirmOrderDetails(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> getSuperStoreDealProducts() async {
    if (!productListLoading) {
      if (productNext != null && !productListLoading) {
        productListLoading = true;

        final Map<String, dynamic>? result = await ShoppingAuthService()
            .getCartItemsByAddressId(productNext, productPrevious,
                addressId: packageDetailsModel.addressId);

        if (result == null) {
          listEmpty = true;
          productListLoading = false;
          return;
        }

        productNext = result['next'];
        productPrevious = result['previous'];
        productCount = result['count'];
        final tempList = await productItem(result['results']);

        listEmpty = false;
        productListLoading = false;
        productList.addAll(tempList);
      }
      if (productList.isEmpty) {
        listEmpty = true;
      }
    }
  }

  Future<List<Product>> productItem(List ordersItemsList) async {
    final List<Product> myListOfOrders = [];
    for (Product item in ordersItemsList) {
      if (item.variantModels != null && item.variantModels!.isNotEmpty) {
        for (var variant in item.variantModels!) {
          // Create a new Product instance with the variant
          Product newProduct = Product(
            id: item.id,
            name: item.name,
            seller: item.seller,
            price: item.price,
            currency: item.currency,
            quantity: item.quantity,
            variantModels: [variant],
          );
          myListOfOrders.add(newProduct);
          await Future.delayed(
              const Duration(milliseconds: 200)); // Delay for processing
        }
      } else {
        myListOfOrders.add(item);
      }
    }
    return myListOfOrders;
  }

  int? getProductDiscountPrice(Product product) {
    if (product.variantModels?.isNotEmpty ?? false) {
      if (checkProductVariantDiscount(product.variantModels?.first)) {
        return product.variantModels?.first.discountedPrice;
      } else {
        return int.tryParse(product.variantModels?.first.price ?? "0") ?? 0;
      }
    } else {
      return getProductPrice(product);
    }
  }

  bool checkProductVariantDiscount(Variant? selectedVariant) {
    if (selectedVariant?.discountIsActive == true &&
        selectedVariant?.discountedPrice != null) {
      return true;
    }
    return false;
  }

  int getProductPrice(Product product) {
    if (product.discountedPrice != null || product.discountedPrice != 0) {
      if (checkProductDiscountOrNot(product)) {
        return product.discountedPrice ?? 0;
      }
    }
    return product.price ?? 0;
  }

  bool checkProductDiscountOrNot(Product product) {
    if (product.discountIsActive == true && product.discountedPrice != null) {
      return true;
    }
    return false;
  }

  int getItemCount() {
    int quantity = 0;
    for (var product in productList) {
      if (product.variantModels?.isNotEmpty ?? false) {
        quantity += product.variantModels?.first.quantity ?? 0;
      } else {
        quantity += product.quantity ?? 0;
      }
    }
    return quantity;
  }

  int getProductCount(Product? product) {
    int quantity = 0;
    if (product?.variantModels?.isNotEmpty ?? false) {
      quantity = product?.variantModels?.first.quantity ?? 0;
    } else {
      quantity = product?.quantity ?? 0;
    }
    return quantity;
  }
}
