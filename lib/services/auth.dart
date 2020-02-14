import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/models/user.dart';
import 'package:http/http.dart' as http;

final String baseUrl = "http://api.slydo.co";
final String localHostUrl = "https://127.0.0.1:8080";

class AuthService {
  DatabaseHelper _db = DatabaseHelper();

  // This function creates a user object from named args passed in
  User createUser(String uuid, String url, String phoneNumber, String fullName, String username,
      String avatar, String qrCode, String password) {
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

  // Log user in if credentials are correct
  Future<User> authenticate(String phoneNumber, String password) async {
    // This method will pass the user name and password to the backend server
    // and if credentials are correct will receive payload with jwt and user info
    // which will be saved to the user table and jwt table then create
    // a user instance which we should pass around throughout the application as
    // the auth user.

    DateTime now = DateTime.now();

    var url = baseUrl + "/api/v1/auth/get-token/";
    Map _body = {"password": password, "phone_number": phoneNumber};
    var response = await http.post(url, body: _body);

    if (response.statusCode == 200) {
      // Because the jwt expires every 5 minutes we will take note of the time they
      // where  created and the use that to compute the expiration time of the
      // token. So that we will only use the token if its still valid.
      // We play safe and use 4 minutes
      DateTime expirationTime = now.add(Duration(seconds: 300));

      Map<String, String> data = {};
      var jsonResponse = json.decode(response.body);
      var jsonData = jsonResponse["user"];

      // Get `access` and `refresh` Tokens from response
      data["access"] = jsonResponse["access"];
      data["refresh"] = jsonResponse["refresh"];

      // Convert DateTime object to string before passing it in.
      data["expiration"] = expirationTime.toString();

      jsonData["password"] = password;
      jsonData["url"] = baseUrl + "/api/v1/customer/" + jsonData["username"];

      // Delete user from db if one exist
      deleteUsers();

      // Delete jwt from db if one exist
      deleteJwt();

      // Save user to database
      User user = createUser(
          jsonData["uuid"],
          jsonData["url"],
          jsonData["phone_number"],
          jsonData["full_name"],
          jsonData["username"],
          jsonData["avatar"],
          jsonData["qr_code"],
          jsonData["password"]);

      _db.saveJwt(data);

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
    var url = baseUrl + "/api/v1/auth/logout/";
    var headers = await getAuthHeaders();
    await http.get(url, headers: headers);
    await deleteUsers();
  }

  // Delete user from db
  Future<int> deleteUsers() async {
    return await _db.deleteUsers();
  }

  // Close connection to db
  Future close() async => _db.close();

  // Get user instance from db
  Future<User> getUser() async {
    return await _db.getUser();
  }

  // Check if token has expired
  bool hasTokenExpired(String expirationTime) {
    // Will return false if token is still valid and true if token is no longer useful
    DateTime now = DateTime.now();
    DateTime tokenExpirationTime = DateTime.parse(expirationTime);
    return !now.isBefore(tokenExpirationTime);
  }

  // Get jwt
  Future<Map<String, dynamic>> getJwt() async {
    return await _db.getJwt();
  }

  Future<Map<String, String>> getAuthHeaders() async {
    var tokenData = await _db.getJwt();
    String expirationTime = tokenData['expiration'];

    // Authenticate again if token has expired
    if (hasTokenExpired(expirationTime)) {
      User _user = await getUser();
      authenticate(_user.phoneNumber, _user.password);
      tokenData = await _db.getJwt(); // get new token now
    }
    String bearer = "Bearer " + tokenData["access"];
    var headers = {"Authorization": bearer, "Content-type": "application/json"};
    return headers;
  }

  // Delete JWT from db
  Future<int> deleteJwt() async {
    return await _db.deleteJwt();
  }

  // Fetch user profile
  Future<CustomerProfile> fetchCustomerProfile(String userName) async {
    var url = baseUrl + "/api/v1/customer/" + userName;
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      CustomerProfile customerProfile = CustomerProfile(
        fullName: jsonData["full_name"],
        userName: jsonData["username"],
        avatar: jsonData["avatar"],
        qrCode: jsonData["qr_code"],
      );
      return customerProfile;
    } else {
      throw "Can't get https.";
    }
  }

  // Update User Avatar
  Future<CustomerProfile> updateCustomerAvatar(File avatar) async {
    User user = await getUser();
    var headers = await getAuthHeaders();
    var url = baseUrl + "/api/v1/update-avatar/" + user.userName;

    if (avatar != null) {
      var avatarPath = avatar.path;
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("PATCH", Uri.parse(url));

      //add fields
      request.fields["username"] = user.userName;
      request.fields["full_name"] = user.fullName;
      request.fields["avatar"] = user.avatar;

      //create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath("avatar", avatarPath);

      //add multipart to request
      request.files.add(multipartFile);
      headers.forEach((k, v) => request.headers[k] = v);
      var response = await request.send();

      var responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        var jsonData = json.decode(responseBody);
        CustomerProfile customerProfile = CustomerProfile(
          fullName: jsonData["full_name"],
          userName: jsonData["username"],
          avatar: jsonData["avatar"],
          qrCode: jsonData["qr_code"],
        );
        return customerProfile;
      } else {
        throw responseBody;
      }
    } else {
      throw "Can't get https.";
    }
  }

