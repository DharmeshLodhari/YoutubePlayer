import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'bus_auth.dart';
import 'models/Ticket.dart';

class TicketDetail extends StatefulWidget {
  @override
  _TicketDetailState createState() => _TicketDetailState();
}

class _TicketDetailState extends State<TicketDetail> {
  // BusDashboardBloc _busDashboardBloc;

  bool isSwap = false;

  List<Ticket> tickets = [Ticket()];
  bool isLoading = false;

  @override
  void initState() {
    getResult();
    super.initState();
  }

  void getResult() async {
    isLoading = true;
    if (mounted) setState(() {});

    tickets = await BusAuthService().getTicket();

    isLoading = false;
    if (mounted) setState(() {});
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
    // _busDashboardBloc = Provider.of<BusDashboardBloc>(context);
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : SingleChildScrollView(
            child: ticketWithImage(),
          );
  }

  Widget ticketWithImage() {
    return Container(
      child: Stack(
        children: [
          Image.asset(
            "assets/images/bus_ticket_background.png",
          ),
          Container(
            height: 470,
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                bookingInfo(),
                const SizedBox(
                  height: 20,
                ),
                MySeparator(color: dividerColor),
                const SizedBox(
                  height: 20,
                ),
                boardingInfo(),
                const SizedBox(
                  height: 24,
                ),
                MySeparator(color: dividerColor),
                const SizedBox(
                  height: 40,
                ),
                Center(
                  child: Container(
                    height: 214,
                    width: 214,
                    child: CachedNetworkImage(imageUrl: tickets[0].qrCode!),
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                bookingInfo(),
                const SizedBox(
                  height: 20,
                ),
                MySeparator(color: dividerColor),
                const SizedBox(
                  height: 20,
                ),
                boardingInfo(),
                const SizedBox(
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
                  padding: const EdgeInsets.all(40),
                  child: CachedNetworkImage(
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        flexibleSpace(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              tickets[0].fromTime!,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: blackFont,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              tickets[0].from!,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: blackFont,
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 12,
        ),
        Container(
          width: 70,
          height: 40,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 6,
                child: Container(
                  width: 70,
                  child: Image.asset(
                    "assets/images/arrow_right.png",
                  ),
                ),
              ),
              Positioned(
                top: -6,
                left: 16,
                child: Text(
                  tickets[0].journeyTime!,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: darkGrey,
                  ),
                  overflow: TextOverflow.visible,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tickets[0].toTime!,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: blackFont,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              tickets[0].to!,
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
              const SizedBox(
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
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    tickets[0].gate!,
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
              const SizedBox(
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
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    tickets[0].seat!,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
