import 'dart:async';
import 'dart:convert';

import 'package:Slydo/constant.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/tiles/transaction.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../routes/route_constants.dart';
import '../../../../../utils/navigation_util.dart';
import '../../../../search_user.dart';
import '../../../user_profile/models/user.dart';
import '../../payment_and_banking_auth.dart';

class PaymentRequestList extends StatefulWidget {
  const PaymentRequestList({super.key});

  @override
  State<PaymentRequestList> createState() => _PaymentRequestListState();
}

class _PaymentRequestListState extends State<PaymentRequestList>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldPaymentListKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerPaymentListKey =
      GlobalKey<ScaffoldMessengerState>();

  final _auth = PaymentAndBankingAuth();
  int? count = 0;
  String? next = "";
  String? previous = "";
  List requestPaymentList = [];
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;
  RefreshBlocForRequestPayment? _refreshBloc;

  // variables for to getting filter requestPaymentList
  String filterValue = "all";
  bool? fromMe;
  String? userName;
  DateTimeRange? newDateTimeRange;
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  final GlobalKey _key = LabeledGlobalKey("paymentRequestListPopUpMenu");
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;
  bool isFirstTime = true;
  late UserBloc userBloc;

  @override
  void initState() {
    // secureScreen();
    debugPrint('INIT STATE');
    getList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        debugPrint('END OF LIST');

        getList();
      }
    });

    super.initState();
  }

  // refresh the list when lifecycle called onResume method
  void _onRefreshOnResume() {
    _refreshBloc = Provider.of<RefreshBlocForRequestPayment>(context);
    _refreshBloc!.addListener(() {
      if (_refreshBloc!.isRefresh) {
        debugPrint("refreshing !!");
        if (mounted) {
          debugPrint('_onRefreshOnResume--->');

          _onRefresh();
          _refreshBloc!.isRefresh = false;
        }
      }
    });
  }

  void _refresh() {
    count = 0;
    next = "";
    previous = "";
    isLoading = false;
    isFirstTime = true;
    isRefreshing = true;
    noItemInList = false;
    requestPaymentList = [];
    if (mounted) setState(() {});
    debugPrint('_REFRESH');

    getList();
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      _refresh();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  void menuItemSelectionChange(String value, int index) {
    if (index == 3) {
      newDateTimeRange = null;
    } else if (index != 4) {
      selectedMenuItemIndex = index;
    }

    switch (value) {
      case "received":
        fromMe = false;
        break;
      case "sent":
        fromMe = true;
        break;

      case "clear_date":
        fromMe =
            fromMe; // To maintain the 'filter value' when you clear the date.
        break;

      case "clear_all":
        fromMe = null;
        userName = null;
        newDateTimeRange = null;
        selectedMenuItemIndex = 0;
        break;

      default:
        fromMe = null;
        break;
    }
    setState(() {});
    debugPrint('menuItemSelectionChange--->');
    _onRefresh();
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      childList: [
        CustomizedPopUpMenuItem(title: "All", value: "all"),
        CustomizedPopUpMenuItem(title: "From me", value: "received"),
        CustomizedPopUpMenuItem(title: "To me", value: "sent"),
        CustomizedPopUpMenuItem(title: "Clear Date", value: 'clear_date'),
        CustomizedPopUpMenuItem(title: "Clear All", value: 'clear_all'),
      ],
      selectedIndex: selectedMenuItemIndex,
      right: 16,
    );
    menu.onChange = menuItemSelectionChange;
    menu.menuState = menuStateChange;

    // refresh the list when lifecycle called onResume method\
    _onRefreshOnResume();

    return ScaffoldMessenger(
      key: _scaffoldMessengerPaymentListKey,
      child: Scaffold(
        key: _scaffoldPaymentListKey,
        resizeToAvoidBottomInset: true,
        backgroundColor: lightGrey,
        appBar: appBar() as PreferredSizeWidget?,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            getDateRangeText(),
            Expanded(child: _buildRequestPaymentList()),
          ],
        ),
      ),
    );
  }

  Widget getDateRangeText() {
    return newDateTimeRange != null
        ? Container(
            color: greyBorderColor.withOpacity(0.2),
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              '${dateFormat.format(newDateTimeRange!.start)} - ${dateFormat.format(newDateTimeRange!.end)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
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
      title: Text(
        'Payment Request',
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        getSearchBtn(),
        const SizedBox(width: 8.0),
        dateFilterIcon(),
        const SizedBox(width: 8.0),
        popUpMenuButton(),
        const SizedBox(width: 8.0),
        paymentRequestBtn(),
        const SizedBox(width: 15),
      ],
    );
  }

  Widget getSearchBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      enableMargin: false,
      backgroundColor: iconBtnGrey,
      icon: const Icon(
        Icons.search,
        color: Colors.black,
        size: 20,
      ),
      onTap: () async {
        final CustomerProfile? userFound = await NavigationUtil.push(
          context,
          screen: const SearchUser(),
        );

        if (userFound != null) {
          userName = userFound.userName;
          _refresh();
        }
      },
    );
  }

  Widget dateFilterIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      enableMargin: false,
      backgroundColor: iconBtnGrey,
      icon: const Icon(
        Icons.date_range_rounded,
        color: Colors.black,
        size: 20,
      ),
      onTap: () async {
        newDateTimeRange = await showDateRangePicker(
          context: context,
          firstDate: DateTime.parse("2020-01-01"),
          lastDate: DateTime.now(),
          builder: customThemeBuilder,
        );

        if (newDateTimeRange != null) {
          setState(() {});
          debugPrint('dateFilterIcon--->');

          _onRefresh();
        }
      },
    );
  }

  Widget paymentRequestBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      enableMargin: false,
      backgroundColor: iconBtnGrey,
      icon: Icon(
        SlydoAppIcon.add,
        size: 16,
        color: blackFont,
      ),
      onTap: () async {
        final PermissionType? hasPermission =
            userBloc.user.hasWritePermission(ProtectionPermission.request);
        if (hasPermission == PermissionType.WRITE) {
          Navigator.of(context).pushNamed(Routes.REQUEST_PAYMENT,
              arguments: <String, bool>{
                'isRequest': true,
                'isFromProfile': true
              });
        } else {
          showToast(
              message: AppLocalization.of(context)?.doNotPermission ?? "");
        }
      },
    );
  }

  Widget menuBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      enableMargin: false,
      backgroundColor: iconBtnGrey,
      icon: Card(
        color: lightGrey,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: _threeItemPopup(),
      ),
    );
  }

  Widget popUpMenuButton() {
    return RoundedBackgroundIcon(
      key: _key,
      height: 34,
      width: 34,
      enableMargin: false,
      backgroundColor: iconBtnGrey,
      icon: Icon(
        Icons.filter_alt_rounded,
        color: isPopMenuOpen ? Colors.white : Colors.black,
        size: 20,
      ),
      onTap: () {
        if (menu.isMenuOpen) {
          menu.closeMenu();
        } else {
          menu.openMenu();
        }
      },
    );
  }

  Widget _threeItemPopup() => PopupMenuButton(
        padding: const EdgeInsets.all(0),
        //    captureInheritedThemes: true,
        icon: Icon(
          SlydoAppIcon.menu,
          size: 16,
          color: blackFont,
        ),
        itemBuilder: (context) {
          final List<PopupMenuEntry> list = [];
          list.add(
            PopupMenuItem(
              value: 1,
              child: Text(
                AppLocalization.of(context)!.filter,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: blackFont),
              ),
            ),
          );
          list.add(
            const PopupMenuDivider(
              height: 10,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              value: "all",
              checked: filterValue == "all" ? true : false,
              child: Text(
                AppLocalization.of(context)!.all,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              value: "received",
              checked: filterValue == "received" ? true : false,
              child: Text(
                AppLocalization.of(context)!.received,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );

          list.add(
            CheckedPopupMenuItem(
              value: "sent",
              checked: filterValue == "sent" ? true : false,
              child: Text(
                AppLocalization.of(context)!.sent,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );
          return list;
        },
        onSelected: (dynamic object) {
          if (mounted) {
            setState(() {
              if (object != 1) {
                filterValue = object as String;
                filterValue = object;
                switch (filterValue) {
                  case "received":
                    fromMe = false;
                    break;
                  case "sent":
                    fromMe = true;
                    break;
                  default:
                    fromMe = false;
                    break;
                }
                debugPrint('_threeItemPopup--->');

                _onRefresh();
              }
            });
          }
        },
      );

  Widget _buildRequestPaymentList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noPendingPaymentRequest,
          )
        : isLoading && requestPaymentList.isEmpty
            ? buildLoadingIndicator(isLoading: isLoading)
            : SmartRefresher(
                enablePullDown: true,
                header: WaterDropHeader(
                  complete: Container(),
                  waterDropColor: navyBlue,
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: SlidableAutoCloseBehavior(
                  closeWhenOpened: true,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(4),
                    //+1 for progressbar
                    itemCount: requestPaymentList.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == requestPaymentList.length) {
                        return buildJumpingLoadingIndicator(
                            isLoading: isLoading);
                      } else {
                        return _getSlideLists(requestPaymentList[index], index);
                      }
                    },
                    controller: _scrollController,
                  ),
                ),
              );
  }

  bool isRefreshing = false;
  void getList() async {
    debugPrint('GET LIST _--->');
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;

        if (mounted) setState(() {});

        try {
          final Map<String, dynamic>? result = await _auth.listPaymentRequests(
            next,
            previous,
            fromMe: fromMe,
            userName: userName,
            isRefreshing: isRefreshing,
            dateTimeRange: newDateTimeRange,
          );
          if (result == null) {
            isLoading = false;
            return;
          }

          next = result['next'];
          count = result['count'];
          previous = result['previous'];
          final tempList = result['results'];
          debugPrint('REQUEST PAYMENT ::: $tempList');

          isLoading = false;
          requestPaymentList.addAll(tempList);
          if (mounted) setState(() {});

          if (isFirstTime && next != null && next != "") {
            isFirstTime = false;
            getList();
          }
        } catch (error) {
          debugPrint("ERROR:- $error");
          isLoading = false;

          if (mounted) setState(() {});
        }
      }
      if (requestPaymentList.isEmpty) {
        noItemInList = true;

        if (mounted) setState(() {});
      } else if (next == null && requestPaymentList.length > 6) {
        _scaffoldMessengerPaymentListKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget sendRequestButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: InkWell(
        onTap: () async {
          if (await checkConnection(context)) {
            Navigator.of(context).pushNamed('/request-payment',
                arguments: <String, bool>{
                  'isRequest': true,
                  'isFromProfile': true
                });
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String text) {
    _scaffoldMessengerPaymentListKey.currentState
        ?.showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> listSecondaryActions(PaymentRequest paymentRequest, int index) {
    return [
      SlideActionButton(
        borderRadius: BorderRadius.circular(5),
        padding: EdgeInsets.zero,
        backgroundColor: navyBlue,
        icon: SlydoAppIcon.send,
        onPressed: (con) {
          acceptPaymentRequestAlert(paymentRequest, index);
        },
        label: "Pay",
      ),
    ];
  }

  List<Widget> listActionSlideActions(
      PaymentRequest paymentRequest, int index) {
    final String caption = paymentRequest.isCredit!
        ? AppLocalization.of(context)!.reject
        : AppLocalization.of(context)!.cancel;
    return [
      SlideActionButton(
        borderRadius: BorderRadius.circular(5),
        padding: EdgeInsets.zero,
        backgroundColor: mateRed,
        icon: SlydoAppIcon.remove,
        onPressed: (con) {
          if (paymentRequest.isCredit!) {
            rejectPaymentRequestAlert(paymentRequest, index);
          } else {
            cancelPaymentRequestAlert(paymentRequest, index);
          }
        },
        label: caption,
      ),
    ];
  }

  Future<bool> checkAccountBalance(PaymentRequest paymentRequest) async {
    // BankAccountBloc bankAccountBloc =
    //     Provider.of<BankAccountBloc>(context, listen: false);
    // if (bankAccountBloc.bankAccount == null ||
    //     bankAccountBloc.bankAccount!.bankName == null) {
    //   Navigator.of(context).pop();
    //   showToast(message: "Please add bank account first !!");
    //   return false;
    // } else {
    final double accountBalance = await getAccountBalance();
    Navigator.of(context).pop();
    debugPrint("accountBalance:- $accountBalance");
    final double spendingAmount = paymentRequest.amount! / 100;
    debugPrint("spendingAmount:- $spendingAmount");
    if (spendingAmount > accountBalance) {
      showToast(message: "You don't have enough money in Slydo account!!");
      return false;
    }
    // }
    return true;
  }

  void acceptPaymentRequestAlert(
      PaymentRequest paymentRequest, int index) async {
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

            final bool result = await checkAccountBalance(paymentRequest);
            if (!result) return;

            final response = await _auth.acceptPaymentRequests(paymentRequest);
            if (response.statusCode == 200 || response.statusCode == 201) {
              _showSnackBar(
                  context, AppLocalization.of(context)!.paymentRequestAccepted);
              if (mounted) {
                setState(() {
                  requestPaymentList.removeAt(index);
                  if (requestPaymentList.length <= 9) {
                    debugPrint('LENGTH LESS THAN 9');
                    getList();
                  }
                });
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
              _showSnackBar(context, error!);
            }
          },
          cancelCallBack: () {
            Navigator.pop(context);
          });
    }
  }

  Future<void> rejectPaymentRequestAlert(
      PaymentRequest paymentRequest, int index) async {
    final bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: mateRed.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.false_icon,
          color: mateRed,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: naturalGreen,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: greyBorderColor,
      actionTwoTextColor: blackFont,
      title: AppLocalization.of(context)!.reject,
      description:
          AppLocalization.of(context)!.areYouSureWantToRejectThisPayment,
      actionOneText: 'Yes',
      actionTwoText: 'No',
    );
    if (result != null && result) {
      final bool done = await _auth.rejectPaymentRequests(paymentRequest);
      if (done) {
        _showSnackBar(
            context, AppLocalization.of(context)!.paymentRequestRejected);
        if (mounted) {
          setState(() {
            requestPaymentList.removeAt(index);
            if (requestPaymentList.length <= 9) {
              getList();
            }
          });
        }
      } else {
        _showSnackBar(context, AppLocalization.of(context)!.error);
      }
    }
  }

  Future<void> cancelPaymentRequestAlert(
      PaymentRequest paymentRequest, int index) async {
    final String actionText = paymentRequest.isCredit! ? 'Reject' : 'Cancel';

    final bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: mateRed.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.false_icon,
          color: mateRed,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: naturalGreen,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: greyBorderColor,
      actionTwoTextColor: blackFont,
      title: paymentRequest.isCredit!
          ? AppLocalization.of(context)!.reject
          : AppLocalization.of(context)!.cancel,
      description: "Are you sure you want to $actionText this request?",
      actionOneText: paymentRequest.isCredit!
          ? AppLocalization.of(context)!.reject
          : 'Yes',
      actionTwoText: "No",
    );
    if (result == null) return;
    if (result) {
      final bool done = await _auth.rejectPaymentRequests(paymentRequest);
      if (done) {
        _showSnackBar(
            context, AppLocalization.of(context)!.paymentRequestCancelled);
        if (mounted) {
          setState(() {
            requestPaymentList.removeAt(index);
            if (requestPaymentList.length <= 9) {
              getList();
            }
          });
        }
      } else {
        _showSnackBar(context, AppLocalization.of(context)!.error);
      }
    }
  }

  Widget _getSlideLists(PaymentRequest paymentRequest, int index) {
    String date;
    if (paymentRequest.createdAt == null) {
      date = ' - ';
    } else {
      date = paymentRequest.createdAt!;
    }
    final PermissionType? hasPermission =
        userBloc.user.hasWritePermission(ProtectionPermission.request);

    return Slidable(
      key: Key("PaymentRequest:${paymentRequest.id! + date}"),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: hasPermission == PermissionType.WRITE ? 0.25 : 0.0001,
        children: listActionSlideActions(paymentRequest, index),
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio:
            hasPermission == PermissionType.WRITE && paymentRequest.isCredit!
                ? 0.25
                : 0.0001,
        children: listSecondaryActions(paymentRequest, index),
      ),
      child: VerticalListItem(paymentRequest),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    // unsecureScreen();
    super.dispose();
  }
}

