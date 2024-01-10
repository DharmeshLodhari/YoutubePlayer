import 'package:Slydo/screens/more_apps/business/models/Item.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/connection_list_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_message_settings.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/rider_registration/models/kyc_data_model.dart';
import 'package:Slydo/screens/more_apps/rider_registration/models/rider_model.dart';
import 'package:Slydo/screens/more_apps/rider_registration/models/rider_registration_model.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/package_details_model.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shipping_option_model.dart';
import 'package:Slydo/screens/more_apps/taxi/model/DirectionsModal.dart';
import 'package:Slydo/screens/more_apps/taxi/model/PlaceModal.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/UserAbout.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../screens/more_apps/shopping/models/store.dart';
import '../screens/more_apps/shopping/shopping_auth.dart';

class UserBloc extends ChangeNotifier {
  // This block notify the change in user status and pass it round the app.
  User _user = User(
      rider: null,
      uuid: null,
      url: null,
      phoneNumber: null,
      fullName: null,
      userName: null,
      avatar: null,
      qrCode: null,
      password: null,
      currency: null);

  ChatMessageSettings _chatMessageSettings = ChatMessageSettings();

  ChatMessageSettings get chatMessageSettings => _chatMessageSettings;

  set chatMessageSettings(ChatMessageSettings val) {
    _chatMessageSettings = val;
    notifyListeners();
  }

  bool get shouldReloadPostPage => _shouldReloadPostPage;
  bool _shouldReloadPostPage = false;

  set shouldReloadPostPage(bool shouldReload) {
    _shouldReloadPostPage = shouldReload;
    notifyListeners();
  }

  // Getter
  User get user => _user;

  // Setter
  set user(User val) {
    _user = val;
    notifyListeners();
  }

  set userAbout(UserAbout? userAbout) {
    _user.userAbout = userAbout;
    notifyListeners();
  }

  set updateNickName(String nickName) {
    _user.nickName = nickName;
    notifyListeners();
  }

  void updateProfileAvatar(String? url) {
    _user.avatar = url;
    notifyListeners();
  }

  void updateRider(RiderModel rider) {
    _user.rider = rider;
    notifyListeners();
  }

  void removeProfileAvatar() {
    _user.avatar = defaultImage;
    notifyListeners();
  }

  void removeProfileCover() {
    _user.wallpaper = "";
    _user.userAbout!.wallpaper = "";
    notifyListeners();
  }

  UserAbout? get userAbout => _user.userAbout;
}

class BankAccountBloc extends ChangeNotifier {
  // This block notify's the change in user status and pass it round the app.
  BankAccount? _bankAccount = BankAccount(
      uuid: null,
      bankAvatar: null,
      bankName: null,
      accountName: null,
      accountNumber: null);

  // Getter
  BankAccount? get bankAccount => _bankAccount;

  // Setter
  set bankAccount(BankAccount? val) {
    _bankAccount = val;
    notifyListeners();
  }
}

class CustomerProfileBloc extends ChangeNotifier {
  // This block notify's the change in user status and pass it round the app.
  CustomerProfile? _customer = CustomerProfile(
    fullName: null,
    userName: null,
    avatar: null,
    qrCode: null,
  );

  // Getter
  CustomerProfile? get customer => _customer;

  // Setter
  set customer(CustomerProfile? val) {
    _customer = val;
    notifyListeners();
  }
}

class RefreshBlocForTransaction extends ChangeNotifier {
  bool _isRefresh = false;

  bool get isRefresh => _isRefresh;

  set isRefresh(bool value) {
    _isRefresh = value;
    notifyListeners();
  }
}

class RefreshBlocForRequestPayment extends ChangeNotifier {
  bool _isRefresh = false;

  bool get isRefresh => _isRefresh;

  set isRefresh(bool value) {
    _isRefresh = value;
    notifyListeners();
  }
}

class RefreshBlocForMessages extends ChangeNotifier {
  bool _isRefresh = false;

  bool get isRefresh => _isRefresh;

  set isRefresh(bool value) {
    _isRefresh = value;
    notifyListeners();
  }
}

class RefreshBlocForConnectionDashboard extends ChangeNotifier {
  bool _isRefresh = false;

