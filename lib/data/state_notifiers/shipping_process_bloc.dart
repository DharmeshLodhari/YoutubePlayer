import 'package:Slydo/screens/more_apps/shipping_process/models/package_details_model.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shipping_option_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:flutter/material.dart';

class ShippingProcessBloc extends ChangeNotifier {
  List<PackageDetailsModel> _packagesList = <PackageDetailsModel>[];

  List<PackageDetailsModel> get packagesList => _packagesList;

  PackageDetailsModel buyNowPackageDetailsModel = PackageDetailsModel();

  set packagesList(List<PackageDetailsModel> value) {
    _packagesList = value;
    notifyListeners();
  }

  bool isPaymentSuccessful = false;
  bool isUseCart = true;

  int? _currentSelectedIndex;

  int? get currentSelectedIndex => _currentSelectedIndex;

  set currentSelectedIndex(int? value) {
    _currentSelectedIndex = value;
    notifyListeners();
  }

  PackageDetailsModel getPackageDetailModel() {
    if (isUseCart) {
      return _packagesList[_currentSelectedIndex!];
    }
    return buyNowPackageDetailsModel;
  }

  bool? isAllShippingProcessCompleted() {
    bool result = true;
    for (int i = 0; i < _packagesList.length; i++) {
      if (_packagesList[i].isShippingProcessCompleted == false) {
        result = false;
        break;
      }
    }
    return result;
  }

  int? getServiceCharge() {
    int serviceCharge = 0;
    for (int i = 0; i < _packagesList.length; i++) {
      serviceCharge = _packagesList[i].customerServiceFee ?? 0;
    }
    return serviceCharge;
  }

  int? getTotalItemCost() {
    int sum = 0;
    for (int i = 0; i < _packagesList.length; i++) {
      sum += _packagesList[i].totalPrice ?? 0;
    }
    return sum;
  }

  int? getTotalShipping() {
    int total = 0;
    for (int i = 0; i < _packagesList.length; i++) {
      total += _packagesList[i].shippingOption?.price ?? 0;
    }
    return total;
  }

  int? getTotalOrder() {
    final int? totalItemCost = getTotalItemCost();
    final int? totalShipping = getTotalShipping();
    final int? serviceCharge = getServiceCharge();
    return (totalItemCost ?? 0) + (totalShipping ?? 0) + (serviceCharge ?? 0);
  }

  void updateDeliveryOption(String pickedDeliveryOption,
      {void Function()? pickUpSelectCallBack}) {
    if (pickedDeliveryOption == "Shipping") {
      getPackageDetailModel().deliveryOption = DeliveryOptions.shipping;
    } else if (pickedDeliveryOption == "In Store/Eat In") {
      getPackageDetailModel().deliveryOption = DeliveryOptions.eatIn;
      updateShippingOption(null);
      getPackageDetailModel().updateDeliveryAddress(null);
    } else if (pickedDeliveryOption == "Pickup") {
      pickUpSelectCallBack!();
      getPackageDetailModel().deliveryOption = DeliveryOptions.pickUp;
      updateShippingOption(null);
      getPackageDetailModel().updateDeliveryAddress(null);
    } else {
      getPackageDetailModel().deliveryOption = DeliveryOptions.shipping;
    }
    notifyListeners();
  }

  void updateShippingProcessCompleted(bool process) {
    getPackageDetailModel().isShippingProcessCompleted = process;
    notifyListeners();
  }

  void updateShippingOptionType(ShippingTypes type) {
    getPackageDetailModel().shippingType = type;
    notifyListeners();
  }

  void updateShippingOption(ShippingOptionModel? shippingOptionModel) {
    getPackageDetailModel().shippingOption = shippingOptionModel;
    notifyListeners();
  }

  void updateBuyNowProduct(Product? value, Variant? variant,
      List<AddOns> addOns, ShippingAddress addressListing) {
    getPackageDetailModel().buyNow = value?.copyWith(quantity: 1);
    getPackageDetailModel().variants = variant;
    getPackageDetailModel().addOns = addOns;
    getPackageDetailModel().merchant = value?.seller;
    getPackageDetailModel().addressId = value?.addressId;
    getPackageDetailModel().totalItems = 1;
    getPackageDetailModel().totalPrice = value?.getBuyNowProductPrice();
    getPackageDetailModel().merchantAddress = addressListing;
    notifyListeners();
  }

  void isPaymentSuccessfully(bool val) {
    isPaymentSuccessful = val;
    notifyListeners();
  }

  void isUseCartProcess(bool val) {
    isUseCart = val;
    notifyListeners();
  }

  Map<String, dynamic> toPlaceOrder(String? userName) {
    final Map<String, dynamic> data = {
      "payment_type": "Slydo",
      "shipping_details": packagesList.map((e) => e.toCartPlaceOrder()).toList()
    };
    if (isUseCart == false) {
      data.addAll({
        "shopped_item": [getPackageDetailModel().toBuyNowPlaceOrder(userName)]
      });
    }
    return data;
  }

  void setPackageDetailForBuyNow() {
    packagesList = [];
    packagesList.add(buyNowPackageDetailsModel);
    notifyListeners();
  }

  void clearBuyNowData() {
    isPaymentSuccessful = false;
    buyNowPackageDetailsModel = PackageDetailsModel();
    notifyListeners();
  }
}
