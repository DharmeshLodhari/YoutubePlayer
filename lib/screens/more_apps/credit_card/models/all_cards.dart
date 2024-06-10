class AllCards {
  String? cardId;
  String? cardBrand;
  String? cardClass;
  String? cardNumber;
  String? securityCode;
  String? limitWindow;
  String? nameLine1;
  String? nameLine2;
  String? expirationDate;
  String? expiration;
  String? terminationDate;
  String? currencyCode;
  String? status;
  String? gatewayMerchantGuid;
  String? color;
  double? availableBalance;
  bool? activated;
  // New property to track the visibility of balance
  bool? isBalanceHidden;
  String? label;

  AllCards(
      {this.cardId,
      this.cardBrand,
      this.cardClass,
      this.cardNumber,
      this.securityCode,
      this.limitWindow,
      this.nameLine1,
      this.nameLine2,
      this.expirationDate,
      this.expiration,
      this.terminationDate,
      this.currencyCode,
      this.status,
      this.gatewayMerchantGuid,
      this.availableBalance,
      this.isBalanceHidden = false,
      this.label,
      this.color,
      this.activated});

  AllCards.fromJson(Map<String, dynamic> json) {
    cardId = json['card_id'];
    cardBrand = json['card_brand'];
    cardClass = json['card_class'];
    cardNumber = json['card_number'];
    securityCode = json['security_code'];
    limitWindow = json['limit_window'];
    nameLine1 = json['name_line1'];
    nameLine2 = json['name_line2'];
    expirationDate = json['expiration_date'];
    expiration = json['expiration'];
    terminationDate = json['termination_date'];
    currencyCode = json['currency_code'];
    status = json['status'];
    gatewayMerchantGuid = json['gateway_merchant_guid'];
    availableBalance = double.parse(json['available_balance'].toString());
    activated = json['activated'];
    label = json['label'];
    color = json['color'];
    isBalanceHidden = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['card_id'] = cardId;
    data['card_brand'] = cardBrand;
    data['card_class'] = cardClass;
    data['card_number'] = cardNumber;
    data['security_code'] = securityCode;
    data['limit_window'] = limitWindow;
    data['name_line1'] = nameLine1;
    data['name_line2'] = nameLine2;
    data['expiration_date'] = expirationDate;
    data['expiration'] = expiration;
    data['termination_date'] = terminationDate;
    data['currency_code'] = currencyCode;
    data['status'] = status;
    data['gateway_merchant_guid'] = gatewayMerchantGuid;
    data['available_balance'] = availableBalance;
    data['activated'] = activated;
    data['label'] = label;
    data['color'] = color;
    return data;
  }
}
