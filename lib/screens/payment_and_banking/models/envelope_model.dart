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

  static String? getMagicEnvelope(dynamic magicEnvelope) {
    if (magicEnvelope == null) {
      return null;
    }
    if (magicEnvelope is String) {
      return magicEnvelope;
    }
    return jsonEncode(magicEnvelope);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['created_at'] = createdAt;
    data['currency'] = currency;
    data['from_customer'] = fromCustomer;
    data['id'] = id;
    data['is_open'] = isOpen;
    data['is_paid'] = isPaid;
    data['message'] = message;
    data['open_at'] = openAt;
    data['paid_at'] = paidAt;
    data['pay_out_transaction'] = payOutTransaction;
    data['title'] = title;
    data['to_customer'] = toCustomer;
    data['transaction'] = transaction;
    data['type'] = type;
    data['magic_envelope'] = magicEnvelope;
    return data;
  }
}
