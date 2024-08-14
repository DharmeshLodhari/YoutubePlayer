import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/common.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CustomPdfPrintOrder {
  CustomPdfPrintOrder({this.order, this.currency, this.product});
  Order? order;
  Product? product;
  String? currency;

  Future<void> printOrderDetails() async {
    // final Uint8List qrCodeImageData = await loadImageData();

    final pdf = pw.Document();
    final customFont = await loadCustomFont();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              _buildPrintOrderDetails(),
              buildPdfHorizontalDotBorder(),
              _buildOrderProductDetails(currency, customFont),
              buildPdfHorizontalDotBorder(),
              _buildProductPriceAndCharges(currency ?? "", customFont),
              pw.SizedBox(height: 10.0),
              _buildPrintDeliveryDetails(),
              pw.SizedBox(height: 20.0),
              _buildQRCode(),
              pw.SizedBox(height: 20.0),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPrintOrderDetails() {
    return pw.Column(
      children: [
        _buildTitle(),
        pw.SizedBox(height: 5.0),
        _buildOrderNo(),
        pw.SizedBox(height: 5.0),
        _buildOrderPlaceDateTime(),
        pw.SizedBox(height: 10.0),
        _buildPaymentStatusTitle(),
        _buildPrintOrderStatus(),
      ],
    );
  }

  pw.Widget _buildTitle() {
    return pw.Text(
      "${messageDecoderWithEmoji(order?.merchant)} Emporium",
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 24.0,
      ),
    );
  }

  pw.Widget _buildOrderNo() {
    return pw.Text(
      'Order No: #${order?.id}',
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.normal,
        fontSize: 14.0,
      ),
    );
  }

  pw.Widget _buildOrderPlaceDateTime() {
    final DateFormat dateFormat = DateFormat("dd MMMM, yyyy, HH:mm:ss");
    final DateTime dateTime = DateTime.parse(order?.createdAt.toString() ?? "");
    final String date = dateFormat.format(dateTime);

    return pw.Text(
      'Order Placed: $date',
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.normal,
        fontSize: 14.0,
      ),
    );
  }

  pw.Widget _buildPaymentStatusTitle() {
    return pw.Text(
      'Payment Status',
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.normal,
        fontSize: 14.0,
      ),
    );
  }

  pw.Widget _buildPrintOrderStatus() {
    return pw.Text(
      '${order?.status}',
      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
    );
  }

  pw.Widget buildPdfHorizontalDotBorder() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 15),
      child: pw.Row(
        children: List.generate(100, (index) {
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 1),
            child: pw.Container(
              width: 8,
              height: 1,
              color: PdfColors.black,
            ),
          );
        }),
      ),
    );
  }

  pw.Widget _buildOrderProductDetails(String? currency, pw.Font customFont) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildItemText('Item', customFont),
            _buildItemText('Amount', customFont),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.ListView.builder(
          padding: pw.EdgeInsets.zero,
          itemCount: order?.orderItems!.length ?? 0,
          itemBuilder: (context, index) {
            if (order?.orderItems?[index].item is Product) {
              product = order?.orderItems?[index].item;
            }
            return pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                getProductNameAndColor(),
                _getProductAmount(currency, customFont),
              ],
            );
          },
        ),
      ],
    );
  }

  pw.Widget _buildItemText(
    String text,
    pw.Font customFont,
  ) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 14,
        font: customFont,
      ),
    );
  }

  pw.Widget getProductNameAndColor() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.Text(
            "${messageDecoderWithEmoji(product?.name)}",
            style: pw.TextStyle(
              fontSize: 14.0,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
          getProductColorSize(),
        ],
      ),
    );
  }

  pw.Widget _getProductAmount(String? currency, pw.Font? customFont) {
    final int productActualPrice;
    if (product?.variantModels?.isNotEmpty ?? false) {
      productActualPrice =
          product?.getDiscountedPrice(product?.variantModels?.first) ?? 0;
    } else {
      productActualPrice = product?.getProductRealPrice() ?? 0;
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.Text(
            "$currency${moneyDisplayNormalizer(productActualPrice)}",
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.normal,
              fontSize: 14,
              font: customFont,
            ),
          ),
          pw.SizedBox(width: 4),
          if ((product?.discountedPrice != null &&
                  product?.discountedPrice != 0) ||
              (product?.pricePercentageChange != null &&
                      product?.pricePercentageChange != 0.0 ||
                  (product?.variantModels?.isNotEmpty ?? false)))
            _buildPricePercentageChanges(currency, customFont),
        ],
      ),
    );
  }

  pw.Widget _buildPricePercentageChanges(
      String? currency, pw.Font? customFont) {
    if (product?.variantModels?.isNotEmpty ?? false) {
      if (product?.checkVariantDiscount(product?.variantModels?.first) ??
          false) {
        return pw.Text(
          "(-${product?.variantModels?.first.discountType == "percentage" ? "${product?.variantModels?.first.discountValue}% off" : currency! + moneyDisplayNormalizer(product?.variantModels?.first.discountValue?.toInt()).toString()})",
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.normal,
            font: customFont,
          ),
        );
      } else {
        return pw.SizedBox();
      }
    } else if (product?.discountedPrice != null &&
        product?.discountedPrice != 0) {
      if (product?.checkProductDiscount() ?? false) {
        return pw.Text(
          "(-${product?.discountType == "percentage" ? "${product?.discountValue}% off" : currency! + moneyDisplayNormalizer(product?.discountValue?.toInt()).toString()})",
          style: pw.TextStyle(
            fontSize: 11,
            font: customFont,
            fontWeight: pw.FontWeight.bold,
          ),
        );
      } else {
        return pw.SizedBox();
      }
    } else if (product?.pricePercentageChange != 0.0) {
      return pw.Text(
        "(${product?.pricePercentageChange!.toInt()}% off)",
        style: pw.TextStyle(
            fontSize: 11, fontWeight: pw.FontWeight.bold, font: customFont),
      );
    } else {
      return pw.SizedBox();
    }
  }

  pw.Widget getProductColorSize() {
    if (product?.variantModels?.isNotEmpty ?? false) {
      final String variantColor = product?.variantModels?.first.colour ?? '';
      final String variantSize = product?.variantModels?.first.value ?? '';
      if (variantColor.isNotEmpty || variantSize.isNotEmpty) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(20),
          ),
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                "(${messageDecoderWithEmoji(variantColor)})",
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
              if (variantColor.isNotEmpty && variantSize.isNotEmpty)
                pw.Text(
                  "/",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.normal,
                  ),
                ),
              pw.Text(
                "(${messageDecoderWithEmoji(variantSize)})",
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      } else {
        return pw.Container();
      }
    } else {
      return pw.Container();
    }
  }

  pw.Widget buildPdfOrderProductDetails() {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Item',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Amount',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.SizedBox(height: 10),
        // Add more content here
      ],
    );
  }

  pw.Widget _buildProductPriceAndCharges(
    String currency,
    pw.Font customFont,
  ) {
    return pw.Column(
      children: [
        _buildProductAndChargesText(
            'Subtotal',
            '$currency${moneyDisplayNormalizer(order?.getSubTotalAmount())}',
            customFont),
        _buildProductAndChargesText(
            'Shipping',
            '$currency${moneyDisplayNormalizer(order?.getShippingPrice())}',
            customFont),
        _buildProductAndChargesText(
            'Service Charge',
            '$currency${moneyDisplayNormalizer(order?.getServiceCharge())}',
            customFont),
        _buildProductAndChargesText(
            'Tax', '$currency${order?.getTaxAmount()}', customFont),
        pw.SizedBox(height: 10),
        _buildProductAndChargesText(
            'Total',
            '$currency${moneyDisplayNormalizer(order?.getTotalAmount())}',
            customFont,
            isTotal: true),
        buildPdfHorizontalDotBorder(),
      ],
    );
  }

  Future<pw.Font> loadCustomFont() async {
    final fontData = await rootBundle.load('assets/fonts/Roboto-Medium.ttf');
    return pw.Font.ttf(ByteData.sublistView(fontData.buffer.asUint8List()));
  }

  pw.Widget _buildProductAndChargesText(
      String title, String amount, pw.Font customFont,
      {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: isTotal ? 24.0 : 12.0,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            amount,
            style: pw.TextStyle(
                fontSize: isTotal ? 24.0 : 12.0,
                fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
                font: customFont),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPrintDeliveryDetails() {
    String formattedDate;
    try {
      final DateTime dateTime = DateTime.parse(order?.pickupDateTime ?? "");
      final DateFormat dateFormat = DateFormat("MMMM dd, yyyy, h:mm:ss");
      formattedDate = dateFormat.format(dateTime);
    } catch (e) {
      print("Error parsing date: $e");
      formattedDate = "-";
    }
    return pw.Column(
      children: [
        pw.Text(
          'Delivery Details',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
          ),
        ),
        pw.SizedBox(height: 8.0),
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

  pw.Widget _buildDeliveryCustomText(String title, String info) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '$title : ',
            style: pw.TextStyle(
              fontSize: 14.0,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            info,
            style: pw.TextStyle(
              fontSize: 14.0,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildQRCode() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // pw.Image(
        //   pw.MemoryImage(imageData),
        //   width: 80,
        //   height: 80,
        // ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Powered by SLYDO',
          style: pw.TextStyle(
            fontSize: 14.0,
            fontWeight: pw.FontWeight.normal,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Download Slydo App on Google Play Store & App Store',
          style: pw.TextStyle(
            fontSize: 14.0,
            fontWeight: pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Future<Uint8List> loadImageData() async {
    try {
      final ByteData data = await rootBundle.load('assets/qr_code.png');
      return data.buffer.asUint8List();
    } catch (e) {
      throw Exception('Error loading asset: $e');
    }
  }
}
