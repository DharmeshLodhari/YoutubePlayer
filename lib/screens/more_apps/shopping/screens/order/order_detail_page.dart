import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shipping_process_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/order/custom_pdf_print_order.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/order_detail_item_tile_new.dart';
import 'package:Slydo/screens/more_apps/shopping/widget/outline_border_button.dart';
import 'package:Slydo/screens/more_apps/shopping/widget/rounded_border_button.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/location_service.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderDetailPage extends StatefulWidget {
  final dynamic arguments;
  const OrderDetailPage({super.key, required this.arguments});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Order? order;
  Product? product;
  late UserBloc userBloc;
  late BasketBloc basketBloc;
  TextEditingController userNoteController = TextEditingController();
  final GlobalKey _key = LabeledGlobalKey("orderDetailPagePopUpMenu");
  late ShippingProcessBloc shippingProcessBloc;
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;
  String? statusOfOrder = "";
  bool isAPILoading = false;
  final _auth = ShoppingAuthService();
  List<int?> orders = [];
  bool isOrderLoading = false;
  String noteDetails = "";
  late http.Response response;
  String errorMessage = "";
  String cartId = "";
  String? currency;
  ShippingAddress? deliveryAddress;
  bool isRefundAPILoading = false;
  bool isLoading = false;
  String? orderId;

  @override
  void initState() {
    order = widget.arguments['order'];

    if (order != null) {
      orderId = order?.id;
    } else {
      orderId = widget.arguments[
          'orderId']; // We get this when we are coming from the scan order QR.
    }

    fetchOrderDetail(orderId ?? "");

    statusOfOrder = order?.status?.toLowerCase();
    getCartId();
    getDeliveryAddress();
    super.initState();
  }

  void fetchOrderDetail(String orderId) async {
    setState(() {
      isLoading = true;
    });
    await _auth.getOrder(orderId).then((value) {
      debugPrint('VALUE :: $value');
      if (mounted) {
        setState(() {
          order = value;
          isLoading = false;
        });
      }
    });
  }

  Future<void> getCartId() async {
    if (mounted) setState(() {});

    cartId = await ShippingProcessAuthService().getCartId();
  }

  Future<void> getDeliveryAddress() async {
    isLoading = true;
    if (mounted) setState(() {});

    deliveryAddress = await ShippingProcessAuthService()
        .getSingleAddressDetail(order?.deliveryAddressId ?? "");

    isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    currency = worldCurrencies[order?.currency] ?? "";
    userBloc = Provider.of<UserBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    shippingProcessBloc = Provider.of<ShippingProcessBloc>(context);
    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      childList: [
        CustomizedPopUpMenuItem(title: "New Order", value: "new order"),
        CustomizedPopUpMenuItem(title: "Processing", value: "processing"),
        CustomizedPopUpMenuItem(
            title: "Awaiting Payment", value: "awaiting payment"),
        CustomizedPopUpMenuItem(title: "Shipped", value: "shipped"),
        CustomizedPopUpMenuItem(title: "Completed", value: "completed"),
        CustomizedPopUpMenuItem(title: "On Hold", value: "on hold"),
        CustomizedPopUpMenuItem(title: "Canceled", value: "canceled"),
      ],
      selectedIndex: selectedMenuItemIndex,
      right: 16,
    );
    menu.onChange = menuItemSelectionChange;
    menu.menuState = menuStateChange;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: SingleChildScrollView(
          child: _buildBody(),
        ),
      ),
    );
  }

  void menuItemSelectionChange(String value, int index) {
    if (userBloc.user.userName == order?.merchant) {
      selectedMenuItemIndex = index;
      statusOfOrder = value;
      setState(() {});
    }
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

  Widget appBar() {
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
        "Ref # : ${order?.id ?? ""}",
        style: TextStyle(
          color: blackFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: "Inter",
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            _printAndroidSheet();
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 15),
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

  void _printAndroidSheet() {
    androidBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          bottomSheetItem(
            title: AppLocalization.of(context)!.preview,
            iconData: Icons.preview,
            iconSize: 20,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                Routes.ORDER_PREVIEW,
                arguments: {"order": order},
              );
            },
          ),
          bottomSheetItem(
            title: AppLocalization.of(context)!.print,
            iconData: Icons.print,
            iconSize: 20,
            isLast: true,
            onTap: () {
              Navigator.pop(context);
              final CustomPdfPrintOrder pdfPrint = CustomPdfPrintOrder(
                order: order,
                currency: currency,
                product: product,
              );
              pdfPrint.printOrderDetails();
            },
          ),
        ],
      ),
    );
  }

  // void _printOrderDetails() async {
  //   try {
  //     await SunmiPrinter.initPrinter();
  //     await SunmiPrinter.bindingPrinter();
  //     await SunmiPrinter.startTransactionPrint(true);
  //
  //     // Proceed with printing
  //     _buildTitle();
  //     _buildOrderNo();
  //     _buildOrderPlaceTime();
  //     _buildOrderPaymentStatus();
  //     _buildPrintOrderStatus();
  //     await SunmiPrinter.line();
  //     await SunmiPrinter.bold();
  //
  //     // Order Product Details
  //     await SunmiPrinter.printRow(cols: [
  //       ColumnMaker(
  //         text: 'Item',
  //         width: 25,
  //         align: SunmiPrintAlign.LEFT,
  //       ),
  //       ColumnMaker(
  //         text: 'Amount',
  //         width: 6,
  //         align: SunmiPrintAlign.RIGHT,
  //       ),
  //     ]);
  //
  //     // Print a list of products
  //     for (int i = 0; i < (order?.orderItems?.length ?? 0); i++) {
  //       if (order?.orderItems?[i].item is Product) {
  //         product = order?.orderItems?[i].item;
  //       }
  //       _getProductNameColorAndAmount();
  //     }
  //     await SunmiPrinter.line();
  //     // Product Price and Charges
  //     _buildProductChargeText(
  //         title: "Subtotal",
  //         amount:
  //             '$currency${moneyDisplayNormalizer(order?.getSubTotalAmount())}');
  //     _buildProductChargeText(
  //         title: "Shipping",
  //         amount:
  //             '$currency${moneyDisplayNormalizer(order?.getShippingPrice())}');
  //     _buildProductChargeText(
  //         title: "Service Charge",
  //         amount:
  //             '$currency${moneyDisplayNormalizer(order?.getServiceCharge())}');
  //     _buildProductChargeText(
  //         title: "Tax", amount: '$currency${order?.getTaxAmount()}');
  //
  //     await SunmiPrinter.bold();
  //     await SunmiPrinter.printRow(cols: [
  //       ColumnMaker(text: "Total", width: 6, align: SunmiPrintAlign.LEFT),
  //       ColumnMaker(
  //           text: '$currency${moneyDisplayNormalizer(order?.getTotalAmount())}',
  //           width: 6,
  //           align: SunmiPrintAlign.RIGHT)
  //     ]);
  //     await SunmiPrinter.line();
  //
  //     // Delivery Details
  //     _buildPrintDelivery();
  //     _buildPrintDeliveryText(
  //         title: 'Customer',
  //         info: "${order?.normalizeName(order?.customerName)}");
  //     _buildPrintDeliveryText(
  //         title: 'Username', info: "@${order?.customerName}");
  //     _buildPrintDeliveryText(
  //         title: 'Payment Method', info: "${order?.paymentType}");
  //     _buildPrintDeliveryText(
  //         title: 'Delivery Option', info: "${order?.shipmentType()}");
  //     //format date
  //     String formattedDate;
  //     try {
  //       final DateTime dateTime = DateTime.parse(order?.pickupDateTime ?? "");
  //       final DateFormat dateFormat = DateFormat("MMMM dd, yyyy, h:mm:ss");
  //       formattedDate = dateFormat.format(dateTime);
  //     } catch (e) {
  //       print("Error parsing date: $e");
  //       formattedDate = "-";
  //     }
  //     _buildPrintDeliveryText(title: 'Pickup Date/Time', info: formattedDate);
  //
  //     // QRCode
  //     _buildQrImage();
  //     await SunmiPrinter.printText(
  //       'Powered by SLYDO',
  //       style: SunmiStyle(
  //         fontSize: SunmiFontSize.MD,
  //         bold: true,
  //         align: SunmiPrintAlign.CENTER,
  //       ),
  //     );
  //     await SunmiPrinter.printText(
  //       'Download Slydo App on Google Play Store & App Store',
  //       style: SunmiStyle(
  //         fontSize: SunmiFontSize.MD,
  //         bold: false,
  //         align: SunmiPrintAlign.CENTER,
  //       ),
  //     );
  //
  //     await SunmiPrinter.lineWrap(2);
  //     await SunmiPrinter.line();
  //     await SunmiPrinter.cut();
  //     await SunmiPrinter.exitTransactionPrint(true);
  //     // await SunmiPrinter.submitTransactionPrint();
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  // }
  Widget _buildBody() {
    return isLoading
        ? const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 30),
              child: CircularProgressIndicator(),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOrderStatus(),
                  _buildPaymentStatus(),
                ],
              ),
              Divider(
                color: lightBlue,
                thickness: 0.5,
              ),
              _buildAllDetails(),
            ],
          );
  }

  Widget _buildAllDetails() {
    String name;
    String? image;
    if (order?.isCustomer(userBloc.user.userName) ?? false) {
      image = order?.merchantAvatar;
      name = order?.normalizeName(order?.merchant) ?? "";
    } else {
      name = order?.normalizeName(order?.customerName) ?? "";
      image = order?.customerAvatar;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildMerchantCustomerIcon(image),
                  const SizedBox(width: 10),
                  _buildCustomerName(name),
                ],
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: order?.orderItems?.length,
                itemBuilder: (BuildContext context, int index) =>
                    getItemTileUi(index),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          color: lightBlue,
          height: 5,
        ),
        checkoutWidget(),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          color: lightBlue,
          height: 5,
        ),
        _buildNoteAndOrderDetails(),
      ],
    );
  }

  Widget _buildMerchantCustomerIcon(String? image) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(80),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed("/photo-viewer", arguments: image);
              },
              child: Container(
                color: Colors.white,
                child: CachedNetworkImage(
                  height: 30,
                  width: 30,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                  imageUrl: image ?? "",
                  errorWidget: imageErrorWidget,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            maxRadius: 7,
            backgroundColor: order?.isCustomer(userBloc.user.userName) ?? false
                ? navyBlue
                : deepPink,
            child: Image.asset(
              order?.isCustomer(userBloc.user.userName) ?? false
                  ? 'assets/images/sales.png'
                  : 'assets/images/purchase.png',
            ),
          ),
          // child: Image.asset(
          //   order?.isCustomer(userBloc.user.userName) ?? false
          //       ? 'assets/images/arrow_down.png'
          //       : 'assets/images/arrow_up.png',
          //   height: 13,
          //   width: 13,
          // ),
        ),
      ],
    );
  }

  Widget _buildCustomerName(String name) {
    return Text(
      order?.normalizeName(name) ?? "",
      style: TextStyle(
        color: lightBlackFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: "Inter",
      ),
    );
  }

  Widget getItemTileUi(int index) {
    if (order?.orderItems?[index].item is Product) {
      if ((order?.isCustomer(userBloc.user.userName) ?? false) &&
          (order?.isCompleted() ?? false)) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            OrderTileForProductNew(
              order: order?.orderItems?[index],
            ),
            _buildWriteReview(index, 'isProduct'),
          ],
        );
      }
      return OrderTileForProductNew(
        order: order?.orderItems?[index],
      );
    } else if (order?.orderItems?[index].item is Service) {
      if ((order?.isCustomer(userBloc.user.userName) ?? false) &&
          (order?.isCompleted() ?? false)) {
        return Column(
          children: [
            OrderTileForService(
              order?.orderItems?[index],
            ),
            _buildWriteReview(index, 'isService'),
          ],
        );
      }
      return OrderTileForService(
        order?.orderItems?[index],
      );
    } else {
      return Container();
    }
  }

  Widget _buildOrderStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 16.0),
      child: Text(
        "Status : ${appendStringDot(order?.status ?? "", 15)}",
        style: TextStyle(
          color: blackFont,
          fontSize: 16,
          fontFamily: "Inter",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPaymentStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: order?.checkOrderStatusBgColor(userBloc.user.userName ?? ""),
        ),
        child: Text(
          order?.isOrderStatus(userBloc.user.userName ?? "") ?? "",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: order?.checkStatusForColor(userBloc.user.userName ?? ""),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
          ),
        ),
      ),
    );
  }

  Widget checkoutWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                AppLocalization.of(context)?.subTotal ?? "",
                style: TextStyle(
                  fontSize: 14,
                  color: black,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                ),
              ),
              Row(
                children: [
                  Text(
                    worldCurrencies[order?.currency] ?? "NGN",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: lightBlackFont,
                    ),
                  ),
                  Text(
                    moneyDisplayNormalizer(order?.getSubTotalAmount()),
                    // moneyDisplayNormalizer(order?.totalPrice),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: lightBlackFont,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                AppLocalization.of(context)?.shipping ?? "",
                style: TextStyle(
                  fontSize: 14,
                  color: black,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                ),
              ),
              Row(
                children: [
                  Text(
                    worldCurrencies[order?.currency] ?? "",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: lightBlackFont,
                    ),
                  ),
                  Text(
                    moneyDisplayNormalizer(order?.getShippingPrice()),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: lightBlackFont,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                AppLocalization.of(context)?.tax ?? "",
                style: TextStyle(
                  fontSize: 14,
                  color: black,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                ),
              ),
              Row(
                children: [
                  Text(
                    worldCurrencies[order?.currency] ?? "",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: lightBlackFont,
                    ),
                  ),
                  Text(
                    order?.getTaxAmount() ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: lightBlackFont,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                AppLocalization.of(context)?.total ?? "",
                style: TextStyle(
                  fontSize: 14,
                  color: black,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Inter",
                ),
              ),
              Row(
                children: [
                  Text(
                    worldCurrencies[order?.currency] ?? "",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: blackFont,
                    ),
                  ),
                  Text(
                    moneyDisplayNormalizer(order?.getTotalAmount()),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: blackFont,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteAndOrderDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNotes(),
          const SizedBox(
            height: 15,
          ),
          _buildOrderDetails(),
          const SizedBox(
            height: 10,
          ),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: darkGrey.withOpacity(
                .4,
              ),
              width: .5)),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              if (userBloc.user.userName != order?.merchant)
                GestureDetector(
                  onTap: () {
                    showEditNoteDialog();
                  },
                  child: SvgPicture.asset(
                    'edit_icon'.toSVG(),
                    width: 20,
                    height: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            getOrderNote(),
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
    );
  }

  void addNote() async {
    await _auth
        .updateOrderNote(noteDetails, order?.id.toString() ?? "")
        .then((value) {
      if (value) {
        setState(() {
          order?.note = noteDetails;
          Navigator.pop(context);
        });
      }
    });
  }

  String getOrderNote() {
    if (order?.note == "") {
      return "${AppLocalization.of(context)?.noSpecialNoteAttached} !!";
    }
    return order?.note ?? "";
  }

  Future<void> showEditNoteDialog() async {
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
          addNote();
          return;
        });
    if (result != null && result == true) {
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildNoteTextField() {
    return TextField(
      controller: userNoteController,
      readOnly: userBloc.user.userName == order?.merchant ? true : false,
      maxLines: 3,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: lightBlue, // Border color
            width: 1.0,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: lightBlue, // Border color
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: navyBlue, // Change the focus color here
            width: 1.0,
          ),
        ),
        filled: true,
        fillColor: white,
        // Background color
      ),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: lightBlackFont,
        fontFamily: "Inter",
      ),
    );
  }

  Widget getPaymentDate() {
    String paymentDate = "Awaiting Payment";
    if (order?.transactionId != null) {
      for (Map<String, dynamic> statusMap in order?.statusTimeStamp ?? []) {
        if (statusMap.keys.first == "Awaiting Payment") {
          paymentDate = statusMap.values.first;
          paymentDate = formatPickupDateTime(paymentDate);
        }
      }
    }

    return OrderDetailRow(
      title: 'Payment Date',
      detail: paymentDate,
    );
  }

  Widget _buildOrderDetails() {
    final DateFormat dateFormat = DateFormat("MMMM dd, yyyy, h:mm a");
    final DateTime dateTime = DateTime.parse(order?.createdAt ?? "");
    final String date = dateFormat.format(dateTime);
    final Map<String, String> formattedDateTimeForPickUp =
        getFormattedDateTime(order?.pickupDateTime ?? "");
    final Map<String, String> formattedDateTimeForEatIn =
        getFormattedDateTime(order?.inStoreDateTime ?? "");

    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: lightBlue,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalization.of(context)?.orderDetail ?? "",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: blackFont,
              fontFamily: "Inter",
            ),
          ),
          const SizedBox(height: 5.0),
          const OrderDetailRow(
            title: 'Order No',
            detail: '#1782903',
          ),
          OrderDetailRow(
            title: 'Order Placed on',
            detail: date,
          ),
          getPaymentDate(),
          OrderDetailRow(
            title: 'Payment Method',
            detail: order?.paymentType ?? "",
          ),
          if (order?.shipmentType() == "PickUp")
            _buildPickUpStore(formattedDateTimeForPickUp['date'] ?? "",
                formattedDateTimeForPickUp['time'] ?? ""),
          if (order?.shipmentType() == "In Store/Eat In")
            _buildEatInStore(formattedDateTimeForEatIn['date'] ?? "",
                formattedDateTimeForEatIn['time'] ?? ""),
          if (order?.shipmentType() == "Delivery") _buildDeliveryDetails()
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildFirstButton(),
          const SizedBox(
            width: 8,
          ),
          _buildSecondButton(),
          _buildThirdButton(),
          _buildRepeatOrder(),
        ],
      ),
    );
  }

  Widget _buildFirstButton() {
    if ((order?.isCustomer(userBloc.user.userName) ?? false) &&
        (order?.newOrderStatus.contains(order?.status) ?? false) &&
        order?.shipmentType() != "Delivery") {
      return Expanded(child: _buildChangeDateButton());
    }
    if ((order?.newOrderStatus.contains(order?.status) ?? false) ||
        order?.status == "Awaiting Payment") {
      return const SizedBox.shrink();
    } else {
      return Expanded(child: _buildTrackOrder());
    }
  }

  Widget _buildSecondButton() {
    // When user is customer
    if (order?.isCustomer(userBloc.user.userName) ?? false) {
      if ((order?.newOrderStatus.contains(order?.status) ?? false) ||
          order?.status == "Processing" ||
          order?.status == "On Hold") {
        return const SizedBox.shrink();
      }
      if (order?.status == "Awaiting Payment") {
        return Expanded(child: _buildPayNow());
      } else if (order?.orderConfirmState.contains(order?.status) == false) {
        return Expanded(child: _buildConfirmDelivery());
      } else if (order?.status == "Canceled" &&
          order?.refundPaymentRequestId == null &&
          order?.refundPaymentId == null &&
          order?.status != "Awaiting Payment") {
        return Expanded(child: _buildRequestRefund());
      } else if (order?.status == "Canceled" &&
          order?.refundPaymentRequestId != null &&
          order?.refundPaymentId != null &&
          order?.status != "Awaiting Payment") {
        return Expanded(child: _buildViewRefund());
      } else if (order?.status == "Canceled" &&
          order?.refundPaymentRequestId != null &&
          order?.refundPaymentId == null &&
          order?.status != "Awaiting Payment") {
        return Expanded(child: _buildViewRefundPaymentRequest());
      } else {
        if (order?.notAllowedStatusUpdate.contains(order?.status) == false) {
          return Expanded(child: _buildUpdateStatus());
        }
      }
    }
    // When user is merchant
    else {
      if (order?.status == "Awaiting Payment") {
        return const SizedBox.shrink();
      }
      if (order?.status == "Canceled" &&
          order?.refundPaymentRequestId != null &&
          order?.refundPaymentId == null &&
          order?.status != "Awaiting Payment") {
        return Expanded(child: _buildRefundPayment());
      } else if (order?.status == "Canceled" &&
          order?.refundPaymentRequestId != null &&
          order?.refundPaymentId != null &&
          order?.status != "Awaiting Payment") {
        return Expanded(child: _buildViewRefund());
      } else if (order?.status == "Canceled" &&
          order?.refundPaymentRequestId != null &&
          order?.refundPaymentId == null &&
          order?.status != "Awaiting Payment") {
        return Expanded(child: _buildViewRefundPaymentRequest());
      }
      if (order?.notAllowedStatusUpdate.contains(order?.status) == false) {
        return Expanded(child: _buildUpdateStatus());
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildThirdButton() {
    if (order?.newOrderStatus.contains(order?.status) == true ||
        order?.status == "Awaiting Payment") {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: _buildCancelOrder(),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPayNow() {
    return RoundedBorderButton(
        title: AppLocalization.of(context)!.payNow,
        onTap: () {
          BottomSheetPassCode(
              context: context,
              isValidCallback: () async {
                await checkAccountBalance();

                // Create the orders
                await placeOrder();
              },
              cancelCallBack: () {
                Navigator.pop(context);
              });
        },
        isLoading: isOrderLoading);
  }

  Widget _buildChangeDateButton() {
    return OutlineBorderButton(
      title: "Change Date/Time",
      onTap: () async {
        // _showDialogDateTime();
      },
    );
  }

  Widget _buildViewRefundPaymentRequest() {
    return RoundedBorderButton(
      title: 'View Refund Request',
      onTap: () {
        Navigator.of(context).pushNamed(Routes.PAYMENT_REQUEST_DETAIL,
            arguments: {'paymentRequest': order?.refundPaymentRequestId});
      },
      isLoading: isAPILoading,
    );
  }

  Widget _buildConfirmDelivery() {
    return RoundedBorderButton(
      title: AppLocalization.of(context)!.confirmDelivery,
      onTap: () {
        showConfirmDialogForOrder();
      },
    );
  }

  Widget _buildRequestRefund() {
    return RoundedBorderButton(
      title: AppLocalization.of(context)!.requestRefund,
      onTap: () {
        if ((order?.totalPrice ?? 0) > 0) {
          showRequestRefundDialog();
        } else {
          showToast(message: 'You can not send request for money');
        }
      },
    );
  }

  Widget _buildRefundPayment() {
    return RoundedBorderButton(
      title: "Refund",
      onTap: () {
        acceptPaymentRequestAlert();
      },
    );
  }

  Widget _buildViewRefund() {
    return RoundedBorderButton(
      title: 'View Refund',
      onTap: () {
        Navigator.of(context).pushNamed(Routes.TRANSACTION_DETAIL,
            arguments: {'transaction': order?.refundPaymentId});
      },
      isLoading: isAPILoading,
    );
  }

  Widget _buildEditAddress() {
    return OutlineBorderButton(
      title: "Edit Address",
      onTap: () async {
        await Navigator.pushNamed(context, Routes.DISPATCH_ADDRESS, arguments: {
          "order": order,
          "isForSelection": false,
        });
      },
    );
  }

  Widget _buildUpdateStatus() {
    return RoundedBorderButton(
      title: "Update Status",
      onTap: () {
        showChangeStatusAndroidSheet();
      },
    );
  }

  Widget _buildRepeatOrder() {
    if ((order?.isCustomer(userBloc.user.userName) ?? false) &&
        (order?.isCompleted() ?? false)) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: RoundedBorderButton(
            title: "Buy Again",
            onTap: () {
              order?.recreateOrder(basketBloc, userBloc);
              NavigationUtil.pushNamed(context,
                  routeName: Routes.SHOPPING_CART);
            },
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCancelOrder() {
    return RoundedBorderButton(
      title: "Cancel Order",
      color: redBtn,
      onTap: () {
        showDeleteDialogForOrder();
      },
    );
  }

  Widget _buildWriteReview(int index, String itemType) {
    return RoundedBorderButton(
      title: "Write a review",
      onTap: () async {
        await Navigator.pushNamed(context, Routes.WRITE_REVIEW_PAGE,
            arguments: {"order": order, "index": index, "type": itemType});
      },
    );
  }

  Widget _buildTrackOrder() {
    return OutlineBorderButton(
      title: "Track Order",
      onTap: () async {
        await Navigator.pushNamed(context, Routes.TRACK_ORDER,
            arguments: {"order": order});
      },
    );
  }

  void showRequestRefundDialog() {
    showDialogBox(
        context: context,
        roundedBackgroundIcon: RoundedBackgroundIcon(
          backgroundColor: navyBlue.withOpacity(0.08),
          borderRadius: 30,
          width: 55,
          height: 55,
          icon: Icon(
            SlydoAppIcon.false_icon,
            color: navyBlue,
            size: 18,
          ),
          enableMargin: false,
        ),
        actionOneBgColor: greySecondaryYarn,
        actionOneTextColor: black,
        actionTwoBgColor: navyBlue,
        actionTwoTextColor: Colors.white,
        fontSize: 14,
        firstActionPrimary: false,
        title: AppLocalization.of(context)!.requestRefund,
        description:
            'Will you like to send a refund request of ${worldCurrencies[order?.currency]}${moneyDisplayNormalizer(order?.totalPrice)} to this merchant?',
        actionOneText: 'No',
        actionTwoText: 'Yes',
        rightButtonOnPressed: () async {
          await customerOrderRefundRequest();
        });
  }

  void acceptPaymentRequestAlert() async {
    final bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: navyBlue.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.true_icon,
          color: navyBlue,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: navyBlue,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: mateRed,
      actionTwoTextColor: Colors.white,
      firstActionPrimary: true,
      title: "Pay",
      description:
          AppLocalization.of(context)!.areYouSureWantToAcceptThisRequest,
      actionOneText: "Pay",
      actionTwoText: AppLocalization.of(context)!.cancel,
    );
    if (result != null && result) {
      BottomSheetPassCode(
          context: context,
          isValidCallback: () async {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    Center(child: CircularLoadingIndicator()));

            final bool result = await checkAccountBalance();
            if (!result) return;

            final response = await PaymentAndBankingAuth()
                .acceptPaymentRequests(order?.refundPaymentRequestId ?? "");
            if (response.statusCode == 200 || response.statusCode == 201) {
              final jsonData = json.decode(response.body);
              debugPrint("jsonData: ====> $jsonData");
              final String paymentId = jsonData["id"] ?? 0;
              if (paymentId != null || paymentId != 0) {
                sendOrderRefundPaymentId(paymentId);
              }
            } else if (response.statusCode == 500) {
              showToast(message: AppLocalization.of(context)!.serverError);
            }
            // else if (response.statusCode == 800) {
            //   Navigator.pushNamed(context, "/add-document");
            // }
            else {
              final Map<String, dynamic> errorData = jsonDecode(response.body);
              String? error = "Error";
              if (errorData.containsKey("errors")) {
                error = errorData['errors'];
              }
              showToast(message: error!);
            }
          },
          cancelCallBack: () {
            Navigator.pop(context);
          });
    }
  }

  void showChangeStatusAndroidSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                color: Colors.white,
                margin: EdgeInsets.zero,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        AppLocalization.of(context)!.status,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w700,
                          color: blackFont,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(
                        color: dividerColor,
                        thickness: 1,
                      ),
                      Expanded(
                        child: ListView(
                          children: <Widget>[
                            statusListTile(
                              title: AppLocalization.of(context)!.newOrder,
                              value: "new order",
                              setState: setState,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.processing,
                              value: "processing",
                              setState: setState,
                            ),
                            statusListTile(
                              title:
                                  AppLocalization.of(context)!.awaitingPayment,
                              value: "awaiting payment",
                              setState: setState,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.shipped,
                              value: "shipped",
                              setState: setState,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.completed,
                              value: "completed",
                              setState: setState,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.onHold,
                              value: "on hold",
                              setState: setState,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.canceled,
                              value: "canceled",
                              setState: setState,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      getSubmitButton(),
                    ],
                  ),
                ));
          });
        });
  }

  void showDeleteDialogForOrder() {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: mateRed,
      title: 'Cancel Order',
      actionOneText: 'Go Back',
      actionTwoText: AppLocalization.of(context)!.cancel,
      description: 'Are you sure you want to cancel this order?',
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: Image.asset('assets/images/delete_dialog_icon.png'),
      ),
      rightButtonOnPressed: () async {
        await updateStatus("Canceled", isRefresh: true);
      },
    );
  }

  Widget statusListTile(
      {required String title, String? value, StateSetter? setState}) {
    return RadioListTile(
      activeColor: navyBlue,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -3),
      value: value,
      groupValue: statusOfOrder,
      onChanged: (value) {
        if (userBloc.user.userName == order?.merchant) {
          setState!(() {
            statusOfOrder = value;
            debugPrint(value);
          });
        }
      },
      controlAffinity: ListTileControlAffinity.trailing,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: statusOfOrder == title ? navyBlue : blackFont,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Widget getSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
      child: CurvedButton(
        onPressed: isAPILoading
            ? () {}
            : () async {
                await updateStatus(statusOfOrder ?? "");
              },
        backgroundColor: navyBlue,
        textColor: Colors.white,
        text: "Save",
        isLoading: isAPILoading,
      ),
    );
  }

  // Customer will send this request to merchant to get the refund
  Future<void> customerOrderRefundRequest() async {
    final locationService = LocationService();
    final UserLocation? userLocation =
        await locationService.getLocation().catchError((error) {
      showToast(message: "$error");
    });

    if (userLocation == null) {
      return null;
    }

    final data = {
      "from_customer": userBloc.user.userName!.trim(),
      "to_customer": order?.merchant,
      "currency": userBloc.user.currency,
      "amount": order?.totalPrice,
      "category": 'Finance',
      "notes": 'Refund Order Ref: ${order?.id}',
      "description": 'Refund Order Ref: ${order?.id} ',
      "latitude": Platform.isIOS ? userLocation.latitude : "",
      "longitude": Platform.isIOS ? userLocation.longitude : "",
      "made_from_chat": false,
      "cart_id`": cartId,
      "data": {
        "order_id": order?.id,
      },
    };

    debugPrint("data $data");
    await PaymentAndBankingAuth().createPaymentRequests(data).then((value) {
      response = value;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        debugPrint("jsonData: ====> $jsonData");
        final int paymentRequestId = jsonData["id"] ?? 0;
        if (paymentRequestId != null || paymentRequestId != 0) {
          sendOrderRefundPaymentRequestId(paymentRequestId);
        }
      } else if (response.statusCode == 500) {
        if (mounted) {
          setState(() {
            errorMessage = AppLocalization.of(context)!.serverError;
            showToast(message: errorMessage);
          });
        }
      } else {
        if (mounted) {
          if (response.statusCode == 406) {
            errorMessage = jsonDecode(value.body)[0];
            showToast(message: errorMessage);
            setState(() {});
          } else {
            debugPrint("ERROR:- ${response.body}");
            setState(() {
              errorMessage = AppLocalization.of(context)!.somethingWentWrong;
              showToast(message: errorMessage);
            });
          }
        }
      }
    });
  }

  // Customer call this function to send the payment-request-id after payment request to update order
  Future<void> sendOrderRefundPaymentRequestId(int paymentRequestId) async {
    final Map<String, dynamic> requestData = {
      "refund_payment_request_id": paymentRequestId,
    };
    // Please send request to that API
    await updateOrderRefundStatus(requestData);
    showToast(message: 'Payment request sent');
  }

  // Merchants call this function to send the payment id after make in refund payment
  Future<void> sendOrderRefundPaymentId(String paymentTransactionId) async {
    final Map<String, dynamic> requestData = {
      "refund_payment_id": paymentTransactionId,
    };

    await updateOrderRefundStatus(requestData);
    showToast(message: AppLocalization.of(context)!.paymentRequestAccepted);
  }

  Future<bool> updateOrderRefundStatus(Map<String, dynamic> data) async {
    try {
      isRefundAPILoading = true;
      if (mounted) setState(() {});
      await _auth
          .updateOrderRefundStatus(data, order?.id.toString() ?? "")
          .then((value) {
        if (value) {
          Navigator.popAndPushNamed(context, Routes.ORDER_LIST);
          return true;
        }
        isRefundAPILoading = false;
        if (mounted) setState(() {});
        return false;
      });
    } catch (e) {
      Navigator.pop(context); // Dismiss bottom-sheet.
      isRefundAPILoading = false;
      if (mounted) setState(() {});
    }
    return false;
  }

  Future<void> updateStatus(String value, {bool isRefresh = false}) async {
    try {
      isAPILoading = true;
      if (mounted) setState(() {});
      await _auth
          .updateOrderStatus(value, order?.id.toString() ?? "")
          .then((updated) {
        if (updated) {
          if (isRefresh) {
            showToast(message: 'Confirm delivery successfully');
            Navigator.popAndPushNamed(context, Routes.ORDER_LIST);
          } else {
            Navigator.pop(context); // Dismiss bottom-sheet.
            showToast(message: 'Status updated successfully');
            Navigator.popAndPushNamed(context, Routes.ORDER_UPDATED,
                arguments: {"orderId": order?.id});
          }
        } else {
          Navigator.pop(context); // Dismiss bottom-sheet.
          statusOfOrder = order?.status?.toLowerCase();
          showToast(message: 'Something went wrong while updating status.');
        }
        isAPILoading = false;
        if (mounted) setState(() {});
      });
    } catch (e) {
      Navigator.pop(context); // Dismiss bottom-sheet.
      statusOfOrder = order?.status?.toLowerCase();
      isAPILoading = false;
      if (mounted) setState(() {});
    }
  }

  Future<bool> checkAccountBalance() async {
    final double accountBalance = await getAccountBalance();
    debugPrint("accountBalance:- $accountBalance");
    final double spendingAmount = order!.totalPrice! / 100;
    debugPrint("spendingAmount:- $spendingAmount");
    if (spendingAmount > accountBalance) {
      showToast(message: "You don't have enough money in Slydo account!!");
      return false;
    }
    return true;
  }

  Future<void> placeOrder() async {
    orders.add(int.parse(order?.id ?? ""));
    isOrderLoading = true;
    if (mounted) setState(() {});
    final response = await PaymentAndBankingAuth()
        .makePaymentForCartOrder({"orders": orders});

    if (response.statusCode == 200 || response.statusCode == 201) {
      isOrderLoading = false;
      if (mounted) setState(() {});
      showToast(message: AppLocalization.of(context)!.sendPaymentSuccess);
      Navigator.popAndPushNamed(context, Routes.ORDER_LIST);
    } else if (response.statusCode == 500) {
      isOrderLoading = false;
      if (mounted) setState(() {});
      showToast(message: AppLocalization.of(context)!.serverError);
    } else {
      isOrderLoading = false;
      if (mounted) setState(() {});
      debugPrint(
        "MakePaymentForOrder Unsuccessful",
      );
    }
  }

  void showConfirmDialogForOrder() {
    showDialogBox(
        context: context,
        roundedBackgroundIcon: RoundedBackgroundIcon(
          backgroundColor: navyBlue.withOpacity(0.08),
          borderRadius: 30,
          width: 55,
          height: 55,
          icon: Icon(
            SlydoAppIcon.true_icon,
            color: navyBlue,
            size: 18,
          ),
          enableMargin: false,
        ),
        actionOneBgColor: greySecondaryYarn,
        actionOneTextColor: black,
        actionTwoBgColor: navyBlue,
        actionTwoTextColor: Colors.white,
        fontSize: 14,
        firstActionPrimary: false,
        title: 'Confirm Delivery',
        description: 'Are you sure you want to Confirm this delivery?',
        actionOneText: AppLocalization.of(context)!.cancel,
        actionTwoText: 'Confirm Delivery',
        rightButtonOnPressed: () {
          isAPILoading
              ? () {}
              : () async {
                  await updateStatus("Complete", isRefresh: true);
                };
        });
  }

  Widget _buildPickUpStore(String date, String time) {
    return Column(
      children: [
        OrderDetailRow(
          title: 'Delivery Option',
          detail: order?.isOrderStatus(userBloc.user.userName ?? "") ?? "",
        ),
        OrderDetailRow(
          title: 'Pickup Date',
          detail: date,
        ),
        if ((order?.customerContactNumber?.isNotEmpty ?? false) &&
            order?.notAllowedStatusUpdate.contains(order?.status) == false)
          OrderDetailRow(
            title: 'Phone Number',
            detail: order?.customerContactNumber ?? "",
          )
        else
          const SizedBox(),
        OrderDetailRow(
          title: 'Pickup Time',
          detail: time,
        ),
        orderFulfilledDetailRow(),
      ],
    );
  }

  Widget _buildEatInStore(String date, String time) {
    return Column(
      children: [
        OrderDetailRow(
          title: 'Delivery Option',
          detail: order?.isOrderStatus(userBloc.user.userName ?? "") ?? "",
        ),
        OrderDetailRow(
          title: 'In Store/Eat In Date',
          detail: date,
        ),
        if ((order?.customerContactNumber?.isNotEmpty ?? false) &&
            order?.notAllowedStatusUpdate.contains(order?.status) == false)
          OrderDetailRow(
            title: 'Phone Number',
            detail: order?.customerContactNumber ?? "",
          )
        else
          const SizedBox(),
        OrderDetailRow(
          title: 'In Store/Eat In Time',
          detail: time,
        ),
        orderFulfilledDetailRow(),
      ],
    );
  }

  Widget orderFulfilledDetailRow() {
    if (order?.notAllowedStatusUpdate.contains(order?.status) == true) {
      String fulfilledTime = "Unknown";
      for (Map<String, dynamic> statusMap in order?.statusTimeStamp ?? []) {
        if (statusMap.keys.first == "Complete") {
          fulfilledTime = statusMap.values.first;
          fulfilledTime = formatPickupDateTime(fulfilledTime);
        }
      }
      return OrderDetailRow(
        title: 'Order Fulfilled',
        detail: fulfilledTime,
      );
    }
    return const SizedBox();
  }

  Widget _buildDeliveryDetails() {
    return Column(
      children: [
        if ((order?.customerContactNumber?.isNotEmpty ?? false) &&
            order?.notAllowedStatusUpdate.contains(order?.status) == false)
          OrderDetailRow(
            title: 'Phone Number',
            detail: order?.customerContactNumber ?? "",
          )
        else
          const SizedBox(),
        OrderDetailRow(
          title: 'Address',
          detail:
              '${deliveryAddress?.addressLineOne}, ${deliveryAddress?.addressLineTwo}',
        ),
        if (order?.notAllowedStatusUpdate.contains(order?.status) == true)
          OrderDetailRow(
            title: 'Order delivered on',
            detail: formatPickupDateTime(order?.deliveryDatetime ?? ""),
          ),
      ],
    );
  }

  // Future<void> _buildTitle() async {
  //   await SunmiPrinter.printText(
  //     '${messageDecoderWithEmoji(order?.merchant)} Emporium',
  //     style: SunmiStyle(
  //       fontSize: SunmiFontSize.LG,
  //       bold: true,
  //       align: SunmiPrintAlign.CENTER,
  //     ),
  //   );
  // }
  //
  // Future<void> _buildOrderNo() async {
  //   await SunmiPrinter.printText(
  //     'Order No: #${order?.id}',
  //     style: SunmiStyle(
  //       fontSize: SunmiFontSize.MD,
  //       bold: true,
  //       align: SunmiPrintAlign.CENTER,
  //     ),
  //   );
  // }
  //
  // Future<void> _buildOrderPlaceTime() async {
  //   final DateFormat dateFormat = DateFormat("dd MMMM, yyyy, HH:mm:ss");
  //   final DateTime dateTime = DateTime.parse(order?.createdAt.toString() ?? "");
  //   final String date = dateFormat.format(dateTime);
  //   await SunmiPrinter.printText(
  //     date,
  //     style: SunmiStyle(
  //       fontSize: SunmiFontSize.MD,
  //       bold: false,
  //       align: SunmiPrintAlign.CENTER,
  //     ),
  //   );
  // }
  //
  // Future<void> _buildOrderPaymentStatus() async {
  //   await SunmiPrinter.printText(
  //     'Payment Status',
  //     style: SunmiStyle(
  //       fontSize: SunmiFontSize.MD,
  //       bold: true,
  //       align: SunmiPrintAlign.CENTER,
  //     ),
  //   );
  // }
  //
  // Future<void> _buildPrintOrderStatus() async {
  //   await SunmiPrinter.printText(
  //     '${order?.status}',
  //     style: SunmiStyle(
  //       fontSize: SunmiFontSize.LG,
  //       bold: true,
  //       align: SunmiPrintAlign.CENTER,
  //     ),
  //   );
  // }
  //
  // Future<void> _buildProductChargeText({String? title, String? amount}) async {
  //   await SunmiPrinter.printRow(cols: [
  //     ColumnMaker(text: title ?? "", width: 6, align: SunmiPrintAlign.LEFT),
  //     ColumnMaker(text: amount ?? '', width: 6, align: SunmiPrintAlign.RIGHT)
  //   ]);
  // }
  //
  // Future<void> _buildPrintDelivery() async {
  //   await SunmiPrinter.printText(
  //     'Delivery Details',
  //     style: SunmiStyle(
  //       fontSize: SunmiFontSize.MD,
  //       bold: true,
  //       align: SunmiPrintAlign.CENTER,
  //     ),
  //   );
  // }
  //
  // Future<void> _buildPrintDeliveryText({String? title, String? info}) async {
  //   await SunmiPrinter.printRow(cols: [
  //     ColumnMaker(text: title ?? "", width: 6, align: SunmiPrintAlign.LEFT),
  //     ColumnMaker(text: info ?? '', width: 6, align: SunmiPrintAlign.RIGHT)
  //   ]);
  // }
  //
  // Future<void> _buildQrImage() async {
  //   await SunmiPrinter.printImage(
  //     base64Decode(""),
  //   );
  // }
  //
  // Future<void> _buildQrDescriptionText(String description) async {
  //   await SunmiPrinter.printText(
  //     description,
  //     style: SunmiStyle(
  //       fontSize: SunmiFontSize.MD,
  //       bold: true,
  //       align: SunmiPrintAlign.CENTER,
  //     ),
  //   );
  // }
  //
  // Future<void> _getProductNameColorAndAmount() async {
  //   // Initialize the variant information strings
  //   String variantColor = '';
  //   String variantSize = '';
  //
  //   // Check if there are any variant models available
  //   if (product?.variantModels?.isNotEmpty ?? false) {
  //     variantColor = product?.variantModels?.first.colour ?? '';
  //     variantSize = product?.variantModels?.first.value ?? '';
  //   }
  //
  //   // Prepare the variant details string
  //   String variantDetails = '';
  //   if (variantColor.isNotEmpty || variantSize.isNotEmpty) {
  //     variantDetails = "(${messageDecoderWithEmoji(variantColor)})";
  //     if (variantColor.isNotEmpty && variantSize.isNotEmpty) {
  //       variantDetails += "/";
  //     }
  //     variantDetails += "(${messageDecoderWithEmoji(variantSize)})";
  //   }
  //   await SunmiPrinter.printRow(cols: [
  //     ColumnMaker(
  //       text: "${messageDecoderWithEmoji(product?.name)} $variantDetails",
  //       width: 25,
  //       align: SunmiPrintAlign.LEFT,
  //     ),
  //     ColumnMaker(
  //       text: _getProductAmountString('$currency'),
  //       width: 6,
  //       align: SunmiPrintAlign.RIGHT,
  //     ),
  //   ]);
  // }

  String _getProductAmountString([String? currency]) {
    final int productActualPrice;
    if (product?.variantModels?.isNotEmpty ?? false) {
      productActualPrice =
          product?.getDiscountedPrice(product?.variantModels?.first) ?? 0;
    } else {
      productActualPrice = product?.getProductRealPrice() ?? 0;
    }

    // Base amount text
    String amountText =
        "$currency${moneyDisplayNormalizer(productActualPrice)}";

    // Append discount details if available
    String discountText = _getPricePercentageChangesString(currency);

    if (discountText.isNotEmpty) {
      amountText += " $discountText";
    }

    return amountText;
  }

  String _getPricePercentageChangesString(String? currency) {
    if (product?.variantModels?.isNotEmpty ?? false) {
      if (product?.checkVariantDiscount(product?.variantModels?.first) ??
          false) {
        return "(-${product?.variantModels?.first.discountType == "percentage" ? "${product?.variantModels?.first.discountValue}% off" : currency! + moneyDisplayNormalizer(product?.variantModels?.first.discountValue?.toInt()).toString()})";
      }
      return '';
    } else if (product?.discountedPrice != null &&
        product?.discountedPrice != 0) {
      if (product?.checkProductDiscount() ?? false) {
        return "(-${product?.discountType == "percentage" ? "${product?.discountValue}% off" : currency! + moneyDisplayNormalizer(product?.discountValue?.toInt()).toString()})";
      }
      return '';
    } else if (product?.pricePercentageChange != 0.0) {
      return "(${product?.pricePercentageChange!.toInt()}% off)";
    }
    return '';
  }
}

class OrderDetailRow extends StatelessWidget {
  final String title;
  final String detail;

  const OrderDetailRow({super.key, required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              '$title : ',
              style: TextStyle(
                fontSize: 12,
                color: blackFont,
                fontWeight: FontWeight.w500,
                fontFamily: "Inter",
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              detail,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: lightBlackFont,
                fontFamily: "Inter",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
