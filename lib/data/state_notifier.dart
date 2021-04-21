import 'package:Slydo/screens/more_apps/business/models/Item.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/connection_list_manager.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/UserAbout.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
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

  set userAbout(UserAbout userAbout) {
    _user.userAbout = userAbout;
    notifyListeners();
  }

  void updateProfileAvatar(String url) {
    _user.avatar = url;
    notifyListeners();
  }

  void removeProfileAvatar() {
    _user.avatar =
        "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png";
    notifyListeners();
  }

  void removeProfileCover() {
    _user.userAbout.wallpaper = "";
    notifyListeners();
  }

  UserAbout get userAbout => _user.userAbout;
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

class RefreshBlocForConnectionDashboard extends ChangeNotifier {
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
    var foundItem;
    try {
      for (int i = 0; i < _items.length; i++) {
        if (_items[i]["item"].id == item.id) {
          foundItem = _items[i];
          break;
        }
      }

      if (foundItem != null) {
        if (foundItem["qty"] > 1) {
          foundItem["qty"] = foundItem["qty"] - 1;
          _total = _total - int.parse(item.price);
        } else if (foundItem["qty"] == 1) {
          _items.remove(foundItem);
          _total = _total - int.parse(item.price);
        } else {
          debugPrint("ERROR while removing element");
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error 1:- $e");
    }
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

class AddInvoiceBloc extends ChangeNotifier {
  List<InvoiceItem> _items = List<InvoiceItem>();
  int _total = 0;

  List<InvoiceItem> get items => _items;

  set items(List<InvoiceItem> value) {
    _items = value;
    notifyListeners();
  }

  int get total => _total;

  set total(int value) {
    _total = value;
    notifyListeners();
  }

  void addItem({InvoiceItem invoiceItem}) {
    _items.add(invoiceItem);
    updateTotal();
    notifyListeners();
  }

  void removeItem({int index}) {
    _items.removeAt(index);
    updateTotal();
    notifyListeners();
  }

  void updateItem({int index, InvoiceItem invoiceItem}) {
    _items.removeAt(index);
    _items.insert(index, invoiceItem);
    updateTotal();
    notifyListeners();
  }

  void clearItems() {
    _items.clear();
    total = 0;
    notifyListeners();
  }

  void updateTotal() {
    int sum = 0;
    _items.forEach((element) {
      sum += (element.amount * element.quantity);
    });
    _total = sum;
  }
}

class ShareMessageToChatBloc extends ChangeNotifier {
  List<CustomerProfile> _recipientUsers = List<CustomerProfile>();

  void addRecipient({CustomerProfile customerProfile}) {
    bool isAlreadyPresent = false;

    /// Check for user is already in the list
    _recipientUsers.forEach((element) {
      if (element.userName == customerProfile.userName) isAlreadyPresent = true;
    });

    /// if user not present in the list then we add that user in recipient list
    if (!isAlreadyPresent) {
      _recipientUsers.add(customerProfile);
      notifyListeners();
      printRecipient();
    }
  }

  void printRecipient() {
    debugPrint("Sharing to ${_recipientUsers.length} Users");

    _recipientUsers.forEach((element) {
      debugPrint(
          "==> Username ${element.userName} ConversationId:- ${element.conversationId}");
    });
  }

  void removeRecipient({CustomerProfile customerProfile, String username}) {
    String userNameToCheck;

    if (customerProfile != null) {
      userNameToCheck = customerProfile.userName;
    } else {
      userNameToCheck = username;
    }

    if (userNameToCheck != null) {
      CustomerProfile recipientToBeRemoved;

      for (int i = 0; i < _recipientUsers.length; i++) {
        if (_recipientUsers[i].userName == customerProfile.userName) {
          recipientToBeRemoved = _recipientUsers[i];
          break;
        }
      }

      if (recipientToBeRemoved != null) {
        _recipientUsers.remove(recipientToBeRemoved);
        printRecipient();
        notifyListeners();
      }
    }
  }

  List<CustomerProfile> getRecipients() {
    return _recipientUsers;
  }

  int recipientsLength() {
    return _recipientUsers.length;
  }

  void clearRecipient() {
    debugPrint("Clearing Sharing List");
    _recipientUsers.clear();
    notifyListeners();
  }
}

class ConnectionListBloc extends ChangeNotifier {
  List<CustomerProfile> _connectionUsers = List<CustomerProfile>();

  List<CustomerProfile> get connectionUsers => _connectionUsers;

  void setConnectionUsers({List<CustomerProfile> users}) async {
    await ConnectionListManager().saveConnectionsToDB(connections: users);

    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    notifyListeners();
  }

  Future<List<CustomerProfile>> _getConnectionUsers() async {
    return await ConnectionListManager().getConnectionsFromDB();
  }

  void updateLastMessageTime({String conversationId, int time}) async {
    await ConnectionListManager()
        .updateLastMessageTime(conversationId: conversationId, time: time);
    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    notifyListeners();
  }

  Future<int> getConnectionsCount() async {
    return await ConnectionListManager().getConnectionsCount();
  }

  Future<void> clearConnectionList() async {
    await ConnectionListManager().clearConnections();
    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    notifyListeners();
    return;
  }
}