  bool get isRefresh => _isRefresh;

  set isRefresh(bool value) {
    _isRefresh = value;
    notifyListeners();
  }
}

class RefreshBlocForConnectionList extends ChangeNotifier {
  bool _isRefresh = false;

  bool get isRefresh => _isRefresh;

  set isRefresh(bool value) {
    _isRefresh = value;
    notifyListeners();
  }
}

class BackgroundFetchStopBloc extends ChangeNotifier {
  bool _isAllowed = true;

  bool get isAllowed => _isAllowed;

  set isAllowed(bool value) {
    _isAllowed = value;
    notifyListeners();
  }
}

class BasketBloc extends ChangeNotifier {
  int orderTotal = 0;
  int orderTotalProductService = 0;
  int totalShippingCost = 0;
  Map<String, int?> userSelectedShippingOption = {};

  // will accept products and services
  List<Map<String, dynamic>> _items = [];
  List<Map<dynamic, dynamic>> productOrService = [];
  int _total = 0;

  int get total => _total;

  set total(int value) {
    _total = value;
    notifyListeners();
  }

  List get items => _items;

  Map<String, String> merchantNameMap = {};
  Map<String, String> merchantNameMapCopy = {};
  List<Map<String, String>> merchantData = [];

  set items(List value) {
    _items = value as List<Map<String, dynamic>>;
    notifyListeners();
  }

  int getProductOrServiceQuantityInCart(String id) {
    int quantity = 0;

    items.forEach((element) {
      if (element["item"].id == id) {
        quantity = int.parse(element['qty'].toString());
      }
    });

    return quantity;
  }

  int getSubTotalPriceByMerchant({required String merchantUserName}) {
    int subTotal = 0;

    items.forEach((element) {
      var item = element['item'];

      if (merchantUserName == item.getMerchantUserName()) {
        List<Map<String, dynamic>> variants = [];
        if (element['variants'] != null) {
          variants = element['variants'];
        } else {
          subTotal +=
              int.parse(element['qty'].toString()) * int.parse(item.price);
        }

        if (variants.isEmpty) {
        } else {
          for (var variant in variants) {
            if (variant.containsKey('id') &&
                variant['id'] != null &&
                variant['id'].toString().isNotEmpty) {
              int quantity = int.parse(variant['quantity'].toString());
              int currentPrice = int.parse(variant['price'].toString());
              subTotal += quantity * currentPrice;
            }
          }
        }
      }
    });

    return subTotal;
  }

  bool isAnyIdEmpty(List<Map<String, dynamic>> mapList) {
    for (var map in mapList) {
      if (map.containsKey('id') &&
          map['id'] != null &&
          map['id'].toString().isNotEmpty) {
        // Found a map with a non-empty 'id' value, return false
        return false;
      }
    }
    // No map with a non-empty 'id' value was found, return true
    return true;
  }

  int getTotalPriceByMerchant(
      {required String merchantUserName, required int shippingOptionPrice}) {
    int total = getSubTotalPriceByMerchant(merchantUserName: merchantUserName) +
        shippingOptionPrice;

    return total;
  }

  // this will add the product or service in the cart;
  void addItemToCart(
      {required var item,
      required String type,
      Map<String, dynamic>? variant,
      List<Map<String, dynamic>?>? addOns}) {
    if (variant != null && variant.isNotEmpty) {
      addItemInBasketWithQty(item, type, variant);
    } else if (addOns != null && addOns.isNotEmpty) {
      addItemInBasketWithAddOns(item, type, addOns);
    } else if (variant != null &&
        variant.isEmpty &&
        addOns != null &&
        addOns.isEmpty) {
      addItemInBasketWithQtyService(item, type);
    } else {
      addItemInBasketWithQtyService(item, type);
    }

    addMerchantName(item);

    notifyListeners();
  }

