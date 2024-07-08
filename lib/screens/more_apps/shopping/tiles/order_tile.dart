import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shipping_process_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/order_detail_item_tile_new.dart';
import 'package:Slydo/screens/more_apps/shopping/widget/outline_border_button.dart';
import 'package:Slydo/screens/more_apps/shopping/widget/rounded_border_button.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/location_service.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderTile extends StatefulWidget {
  OrderTile({super.key, this.order});

  final Order? order;

  @override
  State<OrderTile> createState() => _OrderTileState();
}

class _OrderTileState extends State<OrderTile> {
  late UserBloc userBloc;
  Order? order;
  final GlobalKey _key = LabeledGlobalKey("orderListPopUpMenu");
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;
  String? statusOfOrder = "";
  bool isAPILoading = false;
  bool isRefundAPILoading = false;
  final _auth = ShoppingAuthService();
  List<int?> orders = [];
  bool isOrderLoading = false;
  late http.Response response;
  String errorMessage = "";
  String cartId = "";
  String? status = "";

  @override
  void initState() {
    order = widget.order;
    statusOfOrder = order?.status?.toLowerCase();
    getCartId();
    super.initState();
  }

  Future<void> getCartId() async {
    if (mounted) setState(() {});

    cartId = await ShippingProcessAuthService().getCartId();
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
    return order?.orderItems != null && order?.orderItems?.isNotEmpty == true
        ? Card(
            shadowColor: boxShadowTwo,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  orderNumberAndAmount(),
                  const SizedBox(
                    height: 10,
                  ),
                  orderStatusAndDate(),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Divider(
                      color: lightBlue,
                      thickness: 0.5,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildUserName(),
                      _buildOrdersStatus(),
                    ],
                  ),
                  if (order!.orderItems!.length > 1)
                    getMultipleItemsTileUI()
                  else
                    getItemTileUi(),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(child: _buildFirstButton()),
                      const SizedBox(
                        width: 7,
                      ),
                      Flexible(child: _buildSecondButton()),
                      const SizedBox(
                        width: 7,
                      ),
                      Flexible(child: _buildThirdButton())
                    ],
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildThirdButton() {
    if (order?.orderCancelledState.contains(order?.status) == true) {
      return _buildCancelOrder();
    }
    return const SizedBox.shrink();
  }

