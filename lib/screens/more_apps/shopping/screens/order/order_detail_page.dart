// import 'dart:convert';
// import 'dart:developer';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/order/tracker_stepper.dart'
    as track;
import 'package:Slydo/screens/more_apps/shopping/tiles/order_detail_item_tile.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// import '../../../../../utils/date_time_and_money_converter.dart';
import '../../../../../routes/route_constants.dart';
import '../../../../../utils/global_key.dart';
import '../../../../../utils/navigation_util.dart';
// import '../../../payment_and_banking/payment_and_banking_auth.dart';
import '../../../user_profile/forms/user_address.dart';
import '../../shopping_auth.dart';

// ignore: must_be_immutable
class OrderDetailPage extends StatefulWidget {
  var arguments;

  OrderDetailPage({required this.arguments});

  @override
  _OrderDetailPageState createState() =>
      _OrderDetailPageState(arguments: arguments);
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  var arguments;

  _OrderDetailPageState({this.arguments});

  late BasketBloc basketBloc;
  late UserBloc userBloc;

  SlidableController? _slideController;

  String note = "";

  Order? order;
  List items = [];
  bool isLoading = true;
  final _auth = ShoppingAuthService();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? statusOfOrder = "";
  String? statusOfOrderCopy =
      ""; //This variable is used to track if the statusOfOrder has changed.

  GlobalKey _key = LabeledGlobalKey("orderDetailPagePopUpMenu");
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;
  bool onTap = false;
  bool onTapStatus = false;

  String? getCustomerOrMerchant() {
    var customerOrMerchant = order!.customerName == userBloc.user.userName
        ? order!.merchant
        : order!.customerName;
    return customerOrMerchant;
  }

  String? getAvatar() {
    return order!.customerName == userBloc.user.userName
        ? order!.merchantAvatar
        : order!.customerAvatar;
  }

  String? getAvatarType() {
    return order!.customerName == userBloc.user.userName
        ? order!.merchantType
        : order!.customerType;
  }

