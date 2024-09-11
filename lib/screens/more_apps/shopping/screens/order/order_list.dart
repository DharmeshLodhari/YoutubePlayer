import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/order/order_list_by_status.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/order/search_order_screen.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/user_product_list.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  late UserBloc userBloc;
  final GlobalKey<ScaffoldState> _scaffoldOrderListKey =
      GlobalKey<ScaffoldState>();

  DateFormat dateFormat = DateFormat('yyyy/MM/dd');
  DateTimeRange? newDateTimeRange;
  List<ProductCategory> customCategories = [];
  String selectedStatus = "";
  bool isMerchant = true;
  final PageStorageBucket _bucket = PageStorageBucket();
  String selectedFilter = "all";
  bool isFilterApplied = false;

  List<Filter> filterList = [
    Filter(title: "All", value: "all"),
    Filter(title: "Delivery", value: "Delivery"),
    Filter(title: "Eat in/ In store", value: 'InStore-EatIn'),
    Filter(title: "Pickup", value: 'Pickup'),
    Filter(title: "Refund Successful", value: 'Refund Successful'),
    Filter(title: "Pending Refund Request", value: 'Pending Refund Request'),
    Filter(title: "Sales", value: 'is_outgoing_order'),
    Filter(title: "Purchase", value: 'is_incoming_order'),
  ];

  @override
  void initState() {
    customCategories = const [
      ProductCategory("New Order"),
      ProductCategory("Processing"),
      ProductCategory("Awaiting Payment"),
      ProductCategory("Shipped"),
      ProductCategory("Completed"),
      ProductCategory("On Hold"),
      ProductCategory("Canceled"),
      ProductCategory("All"),
    ];
    selectedStatus = customCategories.first.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          key: _scaffoldOrderListKey,
          backgroundColor: lightGrey,
          appBar: appBar() as PreferredSizeWidget?,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              orderTabView(),
              getDateRangeText(),
              Expanded(
                child: PageStorage(
                  key: PageStorageKey(
                      "$selectedStatus$newDateTimeRange$selectedFilter"),
                  bucket: _bucket,
                  child: OrderListByStatus(
                    selectedStatus:
                        selectedStatus == "All" ? "" : selectedStatus,
                    dateRange: newDateTimeRange,
                    filterValue: selectedFilter == "all" ? "" : selectedFilter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getDateRangeText() {
    return newDateTimeRange != null
        ? Container(
            padding: const EdgeInsets.all(10),
            color: greyBorderColor.withOpacity(0.2),
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              '${dateFormat.format(newDateTimeRange!.start)} - ${dateFormat.format(newDateTimeRange!.end)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: blackFont,
                  fontSize: 14,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w600),
            ),
          )
        : const SizedBox.shrink();
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
      title: Row(
        children: [
          Text(
            AppLocalization.of(context)?.orders ?? "",
            style: TextStyle(
              color: blackFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
      actions: <Widget>[
        _buildSearchIcon(),
        const SizedBox(width: 16),
        dateFilterIcon(),
        const SizedBox(width: 16),
        _buildFilterIcon(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSearchIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: const Icon(
        Icons.search,
        size: 20,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchOrderScreen(),
          ),
        );
      },
      backgroundColor: iconBtnGrey,
      enableMargin: false,
    );
  }

  Widget dateFilterIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
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
          // _onRefresh();
        }
      },
      backgroundColor: iconBtnGrey,
      enableMargin: false,
    );
  }

  Widget orderTabView() {
    return Container(
      color: white,
      child: Column(
        children: [
          const SizedBox(height: 15),
          Container(
            height: 32,
            padding: const EdgeInsets.only(left: 12),
            margin: const EdgeInsets.only(right: 16),
            alignment: Alignment.centerLeft,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                ...customCategories.map((e) => InkWell(
                      onTap: () {
                        setState(() {
                          selectedStatus = e.name;
                        });
                      },
                      child: Container(
                        decoration: selectedStatus == e.name
                            ? BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: navyBlue,
                                    width:
                                        2.5, // This would be the width of the underline
                                  ),
                                ),
                              )
                            : BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: greySecondaryYarn.withOpacity(0.5),
                                    width:
                                        1, // This would be the width of the underline
                                  ),
                                ),
                              ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            e.name.toTitleCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Inter",
                              color: selectedStatus == e.name
                                  ? navyBlue
                                  : darkGrey,
                              fontWeight: selectedStatus == e.name
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterIcon() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(right: 8),
          child: Column(
            children: [
              Expanded(
                child: RoundedBackgroundIcon(
                  height: 34,
                  width: 34,
                  icon: const Icon(
                    Icons.filter_alt_rounded,
                    size: 20,
                  ),
                  onTap: () async {
                    await Future.delayed(const Duration(milliseconds: 100))
                        .then((value) => showFilterProductSheet());
                  },
                  backgroundColor: iconBtnGrey,
                  enableMargin: true,
                ),
              ),
            ],
          ),
        ),
        if (isFilterApplied)
          Positioned(
            top: 10,
            right: 6,
            child: ClipOval(
              child: Container(
                height: 8,
                width: 8,
                color: naturalGreen,
              ),
            ),
          )
        else
          Container()
      ],
    );
  }

  void showFilterProductSheet() {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        enableDrag: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter bottomSheetSetState) =>
                Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Filter",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w700,
                          color: blackFont),
                    ),
                    const SizedBox(height: 40),
                    SingleChildScrollView(
                      child: Column(
                        children: filterList.map<Widget>((filter) {
                          if (selectedFilter == "") selectedFilter = "all";
                          if (selectedFilter == filter.value) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  filter.title ?? "",
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
                                  Navigator.pop(context);
                                  menuItemSelectionChange(filter.value ?? "");
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              filter.title ?? "",
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context);
                              menuItemSelectionChange(filter.value ?? "");
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void menuItemSelectionChange(String value) {
    switch (value) {
      case "all":
        setState(() {
          selectedFilter = "all";
          isFilterApplied = false;
        });
        break;
      case "Delivery":
        setState(() {
          selectedFilter = "Delivery";
          isFilterApplied = true;
        });
        break;
      case "InStore-EatIn":
        setState(() {
          selectedFilter = "InStore-EatIn";
          isFilterApplied = true;
        });
        break;
      case "Pickup":
        setState(() {
          selectedFilter = "Pickup";
          isFilterApplied = true;
        });
        break;
      case "Refund Successful":
        setState(() {
          selectedFilter = "Refund Successful";
          isFilterApplied = true;
        });
        break;
      case "Pending Refund Request":
        setState(() {
          selectedFilter = "Pending Refund Request";
          isFilterApplied = true;
        });
        break;
      case "is_incoming_order":
        setState(() {
          selectedFilter = "is_incoming_order";
          isFilterApplied = true;
        });
        break;
      case "is_outgoing_order":
        setState(() {
          selectedFilter = "is_outgoing_order";
          isFilterApplied = true;
        });
        break;
      default:
        setState(() {
          isFilterApplied = false;
        });
        break;
    }
    setState(() {});
    // debugPrint('menuItemSelectionChange--->');
    // _onRefresh();
  }

  void _onProductRefresh() async {
    if (await checkConnection(context)) {}
  }
}
