import 'package:Slydo/screens/more_apps/shopping/models/store.dart';

/// type : "dsf"
/// item : {}
/// qty : 1
/// variants : [{}]

class BasketItem {
  String? type;
  PurchasableItem? item;
  int? qty;
  List<Variant>? variants;
  List<AddOns>? addOns;
  List<AddedBy>? itemAddedBy;

  BasketItem(
      {this.type,
      this.item,
      this.qty,
      this.variants,
      this.addOns,
      this.itemAddedBy});

  BasketItem.fromJson(dynamic json) {
    type = json['type'];
    item = getPurchasableModel(json);
    qty = json['qty'];
    if (json['variants'] != null) {
      variants = [];
      json['variants'].forEach((v) {
        variants?.add(Variant.fromJson(v));
      });
    }
    if (json['addOns'] != null) {
      addOns = [];
      json['addOns'].forEach((v) {
        addOns?.add(AddOns.fromJson(v));
      });
    }
    if (json['added_by'] != null) {
      itemAddedBy = [];
      json['added_by'].forEach((v) {
        itemAddedBy?.add(AddedBy.fromJson(v));
      });
    }
  }

  bool get hasVariant => variants?.isNotEmpty ?? false;
  bool get hasAddOns => addOns?.isNotEmpty ?? false;

  int getQty() {
    int qty = 0;
    if ((item?.isProduct ?? false)) {
      if (hasVariant) {
        qty = variants?.first.quantity ?? 0;
      } else if (hasAddOns) {
        qty = this.qty ?? 0;
      } else {
        qty = (item as Product).quantity ?? 0;
      }
    }
    return qty;
  }

