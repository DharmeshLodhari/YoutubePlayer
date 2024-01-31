import 'package:Slydo/screens/more_apps/shopping/models/store.dart';

/// type : "dsf"
/// item : {}
/// qty : 1
/// variants : [{}]

class BasketItem {
  BasketItem({
    this.type,
    this.item,
    this.qty,
    this.variants,
  });

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
  }

  bool get hasVariant => variants?.isNotEmpty ?? false;

  String? type;
  PurchasableItem? item;
  int? qty;
  List<Variant>? variants;

  int getQty() {
    int qty = 0;
    if ((item?.isProduct ?? false)) {
      if (hasVariant) {
        qty = variants?.first.quantity ?? 0;
      } else {
        qty = (item as Product).qty ?? 0;
      }
    }
    return qty;
  }

  BasketItem copyWith({
    String? type,
    dynamic item,
    int? qty,
    List<Variant>? variants,
  }) =>
      BasketItem(
        type: type ?? this.type,
        item: item ?? this.item,
        qty: qty ?? this.qty,
        variants: variants ?? this.variants,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = type;
    map['item'] = item;
    map['qty'] = qty;
    if (variants != null) {
      map['variants'] = variants?.map((v) => v.toJson()).toList();
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
}

extension BasketItemListPayloadGenerator on List<BasketItem> {
  Map<String, dynamic> toPayload(BasketItem item) {
    Map<String, dynamic> data = {};

    /// for product
    if (item.item?.isProduct ?? false) {
      Product product = item.item as Product;

      /// we will find all the basket Item with same product but different variant
      List<BasketItem> listOfBasketItem = this.where((element) {
        if (element.item?.isProduct ?? false) {
          if ((element.item as Product).id == product.id) {
            return true;
          }
        }
        return false;
      }).toList();

      if (listOfBasketItem.isNotEmpty) {
        List<Variant?> getListOfVariant =
            listOfBasketItem.map((e) => e.variants?.first).toList();

        List<Map<String, dynamic>> variantData = getListOfVariant
            .where((element) => element != null)
            .toList()
            .map((e) => <String, dynamic>{"id": e?.id, "quantity": e?.quantity})
            .toList();

        data["id"] = product.id;
        data["type"] = item.type;
        if (variantData.isEmpty) {
          data["qty"] = item.qty;
        } else {
          data["qty"] = variantData.fold<num>(0,
              (previousValue, element) => previousValue + element["quantity"]);
        }
        data["variants"] = variantData;
      }
    }

    return data;
  }
}
