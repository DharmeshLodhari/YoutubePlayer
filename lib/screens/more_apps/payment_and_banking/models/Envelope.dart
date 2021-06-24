import 'dart:convert';

class Envelope {
  String amount;
  String createdAt;
  String currency;
  String fromCustomer;
  String id;
  bool isOpen;
  bool isPaid;
  String message;
  String openAt;
  String paidAt;
  String payOutTransaction;
  String magicEnvelope;
  String title;
  String toCustomer;
  String transaction;
  String type;
  String fromCustomerAvatar;
  String toCustomerAvatar;

  Envelope(
      {this.amount,
      this.createdAt,
      this.currency,
      this.fromCustomer,
      this.id,
      this.isOpen,
      this.isPaid,
      this.message,
      this.openAt,
      this.paidAt,
      this.payOutTransaction,
      this.fromCustomerAvatar = "",
      this.toCustomerAvatar = "",
      this.title,
      this.toCustomer,
      this.transaction,
      this.magicEnvelope,
      this.type});

  factory Envelope.fromJson(Map<String, dynamic> json) {
    return Envelope(
        amount: json['amount'].toString(),
        createdAt: json['created_at'],
        currency: json['currency'],
        fromCustomer: json['from_customer'],
        id: json['id'].toString(),
        isOpen: json['is_open'],
        isPaid: json['is_paid'],
        message: json['message'],
        openAt: json['open_at'],
        paidAt: json['paid_at'],
        payOutTransaction: json['pay_out_transaction'].toString(),
        title: json['title'],
        toCustomer: json['to_customer'],
        transaction: json['transaction'].toString(),
        type: json['type'],
        fromCustomerAvatar: json['from_customer_avatar'] ??
            "https://slydo-assets.s3.amazonaws.com/media/customer/avatar/b1a8773527284446a45e9dd31924c5e8.jpg",
        toCustomerAvatar: json['to_customer_avatar'] ??
            "https://slydo-assets.s3.amazonaws.com/media/customer/avatar/4f4470b6dbf44b62859ddf2b945d7472.jpg",
        magicEnvelope: getMagicEnvelope(json['magic_envelope']));
  }

  static String getMagicEnvelope(var magicEnvelope) {
    if (magicEnvelope == null) {
      return null;
    }
    if (magicEnvelope is String) {
      return magicEnvelope;
    }
    return jsonEncode(magicEnvelope);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['created_at'] = this.createdAt;
    data['currency'] = this.currency;
    data['from_customer'] = this.fromCustomer;
    data['id'] = this.id;
    data['is_open'] = this.isOpen;
    data['is_paid'] = this.isPaid;
    data['message'] = this.message;
    data['open_at'] = this.openAt;
    data['paid_at'] = this.paidAt;
    data['pay_out_transaction'] = this.payOutTransaction;
    data['title'] = this.title;
    data['to_customer'] = this.toCustomer;
    data['transaction'] = this.transaction;
    data['type'] = this.type;
    data['magic_envelope'] = this.magicEnvelope;
    data['from_customer_avatar'] = this.fromCustomerAvatar;
    data['to_customer_avatar'] = this.toCustomerAvatar;
    return data;
  }
}
