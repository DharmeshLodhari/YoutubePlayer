import 'package:Slydo/screens/more_apps/shipping_process/auth/shared_cart_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/basket_item_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';

/// id : "96a0a291-71a8-4b13-9aa8-c26b606287b9"
/// members_details : [{"username":"psami","avatar":"http://0.0.0.0:8000/static/images/User_Avatar.png","full_name":"psami"},{"username":"sam","avatar":"http://0.0.0.0:8000/static/images/User_Avatar.png","full_name":"sam"},{"username":"boss","avatar":"http://0.0.0.0:8000/static/images/User_Avatar.png","full_name":"boss"}]
/// name : "My special cart"
/// shared : true
/// members : ["psami","sam","boss"]
/// customer_username : "psami"
/// created_at : "2023-10-23T17:54:07.089166+01:00"

class SharedCartModel {
  String? id;
  List<UserFollowers>? membersDetails;
  String? name;
  bool? shared;
  List<String>? members;
  String? customerUsername;
  String? createdAt;
  // MetaData? metaData;
  bool? splitBill = false;
  bool? splitBillEvenly = false;

  List<BasketItem> _basketItems = [];

  List<BasketItem> get basketItems => _basketItems;

  SharedCartModel({
    this.id,
    this.membersDetails,
    this.name,
    this.shared,
    this.members,
    this.customerUsername,
    this.createdAt,
    // this.metaData,
    this.splitBill,
    this.splitBillEvenly,
  });

  SharedCartModel.fromJson(dynamic json) {
    id = json['id'];
    if (json['members_details'] != null) {
      membersDetails = [];
      json['members_details'].forEach((v) {
        membersDetails?.add(UserFollowers.fromJson(v));
      });
    }
    name = json['name'];
    shared = json['shared'];
    members = json['members'] != null ? json['members'].cast<String>() : [];
    customerUsername = json['customer_username'];
    createdAt = json['created_at'];
    // metaData: json["meta_data"] == null ? null : MetaData.fromJson(json["meta_data"]),
  }

  SharedCartModel copyWith({
    String? id,
    List<UserFollowers>? membersDetails,
    String? name,
    bool? shared,
    List<String>? members,
    String? customerUsername,
    String? createdAt,
  }) =>
      SharedCartModel(
        id: id ?? this.id,
        membersDetails: membersDetails ?? this.membersDetails,
        name: name ?? this.name,
        shared: shared ?? this.shared,
        members: members ?? this.members,
        customerUsername: customerUsername ?? this.customerUsername,
        createdAt: createdAt ?? this.createdAt,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    if (membersDetails != null) {
      map['members_details'] = membersDetails?.map((v) => v.toJson()).toList();
    }
    map['name'] = name;
    map['shared'] = shared;
    map['members'] = members;
    map['customer_username'] = customerUsername;
    map['created_at'] = createdAt;
    // "meta_data": metaData?.toJson(),
    return map;
  }

  double getSplitBillEvenly() {
    double? result = 0;
    if (splitBillEvenly == true) {
      if (membersDetails != null) {
        int? listLength = membersDetails?.length ?? 0;

        result = 100 / listLength;
      }
    }
    return result;
  }

  int getSplitBillEvenlyPayment() {
    int? result = 0;
    if (splitBillEvenly == true) {
      if (membersDetails != null) {
        int? listLength = membersDetails?.length ?? 0;

        result = (getSharedCartTotalPrice() / listLength).floor();
      }
    }
    return result;
  }

  // this will add the product or service in the cart;
  void addItemToCart(
      {required PurchasableItem item,
      required String type,
      Variant? variant,
      List<AddOns>? addOns,
      bool withApiCall = true}) {
    if (variant != null) {
      addItemInBasketWithVariants(item, type, variant,
          withApiCall: withApiCall);
    } else if (addOns != null && addOns.isNotEmpty) {
      addItemInBasketWithAddOns(item, type, addOns, withApiCall: withApiCall);
    } else if (variant != null && addOns != null && addOns.isEmpty) {
      addItemInBasketWithQtyService(item, type, withApiCall: withApiCall);
    } else {
      addItemInBasketWithQtyService(item, type, withApiCall: withApiCall);
    }
  }

