import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/order_detail_item_tile_new.dart';
import 'package:Slydo/screens/more_apps/shopping/widget/outline_border_button.dart';
import 'package:Slydo/screens/more_apps/shopping/widget/rounded_border_button.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
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
  final _auth = ShoppingAuthService();
  List<int?> orders = [];
  bool isOrderLoading = false;

  @override
  void initState() {
    order = widget.order;
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
                  Text(
                    order?.normalizeName(userBloc.user.userName) ?? "",
                    style: TextStyle(
                      color: lightBlackFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Inter",
                    ),
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
                      ...[
                        const SizedBox(
                          width: 7,
                        ),
                        Flexible(child: _buildSecondButton())
                      ],
                      ...[
                        const SizedBox(
                          width: 7,
                        ),
                        Flexible(child: _buildThirdButton())
                      ],
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
      }
    }
    return _buildUpdateStatus();
  }

  Widget _buildFirstButton() {
    return _buildTrackOrder();
  }

  Widget _buildPayNow() {
    return RoundedBorderButton(
      title: "Pay Now",
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
      title: "Confirm Delivery",
      onTap: () {
        showConfirmDialogForOrder();
      },
    );
  }

  Widget _buildRequestRefund() {
    return RoundedBorderButton(
      title: "Request Refund",
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
        // showChangeStatusAndroidSheet();
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
          "Ref # : ${widget.order?.id}",
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
              worldCurrencies[widget.order?.currency] ?? "",
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: "Inter",
              ),
            ),
            Text(
              moneyDisplayNormalizer(widget.order?.totalPrice),
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

  Widget orderStatusAndDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              widget.order?.status ?? "",
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
              "(${widget.order?.orderItems?[0].qty ?? "0"} item)",
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
                              value: "complete",
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
    debugPrint(widget.order?.createdAt);
    final DateTime orderTime =
        DateTime.parse(widget.order?.createdAt ?? '').toLocal();
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
}
