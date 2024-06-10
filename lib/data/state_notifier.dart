import 'package:Slydo/screens/more_apps/business/models/Item.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/connection_list_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/taxi/model/PlaceModal.dart';
import 'package:Slydo/screens/more_apps/taxi/model/directions_modal.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:flutter/material.dart';

export 'package:Slydo/data/state_notifiers/basket_bloc.dart';
export 'package:Slydo/data/state_notifiers/rider_registration_bloc.dart';
export 'package:Slydo/data/state_notifiers/shipping_process_bloc.dart';
export 'package:Slydo/data/state_notifiers/user_bloc.dart';

class BankAccountBloc extends ChangeNotifier {
  // This block notify's the change in user status and pass it round the app.
  BankAccount? _bankAccount = BankAccount(
      uuid: null,
      bankAvatar: null,
      bankName: null,
      accountName: null,
      accountNumber: null);

  // Getter
  BankAccount? get bankAccount => _bankAccount;

  // Setter
  set bankAccount(BankAccount? val) {
    _bankAccount = val;
    notifyListeners();
  }
}

class CustomerProfileBloc extends ChangeNotifier {
  // This block notify's the change in user status and pass it round the app.
  CustomerProfile? _customer = CustomerProfile(
    fullName: null,
    userName: null,
    avatar: null,
    qrCode: null,
  );

  // Getter
  CustomerProfile? get customer => _customer;