  void addItemInBasketWithQtyService(var item, String type,
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
        return;
      }
    });

    if (!flag) {
      BasketItem basketItem = BasketItem(item: item, qty: item.qty, type: type);

      _basketItems.add(basketItem);

      addedOrUpdatedItem = basketItem;
    }

    /// add or update this item to the server
    if (withApiCall && addedOrUpdatedItem != null) {
      BasketListModifierPayload data = _basketItems.toPayload(
          addedOrUpdatedItem!,
          actionType: BasketListModifierAction.increaseQty);
      if (data.payload.isNotEmpty) {
        SharedCartAuthService().addItemToSharedCart(id, data.payload);
      }
    }
  }

  void addItemInBasketWithVariants(
      PurchasableItem item, String type, Variant variant,
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
            type: type, item: item, qty: variant.quantity, variants: [variant]);
        addedOrUpdatedItem = basketItem;
        _basketItems.add(basketItem);
      }
    }

    /// add or update this item to the server
    if (withApiCall && addedOrUpdatedItem != null) {
      BasketListModifierPayload data = _basketItems.toPayload(
          addedOrUpdatedItem,
          actionType: BasketListModifierAction.increaseQty);
      if (data.payload.isNotEmpty) {
        SharedCartAuthService().addItemToSharedCart(id, data.payload);
      }
    }
  }

  void addItemInBasketWithAddOns(
      PurchasableItem item, String type, List<AddOns>? addOns,
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

    /// add or update this item to the server
    if (withApiCall && addedOrUpdatedItem != null) {
      BasketListModifierPayload data = _basketItems.toPayload(
          addedOrUpdatedItem,
          actionType: BasketListModifierAction.increaseQty);
      if (data.payload.isNotEmpty) {
        SharedCartAuthService().addItemToSharedCart(id, data.payload);
      }
    }
  }

  void increaseQty(
      {Product? currentProduct, BasketItem? data, bool withApiCall = true}) {
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

    if (withApiCall && addedOrUpdatedItem != null) {
      BasketListModifierPayload data = _basketItems.toPayload(
          addedOrUpdatedItem,
          actionType: BasketListModifierAction.increaseQty);
      if (data.payload.isNotEmpty) {
        SharedCartAuthService().addItemToSharedCart(id, data.payload);
      }
    }
  }

  void decreaseQty(
      {Product? currentProduct, BasketItem? data, bool withApiCall = true}) {
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

    if (withApiCall && addedOrUpdatedItem != null) {
      BasketListModifierPayload data = _basketItems.toPayload(
        addedOrUpdatedItem,
        actionType: BasketListModifierAction.decreaseQty,
      );
      if (data.payload.isNotEmpty) {
        if (data.payloadType == BasketListModifierPayloadTypes.remove) {
          SharedCartAuthService().removeItemFromSharedCart(id, data.payload);
        } else {
          SharedCartAuthService().addItemToSharedCart(id, data.payload);
        }
      }
    }
  }

  int getSharedCartTotalPrice() {
    int totalPrice = 0;

    for (var item in _basketItems) {
      int variantTotal = 0;
      int normalTotal = 0;
      if (item.item?.isProduct ?? false) {
        if (item.hasVariant) {
          int variantPrice =
              int.parse(item.variants?.first.price.toString() ?? "");
          int quantity = item.variants?.first.quantity ?? 0;
          variantTotal += variantPrice * quantity;
          totalPrice += variantTotal;
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

  double getTotalOfPercentage() {
    double total = 0;
    if (splitBillEvenly == true) {
      total = 100;
    } else {
      if (membersDetails != null) {
        for (var item in membersDetails!) {
          total += item.paymentPercentageValue ?? 0;
        }
      }
    }
    return total;
  }

  void updatePerAndPrice(double val, int index) {
    membersDetails?[index].paymentPercentageValue = val;

    int dividedPayment = 0;
    if (splitBillEvenly == true) {
      dividedPayment = (getSharedCartTotalPrice() /
              int.parse(membersDetails?.length.toString() ?? ''))
          .floor();
    } else {
      dividedPayment = ((getSharedCartTotalPrice() * val) / 100).floor();
    }
    membersDetails?[index].dividedPayment = dividedPayment;
  }

  int getSplitBillTotalPayment() {
    int total = 0;
    for (UserFollowers item in membersDetails ?? []) {
      total += item.dividedPayment ?? 0;
    }
    return total;
  }
}

// /// username : "psami"
// /// avatar : "http://0.0.0.0:8000/static/images/User_Avatar.png"
// /// full_name : "psami"
//
// class MembersDetails {
//   String? username;
//   String? avatar;
//   String? fullName;
//
//   MembersDetails({
//     this.username,
//     this.avatar,
//     this.fullName,
//   });
//
//   MembersDetails.fromJson(dynamic json) {
//     username = json['username'];
//     avatar = json['avatar'];
//     fullName = json['full_name'];
//   }
//
//   MembersDetails copyWith({
//     String? username,
//     String? avatar,
//     String? fullName,
//   }) =>
//       MembersDetails(
//         username: username ?? this.username,
//         avatar: avatar ?? this.avatar,
//         fullName: fullName ?? this.fullName,
//       );
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['username'] = username;
//     map['avatar'] = avatar;
//     map['full_name'] = fullName;
//     return map;
//   }
// }
