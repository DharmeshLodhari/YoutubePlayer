import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../routes/route_constants.dart';
import '../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';

// ignore: must_be_immutable
class PaymentRequestTile extends StatelessWidget {
  final PaymentRequest? paymentRequest;
  Widget? expandedWidget = Container();
  Key? key;

  PaymentRequestTile({this.paymentRequest, this.expandedWidget, this.key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  title: getTitle(),
                  trailing: paymentRequest!.amount! >= amountLimit
                      ? null
                      : getTrailing(),
                  subtitle: getSubtitle(context)),
            ),
            expandedWidget!
          ],
        ),
      ),
    );
  }

  Widget getLeading() {
    return GestureDetector(
      onTap: () {
        Navigator.of(myGlobals.navigationKey.currentContext!)
            .pushNamed("/photo-viewer", arguments: paymentRequest!.avatar);
      },
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            25,
          ),
          // border: Border.all(color: borderColor, width: 2),
          border: Border.all(color: Colors.transparent, width: 0),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: paymentRequest!.avatar!,
            height: 48,
            width: 48,
            errorWidget: imageErrorWidget,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => paymentRequest!.avatar == ""
                ? Icon(Icons.person)
                : CircularLoadingIndicator(),
          ),
        ),
      ),
    );
  }

  Widget getTitle() {
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Text(
        getCustomerName(),
        maxLines: 1,
        style: TextStyle(
          color: blackFont,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
    );
  }

  String getCustomerName() {
    if (paymentRequest!.displayCustomer.length > 24) {
      return "${paymentRequest!.displayCustomer.substring(0, 25)}...";
    } else {
      return paymentRequest!.displayCustomer;
    }
  }

  Widget getSubtitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        paymentRequest!.description != "" && paymentRequest!.description != null
            ? Text(
                "${paymentRequest!.description}",
                style: TextStyle(color: darkGrey, fontSize: 12),
                maxLines: 1,
              )
            : Container(),
        paymentRequest!.amount! >= amountLimit ? getTrailing() : Container(),
        paymentRequest!.createdAt == null ? SizedBox() : getDateTime(context)
      ],
    );
  }

  Widget getTrailing() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[paymentRequest!.currency!]!,
          style: TextStyle(
              fontFamily: "Roboto",
              color: paymentRequest!.isCredit! ? blackFont : navyBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(paymentRequest!.amount),
          style: TextStyle(
              color: paymentRequest!.isCredit! ? blackFont : navyBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
      ],
    );
  }

  Widget getDateTime(BuildContext context) {
    DateTime requestTime = DateTime.parse(paymentRequest!.createdAt!).toLocal();
    String date = DateFormat("dd/MM/yyyy").format(requestTime);
    String time = DateFormat("hh:mm a").format(requestTime);
    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 10),
    );
  }
}

// ignore: must_be_immutable
class TransactionTile extends StatelessWidget {
  UserBloc? userBloc;

  final Transaction? transaction;
  Widget? expandedWidget = Container();

  TransactionTile({this.transaction, this.expandedWidget, this.key})
      : super(key: key);

