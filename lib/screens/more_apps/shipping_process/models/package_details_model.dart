import 'package:Slydo/screens/more_apps/shipping_process/models/shipping_option_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
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
  Product? buyNow;

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
    this.buyNow,
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

  Map<String, dynamic> toCartPlaceOrder() {
    Map<String, dynamic> data = {
      "merchant": merchant,
      "pickup_address_id": addressId ?? "",
      "note": shippingNote,
    };
    int shippingId = 0;
    if (deliveryOption == DeliveryOptions.shipping) {
      if (shippingType == ShippingTypes.slydo) {
        shippingId = 5;
        data.addAll(
            {"rate_id": shippingOption?.rateId ?? "", "insurance": false});
      } else if (shippingType == ShippingTypes.merchant) {
        shippingId = shippingOption?.id ?? 0;
      } else if (shippingType == ShippingTypes.courier) {
        shippingId = 4;
        data.addAll({"rate_id": shippingOption?.rateId ?? ""});
      }
      data.addAll({"delivery_address_id": deliveryAddress?.id ?? ""});
    } else if (deliveryOption == DeliveryOptions.eatIn ||
        deliveryOption == DeliveryOptions.pickUp) {
      shippingId = 1;
    }
    data.addAll({
      "shipping_option_id": shippingId,
    });
    return data;
  }

  Map<String, dynamic> toBuyNowPlaceOrder(String? userName) {
    Map<String, dynamic> data = {
      "id": buyNow?.id ?? "",
      "qty": buyNow?.quantity ?? 1,
      "type": buyNow?.type ?? 'product',
      "add_ons": buyNow?.addOnsModels,
      "variants": buyNow?.variantModels,
      "item_added_by": userName ?? "",
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
        return "Eatin";

      case DeliveryOptions.pickUp:
        return "Pickup";
    }
  }

  String? getDeliveryTime() {
    if (shippingType == null) {
      return null;
    }
    switch (shippingType!) {
      case ShippingTypes.slydo:
        return "Estimated delivery time unknown";

      case ShippingTypes.merchant:
        return "Estimated delivery time unknown";

      case ShippingTypes.courier:
        return shippingOption?.deliveryTime;
    }
  }

  String? getDeliveryTag() {
    if (shippingType == null) {
      return null;
    }
    switch (shippingType!) {
      case ShippingTypes.slydo:
        return "Live Feed";

      case ShippingTypes.merchant:
        return "No Tracking Available";

      case ShippingTypes.courier:
        return "Tracking Available";
    }
  }

  String? getShippingLogo() {
    switch (shippingType!) {
      case ShippingTypes.slydo:
        return "assets/images/slydo.svg";
      case ShippingTypes.merchant:
        return "assets/images/merchant_logo.png";
      case ShippingTypes.courier:
        return shippingOption?.carrierLogo ?? "";
    }
  }

  void updateDeliveryAddress(ShippingAddress? shippingAddress) {
    deliveryAddress = shippingAddress;
  }

  void updateShippingNote(String? note) {
    shippingNote = note;
  }
}
