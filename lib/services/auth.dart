import 'dart:convert';

import 'package:PayBay/data/database_helper.dart';
import 'package:PayBay/models/transactions.dart';
import 'package:PayBay/models/user.dart';
import 'package:http/http.dart' as http;


String ums = "http://192.168.1.5:8080";


class AuthService {

  DatabaseHelper _db = DatabaseHelper();

  Future<User> registerUser(Map data) async {
    var url = ums + "/api/v1/account";
    http.Response response = await http.post(url, body: data);
    if(response.statusCode == 201){
      var jsonData = json.decode(response.body);

      User _authUser = createUser(jsonData["uuid"], jsonData["url"], jsonData["phoneNumber"],
          jsonData["fullName"], jsonData["username"], jsonData["avatar"], jsonData["qrCode"],
          jsonData["password"]);
      return _authUser;
    }
    return User(uuid: null, url: null, phoneNumber: null, fullName: null,
        userName: null, avatar: null, qrCode: null, password: null);
  }

  // This function creates a user object from named args passed in
  User createUser( String uuid,  String url, String phoneNumber,
      String fullName, String username,  String avatar, String qrCode, String password) {

       // Create user instance
       User _user = User(uuid: uuid, url: url, phoneNumber: phoneNumber,
                         fullName: fullName, userName: username, avatar: avatar,
                         qrCode: qrCode, password: password);

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
      User user = createUser(jsonData["uuid"],
                            jsonData["url"].replaceAll("http://127.0.0.1:8080", ums),
                            jsonData["phone_number"],
                            jsonData["full_name"],
                            jsonData["username"],
                            jsonData["avatar"].replaceAll("http://127.0.0.1:8080", ums),
                            jsonData["qr_code"].replaceAll("http://127.0.0.1:8080", ums),
                            jsonData["password"]);
      return user;
    }
    return User(uuid: null, url: null, phoneNumber: null, fullName: null,
                userName: null, avatar: null, qrCode: null, password: null);
  }


  // Log user out
  Future<void> logOut() async {
    await deleteUsers();
    await close();
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
    data["account_name"] = _body["accountName"];
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
    final String accountsURL = "https://api.mockaroo.com/api/dc0e65c0?count=4&key=b81ba250";
    var response = await http.get(accountsURL);

    List<BankAccount> accounts = [];
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      for(var item in jsonData) {
        BankAccount account = BankAccount(
            bankAvatar: item['bankAvatar'],
            uuid: item['uuid'],
            bankName: item['bankName'],
            accountName: item['accountName'],
            accountNumber: int.parse(item['accountNumber']));
        accounts.add(account);
      }

      return accounts;
    }else{
      throw "Can't get https.";
    }
  }


  Future<List<Transaction>> getTransactions() async {
    final String transactionsURL = "https://api.mockaroo.com/api/a2960430?count=10&key=b81ba250";
    var response = await http.get(transactionsURL);

    List<Transaction> transactions = [];
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      for(var item in jsonData){
        Transaction transaction = Transaction(status: item['status'], uuid: item['uuid'],
            description: item['description'], payee: item['payee'], payeeUrl: item['payeeUrl'],
            currency: item['currency'], amount: item['amount'], isCredit: item['isCredit']);
        transactions.add(transaction);
      }

      return transactions;
    }else{
      throw "Can't get https.";
    }
  }





}