class VerticalListItem extends StatefulWidget {
  VerticalListItem(this.paymentRequest, {this.key});

  final PaymentRequest paymentRequest;
  final Key? key;

  @override
  State<VerticalListItem> createState() => _VerticalListItemState();
}

class _VerticalListItemState extends State<VerticalListItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final slidableController = Slidable.of(context);
        if (slidableController != null) {
          if (slidableController.actionPaneType == ActionPaneType.none) {
            slidableController.openEndActionPane();
          } else {
            slidableController.close();
          }
        }
        // Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
        //     ? Slidable.of(context)?.open()
        //     : Slidable.of(context)?.close();
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": widget.paymentRequest.payee});
      },
      onLongPress: () {
        if (mounted) {
          setState(() {
            if (isExpanded) {
              isExpanded = false;
            } else {
              isExpanded = true;
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: PaymentRequestTile(
          paymentRequest: widget.paymentRequest,
          expandedWidget: expandedWidget(),
          key: widget.key,
        ),
      ),
    );
  }

  Widget expandedWidget() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isExpanded ? 48 : 0,
      curve: Curves.fastOutSlowIn,
      child: isExpanded
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 1,
                  color: dividerColor,
                ),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(child: sendMessageButton()),
                      Container(
                        width: 1,
                        color: dividerColor,
                        height: 48,
                      ),
                      Expanded(child: blockUserButton()),
                    ],
                  ),
                ),
              ],
            )
          : Container(),
    );
  }

  Widget sendMessageButton() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white,
        highlightColor: Colors.white,
      ),
      child: InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RoundedBackgroundIcon(
              backgroundColor: navyBlue.withOpacity(0.1),
              icon: Icon(
                SlydoAppIcon.message,
                color: navyBlue,
                size: 14,
              ),
              width: 32,
              height: 32,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              AppLocalization.of(context)!.message,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            )
          ],
        ),
        onTap: () {
          UserAuth()
              .fetchCustomerProfile(widget.paymentRequest.payee)
              .then((user) {
            if (mounted) {
              setState(() {
                isExpanded = false;
              });
            }
            Navigator.of(context).pushNamed('/compose_message', arguments: {
              'recipient': user.userName,
              'subject': "",
            });
          });
        },
      ),
    );
  }

  Widget blockUserButton() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white,
        highlightColor: Colors.white,
      ),
      child: InkWell(
        onTap: () {
          UserAuth()
              .fetchCustomerProfile(widget.paymentRequest.payee)
              .then((user) {
            UserAuth().blockUser(user).then((result) {
              if (mounted) {
                setState(() {
                  isExpanded = false;
                });
              }
              if (result) {
                showToast(
                    message:
                        "${widget.paymentRequest.payee} ${AppLocalization.of(context)!.isBlocked}");
              } else {
                showToast(message: AppLocalization.of(context)!.error);
              }
            });
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RoundedBackgroundIcon(
              backgroundColor: mateRed.withOpacity(0.1),
              icon: Icon(
                SlydoAppIcon.remove,
                color: mateRed,
                size: 14,
              ),
              width: 32,
              height: 32,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              AppLocalization.of(context)!.blockUser,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            )
          ],
        ),
      ),
    );
  }
}
