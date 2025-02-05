class ProviderProductModel {
  int? amount;
  String name;
  bool lookUp;
  String currency;
  String productId;

  ProviderProductModel({
    required this.name,
    required this.lookUp,
    required this.amount,
    required this.currency,
    required this.productId,
  });

  factory ProviderProductModel.fromJson(Map<String, dynamic> json) {
    return ProviderProductModel(
      name: json['name'],
      lookUp: json['lookup'],
      amount: json['amount'],
      productId: json['id'],
      currency: json['currency'],
    );
  }
}
