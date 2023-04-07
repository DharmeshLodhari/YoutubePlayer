import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';

// ignore: must_be_immutable
class TransactionDetail extends StatefulWidget {
  var arguments;

  TransactionDetail({required this.arguments});

  @override
  _TransactionDetailState createState() =>
      _TransactionDetailState(arguments: arguments);
}

class _TransactionDetailState extends State<TransactionDetail> {
  var arguments;
  Transaction? transaction;

  _TransactionDetailState({this.arguments});

  @override
  void initState() {
    fetchTransaction();
    super.initState();
  }

  void fetchTransaction() async {
    transaction = arguments['transaction'];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(
        AppLocalization.of(context)!.transaction,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        showMap(),
        SizedBox(width: 16),
      ],
    );
  }

  Widget showMap() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.location,
        size: 16,
        color: blackFont,
      ),
      onTap: transaction!.latitude != "" ? goToMap : () {},
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height -
            (AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            displayTransactionInfo(),
            flexibleSpace(),
          ],
        ),
      ),
    );
  }

  Widget displaySenderInfo() {
    return ListTile(
      leading: getLeading(),
      title: getSender(),
      subtitle: getSubtitle(),
      trailing: getAmount(),
      onTap: () async {
        if (transaction?.payee == "slydo_envelope" ||
            transaction?.payee == "slydo" ||
            transaction?.displayCustomer == "slydo" ||
            transaction?.displayCustomer == "slydo_envelope") {
          return;
        }
        if (!transaction!.isAnonymous!) {
          Navigator.pushNamed(context, '/profile',
              arguments: {"searchedUserName": transaction!.payee});
        }
      },
    );
  }

  Widget getDescriptionWidget() {
    return Text(
      "${transaction!.description}",
      maxLines: 1,
    );
  }

  Widget getSubtitle() {
    DateTime transactionTime = DateTime.parse(transaction!.createdAt!);
    String date = DateFormat("dd/MM/yyyy").format(transactionTime);
    String time = DateFormat("hh:mm a").format(transactionTime);

    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 12),
    );
  }

  Widget getLeading() {
    return ClipOval(
      child: transaction!.isAnonymous!
          ? Container(
              padding: EdgeInsets.all(4.0),
              child: Image.asset(
                "assets/images/anonymous.png",
                height: 48,
                width: 48,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.fitHeight,
              ),
            )
          : CachedNetworkImage(
              imageUrl: transaction!.avatar!,
              height: 48,
              width: 48,
              colorBlendMode: BlendMode.darken,
              errorWidget: imageErrorWidget,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              placeholder: (context, url) => transaction!.avatar == ""
                  ? Icon(Icons.person)
                  : CircularLoadingIndicator(),
            ),
    );
  }

  Widget getSender() {
    return Text(
      transaction!.displayCustomer,
      style: TextStyle(
        color: blackFont,
        fontWeight: FontWeight.bold,
        fontSize: 15,
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
            color: transaction!.isCredit! ? navyBlue : blackFont,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: "Roboto",
          ),
        ),
        Text(
          moneyDisplayNormalizer(int.parse(transaction!.amount.toString())),
          style: TextStyle(
              color: transaction!.isCredit! ? navyBlue : blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
      ],
    );
  }

  Widget displayTransactionInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: dividerColor,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: dividerColor, width: 0.5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            displaySenderInfo(),
            displayBodyOfTransaction(),
          ],
        ),
      ),
    );
  }

  Widget displayBodyOfTransaction() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Divider(
            color: dividerColor,
            thickness: 1,
            height: 0,
          ),
          transactionOrPayoutTile('assets/images/payout/status.svg',
              AppLocalization.of(context)!.status, transaction!.status!, true),
          transactionOrPayoutTile(
              'assets/images/payout/category.svg',
              AppLocalization.of(context)!.category,
              transaction!.category!,
              false),
          transactionOrPayoutTile(
              'assets/images/payout/note.svg',
              AppLocalization.of(context)!.note,
              messageDecoderWithEmoji(
                      appendStringDot(transaction!.note!, 35)) ??
                  '---',
              false),
          transactionOrPayoutTile(
              'assets/images/payout/description.svg',
              AppLocalization.of(context)!.description,
              messageDecoderWithEmoji(
                      appendStringDot(transaction!.description!, 35)) ??
                  '---',
              false),
        ],
      ),
    );
  }

  void goToMap() {
    debugPrint("go to Map Called !");
    MapsLauncher.launchCoordinates(double.parse(transaction!.latitude!),
        double.parse(transaction!.longitude!));
  }
}
