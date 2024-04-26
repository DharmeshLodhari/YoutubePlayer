import 'package:Slydo/constant.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/tiles/transaction.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../../locator.dart';
import '../../../../../../routes/route_constants.dart';
import '../../../../../../services/app_config_bloc.dart';
import '../../../payment_and_banking_auth.dart';

class SlydoTransactionList extends StatefulWidget {
  @override
  _SlydoTransactionListState createState() => _SlydoTransactionListState();
}

class _SlydoTransactionListState extends State<SlydoTransactionList> {
  final GlobalKey<ScaffoldState> _scaffoldTransactionKey =
      GlobalKey<ScaffoldState>();
  late UserBloc userBloc;

  // Get list of users transactions
  final _auth = PaymentAndBankingAuth();
  SlidableController? _slideController;
  int? count = 0;
  String? next = "";
  String? previous = "";
  List transactionList = [];
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;
  DateTimeRange? newDateTimeRange;
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  // variables for to getting filter transactions
  bool? moneyIn;
  String? userName;

  late CustomerProfileBloc customerProfileBloc;

  final GlobalKey _key = LabeledGlobalKey("transactionListPopUpMenu");
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;
  bool isFirstTime = true;
  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;
    getList();

    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getList();
      }
    });
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // initializePopMenu();
    });
  }

  void _refresh() {
    count = 0;
    next = "";
    previous = "";
    transactionList = [];
    noItemInList = false;
    isFirstTime = true;
    isLoading = false;
    if (mounted) setState(() {});
    getList();
  }

  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        _refresh();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  void menuItemSelectionChange(String value, int index) {
    if (index == 4) {
      newDateTimeRange = null;
    } else {
      selectedMenuItemIndex = index;
    }

    switch (value) {
      case "received":
        moneyIn = true;
        break;
      case "sent":
        moneyIn = false;
        break;

      case "clear_date":
        moneyIn =
            moneyIn; // To maintain the 'filter value' when you clear the date.
        break;

      case "clear_all":
        moneyIn = null;
        userName = null;
        newDateTimeRange = null;

        selectedMenuItemIndex = 0;

        break;

      default:
        moneyIn = null;
        break;
    }

    setState(() {});
    _onRefresh();
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      childList: [
        CustomizedPopUpMenuItem(title: "All", value: "all"),
        CustomizedPopUpMenuItem(title: "Received", value: "received"),
        CustomizedPopUpMenuItem(title: "Sent", value: "sent"),
        CustomizedPopUpMenuItem(title: "Clear All", value: 'clear_all'),
        CustomizedPopUpMenuItem(title: "Clear Date", value: 'clear_date'),
      ],
      selectedIndex: selectedMenuItemIndex,
      right: 16,
    );
    menu.onChange = menuItemSelectionChange;
    menu.menuState = menuStateChange;

    return WillPopScope(
      onWillPop: () async {
        menu.closeMenu();
        customerProfileBloc.customer = null;
        return true;
      },
      child: Scaffold(
        key: _scaffoldTransactionKey,
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildTransactionList()),
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
            Icons.filter_alt_rounded,
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

  Widget _buildTransactionList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.transactionHistoryEmpty,
          )
        : isLoading && transactionList.isEmpty
            ? buildLoadingIndicator(isLoading: isLoading)
            : SmartRefresher(
                enablePullDown: true,
                header: WaterDropHeader(
                  complete: Container(),
                  waterDropColor: navyBlue,
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  //+1 for progressbar
                  itemCount: transactionList.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == transactionList.length) {
                      return buildJumpingLoadingIndicator(isLoading: isLoading);
                    } else {
                      return _getSlidableWithLists(
                          context, transactionList[index], index);
                    }
                  },
                  controller: _scrollController,
                ),
              );
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        final Map<String, dynamic>? result = await _auth.getTransactions(
          next,
          previous,
          moneyIn,
          newDateTimeRange,
          userName: userName,
        );
        if (result == null) {
          isLoading = false;
          return;
        }
        next = result['next'];
        count = result['count'];
        previous = result['previous'];
        final tempList = result['results'];

        isLoading = false;
        transactionList.addAll(tempList);

        if (mounted) setState(() {});

        if (isFirstTime && next != null && next != "") {
          isFirstTime = false;
          getList();
        }
      }
      if (transactionList.isEmpty) {
        noItemInList = true;

        if (mounted) setState(() {});
      } else if (next == null && transactionList.length > 6) {
        showReachedToBottomSnackBar();
      }
    }
  }

  void showReachedToBottomSnackBar() {
    if (mounted) {
      if (next == null &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget openGraph() {
    return IconButton(
      icon: const Icon(
        Icons.pie_chart,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.of(context).pushNamed("/transaction-graph");
      },
    );
  }

  void handleSlideAnimationChanged(Animation<double>? value) {}

  void handleSlideIsOpenChanged(bool? value) {}

  List<Widget> listSecondaryActions(Transaction transaction) {
    final PermissionType? hasPermission =
        userBloc.user.hasWritePermission(ProtectionPermission.transaction);
    if (transaction.payee! == "slydo_envelope" ||
        transaction.payee! == "slydo" ||
        transaction.displayCustomer == "slydo" ||
        transaction.displayCustomer == "slydo_envelope") {
      return [];
    }
    if (transaction.isAnonymous!) return [];
    if (hasPermission == PermissionType.WRITE) {
      return [
        SlideActionButton(
            backgroundColor: naturalGreen,
            icon: SlydoAppIcon.send,
            onTap: () async {
              if (appConfigurationModel?.enablePayment == true) {
                customerProfileBloc.customer =
                    await UserAuth().fetchCustomerProfile(transaction.payee);
                Navigator.of(context)
                    .pushNamed(Routes.SEND_PAYMENT, arguments: <String, bool>{
                  'isFromProfile': false,
                });
              } else {
                showToast(message: 'Payment not available at the moment');
              }
            },
            title: AppLocalization.of(context)!.send,
            slideController: _slideController),
      ];
    } else {
      return [];
    }
  }

  List<Widget> listActionSlideActions(Transaction transaction) {
    final PermissionType? hasPermission =
        userBloc.user.hasWritePermission(ProtectionPermission.transaction);
    if (transaction.payee! == "slydo_envelope" ||
        transaction.payee! == "slydo" ||
        transaction.displayCustomer == "slydo" ||
        transaction.displayCustomer == "slydo_envelope") {
      return [];
    }
    if (transaction.isAnonymous!) return [];

    if (hasPermission == PermissionType.WRITE) {
      return [
        SlideActionButton(
            backgroundColor: navyBlue,
            icon: SlydoAppIcon.receive,
            onTap: () async {
              if (appConfigurationModel?.enablePayment == true) {
                customerProfileBloc.customer =
                    await UserAuth().fetchCustomerProfile(transaction.payee);
                Navigator.of(context).pushNamed(
                  Routes.REQUEST_PAYMENT,
                  arguments: <String, bool>{
                    'isFromProfile': false,
                    'isRequest': true
                  },
                );
              } else {
                showToast(message: 'Payment is not currently available');
              }
            },
            title: AppLocalization.of(context)!.request,
            slideController: _slideController),
      ];
    } else {
      return [];
    }
  }

  Widget _getSlidableWithLists(
      BuildContext context, Transaction transaction, int index) {
    return Slidable(
      key: Key(transaction.payee!),
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: const SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      actions: listActionSlideActions(transaction),
      secondaryActions: listSecondaryActions(transaction),
      child: VerticalListItem(
        transaction,
        key: Key(
            "Transaction:${transaction.amount.toString() + transaction.createdAt!}"),
      ),
    );
  }

  @override
  void dispose() {
    // unsecureScreen();
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class VerticalListItem extends StatefulWidget {
  const VerticalListItem(this.transaction, {this.key}) : super(key: key);

  final Transaction transaction;
  final Key? key;

  @override
  State<VerticalListItem> createState() => _VerticalListItemState();
}

class _VerticalListItemState extends State<VerticalListItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
              ? Slidable.of(context)?.open()
              : Slidable.of(context)?.close(),
      onDoubleTap: () {
        if (widget.transaction.payee == "slydo_envelope" ||
            widget.transaction.payee == "slydo" ||
            widget.transaction.displayCustomer == "slydo" ||
            widget.transaction.displayCustomer == "slydo_envelope") {
          return;
        }

        if (widget.transaction.payee != "Slydo" &&
            widget.transaction.payee != "Private") {
          debugPrint(widget.transaction.payee);
          Navigator.pushNamed(context, Routes.USER_PROFILE,
              arguments: {"searchedUserName": widget.transaction.payee});
        }
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
        child: TransactionTile(
          transaction: widget.transaction,
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
              .fetchCustomerProfile(widget.transaction.payee)
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
              .fetchCustomerProfile(widget.transaction.payee)
              .then((user) {
            UserAuth().blockUser(user).then((result) {
              if (mounted) {
                setState(() {
                  isExpanded = false;
                });
              }
              if (result) {
                showToast(
                    message: "${widget.transaction.payee} " +
                        AppLocalization.of(context)!.isBlocked);
              } else {
                showToast(
                  message: AppLocalization.of(context)!.error,
                );
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
