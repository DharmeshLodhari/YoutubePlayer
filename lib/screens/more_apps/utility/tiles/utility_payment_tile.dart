import 'package:Slydo/screens/more_apps/utility/utility_auth.dart';
import 'package:Slydo/screens/more_apps/utility/utility_history_details.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// {"id":"3182c6bf-cc4c-428c-8cc7-a7869653e3be","status":"Successful","customer_username":"tosinmomodu","created_at":"2022-04-14T17:38:20.951735Z","product":"feded17b-db7e-425d-b2bd-2798fb9d7467"}

class UtilityPaymentTile extends StatelessWidget {
  final Map<String, dynamic>? payment;

  UtilityPaymentTile({this.payment});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        UtilityAuth()
            .getUtilityTransactionsDetails(transactionsId: payment!['id']);
        NavigationUtil.push(
          context,
          screen: UtilityHistoryDetailScreen(
            arguments: {},
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        shadowColor: boxShadowTwo,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Row(
            children: [
              getLeading(),
              SizedBox(
                width: 4,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getTitle(),
                  SizedBox(
                    height: 4,
                  ),
                  getDateTime(),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
              Expanded(
                  child: SizedBox(
                width: 1,
              )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'NGN 50',
                    // payment!['amount'],
                    style: TextStyle(
                        fontFamily: "Roboto",
                        color: blackFont,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  getPaymentStatus(),
                ],
              ),
              SizedBox(
                width: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getLeading() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: CachedNetworkImage(
        height: 50,
        width: 50,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
        imageUrl:
            "https://upload.wikimedia.org/wikipedia/commons/9/93/New-mtn-logo.jpg",
      ),
    );
  }

  Widget getPaymentStatus() {
    Color color = getStatusColor(payment!['status']);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(
        payment!['status'],
        style:
            TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  Color getStatusColor(String? status) {
    if (status == "Processing") {
      return naturalGreen;
    } else if (status == "Complete") {
      return navyBlue;
    } else if (status == "Pending") {
      return starYellow;
    } else if (status == "Canceled") {
      return mateRed;
    } else if (status == "Paused") {
      return darkGrey;
    } else {
      return navyBlue;
    }
  }

  Widget getTitle() {
    return Text(
      payment!['customer_username'],
      // payment!['name'],
      style: TextStyle(
        color: blackFont,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget getDateTime() {
    return Text(
      _getFormattedDateTime(),
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 10),
    );
  }

  String _getFormattedDateTime() {
    return '${DateFormat.yMMMM().format(DateTime.parse(payment!['created_at']))} ${DateFormat.Hm().format(DateTime.parse(payment!['created_at']))}';
  }
}
