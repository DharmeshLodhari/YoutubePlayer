import 'package:Slydo/screens/more_apps/bus/bus_ticket_tile.dart';
import 'package:Slydo/screens/more_apps/flight/flight_dashboard_bloc.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyFlightTicketList extends StatefulWidget {
  @override
  _MyFlightTicketListState createState() => _MyFlightTicketListState();
}

class _MyFlightTicketListState extends State<MyFlightTicketList> {
  FlightDashboardBloc _flightDashboardBloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          _flightDashboardBloc.index = 0;
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Flight tickets",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    _flightDashboardBloc = Provider.of<FlightDashboardBloc>(context);

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: List.generate(
            3,
            (index) => Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: BusTicketTile()),
          ),
        ),
      ),
    );
  }
}
