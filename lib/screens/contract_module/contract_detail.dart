import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ContractDetail extends StatefulWidget {
  var arguments;

  ContractDetail({@required this.arguments});

  @override
  _ContractDetailState createState() =>
      _ContractDetailState(arguments: arguments);
}

class _ContractDetailState extends State<ContractDetail> {
  var arguments;
  Transaction transaction;

  _ContractDetailState({this.arguments});

  final _auth = AuthService();

  @override
  void initState() {
    fetchContract();
    super.initState();
  }

  void fetchContract() async {
    AuthService().getContract("").then((value) {});

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
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: appBar(),
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
        AppLocalization.of(context).transaction,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        openGraphBtn(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget openGraphBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.location,
        size: 16,
        color: blackFont,
      ),
      onTap: transaction.latitude != "" ? goToMap : () {},
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
        _auth.fetchCustomerProfile(transaction.payee).then((user) {
          Navigator.pushNamed(context, '/profile',
              arguments: {"searchedUser": user});
        });
      },
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

    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 12),
    );
  }

  Widget getLeading() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: transaction.avatar,
        height: 48,
        width: 48,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => transaction.avatar == ""
            ? Icon(Icons.person)
            : CircularLoadingIndicator(),
      ),
    );
  }

  Widget getSender() {
    return Text(
      transaction.payee,
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
          worldCurrencies[transaction.currency],
          style: TextStyle(
            color: transaction.isCredit ? navyBlue : blackFont,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: "Roboto",
          ),
        ),
        Text(
          transaction.amount.toString(),
          style: TextStyle(
              color: transaction.isCredit ? navyBlue : blackFont,
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
          detailTile(
            SlydoAppIcon.user,
            AppLocalization.of(context).status,
            transaction.status,
          ),
          detailTile(
            SlydoAppIcon.category,
            AppLocalization.of(context).category,
            transaction.category,
          ),
          detailTile(
            SlydoAppIcon.note_filled,
            AppLocalization.of(context).note,
            transaction.note,
          ),
          detailTile(
            SlydoAppIcon.note,
            AppLocalization.of(context).description,
            transaction.description,
          ),
        ],
      ),
    );
  }

  Widget detailTile(IconData icon, String title, String subtitle) {
    // return Container(
    //   child: ListTile(
    //     dense: true,
    //     leading: icon,
    //     title: Text(
    //       title,
    //       style: TextStyle(
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     subtitle: Text(
    //       subtitle,
    //       style: TextStyle(fontSize: 12),
    //     ),
    //   ),
    // );

    return Container(
      child: ListTile(
        dense: true,
        leading: RoundedBackgroundIcon(
          icon: Icon(
            icon,
            color: blackFont,
            size: 18,
          ),
          backgroundColor: iconBtnGrey,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: blackFont,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: blackFont,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void goToMap() {
    debugPrint("go to Map Called !");
  }
}
