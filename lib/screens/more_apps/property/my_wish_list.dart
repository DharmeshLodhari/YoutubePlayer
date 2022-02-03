import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/PropertyItem.dart';
import 'property_auth.dart';
import 'property_dashboard_bloc.dart';
import 'property_tile.dart';

class MyWishList extends StatefulWidget {
  @override
  _MyWishListState createState() => _MyWishListState();
}

class _MyWishListState extends State<MyWishList> {
  late PropertyDashboardBloc _propertyDashboardBloc;

  List<PropertyItem> myWishList = [];

  bool isLoading = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    getResult("wishList");
    super.initState();
  }

  void getResult(String item) async {
    isLoading = true;
    myWishList.clear();
    if (mounted) {
      setState(() {});
    }

    myWishList = await PropertyAuthService().getPropertyList();

    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        getResult("");
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _propertyDashboardBloc = Provider.of<PropertyDashboardBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        _propertyDashboardBloc.index = 0;
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? Center(
                child: CircularLoadingIndicator(),
              )
            : SmartRefresher(
                enablePullDown: true,
                header: WaterDropHeader(
                  complete: Container(),
                  waterDropColor: navyBlue,
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: myWishList
                          .map((element) => Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: RentPropertyTile(
                                property: element,
                              )))
                          .toList(),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
