import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CurrencyList extends StatefulWidget {
  const CurrencyList({super.key});

  @override
  State<CurrencyList> createState() => _CurrencyListState();
}

class _CurrencyListState extends State<CurrencyList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final List<Map<String, String>> currencyList = [
    {'name': 'Dollars (\$)', 'amount': '1\$ (₦1,690)'},
    {'name': 'Pounds (£)', 'amount': '1£ (₦1,690)'},
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          key: _scaffoldKey,
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
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: navyBlue,
            size: 24,
          ),
          onPressed: () async {
            Navigator.of(context).pop();
          }),
      centerTitle: false,
      title: Text(
        AppLocalization.of(context)!.currency,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        addCurrencyBtn(),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget addCurrencyBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.add,
        size: 16,
        color: blackFont,
      ),
      onTap: () async {
        await Navigator.of(context).pushNamed(Routes.ADD_EDIT_CURRENCY);
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: _buildProductAddOnList(),
    );
  }

  Widget _buildProductAddOnList() {
    return ListView.builder(
      itemCount: currencyList.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () async {
            await Navigator.of(context)
                .pushNamed(Routes.ADD_EDIT_CURRENCY, arguments: {
              'isEdit': true,
            });
          },
          child: currencyTile(currency: currencyList[index], index: index),
        );
        // }
      },
    );
  }

  Widget currencyTile({required Map<String, String> currency, int? index}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            currency['name'] ?? "",
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              fontFamily: "Inter",
            ),
          ),
          subtitle: Text(
            currency['amount'] ?? "",
            maxLines: 1,
            style: TextStyle(
              color: darkGrey,
              fontWeight: FontWeight.w600,
              fontSize: 10,
              fontFamily: "Inter",
            ),
          ),
        ),
      ),
    );
  }

  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    if (await checkConnection(context)) {
      setState(() {
        // Call the callback function with the updated list
        //to pass the list back to edit product page
        // widget.onListRefreshed!(productVariantList);
        _refreshController.refreshCompleted();
      });
    } else {
      _refreshController.refreshCompleted();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
