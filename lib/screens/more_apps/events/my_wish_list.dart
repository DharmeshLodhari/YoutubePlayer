import 'package:Slydo/screens/more_apps/events/event_tile.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'event_auth.dart';
import 'models/PartialEventItem.dart';

class MyWishList extends StatefulWidget {
  @override
  _MyWishListState createState() => _MyWishListState();
}

class _MyWishListState extends State<MyWishList> {
  List<PartialEventItem> eventList = [];

  bool isLoading = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void getResult() async {
    isLoading = true;
    eventList.clear();
    if (mounted) setState(() {});

    eventList = await EventAuthService().getPartialEventList();

    isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    getResult();
    super.initState();
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
    return Scaffold(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: eventList
                        .map(
                          (element) => Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: EventTileWithHeart(
                                partialEvent: element,
                              )),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
    );
  }
}
