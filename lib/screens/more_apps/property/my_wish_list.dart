import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/property_item.dart';
import 'property_auth.dart';
import 'property_dashboard_bloc.dart';
import 'property_tile.dart';

class MyWishList extends StatefulWidget {
  const MyWishList({super.key});

  @override
  State<MyWishList> createState() => _MyWishListState();
}

class _MyWishListState extends State<MyWishList> {
  late PropertyDashboardBloc _propertyDashboardBloc;

  List<PropertyItem> myWishList = [];

  bool isLoading = false;

  final RefreshController _refreshController =
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
    if (await checkConnection(context)) {
      getResult("");
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    _propertyDashboardBloc = Provider.of<PropertyDashboardBloc>(context);

    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          _propertyDashboardBloc.index = 0;
          return;
        }
      },
      child: Scaffold(
        backgroundColor: lightGrey,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: myWishList
                          .map((element) => Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
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
