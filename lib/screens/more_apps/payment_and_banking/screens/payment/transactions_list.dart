import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/tiles/transaction.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../locator.dart';
import '../../../../../routes/route_constants.dart';
import '../../../../../services/app_config_bloc.dart';
import '../../../../../utils/navigation_util.dart';
import '../../../../search_user.dart';
import '../../../user_profile/models/user.dart';
import '../../payment_and_banking_auth.dart';

class TransactionList extends StatefulWidget {
  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  final GlobalKey<ScaffoldState> _scaffoldTransactionKey =
      new GlobalKey<ScaffoldState>();

  // Get list of users transactions
  final _auth = PaymentAndBankingAuth();
  SlidableController? _slideController;
  int? count = 0;
  String? next = "";
  String? previous = "";
  List transactionList = [];
  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;
  RefreshBlocForTransaction? _refreshBloc;
  DateTimeRange? newDateTimeRange;
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  // variables for to getting filter transactions
  bool? moneyIn;
  String? userName;

  late CustomerProfileBloc customerProfileBloc;

  GlobalKey _key = LabeledGlobalKey("transactionListPopUpMenu");
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;
  bool isFirstTime = true;
  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    // secureScreen();
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

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      // initializePopMenu();
    });
  }

  _refresh() {
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
      var connectionResult = value;
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
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      children: [
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
        appBar: appBar() as PreferredSizeWidget?,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            getDateRangeText(),
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
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              '${dateFormat.format(newDateTimeRange!.start)} - ${dateFormat.format(newDateTimeRange!.end)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
              ),
            ),
          )
        : SizedBox.shrink();
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          menu.closeMenu();
          customerProfileBloc.customer = null;
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(
        AppLocalization.of(context)!.transactions,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        getSearchBtn(),
        SizedBox(width: 10.0),
        openGraphBtn(),
        SizedBox(width: 10.0),
        dateFilterIcon(),
        SizedBox(width: 10.0),
        popUpMenuButton(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget getSearchBtn() {
    return SizedBox(
      height: 34,
      width: 34,
      child: Card(
        color: iconBtnGrey,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () async {
            CustomerProfile? userFound = await NavigationUtil.push(
              context,
              screen: SearchUser(),
            );

            if (userFound != null) {
              userName = userFound.userName;
              _refresh();
            }
          },
        ),
      ),
    );
  }

  Widget dateFilterIcon() {
    return SizedBox(
      height: 34,
      width: 34,
      child: Card(
        color: iconBtnGrey,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: Icon(
            Icons.date_range_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () async {
            newDateTimeRange = await showDateRangePicker(
              context: context,
              firstDate: DateTime.parse("2020-01-01"),
              lastDate: DateTime.now(),
              builder: customThemeBuilder,
            );

            if (newDateTimeRange != null) {
              setState(() {});
              _onRefresh();
            }
          },
        ),
      ),
    );
  }

  Widget openGraphBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.graph,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        Navigator.of(context).pushNamed(Routes.TRANSACTION_GRAPH);
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
        margin: EdgeInsets.symmetric(vertical: 10),
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
        : SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 4),
              //+1 for progressbar
              itemCount: transactionList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == transactionList.length) {
                  return buildLoadingIndicator(isLoading: isLoading);
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
        Map<String, dynamic>? result = await _auth.getTransactions(
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
        var tempList = result['results'];

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
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget openGraph() {
    return IconButton(
      icon: Icon(
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
    if (transaction.payee! == "slydo_envelope" ||
        transaction.payee! == "slydo" ||
        transaction.displayCustomer == "slydo" ||
        transaction.displayCustomer == "slydo_envelope") {
      return [];
    }
    if (transaction.isAnonymous!) return [];
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
  }

  List<Widget> listActionSlideActions(Transaction transaction) {
    if (transaction.payee! == "slydo_envelope" ||
        transaction.payee! == "slydo" ||
        transaction.displayCustomer == "slydo" ||
        transaction.displayCustomer == "slydo_envelope") {
      return [];
    }
    if (transaction.isAnonymous!) return [];

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
  }

  Widget _getSlidableWithLists(
      BuildContext context, Transaction transaction, int index) {
    return Slidable(
      key: Key(transaction.payee!),
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(
        transaction,
        key: Key(
            "Transaction:${transaction.amount.toString() + transaction.createdAt!}"),
      ),
      actions: listActionSlideActions(transaction),
      secondaryActions: listSecondaryActions(transaction),
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
  VerticalListItem(this.transaction, {this.key}) : super(key: key);

  final Transaction transaction;
  final Key? key;

  @override
  _VerticalListItemState createState() => _VerticalListItemState();
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
        padding: EdgeInsets.symmetric(vertical: 2),
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
      duration: Duration(milliseconds: 300),
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
            SizedBox(
              width: 10,
            ),
            Text(
              AppLocalization.of(context)!.message,
              style: TextStyle(
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
            SizedBox(
              width: 10,
            ),
            Text(
              AppLocalization.of(context)!.blockUser,
              style: TextStyle(
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