  Key? key;

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
                title: getTitle(),
                subtitle: getSubTitle(context),
                leading: getLeading(),
                trailing: transaction!.amount.toString().length >= amountLimit
                    ? null
                    : getAmount(),
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.TRANSACTION_DETAIL,
                      arguments: {'transaction': transaction});
                },
              ),
            ),
            transaction!.isAnonymous! ? Container() : expandedWidget!,
          ],
        ),
      ),
    );
  }

  Widget getTitle() {
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Text(
        "${transaction!.displayCustomer}",
        maxLines: 1,
        style: TextStyle(
            color: blackFont, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget getLeading() {
    // if (transaction!.isAnonymous!) {
    //   return Container(
    //     padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
    //     child: Image.asset(
    //       "assets/images/anonymous.png",
    //       height: 48,
    //       width: 48,
    //       colorBlendMode: BlendMode.darken,
    //       fit: BoxFit.fitHeight,
    //     ),
    //   );
    // } else if (transaction!.fromCustomer == "") {
    //   return GestureDetector(
    //     onTap: () {
    //       Navigator.of(myGlobals.navigationKey.currentContext!).pushNamed(
    //           "/photo-viewer",
    //           arguments:
    //               getInitials(transaction!.displayFromCustomer).toUpperCase());
    //     },
    //     child: CircleAvatar(
    //       backgroundColor: navyBlue,
    //       radius: 25,
    //       child: Text(
    //         getInitials(transaction!.displayFromCustomer).toUpperCase(),
    //         style: TextStyle(color: white, fontWeight: FontWeight.w700),
    //       ),
    //     ),
    //   );
    // } else {
    //   return Container(
    //     height: 48,
    //     width: 48,
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(
    //         25,
    //       ),
    //       // border: Border.all(color: borderColor, width: 2),
    //       border: Border.all(color: Colors.transparent, width: 0),
    //     ),
    //     child: GestureDetector(
    //       onTap: () {
    //         Navigator.of(myGlobals.navigationKey.currentContext!)
    //             .pushNamed("/photo-viewer", arguments: transaction!.avatar);
    //       },
    //       child: ClipOval(
    //         child: CachedNetworkImage(
    //           imageUrl: transaction!.avatar!,
    //           height: 48,
    //           errorWidget: imageErrorWidget,
    //           width: 48,
    //           colorBlendMode: BlendMode.darken,
    //           fit: BoxFit.cover,
    //           filterQuality: FilterQuality.high,
    //           placeholder: (context, url) => transaction!.avatar == ""
    //               ? Icon(Icons.person)
    //               : CircularLoadingIndicator(),
    //         ),
    //       ),
    //     ),
    //   );
    // }

    return transaction!.isAnonymous!
        ? Container(
            padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Image.asset(
              "assets/images/anonymous.png",
              height: 48,
              width: 48,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fitHeight,
            ),
          )
        : Container(
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
                Navigator.of(myGlobals.navigationKey.currentContext!)
                    .pushNamed("/photo-viewer", arguments: transaction!.avatar);
              },
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: transaction!.avatar!,
                  height: 48,
                  errorWidget: imageErrorWidget,
                  width: 48,
                  colorBlendMode: BlendMode.darken,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  placeholder: (context, url) => transaction!.avatar == ""
                      ? Icon(Icons.person)
                      : CircularLoadingIndicator(),
                ),
              ),
            ),
          );
  }

  Widget getAmount() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[transaction!.currency!]!,
          style: TextStyle(
              fontFamily: "Roboto",
              color: transaction!.isCredit! ? navyBlue : blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(transaction!.amount),
          style: TextStyle(
              color: transaction!.isCredit! ? navyBlue : blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
      ],
    );
  }

  Widget getSubTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        transaction!.description != "" && transaction!.description != null
            ? Text(
                "${transaction!.description}",
                style: TextStyle(color: darkGrey, fontSize: 12),
                maxLines: 1,
              )
            : Container(),
        transaction!.amount.toString().length >= amountLimit
            ? getAmount()
            : Container(),
        getDateTime(context),
      ],
    );
  }

  Widget getDateTime(BuildContext context) {
    DateTime transactionTime =
        DateTime.parse(transaction!.createdAt!).toLocal();
    String date = DateFormat("dd/MM/yyyy").format(transactionTime);
    String time = DateFormat("hh:mm a").format(transactionTime);
    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 10),
    );
  }
}

class ContractTransactionTile extends StatefulWidget {
  final Transaction? transaction;
  ContractTransactionTile({this.transaction});

  @override
  _ContractTransactionTileState createState() =>
      _ContractTransactionTileState();
}

class _ContractTransactionTileState extends State<ContractTransactionTile> {
  UserBloc? userBloc;

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
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            dense: true,
            title: getTitle(),
            subtitle: getSubTitle(context),
            leading: getLeading(),
            trailing: widget.transaction!.amount.toString().length > 6
                ? null
                : getAmount(),
            onTap: () {
              Navigator.of(context).pushNamed('/transaction-detail',
                  arguments: {'transaction': widget.transaction});
            },
          ),
        ),
      ),
    );
  }

  Widget getTitle() {
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Text(
        "${widget.transaction!.payee}",
        maxLines: 1,
        style: TextStyle(
            color: blackFont, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget getLeading() {
    return ClipOval(
      child: widget.transaction!.isAnonymous!
          ? Container(
              padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: Image.asset(
                "assets/images/anonymous.png",
                height: 48,
                width: 48,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.fitHeight,
              ),
            )
          : CachedNetworkImage(
              imageUrl: widget.transaction!.avatar!,
              height: 48,
              errorWidget: imageErrorWidget,
              width: 48,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              placeholder: (context, url) => widget.transaction!.avatar == ""
                  ? Icon(Icons.person)
                  : CircularLoadingIndicator(),
            ),
    );
  }

  Widget getAmount() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[widget.transaction!.currency!]!,
          style: TextStyle(
              fontFamily: "Roboto",
              color: widget.transaction!.isCredit! ? navyBlue : blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(widget.transaction!.amount),
          style: TextStyle(
              color: widget.transaction!.isCredit! ? navyBlue : blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
      ],
    );
  }

  Widget getSubTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "${widget.transaction!.description}",
          style: TextStyle(color: darkGrey, fontSize: 12),
          maxLines: 1,
        ),
        widget.transaction!.amount.toString().length > 6
            ? getAmount()
            : Container(),
        getDateTime(context),
      ],
    );
  }

  Widget getDateTime(BuildContext context) {
    DateTime transactionTime = DateTime.parse(widget.transaction!.createdAt!);
    String date = DateFormat("dd/MM/yyyy").format(transactionTime);
    String time = DateFormat("hh:mm a").format(transactionTime);
    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 10),
    );
  }
}
