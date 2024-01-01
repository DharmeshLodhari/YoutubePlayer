class ShippingOptionModel {
  int? id;
  String? currency;
  int? price;
  String? name;
  String? owner;
  String? type;
  String? priceType;
  DateTime? createdAt;
  DateTime? updatedAt;

  ShippingOptionModel({
    this.id,
    this.currency,
    this.price,
    this.name,
    this.owner,
    this.type,
    this.priceType,
    this.createdAt,
    this.updatedAt,
  });

  factory ShippingOptionModel.fromJson(Map<String, dynamic> json) =>
      ShippingOptionModel(
        id: json["id"],
        currency: json["currency"],
        price: json["price"],
        name: json["name"],
        owner: json["owner"],
        type: json["type"],
        priceType: json["price_type"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "currency": currency,
        "price": price,
        "name": name,
        "owner": owner,
        "type": type,
        "price_type": priceType,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
