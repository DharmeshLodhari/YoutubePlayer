import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../utils/colors.dart';

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
                  trailing: order!.totalPrice.toString().length > 6
                      ? null
                      : getTrailing(),
                  subtitle: getSubtitle(context)),
            ),
          ],
        ),
      ),
    );
  }

  String? getCustomerOrMerchant() {
    var customerOrMerchant = order!.customer == userBloc.user.userName
        ? order!.merchant
        : order!.customer;
    return customerOrMerchant;
  }

  String? getAvatar() {
    return order!.customer == userBloc.user.userName
        ? order!.merchantAvatar
        : order!.customerAvatar;
  }

  String? getAvatarType() {
    return order!.customer == userBloc.user.userName
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
        // border: Border.all(color: borderColor, width: 2),
        border: Border.all(color: Colors.transparent, width: 0),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
              myGlobals.navigationKey.currentContext!, '/profile',
              arguments: {
                "searchedUserName": order!.customer == userBloc.user.userName
                    ? order!.merchant
                    : order!.customer
              });
        },
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: getAvatar()!,
            height: 48,
            width: 48,
            errorWidget: productAndServiceErrorWidget,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => getAvatar() == ""
                ? Icon(Icons.person)
                : CircularLoadingIndicator(),
          ),
        ),
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
              color: navyBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(order!.totalPrice),
          style: TextStyle(
            color: navyBlue,
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
        // Text(
        //   getCustomerOrMerchant()!,
        //   style: TextStyle(color: darkGrey, fontSize: 12),
        //   maxLines: 1,
        // ),
        Text(
          order?.status ?? "",
          style: TextStyle(color: darkGrey, fontSize: 12),
          maxLines: 1,
        ),
        SizedBox(
          height: 2,
        ),
        order!.totalPrice.toString().length > 6 ? getTrailing() : Container(),
        getDateTime(context)
      ],
    );
  }

  Widget getDateTime(BuildContext context) {
    DateTime orderTime = DateTime.parse(order!.createdAt!).toLocal();
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
