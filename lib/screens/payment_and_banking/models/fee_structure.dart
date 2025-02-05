import 'package:flutter/cupertino.dart';

/// customer_api_transaction_fee : 500
/// business_transaction_fee : 400
/// magic_envelope_fee : 400
/// empty_envelope_fee : 400
/// anonymous_transaction_fee : 400
/// tax_rate : 0
/// country : "Nigeria"
/// currency : "NGN"

enum FeesType {
  CUSTOMER_API_TRANSACTION_FEE,
  BUSINESS_TRANSACTION_FEE,
  MAGIC_ENVELOPE_FEE,
  EMPTY_ENVELOPE_FEE,
  ANONYMOUS_TRANSACTION_FEE,
}

class FeeStructure {
  int? customerApiTransactionFee;
  int? businessTransactionFee;
  int? magicEnvelopeFee;
  int? emptyEnvelopeFee;
  int? anonymousTransactionFee;
  double? taxRate;
  String? country;
  String? currency;

  FeeStructure(
      {this.customerApiTransactionFee,
      this.businessTransactionFee,
      this.magicEnvelopeFee,
      this.emptyEnvelopeFee,
      this.anonymousTransactionFee,
      this.taxRate,
      this.country,
      this.currency});

  FeeStructure.fromJson(dynamic json) {
    debugPrint('double ::: ${json['tax_rate']}');
    customerApiTransactionFee = json['customer_api_transaction_fee'];
    businessTransactionFee = json['business_transaction_fee'];
    magicEnvelopeFee = json['magic_envelope_fee'];
    emptyEnvelopeFee = json['empty_envelope_fee'];
    anonymousTransactionFee = json['anonymous_transaction_fee'];
    taxRate = json['tax_rate'].toDouble();
    country = json['country'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['customer_api_transaction_fee'] = customerApiTransactionFee;
    map['business_transaction_fee'] = businessTransactionFee;
    map['magic_envelope_fee'] = magicEnvelopeFee;
    map['empty_envelope_fee'] = emptyEnvelopeFee;
    map['anonymous_transaction_fee'] = anonymousTransactionFee;
    map['tax_rate'] = taxRate;
    map['country'] = country;
    map['currency'] = currency;
    return map;
  }

  String getFeeWithTax({FeesType? type}) {
    switch (type) {
      case FeesType.BUSINESS_TRANSACTION_FEE:
        return calculatePrice(businessTransactionFee!);

      case FeesType.CUSTOMER_API_TRANSACTION_FEE:
        return calculatePrice(customerApiTransactionFee!);

      case FeesType.EMPTY_ENVELOPE_FEE:
        return calculatePrice(emptyEnvelopeFee!);

      case FeesType.MAGIC_ENVELOPE_FEE:
        return calculatePrice(magicEnvelopeFee!);

      case FeesType.ANONYMOUS_TRANSACTION_FEE:
        return calculatePrice(anonymousTransactionFee!);

      default:
        return "";
    }
  }

  String calculatePrice(int price) {
    final double total = price + (price * taxRate!);
    return (total / 100).toString();
  }
}
