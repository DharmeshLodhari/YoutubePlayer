import 'package:Slydo/screens/more_apps/bus/bus_ticket_tile.dart';
import 'package:Slydo/screens/more_apps/train/train_dashboard_bloc.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyTrainTicketList extends StatefulWidget {
  @override
  _MyTrainTicketListState createState() => _MyTrainTicketListState();
}

class _MyTrainTicketListState extends State<MyTrainTicketList> {
  TrainDashboardBloc _trainDashboardBloc;

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
