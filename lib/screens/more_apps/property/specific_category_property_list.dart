import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/property_item.dart';
import 'property_auth.dart';
import 'property_dashboard_bloc.dart';
import 'property_tile.dart';

class SpecificCategoryPropertyList extends StatefulWidget {
  const SpecificCategoryPropertyList({super.key});

  @override
  State<SpecificCategoryPropertyList> createState() =>
      _SpecificCategoryPropertyListState();
}

class _SpecificCategoryPropertyListState
    extends State<SpecificCategoryPropertyList> {
  late PropertyDashboardBloc _propertyDashboardBloc;

  List<PropertyItem> propertyItem = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;

  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() async {
    isLoading = true;
    propertyItem.clear();
    if (mounted) setState(() {});

    propertyItem = await PropertyAuthService().getPropertyList();

    isLoading = false;
    if (mounted) setState(() {});
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
        appBar: appBar() as PreferredSizeWidget?,
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
                      children: propertyItem
                          .map((property) => Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: RentPropertyTile(
                                property: property,
                              )))
                          .toList(),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      getResult();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
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
      title: Text(
        "Popular in London",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
    );
  }
}
