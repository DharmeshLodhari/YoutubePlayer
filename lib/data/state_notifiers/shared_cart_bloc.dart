import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
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

  int? _memberDetailsCurrentIndex;

  int? get memberDetailsCurrentIndex => _memberDetailsCurrentIndex;

  set memberDetailsCurrentIndex(int? value) {
    _memberDetailsCurrentIndex = value;
    notifyListeners();
  }

  // List<Product> _cartItemList = [];
  //
  // List get cartItemList => _cartItemList;
  //
  // set items(List<Product> value) {
  //   _cartItemList = value;
  //   notifyListeners();
  // }

  void updatePaymentPercentageValue(int val, int index) {
    getSharedCartModel().membersDetails?[index].paymentPercentageValue = val;
    notifyListeners();
  }
}