  Widget getLeading() {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          25,
        ),
        border: Border.all(color: Colors.transparent, width: 0),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
              myGlobals.navigationKey.currentContext!, Routes.USER_PROFILE,
              arguments: {
                "searchedUserName":
                    order!.customerName == userBloc.user.userName
                        ? order!.merchant
                        : order!.customerName
              });
        },
        child: userImageUserInitialsPic(
            getAvatar()!, getCustomerOrMerchant()!, 35, 48),
      ),
    );
  }

  @override
  void initState() {
    order = arguments['order'];
    statusOfOrder = order!.status!.toLowerCase();
    statusOfOrderCopy = order!.status!.toLowerCase();
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    fetchOrder(order!.id.toString());
    super.initState();
  }

  getOrderStatusTime(Order? order, String? status) {
    var time = '';
    var date = '';
    order?.statusTimeStamp?.map((e) {
      if (e[status ?? ''] != null) {
        date =
            DateFormat("EEEE, MM d 'h:mm a").format(DateTime.parse(e[status]));
        time = DateFormat("hh:mm:ss").format(DateTime.parse(e[status]));
      }
    }).toList();

    return date + time;
  }

  getActiveOrderStatus(Order? order, String? status) {
    bool value = false;
    order?.statusTimeStamp?.map((e) {
      if (e[status ?? ''] != null) {
        value = true;
      }
    }).toList();
    return value;
  }

  getCanceledOrderStatus(Order? order, String? status) {
    bool value = false;
    for (var v in order!.statusTimeStamp!) {
      if (v.containsKey('Canceled')) {
        value = true;
      }
    }
    return value;
  }

  getOnHoldAndPendingOrderStatus(Order? order, String? status) {
    bool value = false;
    for (var v in order!.statusTimeStamp!) {
      if (v.containsKey('On Hold') || v.containsKey('Pending')) {
        value = true;
      }
    }
    return value;
  }

  void fetchOrder(String orderId) async {
    setState(() {
      isLoading = true;
    });
    _auth.getOrder(orderId).then((value) {
      debugPrint('VALUE :: $value');
      if (mounted) {
        setState(() {
          items = value;
          isLoading = false;
        });
      }
    });
  }

  void menuItemSelectionChange(String value, int index) {
    if (userBloc.user.userName == order!.merchant) {
      selectedMenuItemIndex = index;
      updateStatus(value);
      statusOfOrder = value;
      setState(() {});
    }
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    userBloc = Provider.of<UserBloc>(context);

    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      childList: [
        CustomizedPopUpMenuItem(title: "New order", value: "new order"),
        CustomizedPopUpMenuItem(
            title: "Awaiting payment", value: "awaiting payment"),
        CustomizedPopUpMenuItem(title: "Canceled", value: "canceled"),
        CustomizedPopUpMenuItem(title: "Completed", value: "completed"),
        CustomizedPopUpMenuItem(title: "On hold", value: "on hold"),
        CustomizedPopUpMenuItem(title: "Pending", value: "pending"),
        CustomizedPopUpMenuItem(title: "Processing", value: "processing"),
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
          body: SingleChildScrollView(child: scaffoldBody())),
    );
  }

  Widget appBar() {
    return AppBar(
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
        "${"Ref # :" + (order?.id ?? "")}",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        locationBtn(),
        const SizedBox(width: 10.0),
        noteSheetBtn(),
        const SizedBox(width: 10.0),
        changeOrderStatusSheetBtn(),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget locationBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.location,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        // showNoteAndroidSheet();
        NavigationUtil.push(
          context,
          screen: UserAddress(customerName: order!.customerName),
        );
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget noteSheetBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.note,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        showNoteAndroidSheet();
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget popUpMenuButton() {
    return SizedBox(
      key: _key,
      height: 34,
      width: 34,
      child: Card(
        color: isPopMenuOpen ? navyBlue : iconBtnGrey,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: Icon(
            Icons.settings,
            color: isPopMenuOpen ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () {
            if (menu.isMenuOpen) {
              menu.closeMenu();
            } else {
              menu.openMenu();
            }
          },
        ),
      ),
    );
  }

  Widget changeOrderStatusSheetBtn() {
    if (userBloc.user.userName == order!.merchant) {
      return RoundedBackgroundIcon(
        height: 34,
        width: 34,
        icon: Icon(
          SlydoAppIcon.settings,
          size: 16,
          color: blackFont,
        ),
        onTap: () {
          showChangeStatusAndroidSheet();
        },
        backgroundColor: iconBtnGrey,
        enableMargin: true,
      );
    }
    return const SizedBox.shrink();
  }

  Widget scaffoldBody() {
    bool canPay = order!.status == 'Awaiting Payment' &&
        userBloc.user.userName != order!.merchant;

    return isLoading
        ? Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: CircularLoadingIndicator(),
            ),
          )
        : Container(
            margin: EdgeInsets.symmetric(horizontal: 14, vertical: 20),
            padding: EdgeInsets.only(top: 12, bottom: 12),
            decoration: BoxDecoration(
                border: Border.all(color: greyBackground),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 30.0, top: 20),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        myGlobals.navigationKey.currentContext!,
                        Routes.USER_PROFILE,
                        arguments: {
                          "searchedUserName":
                              order!.customerName == userBloc.user.userName
                                  ? order!.merchant
                                  : order!.customerName
                        }),
                    child: Row(
                      children: [
                        getLeading(),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getCustomerOrMerchant() ?? '',
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 17.4,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              getCustomerOrMerchant() ?? '',
                              style: TextStyle(
                                  color: greyBorderColor,
                                  fontSize: 13.4,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: greyBackground,
                  thickness: 1,
                ),
                !onTap
                    ? Padding(
                        padding: EdgeInsets.all(20),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: blackFont.withOpacity(.12)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Order Summary",
                                  style: TextStyle(
                                      color: blackFont,
                                      fontSize: 17.4,
                                      fontWeight: FontWeight.w600),
                                ),
                                IconButton(
                                    onPressed: () => setState(() {
                                          onTap = !onTap;
                                        }),
                                    icon: Icon(
                                      Icons.keyboard_arrow_up_rounded,
                                      color: navyBlue,
                                    ))
                              ]),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(20),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: blackFont.withOpacity(.12))),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Order Summary",
                                        style: TextStyle(
                                            color: blackFont,
                                            fontSize: 17.4,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      IconButton(
                                          onPressed: () => setState(() {
                                                onTap = !onTap;
                                              }),
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: navyBlue,
                                          ))
                                    ]),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                itemCount: items.length,
                                itemBuilder:
                                    (BuildContext context, int index) =>
                                        getItemTile(index),
                              ),
                              Divider(color: blackFont.withOpacity(.12)),
                              SizedBox(
                                height: 20,
                              ),
                              getOrderDetail(),
                              SizedBox(
                                height: 10,
                              ),

                              // canPay
                              //     ? Expanded(
                              //         child: Align(
                              //           alignment: Alignment.bottomCenter,
                              //           child: Padding(
                              //             padding: const EdgeInsets.all(16.0),
                              //             child: CurvedButton(
                              //               onPressed: () {
                              //                 showDialog(
                              //                     context: context,
                              //                     builder:
                              //                         (dialogLoadingContext) =>
                              //                             LoadingIndicator());

                              //                 var data = {
                              //                   "orders": [order!.id]
                              //                 };
                              //                 PaymentAndBankingAuth()
                              //                     .makePaymentForCartOrder(data)
                              //                     .then(
                              //                   (response) {
                              //                     Navigator.pop(context);
                              //                     if (response.statusCode ==
                              //                         200) {
                              //                       Navigator.pop(context, true);

                              //                       showToast(
                              //                           message:
                              //                               'Payment successful');
                              //                     } else if (response
                              //                             .statusCode ==
                              //                         500) {
                              //                       showToast(
                              //                           message:
                              //                               AppLocalization.of(
                              //                                       context)!
                              //                                   .serverError);
                              //                     } else {
                              //                       showToast(
                              //                           message: jsonDecode(
                              //                                   response.body)[0]
                              //                               ['errors']);
                              //                     }
                              //                   },
                              //                 );
                              //               },
                              //               text: 'Pay Now',
                              //             ),
                              //           ),
                              //         ),
                              //       )
                              //     : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                !onTapStatus
                    ? Padding(
                        padding: EdgeInsets.all(20),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: blackFont.withOpacity(.12)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Track Status",
                                  style: TextStyle(
                                      color: blackFont,
                                      fontSize: 17.4,
                                      fontWeight: FontWeight.w600),
                                ),
                                IconButton(
                                    onPressed: () => setState(() {
                                          onTapStatus = !onTapStatus;
                                        }),
                                    icon: Icon(
                                      Icons.keyboard_arrow_up_rounded,
                                      color: navyBlue,
                                    ))
                              ]),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(20),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: blackFont.withOpacity(.12))),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Track Status",
                                        style: TextStyle(
                                            color: blackFont,
                                            fontSize: 17.4,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      IconButton(
                                          onPressed: () => setState(() {
                                                onTapStatus = !onTapStatus;
                                              }),
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: navyBlue,
                                          ))
                                    ]),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              stepperBody()
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          );
  }

  Widget statusIconButton() {
    return IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () {
        showChangeStatusAndroidSheet();
      },
    );
  }

  Widget getOrderDetail() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          checkoutWidget(),
        ],
      ),
    );
  }

  Widget noteIconButton() {
    return IconButton(
      icon: const Icon(Icons.event_note),
      onPressed: () {
        showNoteAndroidSheet();
      },
    );
  }

  void showNoteAndroidSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                height: MediaQuery.of(context).size.height / 2 +
                    MediaQuery.of(context).viewInsets.bottom,
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        AppLocalization.of(context)!.note,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: blackFont,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    getBodyOfNoteBottomSheet()
                  ],
                ),
              ));
        });
  }

  Widget getBodyOfNoteBottomSheet() {
    bool result =
        order!.note == "" && order!.customerName == userBloc.user.userName;
    if (!result) {
      return Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Text(
                    getOrderNote(),
                    style: TextStyle(
                        fontSize: 14,
                        color: blackFont,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 30,
        ),
        getNoteAddTextField(),
        const SizedBox(
          height: 20,
        ),
        addNoteBtn(),
      ],
    ));
  }

  Widget getNoteAddTextField() {
    return Container(
      child: TextFormField(
        maxLines: 8,
        onFieldSubmitted: (val) {
          addNote();
        },
        cursorColor: blackFont,
        decoration: InputDecoration(
          isDense: true,
          labelText: AppLocalization.of(context)!.enterYourNoteHere,
          labelStyle: TextStyle(color: darkGrey),
          alignLabelWithHint: true,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: greyBorderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: greyBorderColor, width: 1),
          ),
        ),
        onChanged: (val) {
          note = val;
        },
      ),
    );
  }

  Widget addNoteBtn() {
    return CurvedButton(
        backgroundColor: navyBlue,
        text: "Add note",
        textColor: Colors.white,
        onPressed: addNote);
  }

  void addNote() async {
    await _auth.updateOrderNote(note, order!.id.toString()).then((value) {
      if (value) {
        setState(() {
          order!.note = note;
          Navigator.pop(context);
        });
      }
    });
  }

  getOrderNote() {
    if (order!.note == "") {
      return AppLocalization.of(context)!.noSpecialNoteAttached + " !!";
    }
    return order!.note;
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
                            color: blackFont,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: ListView(
                          children: <Widget>[
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.newOrder,
                              value: "new order",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title:
                                  AppLocalization.of(context)!.awaitingPayment,
                              value: "awaiting payment",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title:
                                  AppLocalization.of(context)!.paymentReceived,
                              value: "payment received",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.processing,
                              value: "processing",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.orderPickedUp,
                              value: "order picked up",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title:
                                  AppLocalization.of(context)!.outForDelivery,
                              value: "out for delivery",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.completed,
                              value: "complete",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.canceled,
                              value: "canceled",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.onHold,
                              value: "on hold",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                            statusListTile(
                              title: AppLocalization.of(context)!.pending,
                              value: "pending",
                              setState: setState,
                            ),
                            Divider(
                              height: 0,
                              color: dividerColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ));
          });
        });
  }

  Widget statusListTile(
      {required String title, String? value, StateSetter? setState}) {
    return RadioListTile(
      activeColor: navyBlue,
      title: Text(
        title,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: blackFont,
          fontSize: 16.0,
        ),
      ),
      value: value,
      onChanged: (dynamic value) {
        if (userBloc.user.userName == order!.merchant) {
          setState!(() {
            updateStatus(value);
            statusOfOrder = value;
            print(value);
          });
        }
      },
      groupValue: statusOfOrder,
    );
  }

  Widget checkoutWidget() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: white,
      elevation: 0.5,
      // margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: white),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 18,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppLocalization.of(context)!.subTotal + " : ",
                  style: TextStyle(
                    fontSize: 14,
                    color: black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      worldCurrencies[order!.currency!]!,
                      style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 14.2,
                          fontWeight: FontWeight.w600,
                          color: black),
                    ),
                    Text(
                      moneyDisplayNormalizer(order!.totalPrice),
                      style: TextStyle(
                          fontSize: 14.2,
                          fontWeight: FontWeight.w600,
                          color: black),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppLocalization.of(context)!.shipping + " : ",
                  style: TextStyle(
                    fontSize: 14,
                    color: black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      worldCurrencies[order!.currency!]!,
                      style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 14.2,
                          fontWeight: FontWeight.w600,
                          color: black),
                    ),
                    Text(
                      moneyDisplayNormalizer(0),
                      style: TextStyle(
                          fontSize: 14.2,
                          fontWeight: FontWeight.w600,
                          color: black),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppLocalization.of(context)!.tax + " : ",
                  style: TextStyle(
                    fontSize: 14,
                    color: black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      worldCurrencies[order!.currency!]!,
                      style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 14.2,
                          fontWeight: FontWeight.w600,
                          color: black),
                    ),
                    Text(
                      moneyDisplayNormalizer(0),
                      style: TextStyle(
                          fontSize: 14.2,
                          fontWeight: FontWeight.w600,
                          color: black),
                    ),
                  ],
                ),
              ],
            ),
            Divider(color: blackFont.withOpacity(.12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppLocalization.of(context)!.total + " : ",
                  style: TextStyle(
                    fontSize: 14,
                    color: black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      worldCurrencies[order!.currency!]!,
                      style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 14.2,
                          fontWeight: FontWeight.w600,
                          color: navyBlue),
                    ),
                    Text(
                      moneyDisplayNormalizer(order!.totalPrice),
                      style: TextStyle(
                          fontSize: 14.2,
                          fontWeight: FontWeight.w600,
                          color: navyBlue),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget getItemTile(int index) {
    return _getSlidableWithLists(
      context,
      getItemTileUi(index),
      items[index],
      index,
    );
  }

  getItemTileUi(int index) {
    if (items[index]["type"] == "product") {
      return OrderTileForProduct(
        items[index],
      );
    }
    return OrderTileForService(
      items[index],
    );
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget itemTile, var item, int index) {
    return Slidable(
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: const SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(itemTile, item),
      actions: listActionSlideActions(index),
      secondaryActions: listSecondaryActions(index),
    );
  }

  List<Widget> listSecondaryActions(int index) {
    var item = items[index];
    var conditionForUser =
        item["type"] == "product" ? item["item"].seller : item["item"].provider;

    bool isValid = true;
    if (conditionForUser == userBloc.user.userName) {
      isValid = false;
    }

    return [
      SlideActionButton(
          backgroundColor: isValid ? naturalGreen : Colors.grey[600],
          icon: SlydoAppIcon.text_message,
          onTap: isValid
              ? () {
                  navigateToComposeMessage(conditionForUser, index);
                }
              : () {
                  showToast(message: "You can not send message to yourself!!");
                },
          title: AppLocalization.of(context)!.message,
          slideController: _slideController),
    ];
  }

  void removeItem(int index) {
    var item = items[index];
    Map data = {
      "type": item["type"],
      "id": item.conversationID,
    };

    _auth.removeItemFromShoppingCart(data);
    basketBloc.removeItemFromCart(item);
    showToast(
        message:
            AppLocalization.of(context)!.itemIsRemovedSuccessfullyFromCart);
  }

  List<Widget> listActionSlideActions(int index) {
    return [];
  }

  void navigateToComposeMessage(var conditionForUser, int index) async {
    Navigator.of(context).pushNamed('/compose_message', arguments: {
      'recipient': conditionForUser.toString(),
      'subject': items[index]["item"].name.toString(),
    });
  }

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}

  Product getProduct(String productId) {
    Product product = Product();
    product.id = productId;
    product.name = "";
    product.shortDescription = "";
    product.description = "";
    product.condition = "";
    product.currency = userBloc.user.currency;
    product.price = "0";
    product.availableFrom = DateTime.now();
    product.isAvailable = false;
    product.qrCode = "";
    product.seller = "";
    product.manufacturer = "";
    product.serverImages = [];
    return product;
  }

  void updateStatus(value) {
    showDialog(
        context: context,
        builder: (dialogLoadingContext) => LoadingIndicator());

    _auth.updateOrderStatus(value, order!.id.toString()).then((updated) {
      if (updated) {
        Navigator.pop(context); // Dismiss the loader.
        Navigator.pop(context); // Dismiss bottom-sheet.
        Navigator.pop(context,
            true); //Dismiss the order details page and reload the order list page.
        showToast(message: 'Status updated successfully');
      } else {
        showToast(message: 'Something went wrong while updating status.');
      }
    });
  }

  int _currentStep = 0;

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    _currentStep < 5 ? setState(() => _currentStep += 1) : null;
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  Widget stepperBody() {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            track.OrderTrackerStepper(
              type: track.StepperType.vertical,
              physics: AlwaysScrollableScrollPhysics(),
              currentStep: _currentStep,
              onStepTapped: (step) => tapped(step),
              onStepContinue: continued,
              onStepCancel: cancel,
              controlsBuilder: (context, details) {
                return Container(
                  color: navyBlue,
                  child: Container(),
                );
              },
              steps: <track.Step>[
                track.Step(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      new Text('Order Placed',
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(
                          getActiveOrderStatus(order, "New Order")
                              ? 'This order has been placed sucessfully.'
                              : "",
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                      new Text(getOrderStatusTime(order, "New Order"),
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                  content: SizedBox.shrink(),
                  isActive: getActiveOrderStatus(order, "New Order"),
                  state: getActiveOrderStatus(order, "New Order")
                      ? track.StepState.complete
                      : track.StepState.disabled,
                ),
                track.Step(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Text('Awaiting Payment',
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(
                          getActiveOrderStatus(order, "Awaiting Payment")
                              ? 'Your order is onhold till payment is being confirmed.'
                              : "",
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                      new Text(getOrderStatusTime(order, "Awaiting Payment"),
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                  content: SizedBox.shrink(),
                  isActive: getActiveOrderStatus(order, "Awaiting Payment"),
                  state: getActiveOrderStatus(order, "Awaiting Payment")
                      ? track.StepState.editing
                      : track.StepState.disabled,
                ),
                track.Step(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Text('Payment Successful',
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(
                          getActiveOrderStatus(order, "Payment Successfully")
                              ? 'Payment has been receive sucessfully.'
                              : "",
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                      new Text(getOrderStatusTime(order, "Payment Successful"),
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                  content: SizedBox.shrink(),
                  isActive: getActiveOrderStatus(order, "Payment Successful"),
                  state: getActiveOrderStatus(order, "Payment Successful")
                      ? track.StepState.complete
                      : track.StepState.disabled,
                ),
                track.Step(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Text('Processing',
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(
                          getActiveOrderStatus(order, "Processing")
                              ? 'Your order is being prepared for shipment'
                              : "",
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                      new Text(getOrderStatusTime(order, "Processing"),
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                  content: SizedBox.shrink(),
                  isActive: getActiveOrderStatus(order, "Processing"),
                  state: getActiveOrderStatus(order, "Processing")
                      ? track.StepState.complete
                      : track.StepState.disabled,
                ),
                track.Step(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shipped',
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(
                          getActiveOrderStatus(order, "Order Picked Up")
                              ? 'Your order has been shipped and is in transit'
                              : "",
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                      new Text(getOrderStatusTime(order, "Order Picked Up"),
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                  content: SizedBox.shrink(),
                  isActive: getActiveOrderStatus(order, "Order Picked Up"),
                  state: getActiveOrderStatus(order, "Order Picked Up")
                      ? track.StepState.complete
                      : track.StepState.disabled,
                ),
                track.Step(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('On hold/Pending',
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(
                          getActiveOrderStatus(order, "On Hold") ||
                                  getActiveOrderStatus(order, "Pending")
                              ? 'Your order is onhold till the product is restocked.'
                              : "",
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                      new Text(
                          getOrderStatusTime(order, "On Hold") ??
                              getOrderStatusTime(order, "Pending"),
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                  content: SizedBox.shrink(),
                  isActive: getActiveOrderStatus(order, "On Hold"),
                  state: getActiveOrderStatus(order, "On Hold")
                      ? track.StepState.editing
                      : track.StepState.disabled,
                ),
                track.Step(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Out for delivery',
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(
                          getActiveOrderStatus(order, "Out For Delivery")
                              ? 'Your order is out for delivery and  will arrive soon'
                              : "",
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                      new Text(getOrderStatusTime(order, "Out For Delivery"),
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                  content: SizedBox.shrink(),
                  isActive: getActiveOrderStatus(order, "Out For Delivery"),
                  state: getActiveOrderStatus(order, "Out For Delivery")
                      ? track.StepState.complete
                      : track.StepState.disabled,
                ),
                track.Step(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Canceled',
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(
                          getActiveOrderStatus(order, "Canceled")
                              ? 'This order has been cancelled'
                              : "",
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                      new Text(getOrderStatusTime(order, "Canceled"),
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                  content: SizedBox.shrink(),
                  isActive: getActiveOrderStatus(order, "Canceled"),
                  state: getActiveOrderStatus(order, "Canceled")
                      ? track.StepState.error
                      : track.StepState.disabled,
                ),
                track.Step(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order recieved',
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(
                          getActiveOrderStatus(order, "Complete")
                              ? 'Your order has been delivered sucessfully, thank you for shopping from us'
                              : "",
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                      new Text(getOrderStatusTime(order, "Complete"),
                          style: TextStyle(
                              color: blackFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                  content: SizedBox.shrink(),
                  isActive: getActiveOrderStatus(order, "Complete"),
                  state: getActiveOrderStatus(order, "Complete")
                      ? track.StepState.complete
                      : track.StepState.disabled,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class VerticalListItem extends StatelessWidget {
  Widget? child;
  var item;
  String? type;

  VerticalListItem(Widget child, var item) {
    this.child = child;
    this.type = item["type"];
    this.item = item["item"];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (type == "product") {
          Product? product = item;
          Navigator.pushNamed(context, "/product",
              arguments: {"product": product});
        }
        if (type == "service") {
          Service? service = item;
          Navigator.pushNamed(context, "/service-detail",
              arguments: {"service": service});
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: child,
      ),
    );
  }
}
