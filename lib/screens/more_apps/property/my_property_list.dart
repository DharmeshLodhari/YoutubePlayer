import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/property_item.dart';
import 'property_auth.dart';
import 'property_dashboard_bloc.dart';
import 'property_tile.dart';

class MyPropertyList extends StatefulWidget {
  const MyPropertyList({super.key});

  @override
  State<MyPropertyList> createState() => _MyPropertyListState();
}

class _MyPropertyListState extends State<MyPropertyList> {
  List<PropertyItem> properties = [];
  bool isLoading = false;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  late PropertyDashboardBloc _propertyDashboardBloc;

  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() async {
    isLoading = true;
    properties.clear();
    if (mounted) setState(() {});

    properties = await PropertyAuthService().getPropertyList();

    isLoading = false;
    if (mounted) setState(() {});
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      getResult();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
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
        backgroundColor: lightGrey,
        body: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: navyBlue,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: isLoading
              ? Center(
                  child: CircularLoadingIndicator(),
                )
              : SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: properties
                          .map(
                            (element) => Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: RentPropertyTileWithoutHeart(
                                  property: element,
                                )),
                          )
                          .toList(),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
