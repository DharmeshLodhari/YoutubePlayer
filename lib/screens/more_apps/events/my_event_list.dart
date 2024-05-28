import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/events/event_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/events/event_tile.dart';
import 'package:Slydo/screens/more_apps/events/models/PartialEventItem.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'event_auth.dart';

class MyEventList extends StatefulWidget {
  @override
  _MyEventListState createState() => _MyEventListState();
}

class _MyEventListState extends State<MyEventList> {
  List<PartialEventItem> eventList = [];

  bool isLoading = false;
  RefreshController _refreshController =
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
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        getResult();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
      }
    });
  }

  late EventDashboardBloc _eventDashboardBloc;

  @override
  Widget build(BuildContext context) {
    _eventDashboardBloc = Provider.of<EventDashboardBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        _eventDashboardBloc.index = 0;
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: eventList
                          .map(
                            (element) => Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: EventTile(
                                  partialEventItem: element,
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
