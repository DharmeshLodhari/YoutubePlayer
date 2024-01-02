import 'package:Slydo/screens/more_apps/shipping_process/models/shipping_option_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';

enum DeliveryOptions { shipping, eatIn, pickUp }

enum ShippingTypes { slydo, merchant, courier }

class PackageDetailsModel {
  String? addressId;
  String? merchant;
  int? totalItems;
  int? totalPrice;
  ShippingAddress? merchantAddress;
  ShippingAddress? deliveryAddress;
  DeliveryOptions? deliveryOption;
  ShippingOptionModel? shippingOption;
  ShippingTypes? shippingType;
  String? shippingNote;
  bool insurePackage = false;
  bool isShippingProcessCompleted = false;

  PackageDetailsModel({
    this.addressId,
    this.merchant,
    this.totalItems,
    this.totalPrice,
    this.merchantAddress,
    this.deliveryAddress,
    this.deliveryOption,
    this.shippingOption,
    this.shippingNote = "",
    this.insurePackage = false,
    this.shippingType,
    this.isShippingProcessCompleted = false,
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

  bool requireNote() {
    if (deliveryOption == DeliveryOptions.shipping) {
      return false;
    }
    return true;
  }

  bool getInSurePackage() {
    return insurePackage;
  }

  Map<String, dynamic> toPlaceOrder() {
    Map<String, dynamic> data = {
      "merchant": merchant,
      // "rate_id": shippingOption?.rateId ?? "",
      "pickup_address_id": merchantAddress?.id ?? "",
      "delivery_address_id": deliveryAddress?.id ?? "",
      "shipping_option": shippingOption?.id ?? ""
    };

    return data;
  }

  String? getDeliveryOption() {
    if (deliveryOption == null) {
      return null;
    }

    switch (deliveryOption!) {
      case DeliveryOptions.shipping:
        return "Shipping";

      case DeliveryOptions.eatIn:
        return "Eat in";

      case DeliveryOptions.pickUp:
        return "Pickup";
    }
  }

  void updateDeliveryAddress(ShippingAddress? shippingAddress) {
    deliveryAddress = shippingAddress;
  }

  int getAmount() {
    return totalPrice ?? 0;
  }
}
