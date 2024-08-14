import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/order/custom_pdf_print_order.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/common.dart';
import 'package:Slydo/utils/util.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class OrderPreview extends StatefulWidget {
  final dynamic arguments;

  const OrderPreview({super.key, this.arguments});

  @override
  State<OrderPreview> createState() => _OrderPreviewState();
}

class _OrderPreviewState extends State<OrderPreview> {
  Order? order;
  Product? product;
  String? currency;
  @override
  void initState() {
    order = widget.arguments?['order'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    currency = worldCurrencies[order?.currency] ?? "";
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(
        "Receipt",
        style: TextStyle(
          color: blackFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: "Inter",
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: GestureDetector(
            onTap: () {
              final CustomPdfPrintOrder pdfPrint = CustomPdfPrintOrder(
                order: order,
                currency: currency,
                product: product,
              );
              pdfPrint.printOrderDetails();
            },
            child: Image.asset(
              "assets/images/appIcon/printer.png",
              height: 22,
              width: 22,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildOrderDetails(),
          _buildHorizontalDotBorder(black),
          _buildOrderProductDetails(),
          _buildHorizontalDotBorder(lightBlackFont),
          _buildProductPriceAndCharges(currency ?? ""),
          const SizedBox(height: 10.0),
          _buildDeliveryDetails(),
          const SizedBox(height: 20.0),
          _buildQRCode(),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Column(
      children: [
        _buildTitle(),
        const SizedBox(height: 5.0),
        _buildOrderNo(),
        const SizedBox(height: 5.0),
        _buildOrderPlaceDateTime(),
        const SizedBox(height: 10.0),
        _buildPaymentStatusTitle(),
        _buildOrderStatus(),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      "${messageDecoderWithEmoji(order?.merchant)} Emporium",
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 24.0,
        color: blackFont,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildOrderNo() {
    return Text(
      'Order No: #${order?.id}',
      style: TextStyle(
        color: black,
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildOrderPlaceDateTime() {
    final DateFormat dateFormat = DateFormat("dd MMMM, yyyy, HH:mm:ss");
    final DateTime dateTime = DateTime.parse(order?.createdAt.toString() ?? "");
    final String date = dateFormat.format(dateTime);
    return Text(
      'Order Placed: $date',
      style: TextStyle(
        color: lightBlackFont,
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildPaymentStatusTitle() {
    return Text(
      'Payment Status',
      style: TextStyle(
        color: blackFont,
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildOrderStatus() {
    return Center(
      child: Text(
        '${order?.status}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: blackFont,
          fontSize: 24.0,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Widget _buildHorizontalDotBorder(Color dashColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: DottedLine(
        direction: Axis.horizontal,
        lineLength: double.infinity,
        lineThickness: 1.0,
        dashLength: 9.0,
        dashColor: dashColor,
        dashRadius: 0.0,
        dashGapLength: 5.0,
        dashGapColor: Colors.transparent,
        dashGapRadius: 0.0,
      ),
    );
  }

  Widget _buildOrderProductDetails() {
    final currency = worldCurrencies[order?.currency] ?? "";
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildItemText('Item'),
            _buildItemText('Amount'),
          ],
        ),
        const SizedBox(height: 10),
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: order?.orderItems?.length,
          itemBuilder: (context, index) {
            if (order?.orderItems?[index].item is Product) {
              product = order?.orderItems?[index].item;
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getProductNameAndColor(),
                _getProductAmount(currency),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildItemText(
    String text,
  ) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: black,
        fontFamily: "Inter",
        fontSize: 12,
      ),
    );
  }

  Widget _buildProductPriceAndCharges(String currency) {
    return Column(
      children: [
        _buildProductAndChargesText('Subtotal',
            '$currency${moneyDisplayNormalizer(order?.getSubTotalAmount())}'),
        _buildProductAndChargesText('Shipping',
            '$currency${moneyDisplayNormalizer(order?.getShippingPrice())}'),
        _buildProductAndChargesText('Service Charge',
            '$currency${moneyDisplayNormalizer(order?.getServiceCharge())}'),
        _buildProductAndChargesText('Tax', '$currency${order?.getTaxAmount()}'),
        const SizedBox(height: 10),
        _buildProductAndChargesText('Total',
            '$currency${moneyDisplayNormalizer(order?.getTotalAmount())}',
            isTotal: true),
        _buildHorizontalDotBorder(lightBlackFont),
      ],
    );
  }

  Widget _buildProductAndChargesText(String title, String amount,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 24.0 : 12.0,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? Colors.black : black,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 24.0 : 12.0,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? blackFont : lightBlackFont,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCustomText(String title, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title : ',
            style: TextStyle(
              fontSize: 12.0,
              color: blackFont,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            info,
            style: TextStyle(
              fontSize: 12.0,
              color: lightBlackFont,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getProductAmount([String? currency]) {
    final int productActualPrice;
    if (product?.variantModels?.isNotEmpty ?? false) {
      productActualPrice =
          product?.getDiscountedPrice(product?.variantModels?.first) ?? 0;
    } else {
      productActualPrice = product?.getProductRealPrice() ?? 0;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            "$currency${moneyDisplayNormalizer(productActualPrice)}",
            style: TextStyle(
              color: lightBlackFont,
              fontWeight: FontWeight.w400,
              fontSize: 12,
              fontFamily: "Inter",
            ),
          ),
          const SizedBox(width: 4),
          if ((product?.discountedPrice != null &&
                  product?.discountedPrice != 0) ||
              (product?.pricePercentageChange != null &&
                      product?.pricePercentageChange != 0.0 ||
                  (product?.variantModels?.isNotEmpty ?? false)))
            _buildPricePercentageChanges(currency),
        ],
      ),
    );
  }

  Widget _buildPricePercentageChanges(String? currency) {
    if (product?.variantModels?.isNotEmpty ?? false) {
      if (product?.checkVariantDiscount(product?.variantModels?.first) ??
          false) {
        return Text(
          "(-${product?.variantModels?.first.discountType == "percentage" ? "${product?.variantModels?.first.discountValue}% off" : currency! + moneyDisplayNormalizer(product?.variantModels?.first.discountValue?.toInt()).toString()})",
          style: TextStyle(
            color: lightBlackFont,
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
          "(-${product?.discountType == "percentage" ? "${product?.discountValue}% off" : currency! + moneyDisplayNormalizer(product?.discountValue?.toInt()).toString()})",
          style: TextStyle(
            color: lightBlackFont,
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
        "(${product?.pricePercentageChange!.toInt()}% off)",
        style: TextStyle(
          color: lightBlackFont,
          fontSize: 11,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget getProductNameAndColor() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            "${messageDecoderWithEmoji(product?.name)}",
            style: const TextStyle(
              fontSize: 12.0,
              fontFamily: "Inter",
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          getProductColorSize(),
        ],
      ),
    );
  }

  Widget getProductColorSize() {
    if (product?.variantModels?.isNotEmpty ?? false) {
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
                "(${messageDecoderWithEmoji(variantColor)})",
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
                "(${messageDecoderWithEmoji(variantSize)})",
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

  int? getOriginalPriceFromDiscount() {
    if (product?.variantModels?.isNotEmpty ?? false) {
      if (product?.variantModels?.first.originalPrice != null &&
          product?.variantModels?.first.originalPrice != 0) {
        return product?.variantModels?.first.originalPrice;
      } // return the original price since server calculated the price

      // get the original price from a product that has a discount already apply to the price
      if (product?.variantModels?.first.discountValue != null) {
        if (product?.variantModels?.first.discountType == "price") {
          return ((int.tryParse(product?.variantModels?.first.price ?? "0")) ??
                  0) +
              (product?.variantModels?.first.discountValue ?? 0);
        } else {
          return ((int.tryParse(product?.variantModels?.first.price ?? "0")) ??
                  0) *
              100 ~/
              (100 - (product?.variantModels?.first.discountValue ?? 0));
        }
      }
      return int.tryParse(product?.variantModels?.first.price ?? "0");
    } else {
      // get the original price, if product have discount
      if (product?.originalPrice != null && product?.originalPrice != 0) {
        return product?.originalPrice;
      } // return the original price since server calculated the price

      // get the original price from a product that has a discount already apply to the price
      if (product?.discountValue != null) {
        if (product?.discountType == "price") {
          return (product?.price ?? 0) + (product?.discountValue ?? 0);
        } else {
          return (product?.price ?? 0) *
              100 ~/
              (100 - (product?.discountValue ?? 0));
        }
      }
      return product?.price;
    }
  }

  Widget _buildDeliveryDetails() {
    String formattedDate;
    try {
      final DateTime dateTime = DateTime.parse(order?.pickupDateTime ?? "");
      final DateFormat dateFormat = DateFormat("MMMM dd, yyyy, h:mm:ss");
      formattedDate = dateFormat.format(dateTime);
    } catch (e) {
      print("Error parsing date: $e");
      formattedDate = "-";
    }
    return Column(
      children: [
        Text(
          'Delivery Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: blackFont,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8.0),
        _buildDeliveryCustomText(
            'Customer', "${order?.normalizeName(order?.customerName)}"),
        _buildDeliveryCustomText('Username', '@${order?.customerName}'),
        _buildDeliveryCustomText('Payment Method', order?.paymentType ?? ""),
        _buildDeliveryCustomText(
            'Delivery Option', order?.shipmentType() ?? ""),
        _buildDeliveryCustomText('Pickup Date/Time', formattedDate),
      ],
    );
  }

  Widget _buildQRCode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.qr_code, size: 80.0),
        const SizedBox(height: 8),
        Text(
          'Powered by SLYDO',
          style: TextStyle(
            color: blackFont,
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Download Slydo App on Google Play Store & App Store',
          style: TextStyle(
            color: lightBlackFont,
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  // print code
}