  //get the list of merchant username and name without repetition
  void getAllMerchant() {
    for (var consumableData in items) {
      if (consumableData['type'] == 'product') {
        Product product = consumableData['item'];

        var username = product.seller!;
        if (!merchantData.any((merchant) => merchant['username'] == username)) {
          merchantData
              .add({'name': product.sellerFullName!, 'username': username});
        }
      } else if (consumableData['type'] == 'service') {
        Service service = consumableData['item'];

        var username = service.provider!;
        if (!merchantData.any((merchant) => merchant['username'] == username)) {
          merchantData
              .add({'name': service.providerFullName!, 'username': username});
        }
      }
    }
  }

  void removeMerchant(String name) {
    merchantData.removeWhere((map) => map["name"] == name);
    notifyListeners();
  }

  void addMerchantName(var item) {
    var merchantUserName = item is Product ? item.seller : item.provider;
    var merchantFullName =
        item is Product ? item.sellerFullName : item.providerFullName;

    merchantNameMap[merchantFullName] = merchantUserName;
    merchantNameMapCopy[merchantFullName] = merchantUserName;

    debugPrint('MERCHANT NAME COPY LENGTH ::: ${merchantNameMapCopy.length}');
    debugPrint('MERCHANT NAME COPY ::: $merchantNameMapCopy');
  }

  void removeMerchantName(var item) {
    var merchantFullName =
        item is Product ? item.sellerFullName : item.providerFullName;

    merchantNameMap.remove(merchantFullName);
    merchantNameMapCopy.remove(merchantFullName);
  }

  void addItemInBasketWithQty(
      var item, String type, Map<String, dynamic> variant) {
    bool itemExists = false;

    for (var element in _items) {
      if (element["item"].id == item.id) {
        // Check if the variant ID already exists in the item's variants list
        bool variantIdExists = false;

        Product product = element["item"];

        if (product.variant!.isNotEmpty && product.variant != null) {
          for (var existingVariant in product.variant!) {
            if (existingVariant["id"] == variant["id"]) {
              // Update the existing variant
              int existingQuantity =
                  int.tryParse(existingVariant["quantity"].toString()) ?? 0;
              int variantQuantity =
                  int.tryParse(variant["quantity"].toString()) ?? 0;
              existingVariant["quantity"] =
                  (existingQuantity + variantQuantity).toString();
              existingVariant["image"] = variant["image"];

              variantIdExists = true;
              break;
            }
          }
        }

        // If the variant doesn't exist, add it to the product's variants
        if (!variantIdExists) {
          // product.variant.add(variant);
          element["item"].variant.add(variant);
          notifyListeners();
        }

        // Increase the total quantity and exit the loop
        element["qty"] = (int.tryParse(element["qty"].toString()) ?? 0) + 1;

        if (variant["id"] != null && variant["id"].isNotEmpty) {
          // The variant has a non-empty "id" key
          String price = variant["price"];
          // Subtract the previous variant price and add the updated variant price
          _total = _total -
              (int.tryParse(item.price)! *
                  int.parse(variant["quantity"].toString())) +
              int.parse(price);
          itemExists = true;
        } else {
          // The variant does not have a valid "id" key
          _total = _total + int.parse(item.price);
          itemExists = true;
        }

        continue;
      }
    }

    if (!itemExists) {
      // Item doesn't exist in the basket, so create a new entry
      var product = Product();
      if (item is Product) {
        product.quantity = int.parse(variant['quantity'].toString());
        product.id = item.id;
        product.name = item.name;
        product.price = item.price;
        product.currency = item.currency;
        product.seller = item.seller;
        product.sellerFullName = item.sellerFullName;
        product.sellerAvatar = item.sellerAvatar;
        product.serverImages = item.serverImages;
        product.description = item.description;
        product.variant = [variant];
      }
      var newItem = {
        "type": type,
        "item": product,
        "qty": variant['quantity'],
        "variants": [variant]
      };

      _items.add(newItem);

      if (variant.containsKey("id") &&
          variant["id"] != null &&
          variant["id"].isNotEmpty) {
        // The variant has a non-empty "id" key
        String price = variant["price"];
        _total = _total + int.parse(price);
        itemExists = true;
      } else {
        // The variant does not have a valid "id" key
        _total = _total + int.parse(item.price);
      }
    }

    notifyListeners();
  }

