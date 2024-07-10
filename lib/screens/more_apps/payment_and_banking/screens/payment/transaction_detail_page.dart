import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';

// ignore: must_be_immutable
class TransactionDetail extends StatefulWidget {
  final dynamic arguments;

  const TransactionDetail({super.key, required this.arguments});

  @override
  State<TransactionDetail> createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail> {
  Transaction? transaction;

  @override
  void initState() {
    fetchTransaction();

    super.initState();
  }

  void fetchTransaction() async {
    final transactionFromArgs = widget.arguments['transaction'];
    if (transactionFromArgs is String) {
      transaction = await PaymentAndBankingAuth()
          .getRefundTransaction(transactionFromArgs);
    } else {
      transaction = transactionFromArgs;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        resizeToAvoidBottomInset: true,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
        getAppLable(),
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        showMap(),
        const SizedBox(width: 16),
      ],
    );
  }

  String getAppLable() {
    if (transaction?.note?.contains("Refund") ?? true) {
      return "Refund Transaction";
    }
    return "Transaction";
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
      onTap: transaction?.latitude != "" ? goToMap : () {},
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget scaffoldBody() {
    if (transaction == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height -
              (AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top),
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              displayTransactionInfo(),
              flexibleSpace(),
            ],
          ),
        ),
      );
    }
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
      messageDecoderWithEmoji(transaction?.description) ?? "",
      maxLines: 1,
    );
  }

  Widget getSubtitle() {
    String? text;
    if (transaction?.createdAt != null) {
      final DateTime transactionTime = DateTime.parse(transaction!.createdAt!);
      final String date = DateFormat("dd/MM/yyyy").format(transactionTime);
      final String time = DateFormat("hh:mm a").format(transactionTime);
      text = "$date • $time";
    }
    return Text(
      text ?? '',
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 12),
    );
  }

  Widget getLeading() {
    return ClipOval(
        child: transaction?.isAnonymous ?? false
            ? Container(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  "assets/images/anonymous.png",
                  height: 48,
                  width: 48,
                  colorBlendMode: BlendMode.darken,
                  fit: BoxFit.fitHeight,
                ),
              )
            : userImageUserInitialsPic(transaction?.avatar ?? "",
                transaction?.displayToCustomer ?? "", 25, 48));
  }

  Widget getSender() {
    return Text(
      messageDecoderWithEmoji(transaction?.displayCustomer) ?? "",
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
          worldCurrencies[transaction?.currency] ?? "₦",
          style: TextStyle(
            color: transaction?.isCredit ?? false ? navyBlue : blackFont,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
        Text(
          moneyDisplayNormalizer(transaction?.amount ?? 0),
          style: TextStyle(
              color: transaction?.isCredit ?? false ? navyBlue : blackFont,
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
      shadowColor: boxShadowTwo,
      child: Container(
        decoration: decorateBox(),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Divider(
          color: dividerColor,
          thickness: 1,
          height: 0,
        ),
        transactionOrPayoutTile(
            'assets/images/payout/status.svg',
            AppLocalization.of(context)!.status,
            transaction?.status ?? "",
            true),
        transactionOrPayoutTile(
            'assets/images/payout/category.svg',
            AppLocalization.of(context)!.category,
            transaction?.category ?? "",
            false),
        transactionOrPayoutTile(
            'assets/images/payout/note.svg',
            AppLocalization.of(context)!.note,
            messageDecoderWithEmoji(
                    appendStringDot(transaction?.note ?? "", 35)) ??
                '---',
            false),
        transactionOrPayoutTile(
            'assets/images/payout/description.svg',
            AppLocalization.of(context)!.description,
            messageDecoderWithEmoji(
                    appendStringDot(transaction?.description ?? "", 35)) ??
                '---',
            false),
      ],
    );
  }

  void goToMap() {
    debugPrint("go to Map Called !");
    MapsLauncher.launchCoordinates(double.parse(transaction!.latitude!),
        double.parse(transaction!.longitude!));
  }
}
