import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/payout.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/colors.dart';
import '../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';

class PayoutTile extends StatelessWidget {
  final Payout? payout;
  final Key? key;

  PayoutTile({this.payout, this.key}) : super(key: key);

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
                  worldCurrencies[payout!.currency!]!,
                  style: TextStyle(
                      fontFamily: "Roboto",
                      color: getStatusColor(payout!.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                Text(
                  moneyDisplayNormalizer(payout!.amount),
                  style: TextStyle(
                      color: getStatusColor(payout!.status),
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
    return checkBankImage();
  }

  Color getStatusColor(String? status) {
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
      trimString(payout!.bankName!),
      style: TextStyle(
        color: blackFont,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget getDateTime(BuildContext context) {
    DateTime dateTime = DateTime.parse(payout!.timeStamp!).toLocal();
    String date = DateFormat("dd/MM/yyyy").format(dateTime);
    String time = DateFormat("hh:mm a").format(dateTime);
    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 10),
    );
  }

  Widget checkBankImage() {
    String? url = payout!.bankLogo;

    String imageUrl = url!.replaceAll('https//', 'https://');
    if (payout!.bankName! == "") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 25,
        child: Text(
          getInitials(payout!.bankName!).toUpperCase(),
          style: TextStyle(color: white, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return ClipOval(
        child: GestureDetector(
          onTap: () {
            Navigator.of(myGlobals.navigationKey.currentContext!)
                .pushNamed("/photo-viewer", arguments: imageUrl);
          },
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            height: 48,
            width: 48,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fill,
            errorWidget: imageErrorWidget,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => payout!.bankLogo == ""
                ? Icon(Icons.account_balance)
                : CircularLoadingIndicator(),
          ),
        ),
      );
    }
  }
}
