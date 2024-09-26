class CurrencyModel {
  String? id;
  String? currency;
  int? rate;
  bool? isAutoUpdatedBySlydo;

  CurrencyModel({
    this.id,
    this.currency,
    this.rate,
    this.isAutoUpdatedBySlydo,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) => CurrencyModel(
        id: json["id"],
        currency: json["currency"],
        rate: json["rate"],
        isAutoUpdatedBySlydo: json["is_auto_updated_by_slydo"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "currency": currency,
        "rate": rate,
        "is_auto_updated_by_slydo": isAutoUpdatedBySlydo,
      };

  Map<String, dynamic> toAddUpdate() {
    final map = <String, dynamic>{};
    // map['id'] = id;
    map['currency'] = currency;
    map['rate'] = rate;
    // map['is_auto_updated_by_slydo'] = isAutoUpdatedBySlydo ?? false;
    return map;
  }

  CurrencyModel copyWith({
    String? id,
    String? currency,
    int? rate,
    bool? isAutoUpdatedBySlydo,
  }) {
    return CurrencyModel(
      id: id ?? this.id,
      currency: currency ?? this.currency,
      rate: rate ?? this.rate,
      isAutoUpdatedBySlydo: isAutoUpdatedBySlydo ?? this.isAutoUpdatedBySlydo,
    );
  }
}