  void addItemInBasketWithAddOns(
      var item, String type, List<Map<String, dynamic>?>? addOns) {
    bool itemExists = false;

    _items.forEach((element) {
      if (element["item"].id == item.id) {
        itemExists = true;
        element["qty"] = int.parse(element["qty"].toString()) + 1;
        _total = _total + int.parse(item.price);
        debugPrint("Exising Item Added");
        return;
      }
    });

    if (!itemExists) {
      // Item doesn't exist in the basket, so create a new entry
      var product = Product();
      if (item is Product) {
        product.quantity = item.quantity;
        // product.quantity = addOn['quantity'];
        product.id = item.id;
        product.name = item.name;
        product.price = item.price;
        product.currency = item.currency;
        product.seller = item.seller;
        product.sellerFullName = item.sellerFullName;
        product.sellerAvatar = item.sellerAvatar;
        product.serverImages = item.serverImages;
        product.description = item.description;
        product.addOns = addOns;
      }
      var newItem = {
        "type": type,
        "item": product,
        "qty": item.quantity,
        "add_ons": addOns
      };

      _items.add(newItem);

      // Calculate the total price based on the add-on quantity and options
      // int totalPrice = calculateTotalPrice(item.price, addOn);
      _total = _total +
          int.parse(product.price!) * int.parse(item.quantity.toString());
      // _total += totalPrice;
    }

    notifyListeners();
  }

  int calculateTotalPrice(String itemPrice, Map<String, dynamic> addOn) {
    int itemPriceValue = int.tryParse(itemPrice) ?? 0;
    // int addOnQuantity = addOn["quantity"];
    List<dynamic>? options = addOn["options"];
    int optionTotalPrice = options!.fold(0, (total, option) {
      int optionQuantity = option["quantity"];
      return total + (itemPriceValue * optionQuantity);
    });

    return itemPriceValue * 1 + optionTotalPrice;
  }

  void addItemInBasketWithQtyService(var item, String type) {
    bool flag = false;

    _items.forEach((element) {
      if (element["item"].id == item.id) {
        flag = true;
        element["qty"] = int.parse(element["qty"].toString()) + 1;
        _total = _total + int.parse(item.price);
        debugPrint("Exising Item Added");
        return;
      }
    });

    if (!flag) {
      if (item is Product) {
        _items.add({"type": type, "item": item, "qty": item.quantity});
      } else {
        _items.add({"type": type, "item": item, "qty": 1});
      }

      _total = _total + int.parse(item.price);
      debugPrint("New Item Added");
    }
    notifyListeners();
  }

  void increaseVariantQuantity(String selectedProductId, int variantId) {
    bool itemExists = false;

    for (var i = 0; i < _items.length; i++) {
      Product product = _items[i]["item"];

      if (product.id == selectedProductId) {
        // Check if the variant ID exists in the item's variants list
        for (var j = 0; j < _items[i]["variants"].length; j++) {
          if (int.parse(_items[i]["variants"][j]["id"]) == variantId) {
            // Add one to the variant quantity
            var quantity =
                int.parse(_items[i]["variants"][j]["quantity"].toString()) + 1;
            _items[i]["variants"][j]["quantity"] = quantity.toString();

            // Calculate the total price (assuming "price" is a string)
            _total += int.parse(_items[i]["variants"][j]["price"]);
            // Increase the total quantity
            var qty = int.parse(_items[i]["qty"].toString()) + 1;
            _items[i]["qty"] = qty;

            itemExists = true;
            break;
          }
        }

        break; // Exit the loop once the item is found
      }
    }

    if (!itemExists) {
      debugPrint("Item not found in the basket.");
    }

    notifyListeners();
  }

