import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shared_cart_auth.dart';
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
    if (cartList.isNotEmpty && cartList.length >= 0) {
      return _cartList[_currentSelectedIndex ?? 0];
    } else {
      return SharedCartModel();
    }
  }

  void updateCartModel(SharedCartModel data) {
    _cartList[_currentSelectedIndex ?? 0] = data;
    notifyListeners();
  }

  void addItemToSharedCart(
      {required SharedCartModel cart,
      required PurchasableItem item,
      required String type,
      Variant? variant,
      List<AddOns>? addOns,
      SharedCartMemberModel? currentUser,
      bool withApiCall = true,
      bool replaceUpdatedBy = false}) {
    for (SharedCartModel sh in cartList) {
      if (sh.id == cart.id) {
        sh.addItemToCart(
            item: item,
            type: type,
            variant: variant,
            addOns: addOns,
            currentUser: currentUser,
            withApiCall: withApiCall,
            replaceUpdatedBy: replaceUpdatedBy);
        notifyListeners();
        break;
      }
    }
  }

  void increaseItemToSharedCart(SharedCartModel cart,
      {Product? currentProduct,
      BasketItem? data,
      SharedCartMemberModel? currentUser,
      bool withApiCall = true}) {
    for (SharedCartModel sh in cartList) {
      if (sh.id == cart.id) {
        sh.increaseQty(
            currentProduct: currentProduct,
            data: data,
            currentUser: currentUser,
            withApiCall: withApiCall);
        notifyListeners();
        break;
      }
    }
  }

  void decreaseItemToSharedCart(SharedCartModel cart,
      {Product? currentProduct,
      BasketItem? data,
      SharedCartMemberModel? currentUser,
      bool withApiCall = true}) {
    for (SharedCartModel sh in cartList) {
      if (sh.id == cart.id) {
        sh.decreaseQty(
            currentProduct: currentProduct,
            data: data,
            currentUser: currentUser,
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
    final ShippingProcessBloc shippingProcessBloc =
        Provider.of<ShippingProcessBloc>(context, listen: false);
    shippingProcessBloc.currentSelectedIndex = null;

    for (SharedCartModel sh in cartList) {
      if (sh.id == cart?.id) {
        sh.members?[index].percentageValue = val;
        sh.members?[index].paymentValue =
            (((getSharedCartModel().getSharedCartTotalPrice()) * val) / 100)
                .floor();
        ;
        notifyListeners();
        break;
      }
    }
  }

  bool isUserCartOwner(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

    if (getSharedCartModel().customerUsername == userBloc.user.userName) {
      return true;
    }
    return false;
  }

  Future<void> refreshAllCart(BuildContext context) async {
    await getSharedCartListing(context);
    notifyListeners();
    return;
  }

  Future<void> refreshSharedCartProduct(
      BuildContext context, SharedCartModel cart) async {
    await getSharedCartProductDetail(context, cart);
    notifyListeners();
    return;
  }

  Future<void> getSharedCartListing(BuildContext context) async {
    final Map<String, dynamic>? result =
        await SharedCartAuthService().getSharedCartList("", "");

    final tempList = result?['results'];

    if (tempList != null && (tempList as List).isNotEmpty) {
      final List<SharedCartModel> sharedCartList =
          tempList as List<SharedCartModel>;

      cartList = sharedCartList;

      for (SharedCartModel sharedCartModel in cartList) {
        await getSharedCartProductDetail(context, sharedCartModel);
      }

      debugPrint("CART LIST:- ${cartList.length} ");
    }
  }

  Future<void> getSharedCartProductDetail(
      BuildContext context, SharedCartModel cart) async {
    final Map<String, dynamic>? result =
        await SharedCartAuthService().getCartItemDetails(cart.id, "", "");

    final tempList = result?['results'];

    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

    final SharedCartMemberModel currentUser = userBloc.user.convertToUser();

    if (tempList != null && (tempList as List).isNotEmpty) {
      final List items = tempList;

      for (var element in items) {
        final String type = element is Product ? "product" : "service";

        if (element is Product) {
          /// varient
          final List<Variant>? variantList = element.variantModels;

          /// adds on
          final List<AddOns>? convertedList = element.addOnsModels;

          if (variantList != null && variantList.isNotEmpty) {
            for (var variant in variantList) {
              addItemToSharedCart(
                  cart: cart,
                  item: element,
                  type: type,
                  variant: variant,
                  currentUser: currentUser,
                  replaceUpdatedBy: true,
                  withApiCall: false);
            }
          } else if (convertedList != null && convertedList.isNotEmpty) {
            addItemToSharedCart(
                cart: cart,
                item: element,
                type: type,
                variant: null,
                addOns: convertedList,
                currentUser: currentUser,
                replaceUpdatedBy: true,
                withApiCall: false);
          } else {
            addItemToSharedCart(
              cart: cart,
              item: element,
              type: type,
              currentUser: currentUser,
              replaceUpdatedBy: true,
              withApiCall: false,
            );
          }
        } else {
          addItemToSharedCart(
              cart: cart,
              item: element,
              type: type,
              variant: null,
              addOns: null,
              currentUser: currentUser,
              replaceUpdatedBy: true,
              withApiCall: false);
        }
      }
    }
    debugPrint("CART DETAIL ID:- ${cart.id} ");
  }

  Future<SharedCartModel> refreshCartDetail(String? cartId,
      {required bool isUpdate}) async {
    final SharedCartModel sharedCartModel =
        await getCartDetails(cartId, isUpdate);
    notifyListeners();
    return sharedCartModel;
  }

  Future<SharedCartModel> getCartDetails(String? cartId, bool isUpdate) async {
    SharedCartModel sharedCartModel = SharedCartModel();
    await SharedCartAuthService().getCartDetails(cartId).then((value) {
      sharedCartModel = value;
      if (isUpdate == true) {
        updateCartModel(value);
      }
    }).catchError((error) {
      debugPrint(error.toString());
      debugPrint("Product check variant::: ${error.toString()}");
      // showToast(message: error.toString());
    });
    return sharedCartModel;
  }
}
