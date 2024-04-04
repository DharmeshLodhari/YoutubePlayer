import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTileForChat extends StatefulWidget {
  final Map<String, dynamic>? message;
  final UserBloc? userBloc;
  final ChatConversation? chatConversation;

  TransactionTileForChat({this.message, this.userBloc, this.chatConversation});
  @override
  _TransactionTileForChatState createState() => _TransactionTileForChatState();
}

class _TransactionTileForChatState extends State<TransactionTileForChat> {
  late Transaction transaction;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? data;

    if (widget.message!['text'] is String) {
      data = jsonDecode(widget.message!['text']);
    } else if (widget.message!['text'] is Map) {
      data = widget.message!['text'];
    }
    final bool isCredit =
        widget.userBloc!.user.userName == data!['to_customer'];

    data['is_credit'] = isCredit;

    transaction = Transaction.fromJson(data);

    final bool isSend =
        widget.message!["author"] == widget.userBloc!.user.userName;

    final bool isScreenSmall = MediaQuery.of(context).size.width <= 400;

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isSend) Container() else Container(width: 20),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.40,
                  minWidth: MediaQuery.of(context).size.width / 1.40,
                  minHeight: 50),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(!isSend ? 0 : 6),
                  bottomRight: Radius.circular(isSend ? 0 : 6),
                  topLeft: const Radius.circular(6),
                  topRight: const Radius.circular(6),
                ),
              ),
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 12, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomBoxShadow(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: EdgeInsets.zero,
                      shadowColor: boxShadowTwo,
                      color: chatBackgroundColor,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  messageDecoderWithEmoji(
                                      transaction.description)!,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: blackFont),
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: getUserCurrencySymbol(context,
                                        fontSize: 20),
                                  ),
                                  Text(
                                    moneyDisplayNormalizer(int.parse(
                                        transaction.amount.toString())),
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: navyBlue),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Container(
                    child: Row(
                      children: [
                        Icon(
                          SlydoAppIcon.true_icon,
                          size: 12,
                          color: naturalGreen,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Row(
                          children: [
                            Text(getTransactionStatus(isSend: isSend),
                                style: TextStyle(
                                    color: blackFont,
                                    fontWeight: isScreenSmall
                                        ? FontWeight.w500
                                        : FontWeight.w600,
                                    fontSize: isScreenSmall ? 12 : 14)),
                            Text(
                                "${getDateTime(dateAndTime: widget.message!['created_at'])}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: TextStyle(
                                  color: darkGrey,
                                  fontSize: isScreenSmall ? 10 : 12,
                                  fontWeight: FontWeight.w400,
                                ))
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.chatConversation!.isGroupConversation!)
                    Column(
                      children: [
                        const SizedBox(
                          height: 4,
                        ),
                        Container(
                          width: 42,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: 26,
                                child: Container(
                                  height: 34,
                                  width: 34,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                          color: navyBlue, width: 2)),
                                  child: ClipOval(
                                    child: Container(
                                      color: Colors.white,
                                      child: CachedNetworkImage(
                                        height: 34,
                                        width: 34,
                                        fit: BoxFit.fill,
                                        errorWidget: imageErrorWidget,
                                        imageUrl: widget
                                            .message!['to_customer_avatar'],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 34,
                                width: 34,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        color: naturalGreen, width: 2)),
                                child: ClipOval(
                                  child: Container(
                                    color: Colors.white,
                                    child: CachedNetworkImage(
                                      height: 34,
                                      width: 34,
                                      fit: BoxFit.fill,
                                      errorWidget: imageErrorWidget,
                                      imageUrl: widget
                                          .message!['from_customer_avatar'],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Container()
                ],
              ),
            ),
            if (isSend)
              Container(
                width: 20,
                child: isSend
                    ? Center(
                        child: getMessageTick(message: widget.message!),
                      )
                    : Container(),
              )
            else
              Container(),
          ],
        ),
        const SizedBox(
          height: 1,
        ),
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (isSend)
              Container()
            else
              const SizedBox(
                width: 20,
              ),
            Text(
              formatTime(widget.message!['created_at']),
              style: TextStyle(
                  color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
            ),
            if (isSend)
              const SizedBox(
                width: 20,
              )
            else
              Container(),
          ],
        )
      ],
    );
  }

  String getDateTime({required String dateAndTime}) {
    final DateTime requestTime = DateTime.parse(dateAndTime).toLocal();
    final String date = DateFormat("dd/MM/yy").format(requestTime);
    final String time = DateFormat("hh:mm a").format(requestTime);
    return " • $date • $time";
  }

  String getTransactionStatus({bool? isSend}) {
    if (widget.chatConversation!.isGroupConversation!) {
      if (widget.userBloc!.user.userName == transaction.fromCustomer) {
        return "You were paid";
      }
      if (widget.userBloc!.user.userName == transaction.toCustomer) {
        return "You have paid";
      }
      return "Payment made";
    }
    return isSend! ? "You have paid" : "You were paid";
  }
}

