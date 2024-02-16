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
  String? name;
  String? customerUsername;
  bool? shared;
  DateTime? createdAt;
  int? subtotal;
  // List<Product>? cartItems;
  SharedMetaData? metaData;
  List<SharedCartMemberModel>? members;
  bool? splitBill = false;
  bool? splitBillEvenly = false;

  List<BasketItem> _basketItems = [];

  List<BasketItem> get basketItems => _basketItems;

  SharedCartModel({
    this.id,
    this.name,
    this.customerUsername,
    this.shared,
    this.createdAt,
    this.subtotal,
    // this.cartItems,
    this.metaData,
    this.members,
    this.splitBill,
    this.splitBillEvenly,
  });

  SharedCartModel.fromJson(dynamic json) {
    id = json["id"];
    name = json["name"];
    customerUsername = json["customer_username"];
    shared = json["shared"];
    createdAt =
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]);
    subtotal = json["subtotal"];
    // cartItems = json["cart_items"] == null
    //     ? []
    //     : List<Product>.from(
    //         json["cart_items"]!.map((x) => Product.fromJson(x)));
    metaData = json["meta_data"] == null
        ? null
        : SharedMetaData.fromJson(json["meta_data"]);
    members = json["members"] == null
        ? []
        : List<SharedCartMemberModel>.from(json["members"]!
            .map((x) => SharedCartMemberModel.fromJson(x, metaData)));
  }

  SharedCartModel copyWith({
    String? id,
    String? name,
    String? customerUsername,
    bool? shared,
    DateTime? createdAt,
    int? subtotal,
    // List<Product>? cartItems,
    // SharedMetaData? metaData,
    List<SharedCartMemberModel>? members,
  }) =>
      SharedCartModel(
        id: id ?? this.id,
        name: name ?? this.name,
        customerUsername: customerUsername ?? this.customerUsername,
        shared: shared ?? this.shared,
        createdAt: createdAt ?? this.createdAt,
        subtotal: subtotal ?? this.subtotal,
        // cartItems: cartItems ?? this.cartItems,
        // metaData: metaData ?? this.metaData,
        members: members ?? this.members,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['customer_username'] = customerUsername;
    map['shared'] = shared;
    map['created_at'] = createdAt?.toIso8601String();
    map['subtotal'] = subtotal;
    // map['cart_items'] = cartItems == null
    //     ? []
    //     : List<dynamic>.from(cartItems!.map((x) => x.toJson()));
    // map['meta_data'] = metaData?.toJson();
    map['members'] = members == null
        ? []
        : List<SharedCartMemberModel>.from(members!.map((x) => x.toJson()));
    return map;
  }

  // this will add the product or service in the cart;
  void addItemToCart(
      {required PurchasableItem item,
      required String type,
      Variant? variant,
      List<AddOns>? addOns,
      bool withApiCall = true,
      String? currentUser}) {
    if (variant != null) {
      addItemInBasketWithVariants(item, type, variant,
          withApiCall: withApiCall);
    } else if (addOns != null && addOns.isNotEmpty) {
      addItemInBasketWithAddOns(item, type, addOns, withApiCall: withApiCall);
    } else if (variant != null && addOns != null && addOns.isEmpty) {
      addItemInBasketWithQtyService(item, type, currentUser,
          withApiCall: withApiCall);
    } else {
      addItemInBasketWithQtyService(item, type, currentUser,
          withApiCall: withApiCall);
    }
  }

  void addItemInBasketWithQtyService(var item, String type, String? currentUser,
      {bool withApiCall = true}) {
    /// if we create or update existing basket item we will store that item to this variable
    /// for sending to server
    BasketItem? addedOrUpdatedItem;

    bool flag = false;

    _basketItems.forEach((element) {
      if (element.item?.id == item.id) {
        flag = true;
        element.qty = int.parse(element.qty.toString()) + 1;

        if (withApiCall == true) {
          (element.item as Product).getItemAddedByDetails(
              currentUser, element.qty ?? 0,
              actionType: BasketListModifierAction.increaseQty);
        }

        addedOrUpdatedItem = element;
        return;
      }
    });

    if (!flag) {
      if (withApiCall == true) {
        (item as Product).getItemAddedByDetails(currentUser, item.qty ?? 0,
            actionType: BasketListModifierAction.increaseQty);
      }

      BasketItem basketItem = BasketItem(
        item: item,
        qty: item.qty,
        type: type,
        itemAddedBy: item.itemAddedBy,
      );

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

  void getSplitBillEvenlyPercentage() {
    if (splitBillEvenly == true) {
      if (members != null) {
        int? listLength = members?.length ?? 0;

        for (var item in members!) {
          item.percentageValue =
              double.parse((100 / listLength).toStringAsFixed(2));
        }
      }
    }
  }

  void getSplitBillEvenlyPayment(int? totalOrder) {
    if (splitBillEvenly == true) {
      if (members != null) {
        int? listLength = members?.length ?? 0;

        for (var item in members!) {
          item.paymentValue = ((totalOrder ?? 0) / listLength).floor();
        }
      }
    }
  }

  void updatePerAndPrice(double val, int index) {}

  double getTotalOfPercentage() {
    double total = 0;
    if (splitBillEvenly == true) {
      total = 100;
    } else {
      if (members != null) {
        for (var item in members!) {
          total += item.percentageValue ?? 0;
        }
      }
    }
    return total.roundToDouble();
  }

  int getSplitBillTotalPayment(int? totalOrder) {
    int total = 0;
    if (splitBillEvenly == true) {
      total = totalOrder ?? 0;
    } else {
      if (members != null) {
        for (SharedCartMemberModel item in members ?? []) {
          total += item.paymentValue ?? 0;
        }
      }
    }
    return total;
  }

  List<UserFollowers> convertToUserFollowersList() {
    List<UserFollowers> userList = [];

    userList = members?.map((e) => e.toUserFollowerModel()).toList() ?? [];
    return userList;
  }
}

class SharedCartMemberModel {
  String? userName;
  String? avatar;
  bool? isVerified;
  String? fullName;
  String? accountType;
  double? percentageValue = 0;
  int? paymentValue = 0;

  SharedCartMemberModel({
    this.userName,
    this.avatar,
    this.isVerified,
    this.fullName,
    this.accountType,
    this.percentageValue = 0,
    this.paymentValue = 0,
  });

  SharedCartMemberModel.fromJson(dynamic json, SharedMetaData? mataDataJson) {
    userName = json['username'];
    avatar = json['avatar'];
    isVerified = json['is_verified'];
    fullName = json['full_name'];
    accountType = json['account_type'];
    if (mataDataJson != null) {
      List<UserData>? userData = mataDataJson.userData
              ?.where((element) => element.username == userName)
              .toList() ??
          [];
      if (userData != null && userData.isNotEmpty) {
        percentageValue = double.parse(userData.first.percentage.toString());
        paymentValue = userData.first.amount;
      }
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['username'] = userName;
    map['avatar'] = avatar;
    map['is_verified'] = isVerified;
    map['full_name'] = fullName;
    map['account_type'] = accountType;
    return map;
  }

  UserFollowers toUserFollowerModel() {
    UserFollowers userFollowers = UserFollowers();
    userFollowers.avatar = avatar;
    return userFollowers;
  }
}

class SharedMetaData {
  List<UserData>? userData;

  SharedMetaData({
    this.userData,
  });

  factory SharedMetaData.fromJson(Map<String, dynamic> json) => SharedMetaData(
        userData: json["user-data"] == null
            ? []
            : List<UserData>.from(
                json["user-data"]!.map((x) => UserData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "user-data": userData == null
            ? []
            : List<dynamic>.from(userData!.map((x) => x.toJson())),
      };
}

class CartItem {
  String? id;
  int? qty;
  String? type;
  List<Variant>? variants;
  String? itemUpdatedBy;
  List<AddOns>? addOns;

  CartItem({
    this.id,
    this.qty,
    this.type,
    this.variants,
    this.itemUpdatedBy,
    this.addOns,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json["id"],
        qty: json["qty"],
        type: json["type"],
        variants: json["variants"] == null
            ? []
            : List<Variant>.from(
                json["variants"]!.map((x) => Variant.fromJson(x))),
        itemUpdatedBy: json["item_updated_by"],
        addOns: json["add_ons"] == null
            ? []
            : List<AddOns>.from(
                json["add_ons"]!.map((x) => AddOns.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "qty": qty,
        "type": type,
        "variants": variants == null
            ? []
            : List<Variant>.from(variants!.map((x) => x.toJson())),
        "item_updated_by": itemUpdatedBy,
        "add_ons": addOns == null
            ? []
            : List<AddOns>.from(addOns!.map((x) => x.toJson())),
      };
}

class UserData {
  int? amount;
  String? currency;
  String? username;
  double? percentage;

  UserData({
    this.amount,
    this.currency,
    this.username,
    this.percentage,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        amount: json["amount"],
        currency: json["currency"],
        username: json["username"],
        percentage: json["percentage"],
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "currency": currency,
        "username": username,
        "percentage": percentage,
      };
}
