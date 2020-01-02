import 'package:PayBay/models/user.dart';
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
      password: null);

  // Getter
  User get user => _user;

  // Setter
  set user(User val) {
    _user = val;
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
  );

  // Getter
  Payee get payee => _payee;

  // Setter
  set payee(Payee val) {
    _payee = val;
    notifyListeners();
  }
}
