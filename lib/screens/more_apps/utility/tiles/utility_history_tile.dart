import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/utility/models/utility_transaction_model.dart';
import 'package:Slydo/screens/more_apps/utility/utility_auth.dart';
import 'package:Slydo/screens/more_apps/utility/utility_history_details.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UtilityHistoryTile extends StatelessWidget {
  final UtilityHistoryModel utilityHistoryModel;

  UtilityHistoryTile({required this.utilityHistoryModel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        NavigationUtil.push(
          context,
          screen: UtilityHistoryDetailScreen(
            transactionId: utilityHistoryModel.transactionId,
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
              SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getTitle(),
                  SizedBox(height: 4),
                  utilityHistoryModel.amount.toString().length >= amountLimit
                      ? getAmount()
                      : SizedBox.shrink(),
                  SizedBox(height: 4),
                  getDateTime(),
                  SizedBox(height: 8),
                ],
              ),
              Expanded(
                child: SizedBox(width: 1),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  utilityHistoryModel.amount.toString().length >= amountLimit
                      ? SizedBox.shrink()
                      : getAmount(),
                  SizedBox(height: 8),
                  getPaymentStatus(),
                ],
              ),
              SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget getAmount() {
    return Row(
      children: [
        Text(
          worldCurrencies[utilityHistoryModel.currency]!,
          style: TextStyle(
              fontFamily: "Inter", fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(utilityHistoryModel.amount),
          style: TextStyle(
              fontFamily: "Inter",
              color: blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
      ],
    );
  }

  Widget getLeading() {
    return Card(
      elevation: 10,
      shadowColor: Color(0XFF314167).withOpacity(0.08),
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: CachedNetworkImage(
          height: 35,
          width: 35,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
          imageUrl: utilityHistoryModel.providerAvatar,
        ),
      ),
    );
  }

  Widget getPaymentStatus() {
    Color color = getStatusColor(utilityHistoryModel.status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(
        utilityHistoryModel.status,
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
      utilityHistoryModel.customerUsername,
      // payment!['name'],
      style: TextStyle(
        color: blackFont,
        fontWeight: FontWeight.w600,
        fontSize: 16,
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
    String time =
        DateFormat.jm().format(DateTime.parse(utilityHistoryModel.createdAt));
    String date =
        DateFormat.yMd().format(DateTime.parse(utilityHistoryModel.createdAt));
    return '$date • $time';
  }
}
