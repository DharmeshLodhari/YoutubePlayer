import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/payout.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/colors.dart';

class PayoutTile extends StatefulWidget {
  final Payout payout;

  PayoutTile({this.payout});

  @override
  _PayoutTileState createState() => _PayoutTileState();
}

class _PayoutTileState extends State<PayoutTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1),
          child: ListTile(
            dense: true,
            leading: getLeading(),
            title: getTitle(),
            subtitle: getDateTime(context),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  worldCurrencies[widget.payout.currency],
                  style: TextStyle(
                      fontFamily: "Roboto",
                      color: getStatusColor(widget.payout.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                Text(
                  moneyDisplayNormalizer(widget.payout.amount),
                  style: TextStyle(
                      color: getStatusColor(widget.payout.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getLeading() {
    return ClipOval(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed("/photo-viewer", arguments: widget.payout.bankLogo);
        },
        child: CachedNetworkImage(
          imageUrl: widget.payout.bankLogo,
          height: 48,
          width: 48,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
          placeholder: (context, url) => widget.payout.bankLogo == ""
              ? Icon(Icons.account_balance)
              : CircularLoadingIndicator(),
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    if (status == "Paid") {
      return navyBlue;
    } else if (status == "Pending") {
      return starYellow;
    } else {
      return mateRed;
    }
  }

  Widget getTitle() {
    return Text(
      widget.payout.bankName,
      style: TextStyle(
        color: blackFont,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget getDateTime(BuildContext context) {
    DateTime dateTime = DateTime.parse(widget.payout.timeStamp).toLocal();
    String date = DateFormat("dd/MM/yyyy").format(dateTime);
    String time = DateFormat("hh:mm a").format(dateTime);
    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 10),
    );
  }
}
