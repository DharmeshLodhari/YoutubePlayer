import 'package:flutter/material.dart';

enum ActionValue { send, request, paymentLink, scan, qrcode,
  creditCard, fundCard, freezeCard, withdraw, terminate }

class QuickAction {
  String? image;
  String? title;
  ActionValue? action;
  QuickAction({Key? key, this.image, this.title, this.action});

  static List<QuickAction> get actions => [
        QuickAction(title: 'Send', action: ActionValue.send, image: "home_naira"),
        QuickAction(title: 'Request', action: ActionValue.request, image: "request_pay"),
        QuickAction(title: 'Payment Link', action: ActionValue.paymentLink, image: "payment_link"),
        QuickAction(title: 'Scan QR', action: ActionValue.scan, image:  "scanny"),
        QuickAction(title: 'QR Code', action: ActionValue.qrcode, image:  "qr_scan_me"),
        QuickAction(title: 'Credit Card', action: ActionValue.creditCard, image: "home_credit_card"),
      ];

  static List<QuickAction> get actionsCard => [
    QuickAction(title: 'Fund Card', action: ActionValue.fundCard, image: "request_pay"),
    QuickAction(title: 'Freeze Card', action: ActionValue.freezeCard, image:  "qr_scan_me"),
    QuickAction(title: 'Withdraw', action: ActionValue.withdraw, image:  "qr_scan_me"),
    QuickAction(title: 'Terminate', action: ActionValue.terminate, image:  "qr_scan_me"),
  ];
}
