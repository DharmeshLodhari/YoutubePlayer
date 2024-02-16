import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/basket_item_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  void addItemToSharedCart({
    required SharedCartModel cart,
    required PurchasableItem item,
    required String type,
    Variant? variant,
    List<AddOns>? addOns,
    String? currentUser,
    bool withApiCall = true,
  }) {
    for (SharedCartModel sh in cartList) {
      if (sh.id == cart.id) {
        sh.addItemToCart(
            item: item,
            type: type,
            variant: variant,
            addOns: addOns,
            currentUser: currentUser,
            withApiCall: withApiCall);
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
      {SharedCartModel? cart,
      required double val,
      required int index,
      required BuildContext context}) {
    ShippingProcessBloc shippingProcessBloc =
        Provider.of<ShippingProcessBloc>(context, listen: false);
    shippingProcessBloc.currentSelectedIndex = null;

    for (SharedCartModel sh in cartList) {
      if (sh.id == cart?.id) {
        sh.members?[index].percentageValue = val;
        sh.members?[index].paymentValue =
            (((shippingProcessBloc.getTotalOrder() ?? 0) * val) / 100).floor();
        ;
        notifyListeners();
        break;
      }
    }
  }

  bool isUserCartOwner(BuildContext context) {
    UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

    if (getSharedCartModel().customerUsername == userBloc.user.userName) {
      return true;
    }
    return false;
  }
}
