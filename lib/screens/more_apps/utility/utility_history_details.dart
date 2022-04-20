import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/utility/models/utility_transaction_model.dart';
import 'package:Slydo/screens/more_apps/utility/utility_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';

// ignore: must_be_immutable
class UtilityHistoryDetailScreen extends StatefulWidget {
  final String transactionId;

  UtilityHistoryDetailScreen({required this.transactionId});

  @override
  _UtilityHistoryDetailScreenState createState() =>
      _UtilityHistoryDetailScreenState();
}

class _UtilityHistoryDetailScreenState
    extends State<UtilityHistoryDetailScreen> {
  bool isLoading = true;
  late UtilityHistoryModel _utilityHistoryModel;

  @override
  void initState() {
    super.initState();

    UtilityAuth()
        .getUtilityTransactionsDetails(transactionsId: widget.transactionId)
        .then(
      (utilityHistoryModel) {
        if (utilityHistoryModel != null) {
          isLoading = false;
          _utilityHistoryModel = utilityHistoryModel;
          if (mounted) {
            setState(() {});
          }
        }
      },
    );
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
        AppLocalization.of(context)!.utilityTransactionHistory,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        // showMap(),
        SizedBox(width: 16),
      ],
    );
  }

  // Widget showMap() {
  //   return RoundedBackgroundIcon(
  //     height: 34,
  //     width: 34,
  //     icon: Icon(
  //       SlydoAppIcon.location,
  //       size: 16,
  //       color: blackFont,
  //     ),
  //     onTap: 'utilityHistoryModel.latitude' != "" ? goToMap : () {},
  //     backgroundColor: iconBtnGrey,
  //     enableMargin: true,
  //   );
  // }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height -
            (AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: isLoading
            ? Center(child: CircularLoadingIndicator())
            : Stack(
                children: [
                  Image.asset(
                      'assets/images/utility_history_details_background_card.png'),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            getLeading(),
                            SizedBox(width: 10),
                            getSender(),
                          ],
                        ),
                        SizedBox(height: 26),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Row(
                            children: getDashes(numberOfDashes: 18),
                          ),
                        ),
                        SizedBox(height: 12),
                        displayBodyOfTransaction(),
                      ],
                    ),
                  ),
                  // Column(
                  //   children: [
                  //     displayTransactionInfo(),
                  //     flexibleSpace(),
                  //   ],
                  // ),
                ],
              ),
      ),
    );
  }

  Widget displaySenderInfo() {
    return ListTile(
      leading: getLeading(),
      title: getSender(),
      // subtitle: getSubtitle(),
      trailing: getAmount(),
      onTap: () async {
        // if (transaction?.payee == "slydo_envelope" ||
        //     transaction?.payee == "slydo" ||
        //     transaction?.displayCustomer == "slydo" ||
        //     transaction?.displayCustomer == "slydo_envelope") {
        //   return;
        // }
        // if (!transaction!.isAnonymous!) {
        //   Navigator.pushNamed(context, '/profile',
        //       arguments: {"searchedUserName": transaction!.payee});
        // }
      },
    );
  }

  Widget getDescriptionWidget() {
    return Text(
      "___description",
      maxLines: 1,
    );
  }

  String getFormattedDateTime() {
    DateTime utilityTransactionTime =
        DateTime.parse(_utilityHistoryModel.createdAt);
    String date = DateFormat.jm().format(utilityTransactionTime);
    String time = DateFormat.yMMMMd().format(utilityTransactionTime);

    return "$date, $time";
  }

  List<Widget> getDashes({required int numberOfDashes}) {
    List<Widget> widgets = [];
    for (int i = 0; i < numberOfDashes; i++) {
      widgets.add(
        Container(
          width: 10,
          height: 1,
          color: Color(0XFFD7DAEC),
          margin: EdgeInsets.symmetric(horizontal: 4),
        ),
      );
    }
    return widgets;
  }

  Widget getLeading() {
    return Card(
      elevation: 7,
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CachedNetworkImage(
          height: 35,
          width: 35,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
          imageUrl: _utilityHistoryModel.providerAvatar,
        ),
      ),
    );
  }

  Widget getSender() {
    return Text(
      _utilityHistoryModel.customerUsername,
      style: TextStyle(
        color: blackFont,
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
    );
  }

  Widget getAmount() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[_utilityHistoryModel.currency]!,
          style: TextStyle(
            color: blackFont,
            // color: transaction!.isCredit! ? navyBlue : blackFont,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: "Roboto",
          ),
        ),
        Text(
          moneyDisplayNormalizer(_utilityHistoryModel.amount),
          style: TextStyle(
              color: blackFont,
              // color: transaction!.isCredit! ? navyBlue : blackFont,
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
    TextStyle subtitleTextStyle = TextStyle(
      color: blackFont,
      fontSize: 16,
      fontFamily: "roberto",
      fontWeight: FontWeight.w500,
    );
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          transactionOrKycDetailTile(
            SlydoAppIcon.user,
            AppLocalization.of(context)!.amount,
            '${worldCurrencies[_utilityHistoryModel.currency]!}${moneyDisplayNormalizer(
              int.parse(_utilityHistoryModel.amount.toString()),
            )}',
            subtitleTextStyle: subtitleTextStyle,
          ),

          transactionOrKycDetailTile(
            SlydoAppIcon.date,
            'Date & Time',
            getFormattedDateTime(),
            subtitleTextStyle: subtitleTextStyle,
          ),
          transactionOrKycDetailTile(
            SlydoAppIcon.user,
            AppLocalization.of(context)!.status,
            _utilityHistoryModel.status,
            subtitleTextStyle: subtitleTextStyle,
          ),
          // transactionOrKycDetailTile(
          //   SlydoAppIcon.category,
          //   AppLocalization.of(context)!.category,
          //   'Bill payment',
          //   // transaction!.category!,
          // ),
          transactionOrKycDetailTile(
            SlydoAppIcon.note_filled,
            AppLocalization.of(context)!.note,
            '_ _ _a note',
            // transaction!.note!,
            subtitleTextStyle: subtitleTextStyle,
          ),
          transactionOrKycDetailTile(
            SlydoAppIcon.note,
            AppLocalization.of(context)!.description,
            '_ _ _electricity payment',
            subtitleTextStyle: subtitleTextStyle,
            // transaction!.description!,
          ),
        ],
      ),
    );
  }

  void goToMap() {
    debugPrint("go to Map Called !");
    // MapsLauncher.launchCoordinates(double.parse(utilityHistoryModel.latitude),
    //     double.parse(utilityHistoryModel.longitude));
  }
}
