import 'dart:convert';

import 'package:PayBay/data/database_helper.dart';
import 'package:PayBay/models/transactions.dart';
import 'package:PayBay/models/user.dart';
import 'package:http/http.dart' as http;

String ums = "http://192.168.1.5:8080";
final String pts = "http://192.168.1.5:8000";

class AuthService {
  DatabaseHelper _db = DatabaseHelper();

  // This function creates a user object from named args passed in
  User createUser(String uuid, String url, String phoneNumber, String fullName,
      String username, String avatar, String qrCode, String password) {
    // Create user instance
    User _user = User(
        uuid: uuid,
        url: url,
        phoneNumber: phoneNumber,
        fullName: fullName,
        userName: username,
        avatar: avatar,
        qrCode: qrCode,
        password: password);

    _db.saveUser(_user);
    return _user;
  }

  // log user in if credentials are correct
  Future<User> authenticate(String phoneNumber, String password) async {
    // make http connection here and
    var url = ums + "/api/v1/auth/get-token/";
    Map _body = {"password": password, "phone_number": phoneNumber};
    var response = await http.post(url, body: _body);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body)["user"];
      jsonData["password"] = password;
      jsonData["url"] = ums + "/api/v1/customer/" + jsonData["username"];

      deleteUsers();
      User user = createUser(
          jsonData["uuid"],
          jsonData["url"].replaceAll("http://127.0.0.1:8080", ums),
          jsonData["phone_number"],
          jsonData["full_name"],
          jsonData["username"],
          jsonData["avatar"].replaceAll("http://127.0.0.1:8080", ums),
          jsonData["qr_code"].replaceAll("http://127.0.0.1:8080", ums),
          jsonData["password"]);
      return user;
    }
    return User(
        uuid: null,
        url: null,
        phoneNumber: null,
        fullName: null,
        userName: null,
        avatar: null,
        qrCode: null,
        password: null);
  }

  // Log user out
  Future<void> logOut() async {
    await deleteUsers();
  }

  // Delete user from db
  Future<int> deleteUsers() async {
    return await _db.deleteUsers();
  }

  Future close() async => _db.close();

  // get user instance from db
  Future<User> getUser() async {
    return await _db.getUser();
  }

  Future<bool> userRegistration(Map _body) async {
    var url = ums + "/api/v1/account/";
    Map data = {};

    // convert code to types server understand.
    data["phone_number"] = _body["phoneNumber"];
    data["bank_name"] = _body["bankName"];
    data["full_name"] = _body["accountName"];
    data["account_number"] = _body["accountNumber"];
    data["password1"] = _body["password1"];
    data["password2"] = _body["password2"];

    var response = await http.post(url, body: data);

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<List<BankAccount>> getBankAccounts() async {
    var url = pts + "/transactions/bank-accounts-list";
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List<BankAccount> accounts = [];

      for (var item in jsonData) {
        var bank = item["bank"];
        var logoUrl =
            item["bank"]['logo_url'].replaceAll("http://0.0.0.0:8000/", pts);
        item["bank"]['logo_url'] = logoUrl;

        BankAccount account = BankAccount(
            bankAvatar: item["bank"]['logo_url'],
            uuid: item['id'].toString(),
            bankName: bank['short_name'],
            accountName: item['account_name'],
            accountNumber: item['account_number']);
        accounts.add(account);
      }
      return accounts;
    } else {
      throw "Can't get https.";
    }
  }

  Future<List<Transaction>> getTransactions() async {
    var url = pts + "/transactions/list";
    var response = await http.get(url);

    List<Transaction> transactions = [];
    var user = await getUser();
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      var imageUrl = ums + "/media/customer/avatar/me_rWdkxLb.jpeg";

      for (var item in jsonData) {
        // if sender is not current user then
        bool isCredit = (item["from_customer"] != user.userName &&
                item["to_customer"] == user.userName)
            ? true
            : false;

        item['payeeUrl'] = imageUrl;
        Transaction transaction = Transaction(
            status: item['status'],
            uuid: item['slug'],
            description: item['description'],
            payee: item['to_customer'],
            payeeUrl: item['payeeUrl'],
            currency: item['currency'],
            amount: item['amount'],
            isCredit: isCredit);
        transactions.add(transaction);
      }
      return transactions;
    } else {
      throw "Can't get https.";
    }
  }
}
