import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/bus/bus_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/bus/bus_ticket_tile.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'bus_auth.dart';
import 'models/Transport.dart';

class MyBusTicketList extends StatefulWidget {
  @override
  _MyBusTicketListState createState() => _MyBusTicketListState();
}

class _MyBusTicketListState extends State<MyBusTicketList> {
  late BusDashboardBloc _busDashboardBloc;

  List<Transport> transports = [];
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
    transports.clear();
    if (mounted) setState(() {});

    transports = await BusAuthService().getAvailableTransports();

    isLoading = false;
    if (mounted) setState(() {});
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
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
          _busDashboardBloc.index = 0;
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Bus tickets",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    _busDashboardBloc = Provider.of<BusDashboardBloc>(context);

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
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: transports
                      .map(
                        (element) => InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed("/ticket-detail");
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: BusTicketTile(
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
