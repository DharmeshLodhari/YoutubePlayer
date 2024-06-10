import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/payment/transactions/cash_out_transaction_list.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/payment/transactions/slydo_transaction_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/search_user.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/tab_selection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionList extends StatefulWidget {
  final dynamic arguments;

  TransactionList({Key? key, this.arguments}) : super(key: key);

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  final GlobalKey<ScaffoldState> _scaffoldTransactionKey =
      GlobalKey<ScaffoldState>();

  DateTimeRange? newDateTimeRange;
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  late PageController _pageViewController;
  int currentAskTapOnHome = 0;

  // variables for to getting filter transactions
  bool? moneyIn;
  String? userName;

  late CustomerProfileBloc customerProfileBloc;

  final GlobalKey _key = LabeledGlobalKey("transactionListPopUpMenu");
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;
  bool isFirstTime = true;

  @override
  void initState() {
    _pageViewController =
        PageController(initialPage: widget.arguments['page'] ?? 0);

    currentAskTapOnHome = widget.arguments['page'] ?? 0;

    super.initState();
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

    return PopScope(
      onPopInvoked: (didPop) async {
        if(didPop) {
          menu.closeMenu();
          customerProfileBloc.customer = null;
          return;
        }
      },
      child: Scaffold(
        key: _scaffoldTransactionKey,
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            getDateRangeText(),
            const SizedBox(
              height: 15.0,
            ),
            _buildTabs(),
            _buildPageView(),
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
                fontFamily: "Inter",
              ),
            ),
          )
        : const SizedBox.shrink();
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
            color: blackFont,
            fontSize: 18,
            fontFamily: "Inter",
            fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        getSearchBtn(),
        const SizedBox(width: 10.0),
        openGraphBtn(),
        const SizedBox(width: 10.0),
        dateFilterIcon(),
        const SizedBox(width: 10.0),
        popUpMenuButton(),
        const SizedBox(
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
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.search,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () async {
            final CustomerProfile? userFound = await NavigationUtil.push(
              context,
              screen: const SearchUser(),
            );

            if (userFound != null) {
              userName = userFound.userName;
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
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: const Icon(
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
              // _onRefresh();
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

  Widget _buildTabs() {
    return Column(
      children: [
        TabSelection(
          onTap: (index) {
            currentAskTapOnHome = index;
            _pageViewController.jumpToPage(currentAskTapOnHome);
            if (mounted) setState(() {});
          },
          currentIndex: currentAskTapOnHome,
          firstTab: 'Slydo',
          secondTab: 'Bank Transfer',
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _buildPageView() {
    return Expanded(
      child: PageView(
        onPageChanged: (currentPage) {
          updateCurrentAskTapOnHome(index: currentPage);
        },
        controller: _pageViewController,
        children: [
          SlydoTransactionList(),
          CashoutTransactionsList(),
        ],
      ),
    );
  }

  void updateCurrentAskTapOnHome({required int index}) {
    setState(() {
      currentAskTapOnHome = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
