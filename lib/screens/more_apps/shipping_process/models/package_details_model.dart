import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';

class PackageDetailsModel {
  String? addressId;
  String? merchant;
  int? totalItems;
  int? totalPrice;
  ShippingAddress? merchantAddress;
  ShippingAddress? deliveryAddress;

  PackageDetailsModel({
    this.addressId,
    this.merchant,
    this.totalItems,
    this.totalPrice,
    this.merchantAddress,
    this.deliveryAddress,
  });

  factory PackageDetailsModel.fromJson(Map<String, dynamic> json) {
    return PackageDetailsModel(
      addressId: json["address_id"],
      merchant: json["merchant"],
      totalItems: json["total_items"],
      totalPrice: json["total_price"],
      merchantAddress: json["address"] != null
          ? ShippingAddress.fromJson(json["address"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "address_id": addressId,
        "merchant": merchant,
        "total_items": totalItems,
        "total_price": totalPrice,
      };
}
