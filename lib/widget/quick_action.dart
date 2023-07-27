import 'package:flutter/material.dart';

enum ActionValue { send, request, paymentLink, scan, qrcode, creditcard }

class QuickAction {
  String? image;
  String? title;
  ActionValue? action;
  QuickAction({Key? key, this.image, this.title, this.action});

  static List<QuickAction> get actions => [
        QuickAction(title: 'Send', action: ActionValue.send, image: "home_credit_card"),
        QuickAction(title: 'Request', action: ActionValue.request, image: "request_pay"),
        QuickAction(title: 'Payment Link', action: ActionValue.paymentLink, image: "payment_link"),
        QuickAction(title: 'Scan QR', action: ActionValue.scan, image:  "home_naira"),
        QuickAction(title: 'QR Code', action: ActionValue.qrcode, image:  "scanny"),
        QuickAction(title: 'Credit Card', action: ActionValue.creditcard, image: "home_credit_card"),
      ];
}
