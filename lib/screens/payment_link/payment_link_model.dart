class PaymentLinkModel {
  String? id;
  String? fromCustomer;
  String? status;
  int? pin;
  int? amount;
  String? currency;
  String? createdAt;
  String? updatedAt;
  String? payableFrom;
  String? reference;
  String? link;
  String? category;

  PaymentLinkModel(
      {this.id,
      this.fromCustomer,
      this.status,
      this.pin,
      this.amount,
      this.currency,
      this.createdAt,
      this.updatedAt,
      this.payableFrom,
      this.reference,
      this.link,
      this.category});

  PaymentLinkModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fromCustomer = json['from_customer'];
    status = json['status'];
    pin = json['pin'];
    amount = json['amount'];
    currency = json['currency'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    payableFrom = json['payable_from'];
    reference = json['reference'];
    link = json['link'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['from_customer'] = fromCustomer;
    data['status'] = status;
    data['pin'] = pin;
    data['amount'] = amount;
    data['currency'] = currency;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['payable_from'] = payableFrom;
    data['reference'] = reference;
    data['link'] = link;
    data['category'] = category;
    return data;
  }
}