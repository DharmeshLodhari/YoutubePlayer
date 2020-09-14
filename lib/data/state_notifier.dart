import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/models/user.dart';
import 'package:flutter/material.dart';

class UserBloc extends ChangeNotifier {
  // This block notify's the change in user status and pass it round the app.
  User _user = User(
      uuid: null,
      url: null,
      phoneNumber: null,
      fullName: null,
      userName: null,
      avatar: null,
      qrCode: null,
      password: null,
      currency: null);

  // Getter
  User get user => _user;

  // Setter
  set user(User val) {
    _user = val;
    notifyListeners();
  }
}

class BankAccountBloc extends ChangeNotifier {
  // This block notify's the change in user status and pass it round the app.
  BankAccount _bankAccount = BankAccount(
      uuid: null,
      bankAvatar: null,
      bankName: null,
      accountName: null,
      accountNumber: null);

  // Getter
  BankAccount get bankAccount => _bankAccount;

  // Setter
  set bankAccount(BankAccount val) {
    _bankAccount = val;
    notifyListeners();
  }
}

class PayeeBloc extends ChangeNotifier {
  // This block notify's the change in user status and pass it round the app.
  Payee _payee = Payee(
      uuid: "",
      url: "",
      fullName: null,
      userName: null,
      avatar: null,
      qrCode: null,
      currency: null);

  // Getter
  Payee get payee => _payee;

  // Setter
  set payee(Payee val) {
    _payee = val;
    notifyListeners();
  }
}

class CustomerProfileBloc extends ChangeNotifier {
  // This block notify's the change in user status and pass it round the app.
  CustomerProfile _customer = CustomerProfile(
    fullName: null,
    userName: null,
    avatar: null,
    qrCode: null,
  );

  // Getter
  CustomerProfile get customer => _customer;

  // Setter
  set customer(CustomerProfile val) {
    _customer = val;
    notifyListeners();
  }
}

class RefreshBlocForTransaction extends ChangeNotifier {
  bool _isRefresh = false;

  bool get isRefresh => _isRefresh;

  set isRefresh(bool value) {
    _isRefresh = value;
    notifyListeners();
  }
}

class RefreshBlocForRequestPayment extends ChangeNotifier {
  bool _isRefresh = false;

  bool get isRefresh => _isRefresh;

  set isRefresh(bool value) {
    _isRefresh = value;
    notifyListeners();
  }
}

class RefreshBlocForMessages extends ChangeNotifier {
  bool _isRefresh = false;

  bool get isRefresh => _isRefresh;

  set isRefresh(bool value) {
    _isRefresh = value;
    notifyListeners();
  }
}

class BasketBloc extends ChangeNotifier {
  // will accept products and services
  List<Map<String, dynamic>> _items = List<Map<String, dynamic>>();
  int _total = 0;

  int get total => _total;

  set total(int value) {
    _total = value;
    notifyListeners();
  }

  List get items => _items;

  set items(List value) {
    _items = value;
    notifyListeners();
  }

  // this will add the product or service in the cart;
  void addItemToCart({@required var item, @required String type}) {
    addItemInBasketWithQty(item, type);
    notifyListeners();
  }

  void addItemInBasketWithQty(var item, String type) {
    bool flag = false;

    _items.forEach((element) {
      if (element["item"].id == item.id) {
        flag = true;
        element["qty"] = element["qty"] + 1;
        _total = _total + int.parse(item.price);
        debugPrint("Exising Item Added");
        return;
      }
    });

    if (!flag) {
      _items.add({"type": type, "item": item, "qty": 1});
      _total = _total + int.parse(item.price);
      debugPrint("New Item Added");
    }
    notifyListeners();
  }

  // this will remove the product or service from the cart;
  void removeItemFromCart(item) {
    removeItemInBasketWithQty(item);
    notifyListeners();
  }

  void removeItemInBasketWithQty(var item) {
    try {
      _items.forEach((element) {
        if (element["item"].id == item.id) {
          if (element["qty"] > 1) {
            element["qty"] = element["qty"] - 1;
            _total = _total - int.parse(item.price);
          } else if (element["qty"] == 1) {
            _items.remove(element);
            _total = _total - int.parse(item.price);
          }
          return;
        }
      });
      notifyListeners();
    } catch (e) {}
  }
}

class AddressBloc extends ChangeNotifier {
  Address _address;

  Address get address => _address;

  set address(Address value) {
    _address = value;
    notifyListeners();
  }
}

class DashboardBloc extends ChangeNotifier {
  PageController _pageController = PageController(initialPage: 0);
  int _index = 0;

  int get index => _index;
  PageController get pageController => _pageController;

  set index(int value) {
    _index = value;
    _pageController.animateToPage(_index,
        duration: Duration(milliseconds: 1), curve: Curves.linear);
    notifyListeners();
  }
}
