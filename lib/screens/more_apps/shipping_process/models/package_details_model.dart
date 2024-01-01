class PackageDetailsModel {
  String? addressId;
  String? merchant;
  int? totalItems;
  int? totalPrice;

  PackageDetailsModel({
    this.addressId,
    this.merchant,
    this.totalItems,
    this.totalPrice,
  });

  factory PackageDetailsModel.fromJson(Map<String, dynamic> json) =>
      PackageDetailsModel(
        addressId: json["address_id"],
        merchant: json["merchant"],
        totalItems: json["total_items"],
        totalPrice: json["total_price"],
      );

  Map<String, dynamic> toJson() => {
        "address_id": addressId,
        "merchant": merchant,
        "total_items": totalItems,
        "total_price": totalPrice,
      };
}
