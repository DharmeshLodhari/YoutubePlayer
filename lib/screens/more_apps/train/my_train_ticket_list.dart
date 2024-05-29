import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/train/train_auth.dart';
import 'package:Slydo/screens/more_apps/train/train_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/train/train_ticket_tile.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/Transport.dart';

class MyTrainTicketList extends StatefulWidget {
  @override
  _MyTrainTicketListState createState() => _MyTrainTicketListState();
}

class _MyTrainTicketListState extends State<MyTrainTicketList> {
  late TrainDashboardBloc _trainDashboardBloc;
  List<Transport> transports = [];
  bool isLoading = false;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() async {
    isLoading = true;
    transports.clear();
    if (mounted) setState(() {});

    transports = await TrainAuthService().getAvailableTransports();

    isLoading = false;
    if (mounted) setState(() {});
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
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar() as PreferredSizeWidget?,
      body: scaffoldBody(),
    );
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
          _trainDashboardBloc.index = 0;
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Train tickets",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    _trainDashboardBloc = Provider.of<TrainDashboardBloc>(context);

    return SmartRefresher(
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
                  children: transports
                      .map(
                        (element) => InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed("/ticket-detail");
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: TrainTicketTile(
                                transport: element,
                              )),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
    );
  }
}
