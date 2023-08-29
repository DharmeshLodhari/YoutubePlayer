import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../routes/route_constants.dart';

// ignore: must_be_immutable
class OrderTile extends StatelessWidget {
  late UserBloc userBloc;

  final Order? order;
  Key? key;

  OrderTile({this.order, this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                  dense: true,
                  leading: getLeading(),
                  title: getTitle(context),
                  trailing:
                      order!.totalPrice! >= amountLimit ? null : getTrailing(),
                  subtitle: getSubtitle(context)),
            ),
          ],
        ),
      ),
    );
  }

  String? getCustomerOrMerchant() {
    var customerOrMerchant = order!.customerName == userBloc.user.userName
        ? order!.merchant
        : order!.customerName;
    return customerOrMerchant;
  }

  String? getAvatar() {
    return order!.customerName == userBloc.user.userName
        ? order!.merchantAvatar
        : order!.customerAvatar;
  }

  String? getAvatarType() {
    return order!.customerName == userBloc.user.userName
        ? order!.merchantType
        : order!.customerType;
  }

  Widget getLeading() {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          25,
        ),
        border: Border.all(color: Colors.transparent, width: 0),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
              myGlobals.navigationKey.currentContext!, Routes.USER_PROFILE,
              arguments: {
                "searchedUserName":
                    order!.customerName == userBloc.user.userName
                        ? order!.merchant
                        : order!.customerName
              });
        },
        child: userImageUserInitialsPic(
            getAvatar()!, getCustomerOrMerchant()!, 25, 48),
      ),
    );
  }

  Widget getTitle(context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Text(
        AppLocalization.of(context)!.ref + " # : ${order!.id}",
        style: TextStyle(
            color: blackFont, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget getTrailing() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[order!.currency!]!,
          style: TextStyle(
              fontFamily: "Roboto",
              color: order!.customerName == userBloc.user.userName
                  ? blackFont
                  : navyBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(order!.totalPrice),
          style: TextStyle(
            color: order!.customerName == userBloc.user.userName
                ? blackFont
                : navyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget getSubtitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          order?.status ?? "",
          style: TextStyle(color: darkGrey, fontSize: 12),
          maxLines: 1,
        ),
        SizedBox(height: 2),
        order!.totalPrice! >= amountLimit ? getTrailing() : Container(),
        getDateTime(context)
      ],
    );
  }

  Widget getDateTime(BuildContext context) {
    print(order?.createdAt);
    DateTime orderTime = DateTime.parse(order?.createdAt ?? '').toLocal();
    String date = DateFormat("hh:mm a").format(orderTime);
    String time = DateFormat("dd/MM/yyyy").format(orderTime);
    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 10),
    );
  }
}
