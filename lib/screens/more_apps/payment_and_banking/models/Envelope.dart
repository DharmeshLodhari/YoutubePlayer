import 'dart:convert';

class Envelope {
  String? amount;
  String? createdAt;
  String? currency;
  String? fromCustomer;
  String? id;
  bool isOpen;
  bool isPaid;
  String? message;
  String? openAt;
  String? paidAt;
  String? payOutTransaction;
  String? magicEnvelope;
  String? title;
  String? toCustomer;
  String? transaction;
  String? type;

  Envelope(
      {this.amount,
      this.createdAt,
      this.currency,
      this.fromCustomer,
      this.id,
      this.isOpen = false,
      this.isPaid = false,
      this.message,
      this.openAt,
      this.paidAt,
      this.payOutTransaction,
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
        isOpen: json['is_open'] ?? false,
        isPaid: json['is_paid'] ?? false,
        message: json['message'],
        openAt: json['open_at'],
        paidAt: json['paid_at'],
        payOutTransaction: json['pay_out_transaction'].toString(),
        title: json['title'],
        toCustomer: json['to_customer'],
        transaction: json['transaction'].toString(),
        type: json['type'],
        magicEnvelope: getMagicEnvelope(json['magic_envelope']));
  }

  static String? getMagicEnvelope(var magicEnvelope) {
    if (magicEnvelope == null) {
      return null;
    }
    if (magicEnvelope is String) {
      return magicEnvelope;
    }
    return jsonEncode(magicEnvelope);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    return data;
  }
}
