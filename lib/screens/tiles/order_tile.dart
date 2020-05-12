import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class OrderTile extends StatelessWidget {
  UserBloc userBloc;
  final Order order;
  OrderTile({this.order});

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
                leading: getLeading(),
                title: getTitle(),
                trailing: order.totalPrice.length > 6 ? null : getTrailing(),
                subtitle: getSubtitle(context)),
          ),
        ],
      ),
    );
  }

  String getCustomerOrMerchant() {
    var customerOrMerchant = order.customer == userBloc.user.userName
        ? order.merchant
        : order.customer;
    return customerOrMerchant.length > 17
        ? customerOrMerchant.substring(0, 17)
        : customerOrMerchant;
  }

  String getAvatar() {
    return order.customer == userBloc.user.userName
        ? order.merchantAvatar
        : order.customerAvatar;
  }

  Widget getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: getAvatar(),
        height: 50,
        width: 50,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => getAvatar() == ""
            ? Icon(Icons.person)
            : CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      "Ref # : ${order.id}",
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getTrailing() {
    return Text(
      worldCurrencies[order.currency] + ' ' + order.totalPrice,
      style: TextStyle(
          color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getSubtitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          getCustomerOrMerchant(),
          style: TextStyle(color: Colors.grey[600]),
        ),
        SizedBox(
          height: 2,
        ),
        order.totalPrice.length > 6 ? getTrailing() : Container(),
        getDateTime(context)
      ],
    );
  }

  Widget getDateTime(BuildContext context) {
    DateTime requestTime = DateTime.parse(order.createdAt);

    return Row(
      children: <Widget>[
        Text(
          AppLocalization.of(context).date +
              ": ${requestTime.day}/${requestTime.month}/${requestTime.year}",
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        SizedBox(
          width: 15,
        ),
        Text(
            AppLocalization.of(context).time +
                ": ${requestTime.hour}:${requestTime.minute}",
            style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}
