import 'package:Slydo/screens/more_apps/bus/bus_dashboard_bloc.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TicketDetail extends StatefulWidget {
  @override
  _TicketDetailState createState() => _TicketDetailState();
}

class _TicketDetailState extends State<TicketDetail> {
  BusDashboardBloc _busDashboardBloc;

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
          // _busDashboardBloc.index = 0;
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Ticket",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    _busDashboardBloc = Provider.of<BusDashboardBloc>(context);
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: iconBtnGrey,
          child: Container(
            decoration: decorateBox(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  bookingInfo(),
                  SizedBox(
                    height: 20,
                  ),
                  MySeparator(color: dividerColor),
                  SizedBox(
                    height: 20,
                  ),
                  boardingInfo(),
                  SizedBox(
                    height: 20,
                  ),
                  MySeparator(color: dividerColor),
                  Container(
                    padding: EdgeInsets.all(40),
                    child: CachedNetworkImage(
                        imageUrl:
                            "https://www.pixavi.com/wp-content/uploads/2015/10/apb-qr-code.png"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget bookingInfo() {
    return Row(
      children: [
        flexibleSpace(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "9:00 AM",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: blackFont,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              "Lagos",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: blackFont,
              ),
            ),
          ],
        ),
        SizedBox(
          width: 12,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "2h30m",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: darkGrey,
              ),
            ),
            Stack(
              children: [
                Container(
                  width: 50,
                  child: MySeparator(color: blackFont),
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_right))
              ],
            ),
          ],
        ),
        SizedBox(
          width: 12,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "11:00 AM",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: blackFont,
              ),
            ),
            Text(
              "Abuja",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: blackFont,
              ),
            ),
          ],
        ),
        flexibleSpace()
      ],
    );
  }

  Widget boardingInfo() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              RoundedBackgroundIcon(
                width: 32,
                height: 32,
                backgroundColor: lightGrey,
                borderRadius: 12,
                icon: Icon(
                  SlydoAppIcon.gate,
                  color: blackFont,
                  size: 14,
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Row(
                children: [
                  Text(
                    "Gate : ",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: blackFont,
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    "G3",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: blackFont,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              RoundedBackgroundIcon(
                width: 32,
                height: 32,
                backgroundColor: lightGrey,
                borderRadius: 12,
                icon: Icon(
                  SlydoAppIcon.seat,
                  color: blackFont,
                  size: 14,
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Row(
                children: [
                  Text(
                    "Seat : ",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: blackFont,
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    "B1",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: blackFont,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}

class MySeparator extends StatelessWidget {
  final double height;
  final Color color;

  const MySeparator({this.height = 1.5, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 4.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