  // Register the user with the backend servers
  Future<bool> userRegistration(Map _body) async {
    var data = {};
    var url = baseUrl + "/api/v1/account/";

    // Convert to what the server is expecting
    data["password1"] = _body["password1"];
    data["password2"] = _body["password2"];
    data["full_name"] = _body["fullName"];
    data["phone_number"] = _body["phoneNumber"];

    var response = await http.post(url, body: data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // List the users bank accounts
  Future<List<BankAccount>> getBankAccounts() async {
    var url = baseUrl + "/api/v1/transactions/bank-accounts-list";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List<BankAccount> accounts = [];
      for (var item in jsonData) {
        var bank = item["bank"];
        var logoUrl = item["bank"]['logo_url'];
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

  Future<List<PaymentRequest>> listPaymentRequests() async {
    Map<String, String> knownCustomers = {};

    var url = baseUrl + "/api/v1/transactions/request-payment/list";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<PaymentRequest> paymentRequests = [];
      // This variable will hold list of transactions we got from server
      var user = await getUser();
      var jsonData = json.decode(response.body);

      for (var item in jsonData) {
        // if sender is not current user then
        bool isCredit =
            (item["from_customer"] != user.userName && item["to_customer"] == user.userName)
                ? true
                : false;

        var payee = isCredit ? item["from_customer"] : item['to_customer'];

        try {
          if (knownCustomers.containsKey(payee) == false) {
            var customer = await fetchCustomerProfile(payee);
            knownCustomers[payee] = customer.avatar;
          }
          var avatar = knownCustomers[payee];
          PaymentRequest paymentRequest = PaymentRequest(
              status: item['status'],
              uuid: item['slug'],
              description: item['description'],
              payee: payee,
              avatar: avatar,
              currency: item['currency'],
              amount: item['amount'],
              isCredit: isCredit);
          paymentRequests.add(paymentRequest);
        } catch (Exception) {}
      }
      print(paymentRequests);
      return paymentRequests;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      throw json.decode(response.body);
    }
  }

  // List users transactions
  Future<List<Transaction>> getTransactions() async {
    Map<String, String> knownCustomers = {};
    var url = baseUrl + "/api/v1/transactions/list/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<Transaction> transactions = [];
      // This variable will hold list of transactions we got from server
      var user = await getUser();
      var jsonData = json.decode(response.body);

      for (var item in jsonData) {
        // if sender is not current user then
        bool isCredit =
            (item["from_customer"] != user.userName && item["to_customer"] == user.userName)
                ? true
                : false;

        var payee = isCredit ? item["from_customer"] : item['to_customer'];

        try {
          if (knownCustomers.containsKey(payee) == false) {
            var customer = await fetchCustomerProfile(payee);
            knownCustomers[payee] = customer.avatar;
          }
          var avatar = knownCustomers[payee];
          Transaction transaction = Transaction(
              status: item['status'],
              uuid: item['slug'],
              description: item['description'],
              payee: payee,
              avatar: avatar,
              currency: item['currency'],
              amount: item['amount'],
              isCredit: isCredit);
          transactions.add(transaction);
        } catch (Exception) {}
      }
      return transactions;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      throw json.decode(response.body);
    }
  }

  //Send payment to backend
  Future<http.Response> makePayment(Map data) async {
    var url = baseUrl + "/api/v1/transactions/make-payment/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    return response;
  }

  // TODO: Marge with makePayment
  //Send payment to backend
  Future<bool> addBankAccount(Map data) async {
    var url = baseUrl + "/api/v1/transactions/add-bank-account/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    return response.statusCode == 201;
  }
}