  // Setter
  set customer(CustomerProfile? val) {
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

class RefreshBlocForConnectionList extends ChangeNotifier {
  bool _isRefresh = false;

  bool get isRefresh => _isRefresh;

  set isRefresh(bool value) {
    _isRefresh = value;
    notifyListeners();
  }
}

class BackgroundFetchStopBloc extends ChangeNotifier {
  bool _isAllowed = true;

  bool get isAllowed => _isAllowed;

  set isAllowed(bool value) {
    _isAllowed = value;
    notifyListeners();
  }
}

class AddressBloc extends ChangeNotifier {
  ShippingAddress? _address;

  ShippingAddress? get address => _address;

  set address(ShippingAddress? value) {
    _address = value;
    notifyListeners();
  }
}

class TaxiBloc extends ChangeNotifier {
  PlaceModal? _startingPoint;

  PlaceModal? _destinationPoint;

  Map<String, dynamic>? _rideDetail;

  Directions? _startingPointToDestinationDirections;

  Directions? _driverToStartingPointDirections;

  PlaceModal? get startingPoint => _startingPoint;

  PlaceModal? get destinationPoint => _destinationPoint;

  Map<String, dynamic>? get rideDetail => _rideDetail;

  Directions? get startingPointToDestinationDirections =>
      _startingPointToDestinationDirections;

  Directions? get driverToStartingPointDirections =>
      _driverToStartingPointDirections;

  set startingPoint(PlaceModal? value) {
    _startingPoint = value;
    notifyListeners();
  }

  set destinationPoint(PlaceModal? value) {
    _destinationPoint = value;
    notifyListeners();
  }

  set rideDetail(Map<String, dynamic>? value) {
    _rideDetail = value;
    notifyListeners();
  }

  set startingPointToDestinationDirections(Directions? value) {
    _startingPointToDestinationDirections = value;
    notifyListeners();
  }

  set driverToStartingPointDirections(Directions? value) {
    _driverToStartingPointDirections = value;
    notifyListeners();
  }
}

class DashboardBloc extends ChangeNotifier {
  final PageController _pageController = PageController(initialPage: 0);
  int _index = 0;

  int get index => _index;
  bool topYarn = false;
  bool topStore = false;

  PageController get pageController => _pageController;

  set index(int value) {
    if (value == 1) {
      // secureScreen();
    } else {
      // unsecureScreen();
    }
    _index = value;
    // _pageController.animateToPage(_index,
    //     duration: Duration(milliseconds: 1), curve: Curves.linear);
    notifyListeners();
  }
}

class AddInvoiceBloc extends ChangeNotifier {
  List<InvoiceItem?> _items = [];
  int _total = 0;

  List<InvoiceItem?> get items => _items;

  set items(List<InvoiceItem?> value) {
    _items = value;
    notifyListeners();
  }

  int get total => _total;

  set total(int value) {
    _total = value;
    notifyListeners();
  }

  void addItem({InvoiceItem? invoiceItem}) {
    _items.add(invoiceItem);
    updateTotal();
    notifyListeners();
  }

  void removeItem({required int index}) {
    _items.removeAt(index);
    updateTotal();
    notifyListeners();
  }

  void updateItem({required int index, InvoiceItem? invoiceItem}) {
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
    for (var element in _items) {
      sum += (element!.amount! * element.quantity!);
    }
    _total = sum;
  }
}

class ShareMessageToChatBloc extends ChangeNotifier {
  final List<ChatConversation?> _recipientUsers = [];

  void addRecipient({ChatConversation? chatConversation}) {
    bool isAlreadyPresent = false;

    /// Check for user is already in the list
    for (var element in _recipientUsers) {
      if (element!.userName == chatConversation!.userName)
        isAlreadyPresent = true;
    }

    /// if user not present in the list then we add that user in recipient list
    if (!isAlreadyPresent) {
      _recipientUsers.add(chatConversation);
      notifyListeners();
      printRecipient();
    }
  }

  void printRecipient() {
    debugPrint("Sharing to ${_recipientUsers.length} Users");

    for (var element in _recipientUsers) {
      debugPrint(
          "==> Username ${element!.userName} ConversationId:- ${element.conversationId}");
    }
  }

  void removeRecipient({ChatConversation? customerProfile, String? username}) {
    String? userNameToCheck;

    if (customerProfile != null) {
      userNameToCheck = customerProfile.userName;
    } else {
      userNameToCheck = username;
    }

    if (userNameToCheck != null) {
      ChatConversation? recipientToBeRemoved;

      for (int i = 0; i < _recipientUsers.length; i++) {
        if (_recipientUsers[i]!.userName == customerProfile!.userName) {
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

  List<ChatConversation?> getRecipients() {
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
  List<ChatConversation> _connectionUsers = [];

  List<ChatConversation> get connectionUsers => _connectionUsers;

  Future<void> setConnectionUsers(
      {required List<ChatConversation> users}) async {
    /// adding chat Users in database for message Count
    ChatUserManager().addUsers(users);

    await ConnectionListManager().saveConnectionsToDB(connections: users);

    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    debugPrint('CONNECTION USERS --> ${_connectionUsers.length}');
    notifyListeners();
    return Future.value();
  }

  void addConnectionUser({required ChatConversation chatConversation}) async {
    await ConnectionListManager()
        .addConnectionToDB(chatConversation: chatConversation);

    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    notifyListeners();
  }

  Future<List<ChatConversation>> _getConnectionUsers() async {
    return await ConnectionListManager().getConnectionsFromDB();
  }

  Future<void> updateLastMessageTime(
      {String? conversationId, int? time}) async {
    await ConnectionListManager()
        .updateLastMessageTime(conversationId: conversationId, time: time);
    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    notifyListeners();
  }

  void updateChatConversation(
      {required ChatConversation chatConversation}) async {
    await ConnectionListManager()
        .updateChatConversation(chatConversation: chatConversation);
    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    notifyListeners();
  }

  void deleteChatConversation({String? conversationId}) async {
    await ConnectionListManager()
        .deleteChatConversation(conversationId: conversationId);
    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    notifyListeners();
  }

  Future<int> getConnectionsCount() async {
    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    notifyListeners();

    return _connectionUsers.length;
  }

  Future<void> clearConnectionList() async {
    await ConnectionListManager().clearConnections();
    _connectionUsers.clear();
    _connectionUsers = await _getConnectionUsers();
    notifyListeners();
    return;
  }
}

class ConnectionRequestListBloc extends ChangeNotifier {
  bool _hasConnectionRequests = false;

  bool get hasConnectionRequests => _hasConnectionRequests;

  set setHasConnectionRequests(bool hasRequests) {
    _hasConnectionRequests = hasRequests;
    notifyListeners();
  }
}
