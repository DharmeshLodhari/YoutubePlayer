/// customer_api_transaction_fee : 500
/// business_transaction_fee : 400
/// magic_envelope_fee : 400
/// empty_envelope_fee : 400
/// anonymous_transaction_fee : 400
/// tax_rate : 0
/// country : "Nigeria"
/// currency : "NGN"

class FeeStructure {
  int customerApiTransactionFee;
  int businessTransactionFee;
  int magicEnvelopeFee;
  int emptyEnvelopeFee;
  int anonymousTransactionFee;
  int taxRate;
  String country;
  String currency;

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
    customerApiTransactionFee = json['customer_api_transaction_fee'];
    businessTransactionFee = json['business_transaction_fee'];
    magicEnvelopeFee = json['magic_envelope_fee'];
    emptyEnvelopeFee = json['empty_envelope_fee'];
    anonymousTransactionFee = json['anonymous_transaction_fee'];
    taxRate = json['tax_rate'];
    country = json['country'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
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
}