class PaymentRequestTileForChat extends StatefulWidget {
  final Map<String, dynamic>? message;
  final UserBloc? userBloc;
  final ChatConversation? chatConversation;

  PaymentRequestTileForChat(
      {this.message, this.userBloc, this.chatConversation});

  @override
  _PaymentRequestTileForChatState createState() =>
      _PaymentRequestTileForChatState();
}

class _PaymentRequestTileForChatState extends State<PaymentRequestTileForChat> {
  late PaymentRequest paymentRequest;
  String paymentActionStatus = "None";
  String paymentActionTime = DateTime.now().toString();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// payment actions
    /// Rejected
    /// Accepted
    /// Canceled
    /// None

    Map<String, dynamic>? details;

    if (widget.message!['meta_data'] is Map) {
      details = widget.message!['meta_data'];
    } else if (widget.message!['meta_data'] is String) {
      details = jsonDecode(widget.message!['meta_data']);
    }

    if (details!.isNotEmpty) {
      try {
        if (details['payment_action_status'] != null) {
          paymentActionStatus = details['payment_action_status'].toString();
        }
        if (details['updated_at'] != null) {
          paymentActionTime = details['updated_at'].toString();
        }
      } catch (e) {
        paymentActionStatus = "None";
        paymentActionTime = DateTime.now().toString();
        debugPrint("ERROR:- $e");
      }
    } else {
      paymentActionStatus = "None";
      paymentActionTime = DateTime.now().toString();
    }

    if (widget.message!['text'] is String) {
      paymentRequest =
          PaymentRequest.fromJson(jsonDecode(widget.message!['text']));
    } else if (widget.message!['text'] is Map) {
      paymentRequest = PaymentRequest.fromJson(widget.message!['text']);
    }

    final bool isSend =
        widget.message!["author"] == widget.userBloc!.user.userName;

