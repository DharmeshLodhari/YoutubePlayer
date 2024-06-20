import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/order/order_list_by_status.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderListNew extends StatefulWidget {
  const OrderListNew({super.key});

  @override
  State<OrderListNew> createState() => _OrderListNewState();
}

class _OrderListNewState extends State<OrderListNew> {
  late UserBloc userBloc;
  final GlobalKey<ScaffoldState> _scaffoldOrderListKey =
      GlobalKey<ScaffoldState>();

  DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  DateTimeRange? newDateTimeRange;
  List<ProductCategory> customCategories = [];
  String selectedStatus = "";
  bool isMerchant = true;

  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  void initState() {
    customCategories = const [
      ProductCategory("All"),
      ProductCategory("Awaiting payment"),
      ProductCategory("Processing"),
      ProductCategory("Shipped"),
      ProductCategory("Delivered"),
      ProductCategory("Cancelled")
    ];
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
          backgroundColor: Colors.white,
          appBar: appBar() as PreferredSizeWidget?,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              orderTabView(),
              const SizedBox(height: 20),
              getDateRangeText(),
              Expanded(
                child: PageStorage(
                  key: PageStorageKey("$selectedStatus$newDateTimeRange"),
                  bucket: _bucket,
                  child: OrderListByStatus(
                    selectedStatus:
                        selectedStatus == "All" ? "" : selectedStatus,
                    dateRange: newDateTimeRange,
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
            AppLocalization.of(context)!.orders,
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
        dateFilterIcon(),
        const SizedBox(width: 16),
      ],
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
}