  BasketItem copyWith({
    String? type,
    dynamic item,
    int? qty,
    List<Variant>? variants,
    List<AddOns>? addOns,
    List<AddedBy>? itemAddedBy,
  }) =>
      BasketItem(
        type: type ?? this.type,
        item: item ?? this.item,
        qty: qty ?? this.qty,
        variants: variants ?? this.variants,
        addOns: addOns ?? this.addOns,
        itemAddedBy: itemAddedBy ?? this.itemAddedBy,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = type;
    map['item'] = item;
    map['qty'] = qty;
    if (variants != null) {
      map['variants'] = variants?.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      map['addOns'] = addOns?.map((v) => v.toJson()).toList();
    }
    if (itemAddedBy != null) {
      map['added_by'] = itemAddedBy?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  PurchasableItem? getPurchasableModel(dynamic json) {
    if (json is Map) {
      if (json["type"] == "product") {
        return Product.fromJson(json);
      } else if (json["type"] == "service") {
        return Service.fromJson(json);
      }
    }
    return null;
  }

  void cleanVariantsWithZeroQty() {
    if (hasVariant) {
      if (variants?.first.quantity == 0) {
        variants = [];
      }
    }
  }

  Variant? getVariant() {
    if (hasVariant) {
      return variants?.first;
    }
    return null;
  }
}

enum BasketListModifierPayloadTypes { addOrUpdate, remove }

enum BasketListModifierAction { increaseQty, decreaseQty }

class BasketListModifierPayload {
  final Map<String, dynamic> payload;
  final BasketListModifierPayloadTypes payloadType;

  BasketListModifierPayload({required this.payloadType, required this.payload});
}

extension BasketItemListPayloadGenerator on List<BasketItem> {
  BasketListModifierPayload toPayload(BasketItem basketItem,
      {required BasketListModifierAction actionType}) {
    Map<String, dynamic> data = {};

    BasketListModifierPayloadTypes payloadType =
        BasketListModifierPayloadTypes.addOrUpdate;

    /// for product
    if (basketItem.item?.isProduct ?? false) {
      Product product = basketItem.item as Product;

      List<BasketItem> listOfBasketItem = this.where((element) {
        if (element.item?.isProduct ?? false) {
          if ((element.item as Product).id == product.id) {
            return true;
          }
        }
        return false;
      }).toList();

      /// if we are building payload for product which have variant
      if (basketItem.hasVariant) {
        /// first we will check if the any variant have zero qty then we will remove those variants
        if (actionType == BasketListModifierAction.decreaseQty) {
          this.forEach((element) {
            element.cleanVariantsWithZeroQty();
          });
        }

        // we will find all the basket Item with same product but different variant

        if (listOfBasketItem.isNotEmpty) {
          List<Variant?> getListOfVariant = listOfBasketItem
              .where((element) => element.variants?.isNotEmpty ?? false)
              .toList()
              .map((e) => e.variants?.first)
              .toList();

          List<Map<String, dynamic>> variantData = getListOfVariant
              .where((element) => element != null)
              .toList()
              .map((e) => <String, dynamic>{
                    "id": e?.id,
                    "quantity": e?.quantity,
                    "added_by": e?.addedBy
                        ?.map((e) => <String, dynamic>{
                              "user": e.user?.userName,
                              "quantity": e.quantity
                            })
                        .toList()
                  })
              .toList();

          data["id"] = product.id;
          data["type"] = basketItem.type;

          num qty = variantData.fold<num>(0,
              (previousValue, element) => previousValue + element["quantity"]);

          data["qty"] = qty;
          data["variants"] = variantData;

          if (variantData.isEmpty) {
            payloadType = BasketListModifierPayloadTypes.remove;
          } else {
            payloadType = BasketListModifierPayloadTypes.addOrUpdate;
          }

          /// to remove those items from basket item which's variant's qty =0;
          this.removeWhere((element) => element.variants?.isEmpty ?? false);
        }
      } else if (basketItem.hasAddOns) {
        List<AddedBy> itemAddedBy = [];
        List<BasketItem> basketItemAddedBy = listOfBasketItem
            .where((element) => element.itemAddedBy?.isNotEmpty ?? false)
            .toList();

        for (BasketItem item in basketItemAddedBy) {
          for (AddedBy addedBy in item.itemAddedBy ?? []) {
            itemAddedBy.add(addedBy);
          }
        }

        List<Map<String, dynamic>> itemAddedByData = itemAddedBy
            .where((element) => element != null)
            .toList()
            .map((e) => <String, dynamic>{
                  "user": e.user?.userName,
                  "quantity": e.quantity
                })
            .toList();

        data["id"] = product.id;
        data["type"] = basketItem.type;
        data["qty"] = basketItem.qty;
        List<Map<String, dynamic>> addOnsDataList = (basketItem.item as Product)
                .addOnsModels
                ?.map((e) => {
                      "id": e.id,
                      "options": e.options
                          ?.map((option) => {
                                "id": option.id,
                                "quantity": option.quantity,
                                "added_by": option.addedBy
                                    ?.map((e) => <String, dynamic>{
                                          "user": e.user?.userName,
                                          "quantity": e.quantity
                                        })
                                    .toList()
                              })
                          .toList()
                    })
                .toList() ??
            [];
        data["add_ons"] = addOnsDataList;
        data["added_by"] = itemAddedByData;

        if (basketItem.qty == 0) {
          payloadType = BasketListModifierPayloadTypes.remove;
          this.remove(basketItem);
        } else {
          payloadType = BasketListModifierPayloadTypes.addOrUpdate;
        }
      }

      /// product without variant and addOns
      else {
        List<AddedBy> itemAddedBy = [];
        List<BasketItem> basketItemAddedBy = listOfBasketItem
            .where((element) => element.itemAddedBy?.isNotEmpty ?? false)
            .toList();

        for (BasketItem item in basketItemAddedBy) {
          for (AddedBy addedBy in item.itemAddedBy ?? []) {
            itemAddedBy.add(addedBy);
          }
        }

        List<Map<String, dynamic>> itemAddedByData = itemAddedBy
            .where((element) => element != null)
            .toList()
            .map((e) => <String, dynamic>{
                  "user": e.user?.userName,
                  "quantity": e.quantity
                })
            .toList();

        data["id"] = product.id;
        data["type"] = basketItem.type;
        data["qty"] = basketItem.qty;
        data["added_by"] = itemAddedByData;

        if (basketItem.qty == 0) {
          payloadType = BasketListModifierPayloadTypes.remove;
          this.remove(basketItem);
        } else {
          payloadType = BasketListModifierPayloadTypes.addOrUpdate;
        }
      }
    }
    // return data;
    return BasketListModifierPayload(payloadType: payloadType, payload: data);
  }
}
