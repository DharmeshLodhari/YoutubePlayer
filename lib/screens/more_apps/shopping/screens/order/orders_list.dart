import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../routes/route_constants.dart';
import '../../shopping_auth.dart';
import '../../tiles/order_tile.dart';

class OrdersList extends StatefulWidget {
  @override
  _OrdersListState createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  final GlobalKey<ScaffoldState> _scaffoldOrderListKey =
      new GlobalKey<ScaffoldState>();
  final _auth = ShoppingAuthService();
  SlidableController? _slideController;
  int? count = 0;
  String? next = "";
  String? previous = "";
  List orderList = [];
  bool isSwitched = true;

  late UserBloc userBloc;

  ScrollController _scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;

  // variables for to getting filter orderList
  String filterValue = "";
  DateTime? filterDate;

  GlobalKey _key = LabeledGlobalKey("orderListPopUpMenu");
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;

  @protected
  void initState() {
    this.getList();
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

    super.initState();
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        orderList = [];
        noItemInList = false;
        getList();
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
    if (index == 7 || index == 8) {
      if (index == 7) {
        filterDate = null;
      }
      if (index == 8) {
        filterValue = "";
      }
    } else {
      selectedMenuItemIndex = index;
      filterValue = value;
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

    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      children: [
        CustomizedPopUpMenuItem(title: "New order", value: "new order"),
        CustomizedPopUpMenuItem(
            title: "Awaiting payment", value: "awaiting payment"),
        CustomizedPopUpMenuItem(title: "Canceled", value: "canceled"),
        CustomizedPopUpMenuItem(title: "Completed", value: "completed"),
        CustomizedPopUpMenuItem(title: "On hold", value: "on hold"),
        CustomizedPopUpMenuItem(title: "Pending", value: "pending"),
        CustomizedPopUpMenuItem(title: "Processing", value: "processing"),
        CustomizedPopUpMenuItem(title: "Clear Date", value: "clear"),
        CustomizedPopUpMenuItem(title: "Clear Filter", value: "clear"),
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
        key: _scaffoldOrderListKey,
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: _buildOrderList()),
      ),
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
        AppLocalization.of(context)!.orders,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        Switch(
            value: isSwitched,
            activeThumbImage: AssetImage('assets/images/outgoing_arrow.png'),
            inactiveThumbImage: AssetImage('assets/images/incoming_arrow.png'),
            activeColor: Colors.black.withOpacity(0.8),
            onChanged: (value) {
              if (value == true) {
                showSnackbar(context,
                    message: 'These are your outgoing orders', duration: 1000);
              } else {
                showSnackbar(context,
                    message: 'These are your incoming orders', duration: 1000);
              }
              setState(() {
                count = 0;
                next = "";
                previous = "";
                orderList = [];
                noItemInList = false;

                isSwitched = value;

                getList();
              });
            }),
        SizedBox(width: 8),
        dateFilterIcon(),
        SizedBox(width: 8),
        popUpMenuButton(),
        SizedBox(
          width: 16,
        ),
      ],
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
            filterDate = await showDatePicker(
                builder: customThemeBuilder,
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.parse("2020-01-01"),
                lastDate: DateTime.now());
            setState(() {});
            _onRefresh();
          },
        ),
      ),
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

  Widget _buildOrderList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noOrdersPresent,
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 4),
            //+1 for progressbar
            itemCount: orderList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == orderList.length) {
                return _buildIndicator();
              } else {
                return _getSlidableWithLists(context, orderList[index], index);
              }
            },
            controller: _scrollController,
          );
  }

  Widget _buildIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
            opacity: isLoading ? 1.0 : 00,
            child: isLoading ? CircularLoadingIndicator() : Container()),
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
        DateFormat dateFormat = DateFormat('yyyy-MM-dd');
        String? formattedDate;
        if (filterDate != null) {
          debugPrint("DOB:- ${dateFormat.format(filterDate!)}");
          formattedDate = dateFormat.format(filterDate!);
        }

        var result = await _auth.listOrders(
          next,
          previous,
          filterValue,
          formattedDate,
          isMerchant: isSwitched,
        );
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];

        print('RESULTS ::: $tempList');

        isLoading = false;
        orderList.addAll(tempList);

        if (mounted) setState(() {});

        if (next != null) {
          getList();
        }
      }
      if (orderList.isEmpty) {
        noItemInList = true;

        if (mounted) setState(() {});
      } else if (next == null && orderList.length > 6) {
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
        _scaffoldOrderListKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget sendRequestButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: InkWell(
        onTap: () {
          Connectivity().checkConnectivity().then((value) {
            var connectionResult = value;
            if (connectionResult == ConnectivityResult.wifi ||
                connectionResult == ConnectivityResult.mobile) {
              Navigator.of(context).pushNamed('/request-payment',
                  arguments: <String, bool>{
                    'isRequest': true,
                    'isFromProfile': true
                  });
            } else {
              showToast(
                  message: AppLocalization.of(context)!
                      .internetConnectionNotAvailable);
            }
          });
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}

  List<Widget> listSecondaryActions(Order order, int index) {
    return [
      SlideActionButton(
          backgroundColor: naturalGreen,
          icon: SlydoAppIcon.text_message,
          onTap: () {
            var recipient = userBloc.user.userName == order.merchant
                ? order.customer
                : order.merchant;

            Navigator.of(context).pushNamed(Routes.COMPOSE_MESSAGE, arguments: {
              'recipient': recipient,
              'subject': AppLocalization.of(context)!.orderDetail +
                  " : " +
                  AppLocalization.of(context)!.ref +
                  " #${order.id}",
            });
          },
          title: AppLocalization.of(context)!.message,
          slideController: _slideController),
    ];
  }

  List<Widget> listActionSlideActions(Order order, int index) {
    return [];
  }

  Widget _getSlidableWithLists(BuildContext context, Order order, int index) {
    return Slidable(
      key: Key(order.customer!),
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(order),
      actions: listActionSlideActions(order, index),
      secondaryActions: listSecondaryActions(order, index),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.order);

  final Order order;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.ORDER_DETAIL_PAGE,
            arguments: {"order": order});
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: OrderTile(
          order: order,
          key: Key("Order:${order.id}"),
        ),
      ),
    );
  }
}
