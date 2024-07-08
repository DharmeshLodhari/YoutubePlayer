import 'dart:convert';

import 'package:Slydo/constant.dart';
import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class PaymentRequestDetail extends StatefulWidget {
  final dynamic arguments;

  const PaymentRequestDetail({super.key, required this.arguments});

  @override
  State<PaymentRequestDetail> createState() => _PaymentRequestDetailState();
}

class _PaymentRequestDetailState extends State<PaymentRequestDetail> {
  late UserBloc userBloc;
  PaymentRequest? paymentRequest;
  final _auth = PaymentAndBankingAuth();
  String? userName;
  PermissionType? hasPermission;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerPaymentListKey =
      GlobalKey<ScaffoldMessengerState>();

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
    userBloc = Provider.of<UserBloc>(context);

    hasPermission =
        userBloc.user.hasWritePermission(ProtectionPermission.request);
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
        floatingActionButton: _buildPaymentRequestButton(paymentRequest!),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
    if (paymentRequest == null) {
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
    String? text;
    if (paymentRequest?.createdAt != null) {
      final DateTime transactionTime =
          DateTime.parse(paymentRequest!.createdAt!);
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
        child: userImageUserInitialsPic(paymentRequest?.avatar ?? "",
            paymentRequest?.displayToCustomer ?? "", 25, 48));
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
          worldCurrencies[paymentRequest?.currency] ?? "₦",
          style: TextStyle(
            color: paymentRequest?.isCredit ?? false ? navyBlue : blackFont,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: "Inter",
          ),
        ),
        Text(
          moneyDisplayNormalizer(paymentRequest?.amount ?? 0),
          style: TextStyle(
              color: paymentRequest?.isCredit ?? false ? navyBlue : blackFont,
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
            paymentRequest?.status ?? "",
            true),
        transactionOrPayoutTile(
            'assets/images/payout/description.svg',
            AppLocalization.of(context)!.reference,
            messageDecoderWithEmoji(
                    appendStringDot(paymentRequest?.description ?? "", 35)) ??
                '---',
            false),
      ],
    );
  }

  Widget _buildPaymentRequestButton(PaymentRequest paymentRequest) {
    final isShowButton =
        hasPermission == PermissionType.WRITE && paymentRequest.isCredit!;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isShowButton)
            Expanded(child: _buildPayButton(paymentRequest))
          else
            const SizedBox(),
          SizedBox(width: isShowButton ? 25 : 0),
          Expanded(
              child: _buildCancelOrRejectButton(paymentRequest, isShowButton)),
        ],
      ),
    );
  }

  Future<void> rejectPaymentRequestAlert(PaymentRequest paymentRequest) async {
    final bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: mateRed.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.false_icon,
          color: mateRed,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: naturalGreen,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: greyBorderColor,
      actionTwoTextColor: blackFont,
      title: AppLocalization.of(context)!.reject,
      description:
          AppLocalization.of(context)!.areYouSureWantToRejectThisPayment,
      actionOneText: 'Yes',
      actionTwoText: 'No',
    );
    if (result != null && result) {
      final bool done = await _auth.rejectPaymentRequests(paymentRequest);
      if (done) {
        _showSnackBar(
            context, AppLocalization.of(context)!.paymentRequestRejected);
        Navigator.popAndPushNamed(context, Routes.ACCOUNTS);
      } else {
        _showSnackBar(context, AppLocalization.of(context)!.error);
      }
    }
  }

  void _showSnackBar(BuildContext context, String text) {
    _scaffoldMessengerPaymentListKey.currentState
        ?.showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> cancelPaymentRequestAlert(PaymentRequest paymentRequest) async {
    // final String actionText = paymentRequest.isCredit! ? 'Reject' : 'Cancel';
    final String actionText = paymentRequest.isCredit!
        ? AppLocalization.of(context)!.reject
        : AppLocalization.of(context)!.cancel;
    final bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: mateRed.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.false_icon,
          color: mateRed,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: naturalGreen,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: greyBorderColor,
      actionTwoTextColor: blackFont,
      title: paymentRequest.isCredit!
          ? AppLocalization.of(context)!.reject
          : AppLocalization.of(context)!.cancel,
      description: "Are you sure you want to $actionText this request?",
      actionOneText: paymentRequest.isCredit!
          ? AppLocalization.of(context)!.reject
          : 'Yes',
      actionTwoText: "No",
    );
    if (result == null) return;
    if (result) {
      final bool done = await _auth.rejectPaymentRequests(paymentRequest);
      if (done) {
        _showSnackBar(
            context, AppLocalization.of(context)!.paymentRequestCancelled);
        Navigator.popAndPushNamed(context, Routes.ACCOUNTS);
      } else {
        _showSnackBar(context, AppLocalization.of(context)!.error);
      }
    }
  }

  Widget _buildCancelOrRejectButton(
      PaymentRequest paymentRequest, bool isShowButton) {
    final String caption = isShowButton
        ? AppLocalization.of(context)!.reject
        : AppLocalization.of(context)!.cancel;
    return CurvedButton(
      onPressed: () {
        if (isShowButton) {
          rejectPaymentRequestAlert(paymentRequest);
        } else {
          cancelPaymentRequestAlert(paymentRequest);
        }
      },
      backgroundColor: mateRed,
      textColor: white,
      fontSize: 15,
      text: caption,
    );
  }

  Widget _buildPayButton(PaymentRequest paymentRequest) {
    return CurvedButton(
      onPressed: () {
        acceptPaymentRequestAlert(paymentRequest);
      },
      backgroundColor: navyBlue,
      textColor: white,
      fontSize: 15,
      text: "Pay",
    );
  }

  void acceptPaymentRequestAlert(PaymentRequest paymentRequest) async {
    final bool? result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: navyBlue.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.true_icon,
          color: navyBlue,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: navyBlue,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: mateRed,
      actionTwoTextColor: Colors.white,
      firstActionPrimary: true,
      title: "Pay",
      description:
          AppLocalization.of(context)!.areYouSureWantToAcceptThisRequest,
      actionOneText: "Pay",
      actionTwoText: AppLocalization.of(context)!.cancel,
    );
    if (result != null && result) {
      BottomSheetPassCode(
          context: context,
          isValidCallback: () async {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    Center(child: CircularLoadingIndicator()));

            final bool result = await checkAccountBalance(paymentRequest);
            if (!result) return;

            final response =
                await _auth.acceptPaymentRequests(paymentRequest.id ?? "");
            if (response.statusCode == 200 || response.statusCode == 201) {
              _showSnackBar(
                  context, AppLocalization.of(context)!.paymentRequestAccepted);
              Navigator.popAndPushNamed(context, Routes.ACCOUNTS);
            } else if (response.statusCode == 500) {
              showToast(message: AppLocalization.of(context)!.serverError);
            }
            // else if (response.statusCode == 800) {
            //   Navigator.pushNamed(context, "/add-document");
            // }
            else {
              final Map<String, dynamic> errorData = jsonDecode(response.body);
              String? error = "Error";
              if (errorData.containsKey("errors")) {
                error = errorData['errors'];
              }
              _showSnackBar(context, error!);
            }
          },
          cancelCallBack: () {
            Navigator.pop(context);
          });
    }
  }

  Future<bool> checkAccountBalance(PaymentRequest paymentRequest) async {
    final double accountBalance = await getAccountBalance();
    Navigator.of(context).pop();
    debugPrint("accountBalance:- $accountBalance");
    final double spendingAmount = paymentRequest.amount! / 100;
    debugPrint("spendingAmount:- $spendingAmount");
    if (spendingAmount > accountBalance) {
      showToast(message: "You don't have enough money in Slydo account!!");
      return false;
    }
    return true;
  }
}
