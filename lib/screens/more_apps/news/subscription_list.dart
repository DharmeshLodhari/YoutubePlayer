import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/news/models/SubscriptionItem.dart';
import 'package:Slydo/screens/more_apps/news/news_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

import 'news_auth.dart';

class SubscriptionList extends StatefulWidget {
  @override
  _SubscriptionListState createState() => _SubscriptionListState();
}

class _SubscriptionListState extends State<SubscriptionList> {
  List<SubscriptionItem> subscriptionListItem = [];
  bool isLoading = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() async {
    isLoading = true;
    subscriptionListItem.clear();
    if (mounted) {
      setState(() {});
    }

    subscriptionListItem = await NewsAuthService().getSubscriptionList();

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
        getResult();
        _refreshController.refreshCompleted();
      } else {
        Toast.show(
            AppLocalization.of(context).internetConnectionNotAvailable, context,
            gravity: Toast.BOTTOM, backgroundColor: navyBlue);
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: scaffoldBody());
  }

  Widget scaffoldBody() {
    return isLoading
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
              child: Column(
                children: subscriptionListItem
                    .map((subscriptionItem) => SubscriptionTile(
                          subscriptionItem: subscriptionItem,
                        ))
                    .toList(),
              ),
            ),
          );
  }
}
