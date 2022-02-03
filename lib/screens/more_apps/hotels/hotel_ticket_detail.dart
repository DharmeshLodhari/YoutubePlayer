import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'hotel_dashboard_bloc.dart';

class EventTicketDetail extends StatefulWidget {
  @override
  _EventTicketDetailState createState() => _EventTicketDetailState();
}

class _EventTicketDetailState extends State<EventTicketDetail> {
  late HotelDashboardBloc _hotelDashboardBloc;

  bool isSwap = false;

  @override
  void initState() {
    super.initState();
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
    _hotelDashboardBloc = Provider.of<HotelDashboardBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        _hotelDashboardBloc.index = 0;
        return Future.value(true);
      },
      child: SingleChildScrollView(
        child: ticketWithImage(),
      ),
    );
  }

  Widget ticketWithImage() {
    return Container(
      child: Stack(
        children: [
          Image.asset(
            "assets/images/event_ticket_background.png",
          ),
          Container(
            height: 570,
            padding: EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                bookingInfo(),
                SizedBox(
                  height: 24,
                ),
                MySeparator(color: dividerColor),
                SizedBox(
                  height: 28,
                ),
                placeInfo(),
                SizedBox(
                  height: 16,
                ),
                MySeparator(color: dividerColor),
                SizedBox(
                  height: 40,
                ),
                Center(
                  child: Container(
                    height: 214,
                    width: 214,
                    child: CachedNetworkImage(
                        errorWidget: imageErrorWidget,
                        imageUrl:
                            "https://www.pixavi.com/wp-content/uploads/2015/10/apb-qr-code.png"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget ticketWithOutImage() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                placeInfo(),
                SizedBox(
                  height: 20,
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: -30,
                      top: -10,
                      child: ClipOval(
                          child: Container(
                        height: 20,
                        width: 20,
                        color: lightGrey,
                      )),
                    ),
                    Row(
                      children: [
                        Expanded(child: MySeparator(color: dividerColor)),
                      ],
                    ),
                    Positioned(
                      right: -30,
                      top: -10,
                      child: ClipOval(
                          child: Container(
                        height: 20,
                        width: 20,
                        color: lightGrey,
                      )),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(40),
                  child: CachedNetworkImage(
                      errorWidget: imageErrorWidget,
                      imageUrl:
                          "https://www.pixavi.com/wp-content/uploads/2015/10/apb-qr-code.png"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bookingInfo() {
    return Text(
      '“Sundays on the beach" Brunch & beach party',
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: blackFont,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget placeInfo() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  RoundedBackgroundIcon(
                    backgroundColor: lightGrey,
                    height: 32,
                    width: 32,
                    borderRadius: 12,
                    icon: Icon(
                      SlydoAppIcon.date,
                      size: 14,
                      color: blackFont,
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Text(
                      "Sunday, October 18 • 6:54 PM",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: blackFont),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  RoundedBackgroundIcon(
                    backgroundColor: lightGrey,
                    height: 32,
                    borderRadius: 12,
                    width: 32,
                    icon: Icon(
                      SlydoAppIcon.location,
                      size: 14,
                      color: blackFont,
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Text(
                      "Savana beach bar",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: blackFont),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  RoundedBackgroundIcon(
                    backgroundColor: lightGrey,
                    borderRadius: 12,
                    height: 32,
                    width: 32,
                    icon: Icon(
                      SlydoAppIcon.price_tag,
                      size: 14,
                      color: blackFont,
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Row(
                    children: [
                      Icon(
                        SlydoAppIcon.naira,
                        color: navyBlue,
                        size: 10,
                      ),
                      Text(
                        "34.00",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: navyBlue),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
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
