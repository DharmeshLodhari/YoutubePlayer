import 'package:Slydo/screens/more_apps/train/train_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/train/train_ticket_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchTrain extends StatefulWidget {
  @override
  _SearchTrainState createState() => _SearchTrainState();
}

class _SearchTrainState extends State<SearchTrain> {
  TrainDashboardBloc _trainDashboardBloc;

  bool isSwap = false;

  @override
  void initState() {
    super.initState();
  }

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
          _trainDashboardBloc.index = 0;
          Navigator.pop(context);
        },
      ),
      bottom: swapPlace(),
    );
  }

  Widget scaffoldBody() {
    _trainDashboardBloc = Provider.of<TrainDashboardBloc>(context);
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: List.generate(
            7,
            (index) => InkWell(
              onTap: () {
                Navigator.of(context).pushNamed("/ticket-detail");
              },
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: TrainTicketTile()),
            ),
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
                          SizedBox(
                            width: 4,
                          ),
                          ClipOval(
                            child: Container(
                              height: 4,
                              width: 4,
                              color: navyBlueLight,
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          ClipOval(
                            child: Container(
                              height: 4,
                              width: 4,
                              color: navyBlueLight,
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          InkWell(
                            onTap: () {
                              isSwap = !isSwap;
                              setState(() {});
                            },
                            child: ClipOval(
                              child: Card(
                                elevation: 4,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 2),
                                shadowColor: boxShadow,
                                color: Colors.white,
                                borderOnForeground: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(14),
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
                          SizedBox(
                            width: 4,
                          ),
                          ClipOval(
                            child: Container(
                              height: 4,
                              width: 4,
                              color: navyBlueLight,
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          ClipOval(
                            child: Container(
                              height: 4,
                              width: 4,
                              color: navyBlueLight,
                            ),
                          ),
                          SizedBox(
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
                    SizedBox(
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
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
