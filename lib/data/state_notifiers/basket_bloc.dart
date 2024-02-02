import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:flutter/material.dart';

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
              int quantity = variant['quantity'];
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
      Variant? variant,
      List<AddOns>? addOns}) {
    if (variant != null) {
      addItemInBasketWithQty(item, type, variant);
    } else if (addOns != null && addOns.isNotEmpty) {
      addItemInBasketWithAddOns(item, type, addOns);
    } else if (variant != null && addOns != null && addOns.isEmpty) {
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

  void addItemInBasketWithQty(var item, String type, Variant variant) {
    bool itemExists = false;

    for (var element in _items) {
      if (element["item"].id == item.id) {
        // Check if the variant ID already exists in the item's variants list
        bool variantIdExists = false;

        Product product = element["item"];

        if (product.variantModels!.isNotEmpty &&
            product.variantModels != null) {
          for (var existingVariant in product.variantModels!) {
            if (existingVariant.id == variant.id) {
              // Update the existing variant
              int existingQuantity =
                  int.tryParse(existingVariant.quantity.toString()) ?? 0;
              int variantQuantity =
                  int.tryParse(variant.quantity.toString()) ?? 0;
              existingVariant.quantity = existingQuantity + variantQuantity;
              existingVariant.localImages = variant.localImages;

              variantIdExists = true;
              break;
            }
          }
        }

        // If the variant doesn't exist, add it to the product's variants
        if (!variantIdExists) {
          // product.variant.add(variant);
          (element["item"] as Product).variantModels?.add(variant);
          notifyListeners();
        }

        // Increase the total quantity and exit the loop
        element["qty"] = (int.tryParse(element["qty"].toString()) ?? 0) + 1;

        if (variant.id != null) {
          // The variant has a non-empty "id" key
          String? price = variant.price;
          // Subtract the previous variant price and add the updated variant price
          _total = _total -
              (int.tryParse(item.price)! *
                  int.parse(variant.quantity.toString())) +
              int.parse(price!);
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
        product.quantity = variant.quantity;
        product.id = item.id;
        product.name = item.name;
        product.price = item.price;
        product.currency = item.currency;
        product.seller = item.seller;
        product.sellerFullName = item.sellerFullName;
        product.sellerAvatar = item.sellerAvatar;
        product.serverImages = item.serverImages;
        product.description = item.description;
        product.variantModels = item.variantModels;
      }
      var newItem = {
        "type": type,
        "item": product,
        "qty": variant.quantity,
        "variants": [variant]
      };

      _items.add(newItem);

      if (variant.id != null) {
        // The variant has a non-empty "id" key
        String? price = variant.price;
        _total = _total + int.parse(price!);
        itemExists = true;
      } else {
        // The variant does not have a valid "id" key
        _total = _total + int.parse(item.price);
      }
    }

    notifyListeners();
  }

  void addItemInBasketWithAddOns(var item, String type, List<AddOns>? addOns) {
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
        product.addOnsModels = addOns;
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
        _items.add({"type": type, "item": item, "qty": 1});
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
        List<Variant> variantList =
            (_items[i]['item'] as Product).variantModels ?? [];

        for (var j = 0; j < variantList.length; j++) {
          var variant = variantList[j];
          // debugPrint('fola cart state cart variant id:::: ${variant['id']}');
          // debugPrint('fola cart state cart variantid:::: ${variantId}');

          if (int.parse(variant.id.toString()) == variantId) {
            if (variant.quantity! > 1) {
              // Update the quantity
              variant.quantity = variant.quantity! - 1;
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
        /// varient
        List<Variant>? variantList = element.variantModels;

        /// adds on
        List<AddOns>? convertedList = element.addOnsModels;

        if (variantList != null && variantList.isNotEmpty) {
          for (var variant in variantList) {
            // if (variant is Variant) {
            //   String? price = variant.price.toString();
            //   String? id = variant.id.toString();
            //   int? quantity = variant.quantity;
            //   String? value = variant.value;
            //   String? type2 = variant.type;
            //   String? colour = variant.colour;
            //
            //   String? variantImage; // Get the first image from pictures
            //
            //   if (variant.pictures != null &&
            //       variant.pictures is List &&
            //       (variant.pictures as List).isNotEmpty) {
            //     // variantImage = variant.pictures?.first['file'];
            //     variantImage = variant.pictures?.first.image.toString();
            //   }
            //
            //   Map<String, dynamic> variant1 = {
            //     "id": id,
            //     "quantity": quantity,
            //     "image": variantImage,
            //     "price": price,
            //     "colour": colour,
            //     "value": value,
            //     "type": type2,
            //   };
            //
            //   debugPrint('Variant Data: $variant1');

            // Add each variant as a separate item to the cart
            addItemToCart(item: element, type: type, variant: variant);
            // }
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
