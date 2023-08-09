class CardTransactions {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? transactionId;
  String? merchantName;
  String? merchantCity;
  String? merchantState;
  String? merchantMcc;
  String? merchantMid;
  String? merchantCountry;
  String? transactionType;
  String? transactionStatus;
  double? transactionAmount;
  String? currencyCode;
  String? transactionTime;
  String? description;
  String? network;
  double? authorizationAmount;
  String? authorizationCurrencyCode;
  double? balanceAfterTransaction;
  String? providerCreatedAt;
  String? providerUpdatedAt;

  CardTransactions(
      {this.id,
        this.createdAt,
        this.updatedAt,
        this.transactionId,
        this.merchantName,
        this.merchantCity,
        this.merchantState,
        this.merchantMcc,
        this.merchantMid,
        this.merchantCountry,
        this.transactionType,
        this.transactionStatus,
        this.transactionAmount,
        this.currencyCode,
        this.transactionTime,
        this.description,
        this.network,
        this.authorizationAmount,
        this.authorizationCurrencyCode,
        this.balanceAfterTransaction,
        this.providerCreatedAt,
        this.providerUpdatedAt});

  CardTransactions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    transactionId = json['transaction_id'];
    merchantName = json['merchant_name'];
    merchantCity = json['merchant_city'];
    merchantState = json['merchant_state'];
    merchantMcc = json['merchant_mcc'];
    merchantMid = json['merchant_mid'];
    merchantCountry = json['merchant_country'];
    transactionType = json['transaction_type'];
    transactionStatus = json['transaction_status'];
    transactionAmount = double.parse(json['transaction_amount'].toString());
    currencyCode = json['currency_code'];
    transactionTime = json['transaction_time'];
    description = json['description'];
    network = json['network'];
    authorizationAmount = double.parse(json['authorization_amount'].toString());
    authorizationCurrencyCode = json['authorization_currency_code'];
    balanceAfterTransaction = double.parse(json['balance_after_transaction'].toString());
    providerCreatedAt = json['provider_created_at'];
    providerUpdatedAt = json['provider_updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['transaction_id'] = transactionId;
    data['merchant_name'] = merchantName;
    data['merchant_city'] = merchantCity;
    data['merchant_state'] = merchantState;
    data['merchant_mcc'] = merchantMcc;
    data['merchant_mid'] = merchantMid;
    data['merchant_country'] = merchantCountry;
    data['transaction_type'] = transactionType;
    data['transaction_status'] = transactionStatus;
    data['transaction_amount'] = transactionAmount;
    data['currency_code'] = currencyCode;
    data['transaction_time'] = transactionTime;
    data['description'] = description;
    data['network'] = network;
    data['authorization_amount'] = authorizationAmount;
    data['authorization_currency_code'] = authorizationCurrencyCode;
    data['balance_after_transaction'] = balanceAfterTransaction;
    data['provider_created_at'] = providerCreatedAt;
    data['provider_updated_at'] = providerUpdatedAt;
    return data;
  }
}