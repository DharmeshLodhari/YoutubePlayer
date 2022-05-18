class ProviderDetailsModel {
  int? amount;
  String name;
  String currency;
  String productId;

  ProviderDetailsModel({
    required this.name,
    required this.amount,
    required this.currency,
    required this.productId,
  });

  factory ProviderDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProviderDetailsModel(
      name: json['name'],
      amount: json['amount'],
      productId: json['id'],
      currency: json['currency'],
    );
  }
}
