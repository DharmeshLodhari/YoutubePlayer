import 'package:Slydo/screens/more_apps/flight/flight_auth.dart';
import 'package:Slydo/screens/more_apps/flight/flight_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/flight/flight_ticket_tile.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/transport_model.dart';

class SearchFlight extends StatefulWidget {
  const SearchFlight({super.key});

  @override
  State<SearchFlight> createState() => _SearchFlightState();
}

class _SearchFlightState extends State<SearchFlight> {
  late FlightDashboardBloc _flightDashboardBloc;

  bool isSwap = false;

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

    transports = await FlightAuthService().getAvailableTransports();

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
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: appBar() as PreferredSizeWidget?,
      body: scaffoldBody(),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
          _flightDashboardBloc.index = 0;
          Navigator.pop(context);
        },
      ),
      bottom: swapPlace() as PreferredSizeWidget?,
    );
  }

  Widget scaffoldBody() {
    _flightDashboardBloc = Provider.of<FlightDashboardBloc>(context);
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
                              child: FlightTicketTile(
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

  Widget swapPlace() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Row(
              children: [
                flexibleSpace(flex: 1),
                Column(
                  children: [
                    Text(
                      "From",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: darkGrey,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      isSwap ? "Abuja" : "Lagos",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: blackFont,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Row(
                        children: <Widget>[
                          flexibleSpace(),
                          ClipOval(
                            child: Container(
                              height: 4,
                              width: 4,
                              color: navyBlueLight,
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          ClipOval(
                            child: Container(
                              height: 4,
                              width: 4,
                              color: navyBlueLight,
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          ClipOval(
                            child: Container(
                              height: 4,
                              width: 4,
                              color: navyBlueLight,
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          InkWell(
                            onTap: () {
                              isSwap = !isSwap;
                              setState(() {});
                              getResult();
                            },
                            child: ClipOval(
                              child: Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 2),
                                shadowColor: boxShadow,
                                color: Colors.white,
                                borderOnForeground: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 6.0, top: 4, bottom: 4),
                                    child: Icon(
                                      SlydoAppIcon.swap,
                                      size: 10,
                                      color: navyBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          ClipOval(
                            child: Container(
                              height: 4,
                              width: 4,
                              color: navyBlueLight,
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          ClipOval(
                            child: Container(
                              height: 4,
                              width: 4,
                              color: navyBlueLight,
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          ClipOval(
                            child: Container(
                              height: 4,
                              width: 4,
                              color: navyBlueLight,
                            ),
                          ),
                          flexibleSpace(),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "To",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: darkGrey,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      isSwap ? "Lagos" : "Abuja",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: blackFont,
                      ),
                    ),
                  ],
                ),
                flexibleSpace(flex: 1),
              ],
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
