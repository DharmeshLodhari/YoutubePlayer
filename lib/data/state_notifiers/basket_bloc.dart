import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/basket_item_model.dart';
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

  /// New Model implemented
  List<BasketItem> _basketItems = [];

  List<BasketItem> get basketItems => _basketItems;

  int getProductOrServiceQuantityInCart(String id) {
    int quantity = 0;

    _basketItems.forEach((element) {
      if (element.item?.id == id) {
        quantity = int.parse(element.qty.toString());
      }
    });
    return quantity;
  }

  int getTotalPrice() {
    int totalPrice = 0;

    for (var item in _basketItems) {
      int variantTotal = 0;
      int AddOnOptionTotal = 0;
      int AddOnTotal = 0;
      int normalTotal = 0;
      if (item.item?.isProduct ?? false) {
        if (item.hasVariant) {
          int variantPrice =
              int.parse(item.variants?.first.price.toString() ?? "");
          int quantity = item.variants?.first.quantity ?? 0;
          variantTotal += variantPrice * quantity;
          totalPrice += variantTotal;
        } else if (item.hasAddOns) {
          Product product = item.item as Product;
          for (AddOns itemAddOn in item.addOns ?? []) {
            for (var option in itemAddOn.options!) {
              AddOnOptionTotal +=
                  int.parse(option.price.toString()) * option.quantity;
            }
          }
          normalTotal = int.parse(product.price.toString()) *
              int.parse(product.qty.toString());
          AddOnTotal = AddOnOptionTotal + normalTotal;
          totalPrice += AddOnTotal;
        } else {
          Product product = item.item as Product;

          normalTotal = int.parse(product.price.toString()) *
              int.parse(product.qty.toString());
          totalPrice += normalTotal;
        }
      }
    }
    return totalPrice;
  }

  // this will add the product or service in the cart;
  void addItemToCart({
    required PurchasableItem item,
    required String type,
    Variant? variant,
    List<AddOns>? addOns,
    bool withApiCall = true,
    SharedCartMemberModel? currentUser,
  }) {
    if (variant != null) {
      addItemInBasketWithVariants(item, type, variant, currentUser,
          withApiCall: withApiCall);
    } else if (addOns != null && addOns.isNotEmpty) {
      addItemInBasketWithAddOns(item, type, addOns, currentUser,
          withApiCall: withApiCall);
    } else if (variant != null && addOns != null && addOns.isEmpty) {
      addItemInBasketWithQtyService(item, type, currentUser,
          withApiCall: withApiCall);
    } else {
      addItemInBasketWithQtyService(item, type, currentUser,
          withApiCall: withApiCall);
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

  void addItemInBasketWithVariants(PurchasableItem item, String type,
      Variant variant, SharedCartMemberModel? currentUser,
      {bool withApiCall = true}) {
    /// if we create or update existing basket item we will store that item to this variable
    /// for sending to server
    BasketItem? addedOrUpdatedItem;

    /// if there is no item in basket then we will add that directly with 1 qty
    /// else we will check if same item present then we will increase qty of already added basket item
    if (_basketItems.isEmpty) {
      BasketItem basketItem = BasketItem(
        type: type,
        item: item,
        qty: variant.quantity,
        variants: [variant],
      );

      addedOrUpdatedItem = basketItem;
      _basketItems.add(basketItem);
    } else {
      bool isSameItemPresent = false;

      for (BasketItem basketItem in _basketItems) {
        /// if item is product
        if (item.isProduct) {
          if (basketItem.item is Product) {
            Product alreadyPresentProduct = basketItem.item as Product;
            Product newProduct = item as Product;

            /// check for product id is same then check for variant
            if (alreadyPresentProduct.id == newProduct.id) {
              if (variant.id == basketItem.variants?.first.id) {
                if (basketItem.variants?.first.quantity != null) {
                  basketItem.variants?.first.quantity =
                      (basketItem.variants?.first.quantity ?? 1) + 1;
                  isSameItemPresent = true;

                  addedOrUpdatedItem = basketItem;
                  break;
                }
              }
            }
          }
        }

        /// if item is service
        else if (basketItem.item?.isService ?? false) {
          /// TODO: write code for service
        }
      }

      /// if same item is not present then we will add new basket item with qty 1
      if (isSameItemPresent == false) {
        BasketItem basketItem = BasketItem(
          type: type,
          item: item,
          qty: variant.quantity,
          variants: [variant],
        );
        addedOrUpdatedItem = basketItem;
        _basketItems.add(basketItem);
      }
    }

    notifyListeners();

    /// add or update this item to the server
    if (withApiCall && addedOrUpdatedItem != null) {
      BasketListModifierPayload data = _basketItems.toPayload(
          addedOrUpdatedItem,
          actionType: BasketListModifierAction.increaseQty);
      if (data.payload.isNotEmpty) {
        ShoppingAuthService().addOrUpdateItemToShoppingCart(data.payload);
      }
    }
  }

  void addItemInBasketWithVariantsOld(var item, String type, Variant variant) {
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
        "qty": 1,
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

  void addItemInBasketWithAddOns(PurchasableItem item, String type,
      List<AddOns>? addOns, SharedCartMemberModel? currentUser,
      {bool withApiCall = true}) {
    /// if we create or update existing basket item we will store that item to this variable
    /// for sending to server
    BasketItem? addedOrUpdatedItem;

    /// if there is no item in basket then we will add that directly with 1 qty
    /// else we will check if same item present then we will increase qty of already added basket item
    bool isSameItemPresent = false;

    for (BasketItem basketItem in _basketItems) {
      /// if item is product
      if (item.isProduct) {
        if (basketItem.item is Product) {
          Product alreadyPresentProduct = basketItem.item as Product;
          Product newProduct = item as Product;

          /// check for product id is same then check for addOns
          if (alreadyPresentProduct.id == newProduct.id) {
            basketItem.qty = (basketItem.qty ?? 0) + 1;
            isSameItemPresent = true;

            if ((alreadyPresentProduct.addOnsModels?.isNotEmpty ?? false) &&
                (newProduct.addOnsModels?.isNotEmpty ?? false)) {
              for (AddOns newAddOn in newProduct.addOnsModels ?? []) {
                bool isExistingAddOn = false;
                for (AddOns oldAddOn
                    in alreadyPresentProduct.addOnsModels ?? []) {
                  if (oldAddOn.id == newAddOn.id) {
                    isExistingAddOn = true;

                    for (AddOnOption newOption in newAddOn.options ?? []) {
                      bool isExistingAddOnOptions = false;
                      for (AddOnOption oldOption in oldAddOn.options ?? []) {
                        if (oldOption.id == newOption.id) {
                          isExistingAddOnOptions = true;

                          oldOption.quantity =
                              oldOption.quantity + newOption.quantity;
                          break;
                        }
                      }

                      if (isExistingAddOnOptions == false) {
                        oldAddOn.options?.add(newOption);
                      }
                    }

                    break;
                  }
                }

                if (isExistingAddOn == false) {
                  alreadyPresentProduct.addOnsModels?.add(newAddOn);
                }
              }
            }
            addedOrUpdatedItem = basketItem;
            break;
          }
        }
      }

      /// if item is service
      else if (basketItem.item?.isService ?? false) {
        /// TODO: write code for service
      }
    }

    /// if same item is not present then we will add new basket item with qty 1
    if (isSameItemPresent == false) {
      BasketItem basketItem = BasketItem(
          type: type, item: item, qty: (item as Product).qty, addOns: addOns);
      addedOrUpdatedItem = basketItem;
      _basketItems.add(basketItem);
    }

    notifyListeners();

    /// add or update this item to the server
    if (withApiCall && addedOrUpdatedItem != null) {
      BasketListModifierPayload data = _basketItems.toPayload(
          addedOrUpdatedItem,
          actionType: BasketListModifierAction.increaseQty);
      if (data.payload.isNotEmpty) {
        ShoppingAuthService().addOrUpdateItemToShoppingCart(data.payload);
      }
    }
  }

  void addItemInBasketWithAddOnsOld(var item, String type, List<AddOns>? addOns,
      {bool withApiCall = true}) {
    /// if we create or update existing basket item we will store that item to this variable
    /// for sending to server
    BasketItem? addedOrUpdatedItem;

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

    /// add or update this item to the server
    if (withApiCall && addedOrUpdatedItem != null) {
      BasketListModifierPayload data = _basketItems.toPayload(
          addedOrUpdatedItem,
          actionType: BasketListModifierAction.increaseQty);
      if (data.payload.isNotEmpty) {
        ShoppingAuthService().addOrUpdateItemToShoppingCart(data.payload);
      }
    }
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

  void addItemInBasketWithQtyService(
      var item, String type, SharedCartMemberModel? currentUser,
      {bool withApiCall = true}) {
    /// if we create or update existing basket item we will store that item to this variable
    /// for sending to server
    BasketItem? addedOrUpdatedItem;

    bool flag = false;

    _basketItems.forEach((element) {
      if (element.item?.id == item.id) {
        flag = true;
        element.qty = int.parse(element.qty.toString()) + 1;

        addedOrUpdatedItem = element;
        debugPrint("Exising Item Added");
        return;
      }
    });

    if (!flag) {
      BasketItem basketItem = BasketItem(
        item: item,
        qty: (item as Product).qty,
        type: type,
      );

      _basketItems.add(basketItem);

      addedOrUpdatedItem = basketItem;
    }
    notifyListeners();

    /// add or update this item to the server
    if (withApiCall && addedOrUpdatedItem != null) {
      BasketListModifierPayload data = _basketItems.toPayload(
          addedOrUpdatedItem!,
          actionType: BasketListModifierAction.increaseQty);
      if (data.payload.isNotEmpty) {
        ShoppingAuthService().addOrUpdateItemToShoppingCart(data.payload);
      }
    }
  }

  void addItemInBasketWithQtyServiceOld(var item, String type) {
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

  Future<void> resetShoppingCart() async {
    _items.clear();
    _basketItems.clear();
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
            addItemToCart(
              item: element,
              type: type,
              variant: variant,
              withApiCall: false,
            );
          }
        } else if (convertedList != null && convertedList.isNotEmpty) {
          addItemToCart(
            item: element,
            type: type,
            variant: null,
            addOns: convertedList,
            withApiCall: false,
          );
        } else {
          // If no variants are present, add the product as a single item to the cart
          addItemToCart(
            item: element,
            type: type,
            withApiCall: false,
          );
        }
      } else {
        addItemToCart(
          item: element,
          type: type,
          variant: null,
          addOns: null,
          withApiCall: false,
        );
      }
    }
    if (itemsCart.isEmpty) {
      _items.clear();
      _basketItems.clear();
    }

    notifyListeners();
  }

  Map<String, dynamic> getServerPayload() {
    Map<String, dynamic> data = {};

    return data;
  }

  void increaseQty(
      {Product? currentProduct,
      BasketItem? data,
      SharedCartMemberModel? currentUser,
      bool withApiCall = true}) {
    if (currentProduct != null) {
      for (BasketItem item in _basketItems) {
        if (item.item?.id == currentProduct.id) {
          data = item;
        }
      }
    }

    /// if we create or update existing basket item we will store that item to this variable
    /// for sending to server
    BasketItem? addedOrUpdatedItem;

    if (data?.item?.isProduct ?? false) {
      /// if basket item has variant
      if (data?.hasVariant ?? false) {
        for (BasketItem basketItem in _basketItems) {
          if (basketItem.item?.id == data?.item?.id) {
            Variant? variant = basketItem.variants?.first;
            if (variant != null) {
              if (variant.id == data?.variants?.first.id) {
                variant.quantity = (variant.quantity ?? 0) + 1;
                basketItem.qty = (basketItem.qty ?? 0) + 1;

                addedOrUpdatedItem = basketItem;
                break;
              }
            }
          }
        }

        /// if basket item has add0ns
      } else if (data?.hasAddOns ?? false) {
        for (BasketItem basketItem in _basketItems) {
          Product product = basketItem.item as Product;

          if (basketItem.item?.id == data?.item?.id) {
            for (AddOns addOns in basketItem.addOns ?? []) {
              for (AddOnOption options in addOns.options ?? []) {
                options.quantity = options.quantity + 1;
              }
            }
            basketItem.qty = (basketItem.qty ?? 0) + 1;
            product.qty = (product.qty ?? 0) + 1;
            addedOrUpdatedItem = basketItem;
            break;
          }
        }
      } else {
        for (BasketItem basketItem in _basketItems) {
          if (basketItem.item?.id == data?.item?.id) {
            Product product = basketItem.item as Product;

            basketItem.qty = (basketItem.qty ?? 0) + 1;
            product.qty = (product.qty ?? 0) + 1;

            addedOrUpdatedItem = basketItem;
            break;
          }
        }
      }
    }

    notifyListeners();

    if (withApiCall && addedOrUpdatedItem != null) {
      BasketListModifierPayload data = _basketItems.toPayload(
          addedOrUpdatedItem,
          actionType: BasketListModifierAction.increaseQty);
      if (data.payload.isNotEmpty) {
        ShoppingAuthService().addOrUpdateItemToShoppingCart(data.payload);
      }
    }
  }

  void decreaseQty(
      {Product? currentProduct,
      BasketItem? data,
      SharedCartMemberModel? currentUser,
      bool withApiCall = true}) {
    if (currentProduct != null) {
      for (BasketItem item in _basketItems) {
        if (item.item?.id == currentProduct.id) {
          data = item;
        }
      }
    }

    /// if we create or update existing basket item we will store that item to this variable
    /// for sending to server
    BasketItem? addedOrUpdatedItem;

    if (data?.item?.isProduct ?? false) {
      /// if basket item has variant
      if (data?.hasVariant ?? false) {
        for (BasketItem basketItem in _basketItems) {
          if (basketItem.item?.id == data?.item?.id) {
            Variant? variant = basketItem.variants?.first;
            if (variant != null) {
              if (variant.id == data?.variants?.first.id) {
                variant.quantity = (variant.quantity ?? 0) - 1;
                basketItem.qty = (basketItem.qty ?? 0) - 1;

                addedOrUpdatedItem = basketItem;
                break;
              }
            }
          }
        }

        /// if basket item has add0ns
      } else if (data?.hasAddOns ?? false) {
        for (BasketItem basketItem in _basketItems) {
          Product product = basketItem.item as Product;

          if (basketItem.item?.id == data?.item?.id) {
            // for (AddOns addOns in basketItem.addOns ?? []) {
            //   for (AddOnOption options in addOns.options ?? []) {
            //     options.quantity = options.quantity - 1;
            //   }
            // }
            basketItem.qty = (basketItem.qty ?? 0) - 1;
            product.qty = (product.qty ?? 0) - 1;
            addedOrUpdatedItem = basketItem;
            break;
          }
        }
      } else {
        for (BasketItem basketItem in _basketItems) {
          if (basketItem.item?.id == data?.item?.id) {
            Product product = basketItem.item as Product;

            basketItem.qty = (basketItem.qty ?? 0) - 1;
            product.qty = (product.qty ?? 0) - 1;

            addedOrUpdatedItem = basketItem;
            break;
          }
        }
      }
    }

    notifyListeners();

    if (withApiCall && addedOrUpdatedItem != null) {
      BasketListModifierPayload data = _basketItems.toPayload(
        addedOrUpdatedItem,
        actionType: BasketListModifierAction.decreaseQty,
      );
      if (data.payload.isNotEmpty) {
        if (data.payloadType == BasketListModifierPayloadTypes.remove) {
          ShoppingAuthService().removeItemFromShoppingCart(data.payload);
        } else {
          ShoppingAuthService().addOrUpdateItemToShoppingCart(data.payload);
        }
      }
    }
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
}
