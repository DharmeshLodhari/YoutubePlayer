import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/basket_item_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:flutter/material.dart';

class SharedCartBloc extends ChangeNotifier {
  List<SharedCartModel> _cartList = <SharedCartModel>[];

  List<SharedCartModel> get cartList => _cartList;

  set cartList(List<SharedCartModel> value) {
    _cartList = value;
    notifyListeners();
  }

  int? _currentSelectedIndex;

  int? get currentSelectedIndex => _currentSelectedIndex;

  set currentSelectedIndex(int? value) {
    _currentSelectedIndex = value;
    notifyListeners();
  }

  SharedCartModel getSharedCartModel() {
    return _cartList[_currentSelectedIndex!];
  }

  void addItemToSharedCart(
      {required SharedCartModel cart,
      required PurchasableItem item,
      required String type,
      Variant? variant,
      List<AddOns>? addOns,
      bool withApiCall = true}) {
    for (SharedCartModel sh in cartList) {
      if (sh.id == cart.id) {
        sh.addItemToCart(
            item: item, type: type, variant: variant, addOns: addOns);
        notifyListeners();
        break;
      }
    }
  }

  void increaseItemToSharedCart(SharedCartModel cart,
      {Product? currentProduct, BasketItem? data, bool withApiCall = true}) {
    for (SharedCartModel sh in cartList) {
      if (sh.id == cart.id) {
        sh.increaseQty(
            currentProduct: currentProduct,
            data: data,
            withApiCall: withApiCall);
        notifyListeners();
        break;
      }
    }
  }

  void decreaseItemToSharedCart(SharedCartModel cart,
      {Product? currentProduct, BasketItem? data, bool withApiCall = true}) {
    for (SharedCartModel sh in cartList) {
      if (sh.id == cart.id) {
        sh.decreaseQty(
            currentProduct: currentProduct,
            data: data,
            withApiCall: withApiCall);
        notifyListeners();
        break;
      }
    }
  }

  void updatePercentageAndPrice(
      {SharedCartModel? cart, required double val, required int index}) {
    for (SharedCartModel sh in cartList) {
      if (sh.id == cart?.id) {
        sh.updatePerAndPrice(val, index);
        notifyListeners();
        break;
      }
    }
  }
}
