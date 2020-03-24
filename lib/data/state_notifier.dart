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
