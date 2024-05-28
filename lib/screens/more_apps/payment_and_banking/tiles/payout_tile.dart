import 'package:Slydo/data/currency.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/payout.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PayoutTile extends StatelessWidget {
  final Payout? payout;
  final Key? key;

  PayoutTile({this.payout, this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.PAYOUT_TRANSACTION_DETAIL,
            arguments: {'transaction': payout});
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        shadowColor: boxShadowTwo,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: ListTile(
              dense: true,
              leading: getLeading(),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getBankName(),
                  const SizedBox(
                    height: 2.0,
                  ),
                  getAccountName(),
                ],
              ),
              subtitle: getMaskedAccountNumber(),
              trailing: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          worldCurrencies[payout!.currency!]!,
                          style: TextStyle(
                              fontFamily: "Inter",
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
                    const SizedBox(
                      height: 2.0,
                    ),
                    getPayoutStatus(),
                    const SizedBox(
                      height: 2.0,
                    ),
                    getDateTime(context),
                  ],
                ),
              ),
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

  Widget getBankName() {
    return Text(
      appendStringDot(payout!.bankName!, 20),
      style: TextStyle(
        color: blackFont,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }

  Widget getDateTime(BuildContext context) {
    final DateTime dateTime = DateTime.parse(payout!.timeStamp!).toLocal();
    final String date = DateFormat("dd/MM/yyyy").format(dateTime);
    final String time = DateFormat("hh:mm a").format(dateTime);
    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 10),
    );
  }

  Widget checkBankImage() {
    final String? url = payout!.bankLogo;

    final String imageUrl = url!.replaceAll('https//', 'https://');
    if (payout!.bankLogo! == "") {
      return GestureDetector(
        onTap: () {
          Navigator.of(myGlobals.navigationKey.currentContext!).pushNamed(
              "/photo-viewer",
              arguments: getInitials(payout!.bankName!).toUpperCase());
        },
        child: CircleAvatar(
          backgroundColor: navyBlue,
          radius: 25,
          child: Text(
            getInitials(payout!.bankName!).toUpperCase(),
            style: TextStyle(color: white, fontWeight: FontWeight.w700),
          ),
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
                ? const Icon(Icons.account_balance)
                : CircularLoadingIndicator(),
          ),
        ),
      );
    }
  }

  Widget getAccountName() {
    return Text(
      appendStringDot(payout!.accountName!, 20),
      style: TextStyle(
        color: darkGrey,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  Widget getMaskedAccountNumber() {
    return Text(
      getFormattedAccountNumber(
          accountNumber: payout!.accountNumber!.toString()),
      style: TextStyle(
        color: darkGrey,
        fontWeight: FontWeight.w600,
        fontSize: 10,
      ),
    );
  }

  Widget getPayoutStatus() {
    String? status = "";
    if (payout!.status! == 'Paid' || payout!.status! == 'Settled') {
      status = 'done';
    } else if (payout!.status! == 'Pending') {
      status = 'processing';
    } else if (payout!.status! == 'Cancelled') {
      status = 'cancel';
    }

    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: checkStatusBgColor(status),
      ),
      child: Text(
        trimString(payout!.status!),
        style: TextStyle(
          color: checkStatusForColor(status),
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
