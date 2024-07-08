import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class PaymentRequestDetail extends StatefulWidget {
  final dynamic arguments;

  const PaymentRequestDetail({super.key, required this.arguments});

  @override
  State<PaymentRequestDetail> createState() => _PaymentRequestDetailState();
}

class _PaymentRequestDetailState extends State<PaymentRequestDetail> {
  PaymentRequest? paymentRequest;

  @override
  void initState() {
    fetchTransaction();
    super.initState();
  }

  // void fetchTransaction() async {
  //   paymentRequest = widget.arguments['paymentRequest'];
  //   debugPrint("paymentRequest id: ${paymentRequest?.id}");
  // }

  void fetchTransaction() async {
    final paymentReqFromArgs = widget.arguments['paymentRequest'];
    if (paymentReqFromArgs is String) {
      paymentRequest =
          await PaymentAndBankingAuth().getPaymentRequests(paymentReqFromArgs);
    } else {
      paymentRequest = paymentReqFromArgs;
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
        AppLocalization.of(context)!.paymentRequests,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
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

  Widget displaySenderInfo() {
    return ListTile(
      leading: getLeading(),
      title: getSender(),
      subtitle: getSubtitle(),
      trailing: getAmount(),
      onTap: () async {
        if (paymentRequest?.payee == "slydo_envelope" ||
            paymentRequest?.payee == "slydo" ||
            paymentRequest?.displayCustomer == "slydo" ||
            paymentRequest?.displayCustomer == "slydo_envelope") {
          return;
        }
      },
    );
  }

  Widget getDescriptionWidget() {
    return Text(
      messageDecoderWithEmoji(paymentRequest?.description) ?? "",
      maxLines: 1,
    );
  }

  Widget getSubtitle() {
    final DateTime transactionTime = DateTime.parse(paymentRequest!.createdAt!);
    final String date = DateFormat("dd/MM/yyyy").format(transactionTime);
    final String time = DateFormat("hh:mm a").format(transactionTime);

    return Text(
      "$date • $time",
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 12),
    );
  }

  Widget getLeading() {
    return ClipOval(
        child: userImageUserInitialsPic(paymentRequest!.avatar!,
            paymentRequest!.displayToCustomer, 25, 48));
  }

  Widget getSender() {
    return Text(
      messageDecoderWithEmoji(paymentRequest?.displayCustomer) ?? "",
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
          worldCurrencies[paymentRequest!.currency!]!,
          style: TextStyle(
            color: paymentRequest!.isCredit! ? navyBlue : blackFont,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
        Text(
          moneyDisplayNormalizer(int.parse(paymentRequest!.amount.toString())),
          style: TextStyle(
              color: paymentRequest!.isCredit! ? navyBlue : blackFont,
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
        transactionOrPayoutTile('assets/images/payout/status.svg',
            AppLocalization.of(context)!.status, paymentRequest!.status!, true),
        transactionOrPayoutTile(
            'assets/images/payout/description.svg',
            AppLocalization.of(context)!.reference,
            messageDecoderWithEmoji(
                    appendStringDot(paymentRequest!.description!, 35)) ??
                '---',
            false),
      ],
    );
  }
}