  Future<void> removeOrReduceVariant(
      String selectedProductId, int variantId) async {
    bool itemExists = false;

    for (var i = 0; i < _items.length; i++) {
      Product product = _items[i]["item"];

      if (product.id == selectedProductId) {
        List variantList = _items[i]['item'].variant;

        for (var j = 0; j < variantList.length; j++) {
          var variant = variantList[j];
          // debugPrint('fola cart state cart variant id:::: ${variant['id']}');
          // debugPrint('fola cart state cart variantid:::: ${variantId}');

          if (int.parse(variant['id'].toString()) == variantId) {
            if (int.parse(variant['quantity'].toString()) > 1) {
              // Update the quantity
              variant['quantity'] =
                  int.parse(variant['quantity'].toString()) - 1;
            } else {
              // Remove the variant
              variantList.removeAt(j);
            }
            _items[i]['qty'] = int.parse(_items[i]['qty'].toString()) - 1;

            // debugPrint('fola cart state cart qty 2:::: ${_items[i]['qty']}');

            if (_items[i]['qty'] == 0) {
              //remove item from cart
              Map<String, dynamic> data = {
                "id": selectedProductId,
                "type": "product",
                "qty": 0,
              };
              await ShoppingAuthService().removeItemFromShoppingCart(data);
            }
            itemExists = true;
            break; // Stop searching for the variant
          }
        }

        break; // Exit the loop once the item is found
      }
    }

    if (!itemExists) {
      debugPrint("Item not found in the basket.");
    }

    notifyListeners();
  }

  // this will remove the product or service from the cart;
  void removeItemFromCart(item) {
    removeItemInBasketWithQty(item);

    notifyListeners();
  }

  void removeItemInBasketWithQty(var item) {
    var foundItem;
    try {
      for (int i = 0; i < _items.length; i++) {
        if (_items[i]["item"].id == item.id) {
          foundItem = _items[i];
          break;
        }
      }

      if (foundItem != null) {
        if (foundItem["qty"] > 1) {
          foundItem["qty"] = foundItem["qty"] - 1;
          _total = _total - int.parse(item.price);
        } else if (foundItem["qty"] == 1) {
          _items.remove(foundItem);
          _total = _total - int.parse(item.price);
          removeMerchantName(item);
        } else if (foundItem["qty"] == 0) {
          _items.remove(foundItem);
          _total = _total - int.parse(item.price);
          removeMerchantName(item);
        } else {
          debugPrint("ERROR while removing element");
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error 1:- $e");
    }
  }

  void buyProductOrServiceNow(String type, Map itemData) {
    productOrService.add(itemData);
    notifyListeners();
  }

  void resetShoppingCart() async {
    _items.clear();
    List itemsCart = await ShoppingAuthService().getShoppingCart();

    for (var element in itemsCart) {
      String type = element is Product ? "product" : "service";

      // debugPrint('Variant Data element: $element');

      if (element is Product) {
        List<dynamic>? variantList = element.variant;
        List<Map<String, dynamic>?>? convertedList =
            element.addOns?.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          }
          // Handle other cases or return null if necessary
          return null;
        }).toList();

        if (variantList != null && variantList.isNotEmpty) {
          for (var variant in variantList) {
            if (variant is Map<String, dynamic>) {
              String? price = variant['price'].toString();
              String? id = variant['id'].toString();
              String? quantity = variant['quantity'].toString();
              String? value = variant['value'];
              String? type2 = variant['type'];
              String? colour = variant['colour'];

              String? variantImage = variant['pictures']
                  ?.first['file']; // Get the first image from pictures

              Map<String, dynamic> variant1 = {
                "id": id,
                "quantity": quantity,
                "image": variantImage,
                "price": price,
                "colour": colour,
                "value": value,
                "type": type2,
              };

              debugPrint('Variant Data: $variant1');

              // Add each variant as a separate item to the cart
              addItemToCart(item: element, type: type, variant: variant1);
            }
          }
        } else if (convertedList != null && convertedList.isNotEmpty) {
          addItemToCart(
              item: element, type: type, variant: null, addOns: convertedList);
        } else {
          // If no variants are present, add the product as a single item to the cart
          addItemToCart(item: element, type: type);
        }
      } else {
        addItemToCart(item: element, type: type, variant: null, addOns: null);
      }
    }
    if (itemsCart.isEmpty) {
      _items.clear();
    }

