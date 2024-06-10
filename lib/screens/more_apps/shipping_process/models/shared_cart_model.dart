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
  // bool? splitBill;
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
    // this.splitBill,
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
        : List<SharedCartMemberModel>.from(json["members"]!.map(
            (x) => SharedCartMemberModel.fromJson(x, mataDataJson: metaData)));
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

  bool isUserPaymentDone(String? userName) {
    for (PaymentDatum paymentDoneUser in metaData?.paymentData ?? []) {
      if (userName == paymentDoneUser.fromCustomer) {
        return true;
      }
    }
    for (UserData user in metaData?.userData ?? []) {
      if (userName == user.username &&
          user.percentage == 0.0 &&
          userName != customerUsername) {
        return true;
      }
      if (userName == customerUsername) {
        return true;
      }
    }
    return false;
  }

  bool isAllCartPaymentDone() {
    bool isAllPaymentDone = true;
    for (SharedCartMemberModel member in members ?? []) {
      if (isUserPaymentDone(member.userName) == false) {
        isAllPaymentDone = false;
        break;
      }
    }
    return isAllPaymentDone;
  }

  // this will add the product or service in the cart;
  void addItemToCart(
      {required PurchasableItem item,
      required String type,
      Variant? variant,
      List<AddOns>? addOns,
      bool withApiCall = true,
      SharedCartMemberModel? currentUser,
      bool replaceUpdatedBy = false}) {
    if (variant != null) {
      addItemInBasketWithVariants(item, type, variant, currentUser,
          withApiCall: withApiCall, replaceUpdatedBy: replaceUpdatedBy);
    } else if (addOns != null && addOns.isNotEmpty) {
      addItemInBasketWithAddOns(item, type, addOns, currentUser,
          withApiCall: withApiCall, replaceUpdatedBy: replaceUpdatedBy);
    } else if (variant != null && addOns != null && addOns.isEmpty) {
      addItemInBasketWithQtyService(item, type, currentUser,
          withApiCall: withApiCall, replaceUpdatedBy: replaceUpdatedBy);
    } else {
      addItemInBasketWithQtyService(item, type, currentUser,
          withApiCall: withApiCall, replaceUpdatedBy: replaceUpdatedBy);
    }
  }

  void addItemInBasketWithQtyService(
      var item, String type, SharedCartMemberModel? currentUser,
      {bool withApiCall = true, bool replaceUpdatedBy = false}) {
    /// if we create or update existing basket item we will store that item to this variable
    /// for sending to server
    BasketItem? addedOrUpdatedItem;

    bool flag = false;

    for (var element in _basketItems) {
      if (element.item?.id == item.id) {
        flag = true;

        if (replaceUpdatedBy == true) {
          (element.item as Product).itemAddedBy = item.itemAddedBy;
          element.itemAddedBy = item.itemAddedBy;
          element.qty = (item as Product).quantity;
        }

        if (withApiCall == true) {
          element.qty = int.parse(element.qty.toString()) + 1;
          (element.item as Product).getItemAddedByDetails(currentUser,
              actionType: BasketListModifierAction.increaseQty);
        }

        addedOrUpdatedItem = element;
        continue;
      }
    }

    if (!flag) {
      if (withApiCall == true) {
        (item as Product).getItemAddedByDetails(currentUser,
            actionType: BasketListModifierAction.increaseQty);
      }

      final BasketItem basketItem = BasketItem(
        item: item,
        qty: (item as Product).quantity,
        type: type,
        itemAddedBy: item.itemAddedBy,
      );

      _basketItems.add(basketItem);

      addedOrUpdatedItem = basketItem;
    }

    /// add or update this item to the server
    if (withApiCall && addedOrUpdatedItem != null) {
      final BasketListModifierPayload data = _basketItems.toPayload(
          addedOrUpdatedItem,
          actionType: BasketListModifierAction.increaseQty);
      if (data.payload.isNotEmpty) {
        SharedCartAuthService().addItemToSharedCart(id, data.payload);
      }
    }
  }

  void addItemInBasketWithVariants(PurchasableItem item, String type,
      Variant variant, SharedCartMemberModel? currentUser,
      {bool withApiCall = true, bool replaceUpdatedBy = false}) {
    /// if we create or update existing basket item we will store that item to this variable
    /// for sending to server
    BasketItem? addedOrUpdatedItem;

    /// if there is no item in basket then we will add that directly with 1 qty
    /// else we will check if same item present then we will increase qty of already added basket item
    if (_basketItems.isEmpty) {
      if (withApiCall == true) {
        variant.getVariantAddedByDetails(currentUser,
            actionType: BasketListModifierAction.increaseQty);
      }

      final BasketItem basketItem = BasketItem(
        type: type,
        item: item,
        qty: variant.quantity,
        variants: [variant],
      );

      _basketItems.add(basketItem);

      addedOrUpdatedItem = basketItem;
    } else {
      bool isSameItemPresent = false;

      for (BasketItem basketItem in _basketItems) {
        /// if item is product
        if (item.isProduct) {
          if (basketItem.item is Product) {
            final Product alreadyPresentProduct = basketItem.item as Product;
            final Product newProduct = item as Product;

            /// check for product id is same then check for variant
            if (alreadyPresentProduct.id == newProduct.id) {
              if (variant.id == basketItem.variants?.first.id) {
                if (basketItem.variants?.first.quantity != null) {
                  isSameItemPresent = true;

                  if (replaceUpdatedBy == true) {
                    for (Variant variant in newProduct.variantModels ?? []) {
                      if (variant.id == basketItem.variants?.first.id) {
                        basketItem.variants?.first.addedBy = variant.addedBy;
                        basketItem.variants?.first.addedBy = variant.addedBy;
                        // basketItem.variants?.first.quantity = variant.quantity;
                      }
                    }
                  }

                  if (withApiCall == true) {
                    basketItem.variants?.first.quantity =
                        (basketItem.variants?.first.quantity ?? 1) + 1;
                    basketItem.variants?.first.getVariantAddedByDetails(
                        currentUser,
                        actionType: BasketListModifierAction.increaseQty);
                  }

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
        if (withApiCall == true) {
          variant.getVariantAddedByDetails(currentUser,
              actionType: BasketListModifierAction.increaseQty);
        }

        final BasketItem basketItem = BasketItem(
          type: type,
          item: item,
          qty: variant.quantity,
          variants: [variant],
        );

        addedOrUpdatedItem = basketItem;
        _basketItems.add(basketItem);
      }
    }

    /// add or update this item to the server
    if (withApiCall && addedOrUpdatedItem != null) {
      final BasketListModifierPayload data = _basketItems.toPayload(
          addedOrUpdatedItem,
          actionType: BasketListModifierAction.increaseQty);
      if (data.payload.isNotEmpty) {
        SharedCartAuthService().addItemToSharedCart(id, data.payload);
      }
    }
  }

  void addItemInBasketWithAddOns(PurchasableItem item, String type,
      List<AddOns>? addOns, SharedCartMemberModel? currentUser,
      {bool withApiCall = true, bool replaceUpdatedBy = false}) {
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
          final Product alreadyPresentProduct = basketItem.item as Product;
          final Product newProduct = item as Product;

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

                          if (replaceUpdatedBy == true) {
                            oldOption.addedBy = newOption.addedBy;
                            oldOption.addedBy = newOption.addedBy;
                            oldOption.quantity = newOption.quantity;
                          }

                          if (withApiCall == true) {
                            oldOption.quantity =
                                oldOption.quantity + newOption.quantity;
                            break;
                          }
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

            if (replaceUpdatedBy == true) {
              (basketItem.item as Product).itemAddedBy = item.itemAddedBy;
              basketItem.itemAddedBy = item.itemAddedBy;
              basketItem.qty = item.quantity;
            }

            if (withApiCall == true) {
              final Product presentProduct = (basketItem.item as Product);

              for (AddOns addOn in addOns ?? []) {
                for (AddOns presentAddOn in presentProduct.addOnsModels ?? []) {
                  bool isAddOnExist = false;

                  if (presentAddOn.id == addOn.id) {
                    isAddOnExist = true;

                    bool isAddOnOptionExist = false;
                    for (AddOnOption addOnOptions in addOn.options ?? []) {
                      for (AddOnOption presentAddOnOptions
                          in presentAddOn.options ?? []) {
                        if (presentAddOnOptions.id == addOnOptions.id) {
                          isAddOnOptionExist = true;

                          presentAddOnOptions.getAddOnOptionAddedByDetails(
                              currentUser,
                              actionType: BasketListModifierAction.increaseQty);
                          break;
                        }
                      }

                      if (isAddOnOptionExist == false) {
                        addOnOptions.getAddOnOptionAddedByDetails(currentUser,
                            actionType: BasketListModifierAction.increaseQty);
                        presentAddOn.options?.add(addOnOptions);
                      }
                    }

                    if (isAddOnExist == false) {
                      presentProduct.addOnsModels?.add(addOn);
                    }
                  }
                }
              }

              presentProduct.getItemAddedByDetails(currentUser,
                  actionType: BasketListModifierAction.increaseQty);
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
      if (withApiCall == true) {
        (item as Product).getItemAddedByDetails(currentUser,
            actionType: BasketListModifierAction.increaseQty);

        for (AddOns addOn in addOns ?? []) {
          for (AddOnOption option in addOn.options ?? []) {
            option.getAddOnOptionAddedByDetails(currentUser,
                actionType: BasketListModifierAction.increaseQty);
          }
        }
      }

      final BasketItem basketItem = BasketItem(
          type: type,
          item: item,
          qty: (item as Product).quantity,
          addOns: addOns,
          itemAddedBy: item.itemAddedBy);

      addedOrUpdatedItem = basketItem;
      _basketItems.add(basketItem);
    }

    /// add or update this item to the server
    if (withApiCall && addedOrUpdatedItem != null) {
      final BasketListModifierPayload data = _basketItems.toPayload(
          addedOrUpdatedItem,
          actionType: BasketListModifierAction.increaseQty);
      if (data.payload.isNotEmpty) {
        SharedCartAuthService().addItemToSharedCart(id, data.payload);
      }
    }
  }

  void increaseQty(
      {Product? currentProduct,
      BasketItem? data,
      SharedCartMemberModel? currentUser,
      bool withApiCall = true}) async {
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
            final Variant? variant = basketItem.variants?.first;
            if (variant != null) {
              if (variant.id == data?.variants?.first.id) {
                variant.quantity = (variant.quantity ?? 0) + 1;
                basketItem.qty = (basketItem.qty ?? 0) + 1;

                if (withApiCall == true) {
                  basketItem.variants?.first.getVariantAddedByDetails(
                      currentUser,
                      actionType: BasketListModifierAction.increaseQty);
                }

                addedOrUpdatedItem = basketItem;
                break;
              }
            }
          }
        }

        /// if basket item has add0ns
      } else if (data?.hasAddOns ?? false) {
        for (BasketItem basketItem in _basketItems) {
          final Product product = basketItem.item as Product;

          if (basketItem.item?.id == data?.item?.id) {
            for (AddOns addOns in basketItem.addOns ?? []) {
              for (AddOnOption options in addOns.options ?? []) {
                options.quantity = options.quantity + 1;
              }
            }
            basketItem.qty = (basketItem.qty ?? 0) + 1;
            product.quantity = (product.quantity ?? 0) + 1;

            if (withApiCall == true) {
              (basketItem.item as Product).getItemAddedByDetails(currentUser,
                  actionType: BasketListModifierAction.increaseQty);

              for (AddOns addOn in basketItem.addOns ?? []) {
                for (AddOnOption option in addOn.options ?? []) {
                  option.getAddOnOptionAddedByDetails(currentUser,
                      actionType: BasketListModifierAction.increaseQty);
                }
              }
            }

            addedOrUpdatedItem = basketItem;
            break;
          }
        }
      } else {
        for (BasketItem basketItem in _basketItems) {
          if (basketItem.item?.id == data?.item?.id) {
            final Product product = basketItem.item as Product;

            basketItem.qty = (basketItem.qty ?? 0) + 1;
            product.quantity = (product.quantity ?? 0) + 1;

            if (withApiCall == true) {
              (basketItem.item as Product).getItemAddedByDetails(currentUser,
                  actionType: BasketListModifierAction.increaseQty);
            }
            addedOrUpdatedItem = basketItem;
            break;
          }
        }
      }
    }

    if (withApiCall && addedOrUpdatedItem != null) {
      final BasketListModifierPayload data = _basketItems.toPayload(
          addedOrUpdatedItem,
          actionType: BasketListModifierAction.increaseQty);
      if (data.payload.isNotEmpty) {
        SharedCartAuthService().addItemToSharedCart(id, data.payload);
      }
    }
  }

  void decreaseQty(
      {Product? currentProduct,
      BasketItem? data,
      SharedCartMemberModel? currentUser,
      bool withApiCall = true}) async {
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
            final Variant? variant = basketItem.variants?.first;
            if (variant != null) {
              if (variant.id == data?.variants?.first.id) {
                variant.quantity = (variant.quantity ?? 0) - 1;
                basketItem.qty = (basketItem.qty ?? 0) - 1;

                if (withApiCall == true) {
                  basketItem.variants?.first.getVariantAddedByDetails(
                      currentUser,
                      actionType: BasketListModifierAction.decreaseQty);
                }

                addedOrUpdatedItem = basketItem;
                break;
              }
            }
          }
        }

        /// if basket item has add0ns
      } else if (data?.hasAddOns ?? false) {
        for (BasketItem basketItem in _basketItems) {
          final Product product = basketItem.item as Product;

          if (basketItem.item?.id == data?.item?.id) {
            // for (AddOns addOns in basketItem.addOns ?? []) {
            //   for (AddOnOption options in addOns.options ?? []) {
            //     options.quantity = options.quantity - 1;
            //   }
            // }
            basketItem.qty = (basketItem.qty ?? 0) - 1;
            product.quantity = (product.quantity ?? 0) - 1;

            if (withApiCall == true) {
              (basketItem.item as Product).getItemAddedByDetails(currentUser,
                  actionType: BasketListModifierAction.decreaseQty);
            }
            addedOrUpdatedItem = basketItem;
            break;
          }
        }
      } else {
        for (BasketItem basketItem in _basketItems) {
          if (basketItem.item?.id == data?.item?.id) {
            final Product product = basketItem.item as Product;

            basketItem.qty = (basketItem.qty ?? 0) - 1;
            product.quantity = (product.quantity ?? 0) - 1;

            if (withApiCall == true) {
              (basketItem.item as Product).getItemAddedByDetails(currentUser,
                  actionType: BasketListModifierAction.decreaseQty);
            }

            addedOrUpdatedItem = basketItem;
            break;
          }
        }
      }
    }

    if (withApiCall && addedOrUpdatedItem != null) {
      final BasketListModifierPayload data = _basketItems.toPayload(
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
        final Product product = item.item as Product;
        if (item.hasVariant) {
          final int variantPrice =
              product.getDiscountedPrice(item.variants?.first) ?? 0;
          final int quantity = item.variants?.first.quantity ?? 0;
          variantTotal += variantPrice * quantity;
          totalPrice += variantTotal;
        } else if (item.hasAddOns) {
          for (AddOns itemAddOn in item.addOns ?? []) {
            for (var option in itemAddOn.options!) {
              AddOnOptionTotal +=
                  int.parse(option.price.toString()) * option.quantity;
            }
          }
          normalTotal = product.getProductRealPrice() *
              int.parse(product.quantity.toString());
          AddOnTotal = AddOnOptionTotal + normalTotal;
          totalPrice += AddOnTotal;
        } else {
          normalTotal = product.getProductRealPrice() *
              int.parse(product.quantity.toString());
          totalPrice += normalTotal;
        }
      }
    }
    return totalPrice;
  }

  void getSplitBillEvenlyPercentage() {
    if (splitBillEvenly == true) {
      if (members != null) {
        final int? listLength = members?.length ?? 0;

        for (var item in members!) {
          item.percentageValue =
              double.parse((100 / listLength!).toStringAsFixed(2));
        }
      }
    }
  }

  void getSplitBillEvenlyPayment(int? totalOrder) {
    if (splitBillEvenly == true) {
      if (members != null) {
        final int listLength = members?.length ?? 0;

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
  String? fullName;
  double? percentageValue = 0;
  int? paymentValue = 0;

  SharedCartMemberModel({
    this.userName,
    this.avatar,
    this.fullName,
    this.percentageValue = 0,
    this.paymentValue = 0,
  });

  SharedCartMemberModel.fromJson(Map<String, dynamic> json,
      {SharedMetaData? mataDataJson}) {
    userName = json['username'];
    avatar = json['avatar'];
    fullName = json['full_name'];
    if (mataDataJson != null) {
      final List<UserData> userData = mataDataJson.userData
              ?.where((element) => element.username == userName)
              .toList() ??
          [];
      if (userData != null &&
          userData.isNotEmpty &&
          userData.isNotEmpty == true) {
        percentageValue = double.parse(userData.first.percentage.toString());
        paymentValue = userData.first.amount;
      }
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['username'] = userName;
    map['avatar'] = avatar;
    map['full_name'] = fullName;
    return map;
  }

  UserFollowers toUserFollowerModel() {
    final UserFollowers userFollowers = UserFollowers();
    userFollowers.userName = userName;
    userFollowers.avatar = avatar;
    userFollowers.fullName = fullName;
    return userFollowers;
  }
}

class SharedMetaData {
  List<UserData>? userData;
  List<PaymentDatum>? paymentData;
  ShippingData? shippingData;
  bool? spitBill;

  SharedMetaData({
    this.userData,
    this.paymentData,
    this.shippingData,
    this.spitBill,
  });

  factory SharedMetaData.fromJson(Map<String, dynamic> json) => SharedMetaData(
        userData: json["user-data"] == null
            ? []
            : List<UserData>.from(
                json["user-data"]!.map((x) => UserData.fromJson(x))),
        paymentData: json["payment-data"] == null
            ? []
            : List<PaymentDatum>.from(
                json["payment-data"]!.map((x) => PaymentDatum.fromJson(x))),
        shippingData: json["shipping_data"] == null
            ? null
            : ShippingData.fromJson(json["shipping_data"]),
        spitBill: json["spit_bill"],
      );

  Map<String, dynamic> toJson() => {
        "user-data": userData == null
            ? []
            : List<dynamic>.from(userData!.map((x) => x.toJson())),
        "payment-data": paymentData == null
            ? []
            : List<dynamic>.from(paymentData!.map((x) => x.toJson())),
        "shipping_data": shippingData?.toJson(),
        "spit_bill": spitBill,
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

class PaymentDatum {
  int? id;
  dynamic slug;
  String? notes;
  int? amount;
  String? status;
  String? category;
  String? currency;
  DateTime? createdAt;
  dynamic settledAt;
  String? description;
  String? toCustomer;
  bool? isAnonymous;
  String? fromCustomer;
  bool? madeFromChat;
  String? transactionId;

  PaymentDatum({
    this.id,
    this.slug,
    this.notes,
    this.amount,
    this.status,
    this.category,
    this.currency,
    this.createdAt,
    this.settledAt,
    this.description,
    this.toCustomer,
    this.isAnonymous,
    this.fromCustomer,
    this.madeFromChat,
    this.transactionId,
  });

  factory PaymentDatum.fromJson(Map<String, dynamic> json) => PaymentDatum(
        id: json["id"],
        slug: json["slug"],
        notes: json["notes"],
        amount: json["amount"],
        status: json["status"],
        category: json["category"],
        currency: json["currency"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        settledAt: json["settled_at"],
        description: json["description"],
        toCustomer: json["to_customer"],
        isAnonymous: json["is_anonymous"],
        fromCustomer: json["from_customer"],
        madeFromChat: json["made_from_chat"],
        transactionId: json["transaction_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "notes": notes,
        "amount": amount,
        "status": status,
        "category": category,
        "currency": currency,
        "created_at": createdAt?.toIso8601String(),
        "settled_at": settledAt,
        "description": description,
        "to_customer": toCustomer,
        "is_anonymous": isAnonymous,
        "from_customer": fromCustomer,
        "made_from_chat": madeFromChat,
        "transaction_id": transactionId,
      };
}

class ShippingData {
  String? paymentType;
  List<ShippingDetail>? shippingDetails;

  ShippingData({
    this.paymentType,
    this.shippingDetails,
  });

  factory ShippingData.fromJson(Map<String, dynamic> json) => ShippingData(
        paymentType: json["payment_type"],
        shippingDetails: json["shipping_details"] == null
            ? []
            : List<ShippingDetail>.from(json["shipping_details"]!
                .map((x) => ShippingDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "payment_type": paymentType,
        "shipping_details": shippingDetails == null
            ? []
            : List<dynamic>.from(shippingDetails!.map((x) => x.toJson())),
      };
}

class ShippingDetail {
  String? note;
  String? merchant;
  String? pickupAddressId;
  int? shippingOptionId;

  ShippingDetail({
    this.note,
    this.merchant,
    this.pickupAddressId,
    this.shippingOptionId,
  });

  factory ShippingDetail.fromJson(Map<String, dynamic> json) => ShippingDetail(
        note: json["note"],
        merchant: json["merchant"],
        pickupAddressId: json["pickup_address_id"],
        shippingOptionId: json["shipping_option_id"],
      );

  Map<String, dynamic> toJson() => {
        "note": note,
        "merchant": merchant,
        "pickup_address_id": pickupAddressId,
        "shipping_option_id": shippingOptionId,
      };
}
