import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/services/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';

import '../utils/colors.dart';

// ignore: must_be_immutable
class TransactionDetail extends StatefulWidget {
  var arguments;
  TransactionDetail({@required this.arguments});
  @override
  _TransactionDetailState createState() =>
      _TransactionDetailState(arguments: arguments);
}

class _TransactionDetailState extends State<TransactionDetail> {
  var arguments;
  Transaction transaction;
  _TransactionDetailState({this.arguments});
  final _auth = AuthService();

  @override
  void initState() {
    fetchTransaction();
    super.initState();
  }

  void fetchTransaction() async {
    transaction = arguments['transaction'];
  }

  Widget showBackArrow() {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: showBackArrow(),
          title: Center(child: Text(AppLocalization.of(context).transaction)),
          backgroundColor: darkBlue(),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.location_on,
                color: Colors.white,
              ),
              onPressed: transaction.latitude != "" ? goToMap : () {},
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 10),
                displayTransactionInfo(),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget displaySenderInfo() {
    return Container(
      height: 50,
      width: double.infinity,
      child: ListTile(
        leading: getLeading(),
        title: getSender(),
        subtitle: getSubtitle(),
        onTap: () async {
          _auth.fetchCustomerProfile(transaction.payee).then((user) {
            Navigator.pushNamed(context, '/profile',
                arguments: {"searchedUser": user});
          });
        },
      ),
    );
  }

  Widget getDescriptionWidget() {
    return Text(
      "${transaction.description}",
      maxLines: 1,
    );
  }

  Widget getSubtitle() {
    DateTime transactionTime = DateTime.parse(transaction.createdAt);
    String date = DateFormat("dd/MM/yyyy").format(transactionTime);
    String time = DateFormat("hh:mm a").format(transactionTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        getAmount(),
        Text(
          AppLocalization.of(context).date +
              ": $date" +
              "  " +
              AppLocalization.of(context).time +
              ": " +
              time,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: transaction.avatar,
        height: 40,
        width: 40,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => transaction.avatar == ""
            ? Icon(Icons.person)
            : CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
                backgroundColor: lightBlue(),
              ),
      ),
    );
  }

  getSender() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        transaction.payee,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget getAmount() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[transaction.currency] + " ",
          style: TextStyle(
              color:
                  transaction.isCredit ? Colors.green[400] : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontFamily: "Roboto",
              fontSize: 15),
        ),
        Text(
          transaction.amount.toString(),
          style: TextStyle(
              color:
                  transaction.isCredit ? Colors.green[400] : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
      ],
    );
  }

  displayTransactionInfo() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          displaySenderInfo(),
          displayBodyOfTransaction(),
        ],
      ),
    );
  }

  Widget displayBodyOfTransaction() {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Divider(
            color: Colors.grey[600],
            height: 1,
          ),
          detailTile(Icon(Icons.timer), AppLocalization.of(context).status,
              transaction.status),
          Divider(
            color: Colors.grey[600],
            height: 1,
          ),
          detailTile(Icon(Icons.category), AppLocalization.of(context).category,
              transaction.category),
          Divider(
            color: Colors.grey[600],
            height: 1,
          ),
          detailTile(Icon(Icons.note), AppLocalization.of(context).note,
              transaction.note),
          Divider(
            color: Colors.grey[600],
            height: 1,
          ),
          detailTile(Icon(Icons.description),
              AppLocalization.of(context).description, transaction.description),
          Divider(
            color: Colors.grey[600],
            height: 1,
          ),
        ],
      ),
    );
  }

  Widget detailTile(Icon icon, String title, String subtitle) {
    return Container(
      child: ListTile(
        dense: true,
        leading: icon,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  void goToMap() {
    debugPrint("go to Map Called !");
    MapsLauncher.launchCoordinates(double.parse(transaction.latitude),
        double.parse(transaction.longitude));
  }
}