    final bool isScreenSmall = MediaQuery.of(context).size.width <= 400;

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isSend) Container() else Container(width: 20),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.40,
                  minWidth: MediaQuery.of(context).size.width / 1.40,
                  minHeight: 50),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(!isSend ? 0 : 6),
                  bottomRight: Radius.circular(isSend ? 0 : 6),
                  topLeft: const Radius.circular(6),
                  topRight: const Radius.circular(6),
                ),
              ),
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 12, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomBoxShadow(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: EdgeInsets.zero,
                      shadowColor: boxShadowTwo,
                      color: chatBackgroundColor,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  messageDecoderWithEmoji(
                                      paymentRequest.description)!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: blackFont),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: getUserCurrencySymbol(context,
                                        fontSize: 20),
                                  ),
                                  Text(
                                    moneyDisplayNormalizer(int.parse(
                                        paymentRequest.amount.toString())),
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: navyBlue),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (paymentActionStatus == "None")
                    const SizedBox(
                      height: 12,
                    )
                  else
                    Container(),
                  if (widget.chatConversation!.isGroupConversation!)
                    paymentActionStatus == "None"
                        ? paymentRequest.toCustomer ==
                                    widget.userBloc!.user.userName ||
                                paymentRequest.fromCustomer ==
                                    widget.userBloc!.user.userName
                            ? Container(
                                child: isSend
                                    ? Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: CurvedButton(
                                              text: "CANCEL",
                                              height: 36,
                                              backgroundColor: mateRed,
                                              textColor: Colors.white,
                                              borderRadius: 10,
                                              onPressed:
                                                  rejectOrCancelPaymentRequest,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          Expanded(
                                            child: Container(),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: CurvedButton(
                                              height: 36,
                                              text: "REJECT",
                                              backgroundColor: mateRed,
                                              borderRadius: 10,
                                              textColor: Colors.white,
                                              onPressed:
                                                  rejectOrCancelPaymentRequest,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          Expanded(
                                            child: CurvedButton(
                                              text: "PAY",
                                              height: 36,
                                              backgroundColor: navyBlue,
                                              textColor: Colors.white,
                                              borderRadius: 10,
                                              onPressed: acceptPaymentRequest,
                                            ),
                                          ),
                                        ],
                                      ),
                              )
                            : Container()
                        : Container()
                  else
                    paymentActionStatus == "None"
                        ? Container(
                            child: isSend
                                ? Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: CurvedButton(
                                          text: "CANCEL",
                                          height: 36,
                                          backgroundColor: mateRed,
                                          textColor: Colors.white,
                                          borderRadius: 10,
                                          onPressed:
                                              rejectOrCancelPaymentRequest,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: CurvedButton(
                                          height: 36,
                                          text: "REJECT",
                                          backgroundColor: mateRed,
                                          borderRadius: 10,
                                          textColor: Colors.white,
                                          onPressed:
                                              rejectOrCancelPaymentRequest,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                        child: CurvedButton(
                                          text: "PAY",
                                          height: 36,
                                          backgroundColor: navyBlue,
                                          textColor: Colors.white,
                                          borderRadius: 10,
                                          onPressed: acceptPaymentRequest,
                                        ),
                                      ),
                                    ],
                                  ),
                          )
                        : Container(),
                  if (paymentActionStatus != "None")
                    const SizedBox(
                      height: 12,
                    )
                  else
                    Container(),
                  if (paymentActionStatus != "None")
                    Container(
                      child: Row(
                        children: [
                          Icon(
                            SlydoAppIcon.true_icon,
                            size: 12,
                            color: getStatusOfPaymentColor(),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Row(
                            children: [
                              Text(getStatusOfThePayment(isSend),
                                  style: TextStyle(
                                      color: blackFont,
                                      fontWeight: isScreenSmall
                                          ? FontWeight.w500
                                          : FontWeight.w600,
                                      fontSize: isScreenSmall ? 12 : 14)),
                              Text(
                                  "${getDateTime(dateAndTime: paymentActionTime)}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: TextStyle(
                                    color: darkGrey,
                                    fontSize: isScreenSmall ? 10 : 12,
                                    fontWeight: FontWeight.w400,
                                  ))
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    Container(),
                  if (widget.chatConversation!.isGroupConversation!)
                    Column(
                      children: [
                        const SizedBox(
                          height: 4,
                        ),
                        Container(
                          width: 42,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: 26,
                                child: Container(
                                  height: 34,
                                  width: 34,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                          color: navyBlue, width: 2)),
                                  child: ClipOval(
                                    child: Container(
                                      color: Colors.white,
                                      child: CachedNetworkImage(
                                        height: 34,
                                        width: 34,
                                        fit: BoxFit.fill,
                                        errorWidget: imageErrorWidget,
                                        imageUrl:
                                            paymentRequest.toCustomerAvatar!,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 34,
                                width: 34,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        color: naturalGreen, width: 2)),
                                child: ClipOval(
                                  child: Container(
                                    color: Colors.white,
                                    child: CachedNetworkImage(
                                      height: 34,
                                      width: 34,
                                      fit: BoxFit.fill,
                                      errorWidget: imageErrorWidget,
                                      imageUrl:
                                          paymentRequest.fromCustomerAvatar!,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Container()
                ],
              ),
            ),
            if (isSend)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 20,
                  child: isSend
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: getMessageTick(message: widget.message!))
                      : Container(),
                ),
              )
            else
              Container(),
          ],
        ),
        const SizedBox(
          height: 1,
        ),
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (isSend)
              Container()
            else
              const SizedBox(
                width: 20,
              ),
            Text(
              formatTime(paymentActionTime),
              style: TextStyle(
                  color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
            ),
            if (isSend)
              const SizedBox(
                width: 20,
              )
            else
              Container(),
          ],
        )
      ],
    );
  }

  void acceptPaymentRequest() {
    BottomSheetPassCode(
        context: context,
        isValidCallback: () async {
          final response = await PaymentAndBankingAuth().acceptPaymentRequests(
              paymentRequest,
              messageId: widget.message!["id"]);

          if (response.statusCode == 200) {
            showToast(message: "Payment request fulfilled !!");
          } else {
            debugPrint(
                "RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
          }
        },
        cancelCallBack: () {
          Navigator.pop(context);
        });
  }

  void rejectOrCancelPaymentRequest() async {
    final result = await PaymentAndBankingAuth().rejectPaymentRequests(
        paymentRequest,
        messageId: widget.message!["id"]);
    if (result) {
      showToast(message: "Payment status updated successfully !!");
    }
  }

  String getDateTime({required String dateAndTime}) {
    final DateTime requestTime = DateTime.parse(dateAndTime).toLocal();
    final String date = DateFormat("dd/MM/yy").format(requestTime);
    final String time = DateFormat("hh:mm a").format(requestTime);
    return " • $date • $time";
  }

  String getStatusOfThePayment(bool isSend) {
    if (paymentActionStatus == "Rejected") {
      return "Request Rejected";
    } else if (paymentActionStatus == "Accepted") {
      if (widget.chatConversation!.isGroupConversation!) {
        if (widget.userBloc!.user.userName == paymentRequest.fromCustomer) {
          return "You were paid";
        }
        if (widget.userBloc!.user.userName == paymentRequest.toCustomer) {
          return "You have paid";
        }
        return "Request Accepted";
      }
      return isSend ? "You were paid" : "You have paid";
    } else if (paymentActionStatus == "Canceled") {
      return "Request Canceled";
    } else {
      return "";
    }
  }

  Color getStatusOfPaymentColor() {
    if (paymentActionStatus == "Rejected") {
      return mateRed;
    } else if (paymentActionStatus == "Accepted") {
      return naturalGreen;
    } else if (paymentActionStatus == "Canceled") {
      return mateRed;
    } else {
      return Colors.transparent;
    }
  }
}
