import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/order_detail_item_tile_new.dart';
import 'package:Slydo/screens/more_apps/shopping/widget/outline_border_button.dart';
import 'package:Slydo/screens/more_apps/shopping/widget/rounded_border_button.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  late UserBloc userBloc;
  TextEditingController userNoteController = TextEditingController();
  final GlobalKey _key = LabeledGlobalKey("orderDetailPagePopUpMenu");

  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;
  String? statusOfOrder = "";
  bool isAPILoading = false;
  final _auth = ShoppingAuthService();
  List<int?> orders = [];
  bool isOrderLoading = false;
  String noteDetails = "";

  @override
  void initState() {
    order = widget.arguments['order'];
    statusOfOrder = order?.status?.toLowerCase();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
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
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
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
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOrderStatus(),
        Divider(
          color: lightBlue,
          thickness: 0.5,
        ),
        _buildAllDetails(),
      ],
    );
  }

  Widget _buildAllDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerName(),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                // padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                itemCount: order?.orderItems?.length,
                itemBuilder: (BuildContext context, int index) =>
                    getItemTileUi(index),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(
            color: lightGrey,
            thickness: 5,
          ),
        ),
        checkoutWidget(),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(
            color: lightGrey,
            thickness: 5,
          ),
        ),
        _buildNoteAndOrderDetails(),
      ],
    );
  }

  Widget _buildCustomerName() {
    return Text(
      order?.normalizeName(userBloc.user.userName) ?? "",
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
      if (order?.status == AppLocalization.of(context)!.completed) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            OrderTileForProductNew(
              order: order?.orderItems?[index],
            ),
            if (order?.status == "Complete" && order?.canWriteReview() == false)
              _buildWriteReview(index, 'isProduct'),
          ],
        );
      }
      return OrderTileForProductNew(
        order: order?.orderItems?[index],
      );
    } else if (order?.orderItems?[index].item is Service) {
      if (order?.status == AppLocalization.of(context)!.completed) {
        return Column(
          children: [
            OrderTileForService(
              order?.orderItems?[index],
            ),
            if (order?.status == "Complete" && order?.canWriteReview() == false)
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
        "Status : ${order?.status}",
        style: TextStyle(
          color: blackFont,
          fontSize: 16,
          fontFamily: "Inter",
          fontWeight: FontWeight.bold,
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
                AppLocalization.of(context)!.subTotal,
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
                    moneyDisplayNormalizer(order?.totalPrice),
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
                AppLocalization.of(context)!.shipping,
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
                    worldCurrencies[order?.currency!]!,
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: lightBlackFont,
                    ),
                  ),
                  Text(
                    moneyDisplayNormalizer(order?.shippingPrice),
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
                AppLocalization.of(context)!.tax,
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
                    worldCurrencies[order?.currency!]!,
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: lightBlackFont,
                    ),
                  ),
                  Text(
                    moneyDisplayNormalizer(0),
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
                AppLocalization.of(context)!.total,
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
                    worldCurrencies[order?.currency!]!,
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: blackFont,
                    ),
                  ),
                  Text(
                    moneyDisplayNormalizer(order?.totalPrice),
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
        ));
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
                AppLocalization.of(context)!.note,
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
          // _buildNoteTextField(),
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
      return "${AppLocalization.of(context)!.noSpecialNoteAttached} !!";
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

  Widget _buildOrderDetails() {
    final DateFormat dateFormat = DateFormat("MMMM dd, yyyy");
    final DateTime dateTime = DateTime.parse(order?.createdAt.toString() ?? "");
    final String date = dateFormat.format(dateTime);
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
            AppLocalization.of(context)!.orderDetail,
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
            title: 'Order placed on',
            detail: date,
          ),
          OrderDetailRow(
            title: 'Payment Method',
            detail: order?.paymentType ?? "",
          ),
          const OrderDetailRow(
            title: 'Address',
            detail: 'No 5, Adetutu street, ikeja, lagos, Nigeria, 100001',
          ),
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
          const SizedBox(
            width: 8,
          ),
          _buildThirdButton()
        ],
      ),
    );
  }

  Widget _buildThirdButton() {
    if (order?.orderCancelledState.contains(order?.status) == true) {
      return Expanded(child: _buildCancelOrder());
    }
    return const SizedBox.shrink();
  }

  Widget _buildSecondButton() {
    if (order?.refundPaymentRequestId != null ||
        order?.refundPaymentId != null) {
      // Merchant has made a refund payment
      if (order?.refundPaymentId != null) {
        return Expanded(child: _buildViewRefundTransaction());
      }
      // Customer has made a refund request
      return Expanded(child: _buildViewRefundPaymentRequest());
    }

    if (order?.isCustomer(userBloc.user.userName) ?? false) {
      if (order?.status == "Awaiting payment") {
        return Expanded(child: _buildPayNow());
      } else if (order?.orderConfirmState.contains(order?.status) == false) {
        return Expanded(child: _buildConfirmDelivery());
      } else if (order?.status == "Canceled" &&
          order?.refundPaymentRequestId == null &&
          order?.refundPaymentId == null) {
        return Expanded(child: _buildRequestRefund());
      } else {
        if (order?.notAllowedStatusUpdate.contains(order?.status) == false) {
          return Expanded(child: _buildUpdateStatus());
        }
      }
    } else {
      if (order?.status == "Canceled" &&
          order?.refundPaymentRequestId != null &&
          order?.refundPaymentId == null) {
        return Expanded(child: _buildRefundPayment());
      }
      if (order?.notAllowedStatusUpdate.contains(order?.status) == false) {
        return Expanded(child: _buildUpdateStatus());
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildFirstButton() {
    return Expanded(child: _buildTrackOrder());
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

  Widget _buildViewRefundTransaction() {
    return RoundedBorderButton(
      title: 'View Refund Transaction',
      onTap: () {
        Navigator.of(context).pushNamed(Routes.TRANSACTION_DETAIL,
            arguments: {'transaction': order?.refundPaymentId});
      },
      isLoading: isAPILoading,
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
      title: AppLocalization.of(context)!.refundRequest,
      onTap: () {
        // await Navigator.pushNamed(context, Routes.WRITE_REVIEW_PAGE,
        //     arguments: {"order": order});
      },
    );
  }

  Widget _buildRefundPayment() {
    return RoundedBorderButton(
      title: "Refund Payment",
      onTap: () {
        // await Navigator.pushNamed(context, Routes.WRITE_REVIEW_PAGE,
        //     arguments: {"order": order});
      },
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
            // updateStatus(value);
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
