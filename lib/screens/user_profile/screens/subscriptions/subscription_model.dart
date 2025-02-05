class SubscriptionsModel {
  int id;
  int price;
  String currency;
  String accountType;
  String subscriptionType;

  SubscriptionsModel({
    required this.id,
    required this.price,
    required this.currency,
    required this.accountType,
    required this.subscriptionType,
  });

  factory SubscriptionsModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionsModel(
      id: json['id'],
      price: json['price'],
      currency: json['currency'],
      accountType: json['account_type'],
      subscriptionType: json['subscription_type'],
    );
  }
}
