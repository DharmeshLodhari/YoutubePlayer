import 'dart:async';
import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shared_cart_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shipping_process_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/screens/more_apps/shipping_process/tiles/members_payment_tile.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../widget/vertical_list_item.dart';

class SharedCartPayment extends StatefulWidget {
  const SharedCartPayment({Key? key}) : super(key: key);

  @override
  State<SharedCartPayment> createState() => _SharedCartPaymentState();
}

class _SharedCartPaymentState extends State<SharedCartPayment> {
  late SharedCartBloc sharedCartBloc;
  late UserBloc userBloc;
  late ShippingProcessBloc shippingProcessBloc;
  SlidableController? _slideController;
  TextEditingController amountController = TextEditingController();
  String? selectedCategory;
  List<String?> paymentCategories = [];

  bool isOrderLoading = false;
  List<int?> orders = [];
  // String errorMessage = "";
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool splitSwitch = false;

  @override
  void initState() {
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    selectedCategory = "Shopping";

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      amountController.text = moneyDisplayNormalizer(
          int.parse(shippingProcessBloc.getTotalOrder().toString()));
      _onRefresh();
    });
    fetchCategory();
    super.initState();
  }

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void fetchCategory() async {
    PaymentAndBankingAuth().getPaymentCategory().then((result) {
      if (mounted) {
        setState(() {
          List categoriesList = result["results"]["data"];
          categoriesList.forEach((data) {
            paymentCategories.add(data["name"]);
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: lightGrey,
          persistentFooterButtons: [],
          appBar: _buildAppBar() as PreferredSizeWidget?,
          body: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: _buildBody(),
          ),
          floatingActionButton: _buildFloatingButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }

  _buildFloatingButton() {
    if (sharedCartBloc.isUserCartOwner(context)) return _buildPaymentButton();
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 16,
      title: Text(
        'Send Payment',
        style: TextStyle(
          fontSize: 20,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      elevation: 0,
    );
  }

  Widget _buildBody() {
    sharedCartBloc = Provider.of<SharedCartBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    shippingProcessBloc = Provider.of<ShippingProcessBloc>(context);
    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        if (sharedCartBloc.isUserCartOwner(context))
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: selectedListItemBackgroundBlue),
                  borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.zero,
              shadowColor: boxShadowTwo,
              color: white,
              child: Container(
                decoration: decorateBox(),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmount(),
                    const SizedBox(
                      height: 16,
                    ),
                    getCategoryDropDown(),
                    const SizedBox(
                      height: 16,
                    ),
                    _buildReference(),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: Column(
            children: [
              _buildSplitBill(),
              const SizedBox(
                height: 10,
              ),
              if (splitSwitch == true) _buildMemberList(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmount() {
    return CustomizedTextFormField(
      controller: amountController,
      labelText: "Amount",
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      isReadOnly: true,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            // productPrice = double.parse(val.replaceAll(',', '')).toString();
          } catch (e) {
            showToast(message: e.toString());
          }
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double.parse(val.replaceAll(',', ''));
            return null;
          } catch (e) {
            return AppLocalization.of(context)!.invalidAmount;
          }
        }
        return AppLocalization.of(context)!.pleaseEnterValidAmout;
      },
    );
  }

  Widget getCategoryDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalization.of(context)!.category,
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        const SizedBox(
          height: 6,
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: const EdgeInsets.all(0),
          borderOnForeground: true,
          child: ListTile(
            dense: true,
            title: Text(
              selectedCategory != null ? selectedCategory! : "",
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(
                  color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            trailing: Icon(
              Icons.keyboard_arrow_down,
              color: darkGrey,
            ),
            onTap: () {
              selectCategory();
            },
          ),
        ),
      ],
    );
  }

  void selectCategory() async {
    final pressedCategory = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.transparent,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: paymentCategories.map<Widget>((category) {
                          if (selectedCategory == category) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  category!,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: TextStyle(
                                      color: navyBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                trailing: Icon(
                                  SlydoAppIcon.checked,
                                  color: navyBlue,
                                  size: 12,
                                ),
                                onTap: () {
                                  Navigator.pop(context, category);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              category!,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, category);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCategory != null) {
      selectedCategory = pressedCategory;
      debugPrint("selected category $selectedCategory");
      setState(() {});
    }
  }

  Widget _buildReference() {
    return CustomizedTextFormField(
      fontSize: 14,
      labelText: "Reference",
      labelColor: darkGrey,
      fontWeight: FontWeight.w500,
    );
  }

  Widget _buildSplitBill() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Split Bill',
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w600,
            fontFamily: "Inter",
            fontSize: 14,
          ),
        ),
        Transform.scale(
          scale: .8,
          child: CupertinoSwitch(
            value: splitSwitch,
            onChanged: (value) {
              if (sharedCartBloc.isUserCartOwner(context)) {
                splitSwitch = !splitSwitch;
                setState(() {});
              }
            },
            activeColor: const Color(0xff3F61DB), // Color when switch is ON
          ),
        ),
      ],
    );
  }

  Widget _buildMemberList() {
    return Column(
      children: [
        ...sharedCartBloc
                .getSharedCartModel()
                .members
                ?.asMap()
                .entries
                .map((e) {
              final int index = e.key;
              final SharedCartMemberModel member = e.value;

              return buildMemberTile(member, index);
            }).toList() ??
            [],
        // ListView.builder(
        //   physics: NeverScrollableScrollPhysics(),
        //   shrinkWrap: true,
        //   itemCount: sharedCartBloc.getSharedCartModel().members?.length,
        //   itemBuilder: (BuildContext context, int index) {
        //     if (index == sharedCartBloc.getSharedCartModel().members?.length) {
        //       return buildLoadingIndicator(isLoading: isLoading);
        //     } else {
        //       return buildMemberTile(index);
        //     }
        //   },
        // ),
        const SizedBox(height: 10),
        if (sharedCartBloc.isUserCartOwner(context)) _buildSplitEvenly(),
        _buildTotalAmount(),
      ],
    );
  }

  Widget buildMemberTile(SharedCartMemberModel member, int index) {
    return member.userName == userBloc.user.userName &&
            member.userName !=
                sharedCartBloc.getSharedCartModel().customerUsername &&
            sharedCartBloc
                    .getSharedCartModel()
                    .isUserPaymentDone(member.userName) ==
                false
        ? _getSlidableWithLists(
            context,
            MemberPaymentTile(
              member: member,
              index: index,
            ),
            member,
          )
        : MemberPaymentTile(
            member: member,
            index: index,
            isUserPaymentDone: sharedCartBloc
                .getSharedCartModel()
                .isUserPaymentDone(member.userName),
          );
  }

  Widget _buildSplitEvenly() {
    return CustomizedCheckBoxField(
      onTap: () {
        sharedCartBloc.getSharedCartModel().splitBillEvenly =
            !(sharedCartBloc.getSharedCartModel().splitBillEvenly ?? false);
        sharedCartBloc.getSharedCartModel().getSplitBillEvenlyPercentage();
        sharedCartBloc
            .getSharedCartModel()
            .getSplitBillEvenlyPayment(shippingProcessBloc.getTotalOrder());
        setState(() {});
      },
      isChecked: sharedCartBloc.getSharedCartModel().splitBillEvenly,
      title: "Split bill evenly",
    );
  }

  Widget _buildTotalAmount() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          leading: Text(
            'Total : ${sharedCartBloc.getSharedCartModel().getTotalOfPercentage()}%',
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w500,
              fontFamily: "Inter",
              fontSize: 14,
            ),
          ),
          trailing: Container(
            width: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "${worldCurrencies[userBloc.user.currency]}",
                  style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Inter",
                    fontSize: 14,
                  ),
                ),
                Text(
                  moneyDisplayNormalizer(sharedCartBloc
                      .getSharedCartModel()
                      .getSplitBillTotalPayment(
                          shippingProcessBloc.getTotalOrder())),
                  style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Inter",
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getSlidableWithLists(BuildContext context, Widget cartMemberTile,
      SharedCartMemberModel? member) {
    return Slidable(
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(cartMemberTile),
      secondaryActions: listActionSlideActions(member, context),
    );
  }

  List<Widget> listActionSlideActions(
      SharedCartMemberModel? member, BuildContext context) {
    return [
      SlideActionButton(
          backgroundColor: naturalGreen,
          icon: SlydoAppIcon.true_icon,
          onTap: () {
            _buildConfirmPaymentDialog(context);
          },
          title: AppLocalization.of(context)!.accept,
          slideController: _slideController),
    ];
  }

  Widget _buildPaymentButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CurvedButton(
        onPressed: () {
          if (splitSwitch == false ||
              sharedCartBloc.getSharedCartModel().isAllCartPaymentDone()) {
            BottomSheetPassCode(
                context: context,
                isValidCallback: () async {
                  // await checkAccountBalance();

                  // Create the orders
                  await placeOrder();
                },
                cancelCallBack: () {
                  Navigator.pop(context);
                });
          } else {
            if (sharedCartBloc.getSharedCartModel().getSplitBillTotalPayment(
                    shippingProcessBloc.getTotalOrder()) ==
                sharedCartBloc.getSharedCartModel().getSharedCartTotalPrice()) {
              requestForPayment();
            } else {
              showToast(message: "Total payment is not 100%");
            }
          }
        },
        backgroundColor: navyBlue,
        textColor: white,
        text: paymentBtnText(),
        isLoading: isOrderLoading,
      ),
    );
  }

  String paymentBtnText() {
    String btnText = "";
    if (splitSwitch == false ||
        sharedCartBloc.getSharedCartModel().isAllCartPaymentDone()) {
      btnText = 'Send Payment';
    } else {
      btnText = 'Request Payment';
    }
    return btnText;
  }

  Future<void> placeOrder() async {
    // debugPrint(
    //     "place order ${shippingProcessBloc.toPlaceOrder(userBloc.user.userName)}");
    // place order {payment_type: Slydo, shipping_details: []}
    Map<String, dynamic> shippingData =
        shippingProcessBloc.toPlaceOrder(userBloc.user.userName);
    List<ShippingDetail>? shippingDetailsList = sharedCartBloc
        .getSharedCartModel()
        .metaData
        ?.shippingData
        ?.shippingDetails;
    if ((shippingData['shipping_details'] == null ||
            (shippingData['shipping_details'] as List).isEmpty) &&
        shippingDetailsList?.isNotEmpty == true) {
      shippingData['shipping_details'] =
          shippingDetailsList?.map((e) => e.toJson()).toList();
    }
    if (!isOrderLoading) {
      isOrderLoading = true;
      if (mounted) setState(() {});
      await ShippingProcessAuthService()
          .placeOrder(
              data: shippingData,
              isCartProcess: false,
              isSharedCart: true,
              sharedCartId: sharedCartBloc.getSharedCartModel().id)
          .then(
        (value) async {
          if (value != null) {
            // Send the list of of orders for payment processing
            for (int i = 0; i < value.length; i++) {
              orders.add(value[i]["id"]);
            }
            var response = await PaymentAndBankingAuth()
                .makePaymentForCartOrder({"orders": orders});

            if (response.statusCode == 200) {
              Navigator.popUntil(
                  context, ModalRoute.withName(Routes.DASHBOARD));
              Navigator.of(context).pushNamed(Routes.SUCCESSFUL_ORDER);
              showToast(
                  message: AppLocalization.of(context)!.sendPaymentSuccess);
            } else if (response.statusCode == 500) {
              showToast(message: AppLocalization.of(context)!.serverError);
            } else {
              showToast(message: 'Error');
              debugPrint(
                "MakePaymentForCartOrder Unsuccessful",
              );
            }
          } else {
            showToast(message: 'Error');
            debugPrint(
              "Could Not Place The Order",
            );
          }
          isOrderLoading = false;
          if (mounted) setState(() {});
        },
      ).catchError((error) {
        isOrderLoading = false;
        if (mounted) setState(() {});
        debugPrint(error.toString());
        showToast(message: error.toString());
      });
    }
  }

  Future<void> requestForPayment() async {
    List<Map<String, dynamic>> dataList = [];
    for (SharedCartMemberModel member
        in sharedCartBloc.getSharedCartModel().members ?? []) {
      // if (member.userName != userBloc.user.userName) {
      Map<String, dynamic> data = {
        "username": member.userName,
        "currency": "NGN",
        "amount": member.paymentValue,
        "percentage": member.percentageValue,
      };
      dataList.add(data);
      // }
    }
    Map<String, dynamic> metaData = {
      "meta_data": {
        "spit_bill": splitSwitch,
        "shipping_data":
            shippingProcessBloc.toPlaceOrder(userBloc.user.userName),
        "user_data": dataList,
      }
    };
    if (!isOrderLoading) {
      isOrderLoading = true;
      await SharedCartAuthService()
          .requestPayment(sharedCartBloc.getSharedCartModel().id, metaData)
          .then((value) async {
        if (value == true) {
          await sharedCartBloc.refreshAllCart(context);
          Navigator.of(context)
              .popUntil(ModalRoute.withName(Routes.SHOPPING_CART));
          showToast(
              message: AppLocalization.of(context)!.requestPaymentSuccessfully);
        } else {
          showToast(message: AppLocalization.of(context)!.requestFailed);
        }
        isOrderLoading = false;
      }).catchError((error) {
        showToast(message: error.toString());
        isOrderLoading = false;
      });
    }
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) async {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        await sharedCartBloc.refreshSharedCartProduct(
            context, sharedCartBloc.getSharedCartModel());
        SharedCartModel sharedCartModel = await sharedCartBloc
            .refreshCartDetail(sharedCartBloc.getSharedCartModel().id,
                isUpdate: false);
        splitSwitch = sharedCartModel.metaData?.spitBill ?? false;
        setState(() {
          _refreshController.refreshCompleted();
        });
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  void _buildConfirmPaymentDialog(BuildContext context) {
    showDialogBoxWithInput(
        context: context,
        actionOneTextColor: blackFont,
        actionOneBgColor: greyBorderColor,
        actionTwoTextColor: white,
        actionTwoBgColor: navyBlue,
        actionOneText: AppLocalization.of(context)!.cancel,
        actionTwoText: AppLocalization.of(context)!.accept,
        firstActionPrimary: false,
        content: Column(
          children: [
            Text(AppLocalization.of(context)!.confirmPayment,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Inter",
                    fontSize: 16.0),
                textAlign: TextAlign.center),
            Container(
              margin: EdgeInsets.only(top: 25, bottom: 15, left: 10, right: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'A Sum of ',
                      style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Inter",
                        fontSize: 14.0,
                      ),
                    ),
                    TextSpan(
                      text:
                          '${worldCurrencies[userBloc.user.currency]}${moneyDisplayNormalizer(getUserCartAmount())} ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: blackFont,
                        fontFamily: "Inter",
                        fontSize: 14.0,
                      ),
                    ),
                    TextSpan(
                      text: 'will be deducted from your account ?',
                      style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Inter",
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        leftButtonOnPressed: () async {
          Navigator.pop(context);
        },
        rightButtonOnPressed: () async {
          Navigator.pop(context);
          Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
          Navigator.of(context).pushNamed(Routes.ACCOUNTS);
        });
  }

  int getUserCartAmount() {
    int amount = 0;
    for (UserData user
        in sharedCartBloc.getSharedCartModel().metaData?.userData ?? []) {
      if (user.username == userBloc.user.userName) {
        amount = user.amount ?? 0;
      }
    }
    return amount;
  }
}