    notifyListeners();
  }
}

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

  void updateDeliveryOption(String pickedDeliveryOption) {
    if (pickedDeliveryOption == "Shipping") {
      getPackageDetailModel().deliveryOption = DeliveryOptions.shipping;
    } else if (pickedDeliveryOption == "Eatin") {
      getPackageDetailModel().deliveryOption = DeliveryOptions.eatIn;
      updateShippingOption(null);
      getPackageDetailModel().updateDeliveryAddress(null);
    } else if (pickedDeliveryOption == "Pickup") {
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

  void updateBuyNowProduct(Product? value, ShippingAddress addressListing) {
    getPackageDetailModel().buyNow = value;
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
    Map<String, dynamic> data = {
      "payment_type": "Slydo",
      "shipping_details": packagesList.map((e) => e.toCartPlaceOrder()).toList()
    };
    if (isUseCart == false)
      data.addAll({
        "shopped_item": [getPackageDetailModel().toBuyNowPlaceOrder(userName)]
      });
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

class RiderRegistrationBloc extends ChangeNotifier {
  RiderRegistrationModel? registrationModel = RiderRegistrationModel();
  KYCDataModel? kycDataModel = KYCDataModel();
  XFile? _tempPicture;

  XFile? get tempPicture => _tempPicture;

  set tempPicture(XFile? value) {
    _tempPicture = value;
    notifyListeners();
  }

  void updateKYCDataModel(KYCDataModel data) {
    kycDataModel = data;
    notifyListeners();
  }

  void updateRideType(String rideType) {
    if (rideType == "Car") {
      registrationModel?.rideTypeOptions = RideTypeOptions.car;
    } else if (rideType == "Bicycle") {
      registrationModel?.rideTypeOptions = RideTypeOptions.bicycle;
    } else if (rideType == "Motorcycle") {
      registrationModel?.rideTypeOptions = RideTypeOptions.motorcycle;
    }
    notifyListeners();
  }

  void updateKYCType(KYCTypes type) {
    switch (type) {
      case KYCTypes.riderPhoto:
        registrationModel?.kycTypes = KYCTypes.riderPhoto;
        break;
      case KYCTypes.identityCard:
        registrationModel?.kycTypes = KYCTypes.identityCard;
        break;
      case KYCTypes.vehicleInsurance:
        registrationModel?.kycTypes = KYCTypes.vehicleInsurance;
        break;
      case KYCTypes.drivingLicense:
        registrationModel?.kycTypes = KYCTypes.drivingLicense;
        break;
      case KYCTypes.hackneyPermit:
        registrationModel?.kycTypes = KYCTypes.hackneyPermit;
        break;
      default:
        break;
    }
    notifyListeners();
  }

  bool isPhotoAdded(KYCTypes type) {
    switch (type) {
      case KYCTypes.riderPhoto:
        return registrationModel?.mRiderPhoto != null ||
                kycDataModel?.selfie != null
            ? true
            : false;
      case KYCTypes.identityCard:
        return registrationModel?.mIdentityCard != null ||
                kycDataModel?.governmentId != null
            ? true
            : false;
      case KYCTypes.vehicleInsurance:
        return registrationModel?.mVehicleInsurance != null ||
                kycDataModel?.vehicleInsurance != null
            ? true
            : false;
      case KYCTypes.drivingLicense:
        return registrationModel?.mDrivingLicense != null ||
                kycDataModel?.vehicleLicense != null
            ? true
            : false;
      case KYCTypes.hackneyPermit:
        return registrationModel?.mDrivingLicense != null ||
                kycDataModel?.vehicleLicense != null
            ? true
            : false;
      default:
        return false;
    }
  }

  void setPhotoInRegistrationModel(XFile image, KYCTypes? type) {
    switch (type) {
      case KYCTypes.riderPhoto:
        registrationModel?.mRiderPhoto = image;
        break;
      case KYCTypes.identityCard:
        registrationModel?.mIdentityCard = image;
        break;
      case KYCTypes.vehicleInsurance:
        registrationModel?.mVehicleInsurance = image;
        break;
      case KYCTypes.drivingLicense:
        registrationModel?.mDrivingLicense = image;
        break;
      case KYCTypes.hackneyPermit:
        registrationModel?.mDrivingLicense = image;
        break;
      default:
        break;
    }
    notifyListeners();
  }

  bool checkAllProofAdded(RideTypeOptions? rideType) {
    switch (rideType) {
      case RideTypeOptions.car:
        if (registrationModel?.mRiderPhoto != null &&
            registrationModel?.mIdentityCard != null &&
            registrationModel?.mVehicleInsurance != null &&
            registrationModel?.mDrivingLicense != null) {
          return true;
        }
        return false;
      case RideTypeOptions.bicycle:
        if (registrationModel?.mRiderPhoto != null &&
            registrationModel?.mIdentityCard != null &&
            registrationModel?.mDrivingLicense != null) {
          return true;
        }
        return false;
      case RideTypeOptions.motorcycle:
        if (registrationModel?.mRiderPhoto != null &&
            registrationModel?.mIdentityCard != null &&
            registrationModel?.mVehicleInsurance != null &&
            registrationModel?.mDrivingLicense != null) {
          return true;
        }
        return false;
      default:
        return false;
    }
  }

  String? getUploadKYCTypePhoto() {
    switch (registrationModel?.kycTypes) {
      case KYCTypes.riderPhoto:
        return kycDataModel?.selfie;
      case KYCTypes.identityCard:
        return kycDataModel?.governmentId;
      case KYCTypes.vehicleInsurance:
        return kycDataModel?.vehicleInsurance;
      case KYCTypes.drivingLicense:
        return kycDataModel?.vehicleLicense;
      case KYCTypes.hackneyPermit:
        return kycDataModel?.vehicleLicense;
      default:
        return null;
    }
  }
}

class AddressBloc extends ChangeNotifier {
  ShippingAddress? _address;

  ShippingAddress? get address => _address;

  set address(ShippingAddress? value) {
    _address = value;
    notifyListeners();
  }
}

class TaxiBloc extends ChangeNotifier {
  PlaceModal? _startingPoint;

  PlaceModal? _destinationPoint;

  Map<String, dynamic>? _rideDetail;

  Directions? _startingPointToDestinationDirections;

  Directions? _driverToStartingPointDirections;

  PlaceModal? get startingPoint => _startingPoint;

  PlaceModal? get destinationPoint => _destinationPoint;

  Map<String, dynamic>? get rideDetail => _rideDetail;

  Directions? get startingPointToDestinationDirections =>
      _startingPointToDestinationDirections;

  Directions? get driverToStartingPointDirections =>
      _driverToStartingPointDirections;

  set startingPoint(PlaceModal? value) {
    _startingPoint = value;
    notifyListeners();
  }

  set destinationPoint(PlaceModal? value) {
    _destinationPoint = value;
    notifyListeners();
  }

  set rideDetail(Map<String, dynamic>? value) {
    _rideDetail = value;
    notifyListeners();
  }

  set startingPointToDestinationDirections(Directions? value) {
    _startingPointToDestinationDirections = value;
    notifyListeners();
  }

  set driverToStartingPointDirections(Directions? value) {
    _driverToStartingPointDirections = value;
    notifyListeners();
  }
}

class DashboardBloc extends ChangeNotifier {
  PageController _pageController = PageController(initialPage: 0);
  int _index = 0;

  int get index => _index;
  bool topYarn = false;
  bool topStore = false;

  PageController get pageController => _pageController;

  set index(int value) {
    if (value == 1) {
      // secureScreen();
    } else {
      // unsecureScreen();
    }
    _index = value;
    _pageController.animateToPage(_index,
        duration: Duration(milliseconds: 1), curve: Curves.linear);
    notifyListeners();
  }
}

class AddInvoiceBloc extends ChangeNotifier {
  List<InvoiceItem?> _items = [];
  int _total = 0;

  List<InvoiceItem?> get items => _items;

  set items(List<InvoiceItem?> value) {
    _items = value;
    notifyListeners();
  }

  int get total => _total;

  set total(int value) {
    _total = value;
    notifyListeners();
  }

  void addItem({InvoiceItem? invoiceItem}) {
    _items.add(invoiceItem);
    updateTotal();
    notifyListeners();
  }

  void removeItem({required int index}) {
    _items.removeAt(index);
    updateTotal();
    notifyListeners();
  }

  void updateItem({required int index, InvoiceItem? invoiceItem}) {
    _items.removeAt(index);
    _items.insert(index, invoiceItem);
    updateTotal();
    notifyListeners();
  }

  void clearItems() {
    _items.clear();
    total = 0;
    notifyListeners();
  }

  void updateTotal() {
    int sum = 0;
    _items.forEach((element) {
      sum += (element!.amount! * element.quantity!);
    });
    _total = sum;
  }
}

class ShareMessageToChatBloc extends ChangeNotifier {
  List<ChatConversation?> _recipientUsers = [];

  void addRecipient({ChatConversation? chatConversation}) {
    bool isAlreadyPresent = false;

    /// Check for user is already in the list
    _recipientUsers.forEach((element) {
      if (element!.userName == chatConversation!.userName)
        isAlreadyPresent = true;
    });

    /// if user not present in the list then we add that user in recipient list
    if (!isAlreadyPresent) {
      _recipientUsers.add(chatConversation);
      notifyListeners();
      printRecipient();
    }
  }

  void printRecipient() {
    debugPrint("Sharing to ${_recipientUsers.length} Users");

    _recipientUsers.forEach((element) {
      debugPrint(
          "==> Username ${element!.userName} ConversationId:- ${element.conversationId}");
    });
  }

  void removeRecipient({ChatConversation? customerProfile, String? username}) {
    String? userNameToCheck;

    if (customerProfile != null) {
      userNameToCheck = customerProfile.userName;
    } else {
      userNameToCheck = username;
    }

    if (userNameToCheck != null) {
      ChatConversation? recipientToBeRemoved;

      for (int i = 0; i < _recipientUsers.length; i++) {
        if (_recipientUsers[i]!.userName == customerProfile!.userName) {
          recipientToBeRemoved = _recipientUsers[i];
          break;
        }
      }

      if (recipientToBeRemoved != null) {
        _recipientUsers.remove(recipientToBeRemoved);
        printRecipient();
        notifyListeners();
      }
    }
  }

  List<ChatConversation?> getRecipients() {
    return _recipientUsers;
  }

  int recipientsLength() {
    return _recipientUsers.length;
  }

  void clearRecipient() {
    debugPrint("Clearing Sharing List");
    _recipientUsers.clear();
    notifyListeners();
  }
}

class ConnectionListBloc extends ChangeNotifier {
  List<ChatConversation> _connectionUsers = [];

  List<ChatConversation> get connectionUsers => _connectionUsers;

  Future<void> setConnectionUsers(
      {required List<ChatConversation> users}) async {
    /// adding chat Users in database for message Count
    ChatUserManager().addUsers(users);

    await ConnectionListManager().saveConnectionsToDB(connections: users);

    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    debugPrint('CONNECTION USERS --> ${_connectionUsers.length}');
    notifyListeners();
    return Future.value();
  }

  void addConnectionUser({required ChatConversation chatConversation}) async {
    await ConnectionListManager()
        .addConnectionToDB(chatConversation: chatConversation);

    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    notifyListeners();
  }

  Future<List<ChatConversation>> _getConnectionUsers() async {
    return await ConnectionListManager().getConnectionsFromDB();
  }

  Future<void> updateLastMessageTime(
      {String? conversationId, int? time}) async {
    await ConnectionListManager()
        .updateLastMessageTime(conversationId: conversationId, time: time);
    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    notifyListeners();
  }

  void updateChatConversation(
      {required ChatConversation chatConversation}) async {
    await ConnectionListManager()
        .updateChatConversation(chatConversation: chatConversation);
    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    notifyListeners();
  }

  void deleteChatConversation({String? conversationId}) async {
    await ConnectionListManager()
        .deleteChatConversation(conversationId: conversationId);
    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    notifyListeners();
  }

  Future<int> getConnectionsCount() async {
    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    notifyListeners();

    return _connectionUsers.length;
  }

  Future<void> clearConnectionList() async {
    await ConnectionListManager().clearConnections();
    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    notifyListeners();
    return;
  }
}

class ConnectionRequestListBloc extends ChangeNotifier {
  bool _hasConnectionRequests = false;

  bool get hasConnectionRequests => _hasConnectionRequests;

  set setHasConnectionRequests(bool hasRequests) {
    _hasConnectionRequests = hasRequests;
    notifyListeners();
  }
}
