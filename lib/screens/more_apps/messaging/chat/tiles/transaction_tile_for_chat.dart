import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class TransactionTileForChat extends StatefulWidget {
  final Map<String, dynamic> message;
  final UserBloc userBloc;

  TransactionTileForChat({this.message, this.userBloc});
  @override
  _TransactionTileForChatState createState() => _TransactionTileForChatState();
}

class _TransactionTileForChatState extends State<TransactionTileForChat> {
  Transaction transaction;
  @override
  void initState() {
    debugPrint("MESSAGE:- ${widget.message['text']}");

    Map<String, dynamic> data = widget.message['text'];

    bool isCredit = widget.userBloc.user.userName == data['to_customer'];

    data['is_credit'] = isCredit;
    // var payee = isCredit ? data["from_customer"] : data['to_customer'];
    // var avatar =
    // isCredit ? data["from_customer_avatar"] : data['to_customer_avatar'];

    transaction = Transaction.fromJson(data);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isSend = widget.message["author"] == widget.userBloc.user.userName;

    return GestureDetector(
      onLongPress: () {
        if (transaction.description.isNotEmpty) {
          Clipboard.setData(new ClipboardData(text: transaction.description));
          Toast.show("Text copied !!", context,
              gravity: Toast.BOTTOM,
              duration: Toast.LENGTH_LONG,
              backgroundColor: navyBlue,
              textColor: Colors.white);
        }
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              isSend ? Container() : Container(width: 20),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width / 1.40,
                    minWidth: MediaQuery.of(context).size.width / 1.40,
                    minHeight: 50),
                decoration: BoxDecoration(
                  color: chatBackgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(!isSend ? 0 : 6),
                    bottomRight: Radius.circular(isSend ? 0 : 6),
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomBoxShadow(
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        margin: EdgeInsets.zero,
                        shadowColor: boxShadowTwo,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    transaction.description,
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
                                    Icon(
                                      SlydoAppIcon.naira,
                                      color: navyBlue,
                                      size: 14,
                                    ),
                                    Text(
                                      transaction.amount.toString(),
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
                    SizedBox(
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
                          SizedBox(
                            width: 4,
                          ),
                          Row(
                            children: [
                              Text(isSend ? "You paid" : "You were paid",
                                  style: TextStyle(
                                      color: blackFont,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              Text(
                                  "${getDateTime(dateAndTime: DateTime.now().toString())}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: TextStyle(
                                    color: darkGrey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              isSend
                  ? Container(
                      width: 20,
                      child: isSend
                          ? Center(
                              child: getMessageTick(message: widget.message),
                            )
                          : Container(),
                    )
                  : Container(),
            ],
          ),
          SizedBox(
            height: 1,
          ),
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              isSend
                  ? Container()
                  : SizedBox(
                      width: 20,
                    ),
              Text(
                formatTime(widget.message['created_at']),
                style: TextStyle(
                    color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
              ),
              isSend
                  ? SizedBox(
                      width: 20,
                    )
                  : Container(),
            ],
          )
        ],
      ),
    );
  }

  String getDateTime({String dateAndTime}) {
    DateTime requestTime = DateTime.parse(dateAndTime);
    String date = DateFormat("dd/MM/yyyy").format(requestTime);
    String time = DateFormat("hh:mm a").format(requestTime);
    return " • $date • $time";
  }
}

class PaymentRequestTileForChat extends StatefulWidget {
  final Map<String, dynamic> message;
  final UserBloc userBloc;

  PaymentRequestTileForChat({this.message, this.userBloc});

  @override
  _PaymentRequestTileForChatState createState() =>
      _PaymentRequestTileForChatState();
}

class _PaymentRequestTileForChatState extends State<PaymentRequestTileForChat> {
  PaymentRequest paymentRequest;
  @override
  void initState() {
    paymentRequest = PaymentRequest.fromJson(jsonDecode(widget.message['text']),
        currentUser: widget.userBloc.user);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isSend = widget.message["author"] == widget.userBloc.user.userName;

    return GestureDetector(
      onLongPress: () {
        if (paymentRequest.description.isNotEmpty) {
          Clipboard.setData(
              new ClipboardData(text: paymentRequest.description));
          Toast.show("Text copied !!", context,
              gravity: Toast.BOTTOM,
              duration: Toast.LENGTH_LONG,
              backgroundColor: navyBlue,
              textColor: Colors.white);
        }
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              isSend ? Container() : Container(width: 20),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width / 1.40,
                    minWidth: MediaQuery.of(context).size.width / 1.40,
                    minHeight: 50),
                decoration: BoxDecoration(
                  color: chatBackgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(!isSend ? 0 : 6),
                    bottomRight: Radius.circular(isSend ? 0 : 6),
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomBoxShadow(
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        margin: EdgeInsets.zero,
                        shadowColor: boxShadowTwo,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    paymentRequest.description,
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
                                    Icon(
                                      SlydoAppIcon.naira,
                                      color: navyBlue,
                                      size: 14,
                                    ),
                                    Text(
                                      paymentRequest.amount.toString(),
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
                    SizedBox(
                      height: 12,
                    ),
                    Container(
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
                                    onPressed: () {},
                                  ),
                                ),
                                SizedBox(
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
                                    onPressed: () async {
                                      // var result = await PaymentAndBankingAuth()
                                      //     .rejectPaymentRequests(paymentRequest,
                                      //         messageId:
                                      //             widget.message["message_id"]);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child: CurvedButton(
                                    text: "PAY",
                                    height: 36,
                                    backgroundColor: navyBlue,
                                    textColor: Colors.white,
                                    borderRadius: 10,
                                    onPressed: () async {
                                      // var response =
                                      //     await PaymentAndBankingAuth()
                                      //         .acceptPaymentRequests(
                                      //             paymentRequest,
                                      //             messageId: widget
                                      //                 .message["message_id"]);
                                    },
                                  ),
                                ),
                              ],
                            ),
                    )
                  ],
                ),
              ),
              isSend
                  ? Container(
                      width: 20,
                      child: isSend
                          ? Center(
                              child: getMessageTick(message: widget.message),
                            )
                          : Container(),
                    )
                  : Container(),
            ],
          ),
          SizedBox(
            height: 1,
          ),
          Row(
            mainAxisAlignment:
                isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              isSend
                  ? Container()
                  : SizedBox(
                      width: 20,
                    ),
              Text(
                formatTime(widget.message['created_at']),
                style: TextStyle(
                    color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
              ),
              isSend
                  ? SizedBox(
                      width: 20,
                    )
                  : Container(),
            ],
          )
        ],
      ),
    );
  }

  String getDateTime({String dateAndTime}) {
    DateTime requestTime = DateTime.parse(dateAndTime);
    String date = DateFormat("dd/MM/yyyy").format(requestTime);
    String time = DateFormat("hh:mm a").format(requestTime);
    return " • $date • $time";
  }
}