  Widget _buildSecondButton() {
    if (order?.isCustomer(userBloc.user.userName) ?? false) {
      if (order?.status == "Complete") {
        if (order?.canWriteReview() == false) return _buildWriteReview();
      } else if (order?.status == "Awaiting payment") {
        return _buildPayNow();
      } else if (order?.orderConfirmState.contains(order?.status) == false) {
        return _buildConfirmDelivery();
      } else if (order?.status == "Canceled" &&
          order?.refundPaymentRequestId == null &&
          order?.refundPaymentId == null) {
        return _buildRequestRefund();
      } else {
        if (order?.notAllowedStatusUpdate.contains(order?.status) == false) {
          return _buildUpdateStatus();
        }
      }
    } else {
      if (order?.status == "Canceled" &&
          order?.refundPaymentRequestId != null &&
          order?.refundPaymentId == null) {
        return _buildRefundPayment();
      }
      if (order?.notAllowedStatusUpdate.contains(order?.status) == false) {
        return _buildUpdateStatus();
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildFirstButton() {
    return _buildTrackOrder();
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
      isLoading: isOrderLoading,
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
      title: "Refund Payment",
      onTap: () {
        acceptPaymentRequestAlert();
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

  Widget _buildWriteReview() {
    return RoundedBorderButton(
      title: "Write a review",
      onTap: () async {
        await Navigator.pushNamed(context, Routes.WRITE_REVIEW_PAGE,
            arguments: {"order": order});
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

  Widget getItemTileUi() {
    for (OrderItem orders in order?.orderItems ?? []) {
      if (orders.item is Product) {
        return OrderTileForProductNew(
          order: orders,
        );
      } else if (orders.item is Service) {
        return OrderTileForService(
          orders,
        );
      } else {
        return Container();
      }
    }
    return Container();
    // if (order?.orderItems?[index].item?["type"] == "product") {
    //   return OrderTileForProductNew(
    //     order: order?.orderItems?[index],
    //   );
    // }
    // return OrderTileForService(
    //   order?.orderItems?[index],
    // );
  }

  Widget getMultipleItemsTileUI() {
    return OrderTileForMultipleProductNew(
      order: order?.orderItems,
    );
  }

  Widget orderNumberAndAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Ref # : ${order?.id}",
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
        Row(
          children: [
            Text(
              "Total: ",
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: "Inter",
              ),
            ),
            Text(
              worldCurrencies[order?.currency] ?? "",
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: "Inter",
              ),
            ),
            Text(
              moneyDisplayNormalizer(order?.totalPrice),
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
      ],
    );
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
        rightButtonOnPressed: () async {
          await updateStatus("Complete", isRefresh: true);
        });
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
        title: AppLocalization.of(context)!.refundRequest,
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

  Widget orderStatusAndDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              order?.status ?? "",
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
              maxLines: 1,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              "(${order?.orderItems?[0].qty ?? "0"} item)",
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
        getDateTime(),
      ],
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
                    topRight: Radius.circular(20),
                  ),
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
                      Expanded(child: getOrderUpdateStatusList()),
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

  Widget getOrderUpdateStatusList() {
    if (order?.isMerchant(userBloc.user.userName) ?? false) {
      return ListView(
        children: <Widget>[
          statusListTile(
            title: "Processing",
            value: "Processing",
            setState: setState,
          ),
          statusListTile(
            title: "On Hold",
            value: "On Hold",
            setState: setState,
          ),
          statusListTile(
            title: "Ready For Delivery",
            value: "Ready For Delivery",
            setState: setState,
          ),
        ],
      );
    }
    return ListView(
      children: <Widget>[
        statusListTile(
          title: "Confirm Delivery",
          value: "Confirm Delivery",
          setState: setState,
        ),
        statusListTile(
          title: "Completed",
          value: "Complete",
          setState: setState,
        ),
      ],
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
        text: "Update",
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
          showToast(message: 'Status updated successfully');
          if (isRefresh) {
            Navigator.popAndPushNamed(context, Routes.ORDER_LIST);
          } else {
            Navigator.popAndPushNamed(context, Routes.ORDER_UPDATED,
                arguments: {"orderId": order?.id});
          }
        } else {
          statusOfOrder = order?.status?.toLowerCase();
          showToast(message: 'Something went wrong while updating status.');
        }
        isAPILoading = false;
        if (mounted) setState(() {});
      });
    } catch (e) {
      statusOfOrder = order?.status?.toLowerCase();
      isAPILoading = false;
      if (mounted) setState(() {});
    }
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
      // statusOfOrder = order?.status?.toLowerCase();
      isRefundAPILoading = false;
      if (mounted) setState(() {});
    }
    return false;
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

  Widget getDateTime() {
    debugPrint(order?.createdAt);
    final DateTime orderTime = DateTime.parse(order?.createdAt ?? '').toLocal();
    final String date = DateFormat("MMM d, yyyy").format(orderTime);
    return Text(
      date,
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(
        color: blackFont,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      ),
    );
  }

  Future<bool> checkAccountBalance() async {
    final double accountBalance = await getAccountBalance();
    debugPrint("accountBalance:- $accountBalance");
    final double spendingAmount = order!.totalPrice! / 100;
    debugPrint("spendingAmount:- $spendingAmount");
    if (spendingAmount > accountBalance) {
      showToast(message: "You don't have enough money in Slydo account!!");
      return false;
    } else {
      return true;
    }
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

  Widget _buildUserName() {
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

  Widget _buildOrdersStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: order?.checkOrderStatusBgColor(userBloc.user.userName ?? ""),
      ),
      child: Text(
        order?.isOrderStatus(userBloc.user.userName ?? "") ?? "",
        style: TextStyle(
          color: order?.checkStatusForColor(userBloc.user.userName ?? ""),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
      ),
    );
  }
}
