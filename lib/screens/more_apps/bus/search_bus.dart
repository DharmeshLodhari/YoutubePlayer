import 'package:Slydo/screens/more_apps/bus/bus_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/bus/bus_ticket_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchBus extends StatefulWidget {
  @override
  _SearchBusState createState() => _SearchBusState();
}

class _SearchBusState extends State<SearchBus> {
  BusDashboardBloc _busDashboardBloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: appBar(),
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
          // _busDashboardBloc.index = 0;
          Navigator.pop(context);
        },
      ),
      bottom: swapPlace(),
    );
  }

  Widget scaffoldBody() {
    _busDashboardBloc = Provider.of<BusDashboardBloc>(context);
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: List.generate(
            7,
            (index) => Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: BusTicketTile()),
          ),
        ),
      ),
    );
  }

  Widget swapPlace() {
    return PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: Container(
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
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      "Lagos",
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
                          ClipOval(
                            child: Container(
                              height: 4,
                              width: 4,
                              color: navyBlueLight,
                            ),
                          ),
                          ClipOval(
                            child: Container(
                              height: 4,
                              width: 4,
                              color: navyBlueLight,
                            ),
                          ),
                          ClipOval(
                            child: Container(
                              height: 4,
                              width: 4,
                              color: navyBlueLight,
                            ),
                          ),
                          ClipOval(
                            child: Container(
                              decoration: decorateBox(),
                              height: 50,
                              width: 50,
                            ),
                          ),
                          ClipOval(
                            child: Container(
                              height: 4,
                              width: 4,
                              color: navyBlueLight,
                            ),
                          ),
                          ClipOval(
                            child: Container(
                              height: 4,
                              width: 4,
                              color: navyBlueLight,
                            ),
                          ),
                          ClipOval(
                            child: Container(
                              height: 4,
                              width: 4,
                              color: navyBlueLight,
                            ),
                          ),
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
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      "Abuja",
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
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
