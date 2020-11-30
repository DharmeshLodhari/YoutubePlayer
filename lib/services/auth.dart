import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/models/Contract.dart';
import 'package:Slydo/models/Invoice.dart';
import 'package:Slydo/models/message.dart';
import 'package:Slydo/models/payout.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final String baseUrl = "https://api.slydo.co";
final String secureBaseUrl = "https://api.slydo.co";
final String localHostUrl = "https://127.0.0.1:8080";

class AuthService {
  final String baseUrl = "https://api.slydo.co";
  final String secureBaseUrl = "https://api.slydo.co";
  final String localHostUrl = "https://127.0.0.1:8080";

  DatabaseHelper _db = DatabaseHelper();

  // This function creates a user object from named args passed in
  Future<User> createUser(
    String uuid,
    String url,
    String phoneNumber,
    String fullName,
    String username,
    String type,
    String avatar,
    String qrCode,
    String password,
    String currency,
    bool isVerified,
  ) async {
    // Create user instance
    User _user = User(
      uuid: uuid,
      url: url,
      phoneNumber: phoneNumber,
      fullName: fullName,
      userName: username,
      type: type,
      avatar: avatar,
      qrCode: qrCode,
      password: password,
      currency: currency,
      isVerified: isVerified,
    );
    //delete old user if exist
    await _db.deleteUsers();

    await _db.saveUser(_user);
    return _user;
  }

  int getEpochTime(DateTime time) {
    var ms = time.millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  // Log user in if credentials are correct
  Future<User> authenticate(String phoneNumber, String password) async {
    // This method will pass the user name and password to the backend server
    // and if credentials are correct will receive payload with jwt and user info
    // which will be saved to the user table and jwt table then create
    // a user instance which we should pass around throughout the application as
    // the auth user.

    var url = secureBaseUrl + "/api/v1/user/auth/get-token/";
    var uuid = Uuid();
    var transactionId = uuid.v4();
    var headers = {
      "TransactionId": transactionId,
      "DeviceType": Platform.isAndroid ? "Android" : "IOS",
      "User-Agent": "Slydo-Mobile",
    };

    // Because the jwt expires every 5 minutes we will take note of the time they
    // where  created and the use that to compute the expiration time of the
    // token. So that we will only use the token if its still valid.
    // We play safe and use 4 minutes
    DateTime now = DateTime.now();
    int expirationTime =
        getEpochTime(now.add(Duration(seconds: 220))); // 3.66667 Minute
    Map _body = {"password": password, "phone_number": phoneNumber};

    var response = await http.post(url, body: _body, headers: headers);
    if (response.statusCode == 200) {
      Map<String, String> data = {};
      var jsonResponse = json.decode(response.body);
      data["access"] = jsonResponse[
          "access"]; // Get `access` and `refresh` Tokens from response
      data["refresh"] = jsonResponse["refresh"];
      data["expiration"] =
          expirationTime.toString(); // Convert expirationTime int to string .

      // Delete jwt from db if one exist
      await deleteJwt();
      await _db.saveJwt(data);

      // Save user to database
      var jsonData = jsonResponse["user"];
      jsonData["password"] = password;
      jsonData["url"] =
          secureBaseUrl + "/api/v1/user/customer/" + jsonData["username"];
      // Delete user from db if one exist
      await deleteUsers();
      User user = await createUser(
        jsonData["uuid"],
        jsonData["url"],
        jsonData["phone_number"],
        jsonData["full_name"],
        jsonData["username"],
        jsonData["account_type"],
        jsonData["avatar"],
        jsonData["qr_code"],
        jsonData["password"],
        jsonData["default_currency"],
        jsonData["is_verified"] ?? false,
      );
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
    var url = secureBaseUrl + "/api/v1/user/auth/logout/";
    var headers = await getAuthHeaders();
    await http.get(url, headers: headers);
    await deleteUsers();
    await deleteDevice();
    await unRegisterDevice();
  }

  // Delete user from db
  Future<int> deleteUsers() async {
    return await _db.deleteUsers();
  }

  // Delete device from db
  Future<int> deleteDevice() async {
    return await _db.deleteDevice();
  }

  // Close connection to db
  Future close() async => _db.close();

  // Get user instance from db
  Future<User> getUser() async {
    return await _db.getUser();
  }

  // Check if token has expired
  bool hasTokenExpired(String expirationTimeString) {
    // Will return false if token is still valid and true if token is no longer useful

    int expirationTime = int.parse(expirationTimeString);
    int now = getEpochTime(DateTime.now());
    return now >= expirationTime;
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
      debugPrint("Token Expired getting new one");
      User _user = await getUser();
      await authenticate(_user.phoneNumber, _user.password);
      tokenData = await _db.getJwt(); // get new token now
    }

    String bearer = "Bearer " + tokenData["access"];
    var uuid = Uuid();
    var transactionId = uuid.v4();
    var headers = {
      "Authorization": bearer,
      "Content-type": "application/json",
      "TransactionId": transactionId,
      "DeviceType": Platform.isAndroid ? "Android" : "IOS",
      "User-Agent": "Slydo-Mobile",
    };
    return headers;
  }

  // Delete JWT from db
  Future<int> deleteJwt() async {
    return await _db.deleteJwt();
  }

  // Fetch user profile
  Future<CustomerProfile> fetchCustomerProfile(String userName) async {
    var url = secureBaseUrl + "/api/v1/user/customer/" + userName.trim();
    var uuid = Uuid();
    var transactionId = uuid.v4();
    var headers = {
      "Content-type": "application/json",
      "TransactionId": transactionId,
      "DeviceType": Platform.isAndroid ? "Android" : "IOS",
      "User-Agent": "Slydo-Mobile",
    };
    var response = await http.get(url, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      CustomerProfile customerProfile = CustomerProfile(
        fullName: jsonData["full_name"],
        userName: jsonData["username"],
        avatar: jsonData["avatar"],
        qrCode: jsonData["qr_code"],
      );
      return customerProfile;
    } else {
      debugPrint(jsonData.toString());
      return null;
    }
  }

  // Update User Avatar
  Future<CustomerProfile> updateCustomerAvatar(File avatar) async {
    User user = await getUser();
    var headers = await getAuthHeaders();
    var url =
        secureBaseUrl + "/api/v1/user/update-avatar/" + user.userName + "/";

    if (avatar != null) {
      var avatarPath = avatar.path;
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("PATCH", Uri.parse(url));

      //add fields
      request.fields["username"] = user.userName;
      request.fields["full_name"] = user.fullName;
      request.fields["avatar"] = user.avatar;

      //create multipart using filepath, string or bytes
      var multipartFile =
          await http.MultipartFile.fromPath("avatar", avatarPath);

      //add multipart to request
      request.files.add(multipartFile);
      headers.forEach((k, v) => request.headers[k] = v);
      var response = await request.send();

      if (response.statusCode == 413) {
        return Future.error(
            "Please upload smaller image, This image is too large.");
      }
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

  Future<User> verifyUserDetail(File documentPhoto, File userPhoto) async {
    var headers = await getAuthHeaders();
    var url = secureBaseUrl + "/api/v1/user/kyc/";

    if (documentPhoto != null && userPhoto != null) {
      var document = documentPhoto.path;
      var selfie = userPhoto.path;
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("PATCH", Uri.parse(url));

      //add fields
      request.fields["document"] = document;
      request.fields["selfie"] = selfie;

      //create multipart using filepath, string or bytes
      var multipartFile1 =
          await http.MultipartFile.fromPath("document", document);
      var multipartFile2 = await http.MultipartFile.fromPath("selfie", selfie);

      //add multipart to request
      request.files.add(multipartFile1);
      request.files.add(multipartFile2);
      headers.forEach((k, v) => request.headers[k] = v);
      var response = await request.send();

      var responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        var jsonData = json.decode(responseBody);

        User user = await createUser(
          jsonData["uuid"],
          jsonData["url"],
          jsonData["phone_number"],
          jsonData["full_name"],
          jsonData["username"],
          jsonData["account_type"],
          jsonData["avatar"],
          jsonData["qr_code"],
          jsonData["password"],
          jsonData["default_currency"],
          jsonData["is_verified"] ?? true,
        );
        return user;
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
    var url = secureBaseUrl + "/api/v1/user/account/";

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

  User createUserInstance(Map<String, dynamic> item) {
    User _user = User(
      uuid: item["uuid"],
      url: item["url"],
      phoneNumber: item["phone_number"],
      fullName: item["full_name"],
      userName: item["username"],
      avatar: item["avatar"],
      qrCode: item["qr_code"],
      password: item["password"],
      currency: item["default_currency"],
      isVerified: item["is_verified"],
    );
    return _user;
  }

  // List the users bank accounts
  Future<List<BankAccount>> getBankAccounts() async {
    var url = secureBaseUrl + "/api/v1/transactions/bank-accounts-list/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List<BankAccount> accounts = [];
      for (var item in jsonData['results']) {
        if (item['is_default'] == true) {
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
      }
      return accounts;
    } else {
      throw "Can't get https.";
    }
  }

  // delete single bankaccount
  Future<bool> deleteBankAccount(String id) async {
    var url =
        secureBaseUrl + "/api/v1/transactions/delete-bank-account/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addBankAccount(Map data) async {
    var url = secureBaseUrl + "/api/v1/transactions/add-bank-account/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    return response.statusCode == 201;
  }

  // update bank account information
  Future<bool> updateBankAccount(Map data) async {
    var url = secureBaseUrl +
        "/api/v1/transactions/set-default-bank-account/" +
        data['uuid'] +
        "/";
    var headers = await getAuthHeaders();
    var response;
    var _data = jsonEncode(data);
    try {
      response = await http.patch(url, headers: headers, body: _data);
    } catch (e) {
      debugPrint("update bank account : " + e.toString());
    }
    if (response.statusCode != 200) {
      var jsonData = response.body;
      debugPrint(jsonData);
    }
    return response.statusCode == 200;
  }

  // List the users bank accounts with pagination
  Future<Map<String, dynamic>> getBankAccountsPagination(
      String next, String previous) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = secureBaseUrl + "/api/v1/transactions/bank-accounts-list/";
    } else {
      url = next;
    }
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List<BankAccount> accounts = [];
      for (var item in jsonData['results']) {
        var bank = item["bank"];
        var logoUrl = item["bank"]['logo_url'];
        item["bank"]['logo_url'] = logoUrl;

        BankAccount account = BankAccount(
          bankAvatar: item["bank"]['logo_url'],
          uuid: item['id'].toString(),
          bankName: bank['short_name'],
          accountName: item['account_name'],
          accountNumber: item['account_number'],
          isDefault: item['is_default'],
        );
        accounts.add(account);
      }
      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": accounts
      };
      return result;
    } else {
      throw "Can't get https.";
    }
  }

  // Accept Payment with POST method with empty data  post
  Future<http.Response> acceptPaymentRequests(
      PaymentRequest paymentRequest) async {
    var url = secureBaseUrl + "/api/v1/transactions/request-payment/accept/";
    var data = {"id": paymentRequest.id};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    return response;
  }

  // Patch payment status with empty data  patch
  Future<bool> rejectPaymentRequests(PaymentRequest paymentRequest) async {
    var url = secureBaseUrl +
        "/api/v1/transactions/request-payment/update/" +
        paymentRequest.id +
        "/";
    var headers = await getAuthHeaders();
    var data = {};
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // Create Payment request with data from user input  post method  return true / false
  Future<http.Response> createPaymentRequests(Map data) async {
    var url = secureBaseUrl + "/api/v1/transactions/request-payment/create/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    return response;
  }

  Future<Map<String, dynamic>> listPaymentRequests(
      String next, String previous, bool toMe, bool fromMe) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = secureBaseUrl + "/api/v1/transactions/request-payment/list/";
      if (toMe) {
        url = url + "?to_me=true";
      }
      if (fromMe) {
        url = url + "?from_me=true";
      }
    } else {
      url = next;
    }

    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      List<PaymentRequest> paymentRequests = [];
      // This variable will hold list of transactions we got from server
      var user = await getUser();
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        // if sender is not current user then
        bool isCredit = (item["from_customer"] != user.userName &&
                item["to_customer"] == user.userName)
            ? true
            : false;

        var payee = isCredit ? item["from_customer"] : item['to_customer'];
        var avatar = isCredit
            ? item["from_customer_avatar"]
            : item['to_customer_avatar'];

        PaymentRequest paymentRequest = PaymentRequest(
            status: item['status'],
            id: item['id'].toString(),
            description: item['description'],
            payee: payee,
            avatar: avatar,
            currency: item['currency'],
            createdAt: item['created_at'],
            amount: item['amount'],
            isCredit: isCredit);
        paymentRequests.add(paymentRequest);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": paymentRequests
      };
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      throw json.decode(response.body);
    }
  }

  // List users transactions
  Future<Map<String, dynamic>> getTransactions(
      String next, String previous, bool moneyIn, bool moneyOut) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = secureBaseUrl + "/api/v1/transactions/list/";
      if (moneyIn) {
        url = url + "?money_in=true";
      }
      if (moneyOut) {
        url = url + "?money_out=true";
      }
    } else {
      url = next;
    }
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<Transaction> transactions = [];
      // This variable will hold list of transactions we got from server
      var user = await getUser();
      var jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        // if sender is not current user then
        bool isCredit = (item["from_customer"] != user.userName &&
                item["to_customer"] == user.userName)
            ? true
            : false;

        var payee = isCredit ? item["from_customer"] : item['to_customer'];
        var avatar = isCredit
            ? item["from_customer_avatar"]
            : item['to_customer_avatar'];

        Transaction transaction = Transaction(
            status: item['status'],
            uuid: item['slug'],
            description: item['description'],
            payee: payee,
            avatar: avatar,
            currency: item['currency'],
            createdAt: item['created_at'],
            category: item['category'],
            note: item['notes'],
            latitude: item['latitude'] ?? "",
            longitude: item['longitude'] ?? "",
            amount: item['amount'],
            isCredit: isCredit);
        transactions.add(transaction);
      }
      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": transactions
      };
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      throw json.decode(response.body);
    }
  }

  //Send payment to backend
  Future<http.Response> makePayment(Map data) async {
    var url = secureBaseUrl + "/api/v1/transactions/make-payment/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    return response;
  }

  //send payment of the order to particular sellers
  Future<http.Response> makePaymentForCartOrder(var data) async {
    var url = secureBaseUrl + "/api/v1/transactions/make-payment-for-orders/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    return response;
  }

  //Send payout to backend
  Future<http.Response> accountPayout(Map data) async {
    var url = secureBaseUrl + "/api/v1/transactions/payout/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    return response;
  }

  // List of bank Payout
  Future<Map<String, dynamic>> getPayoutList(
      String next, String previous) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = secureBaseUrl + "/api/v1/transactions/payout/";
    } else {
      url = next;
    }
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<Payout> payouts = [];
      var jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        var timeStamp = item["credited_at"] == null
            ? item["created_at"]
            : item["credited_at"];

        Payout payout = Payout(
          uuid: item['id'],
          status: item['status'],
          amount: item['amount'],
          currency: item['currency'],
          timeStamp: timeStamp,
          bankName: item["customer_bank_account"]["bank"]["short_name"],
          bankLogo: item["customer_bank_account"]["bank"]["logo_url"],
        );
        payouts.add(payout);
      }
      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": payouts
      };
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      throw json.decode(response.body);
    }
  }

  //register device
  Future<bool> registerDevice(Map data) async {
    var url = secureBaseUrl + "/api/v1/notification/register-device/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);

    var response = await http.post(url, headers: headers, body: _data);
    return response.statusCode == 200;
  }

  // it will unregister the device from server
  Future<bool> unRegisterDevice() async {
    var url = secureBaseUrl + "/api/v1/notification/unregister-device/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode({});
    var response;
    try {
      response = await http.patch(url, headers: headers, body: _data);
    } catch (e) {
      debugPrint(e.toString());
    }
    return response.statusCode == 200;
  }

  // it will tell the server our app is in which state
  Future<bool> updateAppState(Map data) async {
    var url = secureBaseUrl + "/api/v1/notification/update-app-state/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response;
    try {
      response = await http.patch(url, headers: headers, body: _data);
    } catch (e) {
      debugPrint("updateAppState : " + e.toString());
    }
    if (response.statusCode != 200) {
      var jsonData = response.body;
      debugPrint(jsonData);
    }
    return response.statusCode == 200;
  }

  // Get Account Balance
  Future<Map> getAccountBalance() async {
    var url = secureBaseUrl + "/api/v1/transactions/check-account-balance/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      return jsonData;
    } else {
      return {"balance": 0, "spendable_balance": 0, "over_draft": 0};
    }
  }

  // Send email to user.
  Future<bool> sendMessage(Map data) async {
    var url = secureBaseUrl + "/api/v1/messaging/send/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, body: _data, headers: headers);
    if (response.statusCode == 201) {
      return true;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // it will update the message actions:  [Archived,UnArchived,Starred,UnStarred]
  Future<bool> updateMessage(String id, String action) async {
    var url =
        secureBaseUrl + "/api/v1/messaging/update/" + id + "/" + action + "/";
    var headers = await getAuthHeaders();
    var response = await http.patch(url, headers: headers);
    var jsonData = json.decode(response.body);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw jsonData;
    }
  }

  // it will delete the message
  Future<bool> deleteMessage(String id) async {
    var url = secureBaseUrl + "/api/v1/messaging/delete/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  // Get single message
  Future<Message> getMessage(String id) async {
    var url = secureBaseUrl + "/api/v1/messaging/read/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      Message message = Message(
        subject: jsonData["subject"],
        id: jsonData["id"],
        body: jsonData["body"],
        timeStamp: jsonData["time_sent"],
        isRead: jsonData["is_read"],
        recipient: jsonData["recipient"],
        sender: jsonData["sender"],
        senderAvatar: jsonData["sender_avatar"],
        recipientAvatar: jsonData["recipient_avatar"],
        isArchivedByRecipient: jsonData["is_archived_by_recipient"],
        isStarredByRecipient: jsonData["is_starred_by_recipient"],
        isArchivedBySender: jsonData["is_archived_by_sender"],
        isStarredBySender: jsonData["is_starred_by_sender"],
      );
      return message;
    } else {
      throw jsonData;
    }
  }

  // List messages filters: [archived,sent,starred,all]
  Future<Map<String, dynamic>> listMessages(String next, String previous,
      {String filter}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = secureBaseUrl + "/api/v1/messaging/list/" + filter + "/";
    } else {
      url = next;
    }
    var headers = await getAuthHeaders();

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<PartialMessage> messagesList = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        PartialMessage message = PartialMessage(
          subtitle: item["subtitle"],
          subject: item["sender"],
          id: item["id"],
          timeStamp: item["time_sent"],
          isRead: item["is_read"],
          recipient: item["recipient"],
          sender: item["sender"],
          senderAvatar: item["sender_avatar"],
          recipientAvatar: item["recipient_avatar"],
          isArchivedByRecipient: item["is_archived_by_recipient"],
          isStarredByRecipient: item["is_starred_by_recipient"],
          isArchivedBySender: item["is_archived_by_sender"],
          isStarredBySender: item["is_starred_by_sender"],
        );
        messagesList.add(message);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": messagesList
      };
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      throw json.decode(response.body);
    }
  }

  Map getNonAuthHeader() {
    var uuid = Uuid();
    var transactionId = uuid.v4();
    var headers = {
      "Content-type": "application/json",
      "TransactionId": transactionId,
      "DeviceType": Platform.isAndroid ? "Android" : "IOS",
      "User-Agent": "Slydo-Mobile",
    };
    return headers;
  }

  // it will register the phone number to get OTP
  Future<bool> registerPhoneNumber(String phoneNumber) async {
    var url = secureBaseUrl + "/api/v1/sms/register-phone-number";
    var headers = getNonAuthHeader();
    var data = {
      "phone": phoneNumber,
    };
    var _data = jsonEncode(data);
    var response = await http.post(url, body: _data, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw jsonData;
    }
  }

  // it will verify the phone number to  OTP
  Future<String> verifyPhoneNumber(
      // ignore: non_constant_identifier_names
      String phoneNumber,
      String otp,
      String passwordToken) async {
    var url = secureBaseUrl + "/api/v1/sms/verify";
    var headers = getNonAuthHeader();
    var data = {
      "phone": phoneNumber,
      "code": otp,
      "password-token": passwordToken,
    };
    var _data = jsonEncode(data);
    var response = await http.post(url, body: _data, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      var resetToken = jsonData['reset-token'];
      return resetToken;
    } else {
      throw jsonData;
    }
  }

  // it will verify the phone number to  OTP
  Future<bool> passwordReset(String passwordOne, String passwordTwo,
      String phoneNumber, String resetToken) async {
    var url = secureBaseUrl + "/api/v1/user/auth/password-reset/";
    var headers = getNonAuthHeader();
    var data = {
      "password1": passwordOne,
      "password2": passwordTwo,
      "reset-token": resetToken,
      "phone-number": phoneNumber,
    };
    var _data = jsonEncode(data);
    var response = await http.patch(url, body: _data, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw jsonData;
    }
  }

  //Products
  Product createProduct(Map<String, dynamic> item) {
    Product product = Product();
    product.id = item['id'];
    product.localImages = item['localImages'];
    product.serverImages = product.imageDataToList(item['pictures']);
    product.pictureMap = item['pictures'];
    product.name = item['name'];
    product.qrCode = item['qr_code'];
    product.manufacturer = item['manufacturer'];
    product.isAvailable = item["is_available"];
    product.availableFrom = DateTime.parse(item['available_from']);
    product.description = item['description'];
    product.shortDescription = item["short_description"];
    product.category = item['category'].toString();
    product.condition = item['condition'];
    product.seller = item['seller'];
    product.sellerAvatar = item["seller_avatar"];
    product.price = item['price'].toString();
    product.currency = item["currency"];
    return product;
  }

  // delete product and service image

  Future<bool> deleteProductOrServiceImage(String imageId) async {
    var url = secureBaseUrl + "/api/v1/images/" + imageId + "/";
    var headers = await getAuthHeaders();
    var response = await http.delete(
      url,
      headers: headers,
    );
    if (response.statusCode == 204) {
      return true;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // List Products
  Future<Map<String, dynamic>> listOfProduct(String next, String previous,
      {String userId}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = secureBaseUrl + "/api/v1/products/by-seller/" + userId + "/";
    } else {
      url = next;
    }
    debugPrint(url);
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<Product> productList = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        Product product = createProduct(item);
        productList.add(product);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": productList
      };
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      List<Product> productList = [];
      Map<String, dynamic> result = {
        "count": 0,
        "next": "test",
        "previous": "test",
        "results": productList
      };
      return result;
    }
  }

  String dateToString(DateTime date) {
    var formatter = new DateFormat('yyyy-MM-dd');
    var formatted = formatter.format(date);
    return formatted;
  }

  // Add Product
  Future<bool> addProduct(Product product) async {
    var headers = await getAuthHeaders();
    var url = secureBaseUrl + "/api/v1/products/";

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST", Uri.parse(url));

    Map<dynamic, dynamic> _data = product.toMap();
    _data["available_from"] = dateToString(product.availableFrom);
    _data["image_count"] = product.localImages.length;

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });
    List<MultipartFile> newList = new List<MultipartFile>();
    for (int i = 0; i < product.localImages.length; i++) {
      // Add fields
      request.fields["imagefile_$i"] = product.localImages[i].path;

      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath(
          "imagefile_$i", product.localImages[i].path);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    // Add multipart to request
    request.files.addAll(newList);
    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 201) {
      return true;
    } else {
      throw responseBody;
    }
  }

  // Edit Product
  Future<bool> editProduct(Product product) async {
    var headers = await getAuthHeaders();
    var url = secureBaseUrl + "/api/v1/products/" + product.id.toString() + "/";

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("PATCH", Uri.parse(url));

    Map<dynamic, dynamic> _data = product.toMap();
    _data["available_from"] = dateToString(product.availableFrom);
    _data["image_count"] = product.localImages.length;

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });
    List<MultipartFile> newList = new List<MultipartFile>();
    for (int i = 0; i < product.localImages.length; i++) {
      // Add fields
      request.fields["imagefile_$i"] = product.localImages[i].path;

      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath(
          "imagefile_$i", product.localImages[i].path);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    // Add multipart to request
    request.files.addAll(newList);

    headers.forEach((k, v) => request.headers[k] = v);

    var response = await request.send();

    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      return true;
    } else {
      throw responseBody;
    }
  }

  // Get single product
  Future<Product> getProduct(String id) async {
    var url = secureBaseUrl + "/api/v1/products/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      Product product = createProduct(jsonData);
      return product;
    } else {
      throw jsonData;
    }
  }

  // delete single product
  Future<bool> deleteProduct(String id) async {
    var url = secureBaseUrl + "/api/v1/products/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await http.delete(
      url,
      headers: headers,
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  //Service
  Service createService(Map<String, dynamic> item) {
    Service service = Service();
    service.id = item['id'];
    service.localImages = item['localImages'];
    service.serverImages = service.imageDataToList(item['pictures']);
    service.pictureMap = item['pictures'];
    service.name = item['name'];
    service.qrCode = item['qr_code'];
    service.isAvailable = item["is_available"];
    service.availableFrom = DateTime.parse(item['available_from']);
    service.description = item['description'];
    service.shortDescription = item["short_description"];
    service.category = item['category'];
    service.provider = item['provider'];
    service.price = item['price'].toString();
    service.currency = item["currency"];
    service.providerAvatar = item["provider_avatar"];

    return service;
  }

  // List services
  Future<Map<String, dynamic>> listServicesByProvider(
      String next, String previous,
      {String userId}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = secureBaseUrl + "/api/v1/services/by-provider/" + userId + "/";
    } else {
      url = next;
    }
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<Service> serviceList = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        Service service = createService(item);
        serviceList.add(service);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": serviceList
      };
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      List<Service> serviceList = [];

      Map<String, dynamic> result = {
        "count": 0,
        "next": "test",
        "previous": "test",
        "results": serviceList
      };
      return result;
    }
  }

  // addService
  Future<bool> addService(Service service) async {
    var headers = await getAuthHeaders();
    var url = secureBaseUrl + "/api/v1/services/";

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST", Uri.parse(url));

    Map<dynamic, dynamic> _data = service.toMap();
    _data["available_from"] = dateToString(service.availableFrom);
    _data["image_count"] = service.localImages.length;

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });
    List<MultipartFile> newList = new List<MultipartFile>();
    for (int i = 0; i < service.localImages.length; i++) {
      // Add fields
      request.fields["imagefile_$i"] = service.localImages[i].path;

      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath(
          "imagefile_$i", service.localImages[i].path);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    // Add multipart to request
    request.files.addAll(newList);
    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 201) {
      return true;
    } else {
      throw responseBody;
    }
  }

// edit service
  Future<bool> editService(Service service) async {
    var headers = await getAuthHeaders();
    var url = secureBaseUrl + "/api/v1/services/" + service.id.toString() + "/";

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("PATCH", Uri.parse(url));

    Map<dynamic, dynamic> _data = service.toMap();
    _data["available_from"] = dateToString(service.availableFrom);
    _data["image_count"] = service.localImages.length;

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });

    if (service.localImages.length > 0) {
      List<MultipartFile> newList = new List<MultipartFile>();
      for (int i = 0; i < service.localImages.length; i++) {
        //add fields
        request.fields["imagefile_$i"] = service.localImages[i].path;

        //create multipart using filepath, string or bytes
        var multipartFile = await http.MultipartFile.fromPath(
            "imagefile_$i", service.localImages[i].path);

        //add multipart to newList
        newList.add(multipartFile);
      }
      //add multipart to request
      request.files.addAll(newList);
    }
    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }

    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      return true;
    } else {
      throw responseBody;
    }
  }

// Get single service
  Future<Service> getService(String id) async {
    var url = secureBaseUrl + "/api/v1/services/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      Service service = createService(jsonData);
      return service;
    } else {
      throw jsonData;
    }
  }

  // delete single service
  Future<bool> deleteService(String id) async {
    var url = secureBaseUrl + "/api/v1/services/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await http.delete(
      url,
      headers: headers,
    );
    if (response.statusCode == 204) {
      return true;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  //search

  // List the searched item
  Future<Map<String, dynamic>> searchEndpoint(String url) async {
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": jsonData["results"],
      };
      return result;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // List the  item with pagination
  Future<Map<String, dynamic>> searchEndpointPagination(
      String url, String next, String previous) async {
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = next;
    }
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": jsonData["results"],
      };
      return result;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // Transactions graph and Category
  Future<Map<String, dynamic>> getTransactionWeeklyReport(
      String weekNumber) async {
    var url = secureBaseUrl +
        "/api/v1/transactions/transaction-filter/?week=" +
        weekNumber;
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      return jsonData;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  Future<Map<String, dynamic>> getPaymentCategory() async {
    var url = secureBaseUrl + "/api/v1/transactions/payment-category/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      Map<String, dynamic> result = {
        "results": jsonData["results"],
      };
      return result;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // Update Order Status
  Future<bool> updateOrderStatus(String value, String orderId) async {
    var data = {"status": value};
    var _data = jsonEncode(data);
    var url = secureBaseUrl + "/api/v1/order/" + orderId + "/update-status/";
    var headers = await getAuthHeaders();
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // Update Order Note
  Future<bool> updateOrderNote(String note, String orderId) async {
    var data = {"note": note};
    var _data = jsonEncode(data);
    var url = secureBaseUrl + "/api/v1/order/" + orderId + "/add-note/";
    var headers = await getAuthHeaders();
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // List of Orders
  Future<dynamic> listOrders(
      String next, String previous, String filterValue) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = secureBaseUrl + "/api/v1/order/";
      if (filterValue != "" && filterValue != null) {
        url = url + "?status__iexact=$filterValue";
      }
    } else {
      url = next;
    }

    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      List items = List();
      var data = jsonData["results"];
      for (int i = 0; i < data.length; i++) {
        var order = Order.fromJson(data[i]);
        items.add(order);
      }

      jsonData["results"] = items;
      return jsonData;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      throw json.decode(response.body);
    }
  }

  // Get single Order
  Future<dynamic> getOrder(String id) async {
    var url = secureBaseUrl + "/api/v1/order/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      List items = List();
      var data = jsonData["results"];
      for (int i = 0; i < data.length; i++) {
        if (data[i]["item"].containsKey("manufacturer")) {
          var product = Product.fromJson(data[i]["item"]);
          items.add({
            "type": "product",
            "item": product,
            "qty": int.parse(data[i]["qty"]),
          });
        }
        if (!data[i]["item"].containsKey("manufacturer")) {
          var service = Service.fromJson(data[i]["item"]);
          items.add({
            "type": "service",
            "item": service,
            "qty": int.parse(data[i]["qty"]),
          });
        }
      }
      return items;
    } else {
      throw jsonData;
    }
  }

  //ShoppingCart
  Future<List> getShoppingCart() async {
    var url = secureBaseUrl + "/api/v1/shopping-cart/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    var jsonData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return getCartItems(jsonData);
    }
    throw jsonData;
  }

  Future<bool> addItemToShoppingCart(Map data) async {
    var url = secureBaseUrl + "/api/v1/shopping-cart/add-item/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    var jsonData = jsonDecode(response.body);
    debugPrint("sent data: " + _data.toString());
    if (response.statusCode == 200) {
      debugPrint("response" + jsonData.toString());

      return true;
    }
    return false;
  }

  Future<bool> removeItemToShoppingCart(Map data) async {
    var url = secureBaseUrl + "/api/v1/shopping-cart/remove-item/";
    var _data = jsonEncode(data);
    var headers = await getAuthHeaders();
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    } else
      return false;
  }

  //place shopping cart order
  Future<dynamic> placeOrderOfShoppingCart(Map data) async {
    var url = secureBaseUrl + "/api/v1/shopping-cart/";
    var _data = jsonEncode(data);
    var headers = await getAuthHeaders();
    var response = await http.post(url, headers: headers, body: _data);
    var jsonData = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return jsonData;
    }
    return null;
  }

  List<dynamic> getCartItems(var jsonResponse) {
    List items = List();
    var data = jsonResponse["results"];

    for (int i = 0; i < data.length; i++) {
      if (data[i]["type"] == "product") {
        for (int j = 0; j < data[i]["qty"]; j++) {
          var product = Product.fromJson(data[i]);
          items.add(product);
        }
      }
      if (data[i]["type"] == "service") {
        for (int j = 0; j < data[i]["qty"]; j++) {
          var service = Service.fromJson(data[i]);
          items.add(service);
        }
      }
    }
    return items;
  }

  Future<bool> verifyBVN(String bvnNumber) async {
    return true;
  }

  // top up slydo account
  Future<bool> topUpAccountByCC(Map data) async {
    var url = secureBaseUrl + "/api/v1/transactions/top-up/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    if (response.statusCode != 200) {
      return true;
    }
    debugPrint("topUp By CC${response.body}");
    return false;
  }

  Future<Address> fetchUserAddress() async {
    var url = secureBaseUrl + "/api/v1/user/address/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    var jsonData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Address.fromJson(jsonData);
    }
    return Address(
        addressLineOne: "",
        addressLineTwo: "",
        city: "",
        state: "",
        country: "",
        countryIsoCode: "NG");
  }

  Future<bool> addUserAddress(Map data) async {
    var url = secureBaseUrl + "/api/v1/user/address/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    debugPrint("address add failed : ${response.body}");
    return true;
  }

  Future<List<dynamic>> ownersOrderProductsAndServices(
      {@required String type,
      @required String userId,
      @required String exclude}) async {
    String urlPart = type == "products"
        ? "sellers-other-products"
        : "providers-other-services";

    var url = "$secureBaseUrl/api/v1/$type/$urlPart/$userId/?exclude=$exclude";

    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    List items = List();
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      var data = jsonData["results"];
      for (int i = 0; i < data.length; i++) {
        if (type == "products") {
          var product = Product.fromJson(data[i]);
          items.add(product);
        }
        if (type == "services") {
          var service = Service.fromJson(data[i]);
          items.add(service);
        }
      }
      return items;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      return items;
    }
  }

  //Friends List

  Future<Map<String, dynamic>> contacts(String next, String previous) async {
    var url = secureBaseUrl + "/api/v1/user/contacts/";
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = next;
    }
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body) ?? {};

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": jsonData["results"],
      };
      return result;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  Future<bool> removeFromContactList(CustomerProfile user) async {
    var url = secureBaseUrl + "/api/v1/user/contacts/remove-from-contact/";
    var data = {"user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // Check if user is the the checker's list of contact
  Future<bool> checkInContactList(String user, String checker) async {
    // Note that the checker is the request.user making this request.
    var url = secureBaseUrl + "/api/v1/user/contacts/check-in-contact/";
    var data = {"checker": checker, "user": user};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> checkInRequest(String user) async {
    // Note that the checker is the request.user making this request.
    var url = secureBaseUrl + "/api/v1/user/contact-request/check-in-request/";
    var data = {"to_user": user};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> makeContactRequest(CustomerProfile user) async {
    var url = secureBaseUrl + "/api/v1/user/contact-request/";
    var data = {"to_user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    if (response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // Block Contact
  Future<Map<String, dynamic>> listBlockUsers(
      String next, String previous) async {
    var url = secureBaseUrl + "/api/v1/user/contacts/list-block-contact/";
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = next;
    }
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": jsonData["results"],
      };
      return result;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  Future<bool> blockUser(CustomerProfile user) async {
    var url = secureBaseUrl + "/api/v1/user/contacts/block-contact/";
    var data = {"user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> unBlockUser(CustomerProfile user) async {
    var url = secureBaseUrl + "/api/v1/user/contacts/unblock-contact/";
    var data = {"user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // Contact Request
  Future<Map<String, dynamic>> listContactRequests(
      String next, String previous) async {
    var url = secureBaseUrl + "/api/v1/user/contact-request/";
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = next;
    }
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": jsonData["results"],
      };
      return result;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  Future<bool> acceptContactRequest(CustomerProfile user) async {
    var url = secureBaseUrl + "/api/v1/user/contact-request/accept/";
    var data = {"user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> rejectContactRequest(CustomerProfile user) async {
    var url = secureBaseUrl + "/api/v1/user/contact-request/cancel-or-reject/";
    var data = {"user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> upgradeUserProfile(Map<String, dynamic> data) async {
    var url = secureBaseUrl + "/api/v1/user/upgrade-user-account/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);

    if (response.statusCode == 201) {
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> getUserProfileUpgradeDetails() async {
//    var url = secureBaseUrl + "/api/v1/transactions/payment-category/";
//    var headers = await getAuthHeaders();
//    var response = await http.get(url, headers: headers);
//    if (response.statusCode == 200) {
//      var jsonData = json.decode(response.body);
//
//      Map<String, dynamic> result = {
//        "results": jsonData["results"],
//      };
//      return result;
//    } else {
//      var jsonData = json.decode(response.body);
//      throw jsonData;
//    }

    return {
      "results": {
        "data": [
          {"name": "Business", "price": "100"},
          {"name": "Developer", "price": "200"},
        ]
      }
    };
  }

  Future<Map<String, dynamic>> topUpAccountByBank(
      Map<String, dynamic> data) async {
    var amount =
        (double.parse(data["amount"]) - (double.parse(data["amount"]) * 0.03))
            .toString();
    await Future.delayed(Duration(seconds: 2));
    // return Future.error("Something wrong please try later!");
    return {"token": "123456789012", "amount": amount, "currency": "NGN"};
  }

  Future<bool> confirmTopUpWithReferenceNumber(
      Map<String, dynamic> data) async {
    await Future.delayed(Duration(seconds: 2));
    // return Future.error("Something wrong please try later!");
    return true;
  }

  Future<List<Contract>> getContractList() async {
    List<Contract> contracts = List.generate(
        10,
        (index) => Contract.fromJson({
              "status": "Paid",
              "uuid": "sadas",
              "description": "Softwear Development",
              "payee_name": "Stephen Blue",
              "payee_id": "stephen.blue",
              "payee_avatar":
                  "https://png.pngtree.com/png-vector/20190704/ourmid/pngtree-businessman-user-avatar-free-vector-png-image_1538405.jpg",
              "payment_period": "monthly",
              "amount": "2000",
              "currency": "NGN",
              "created_at": "2020-11-10 16:56:44.184311",
              "end_at": "2020-11-20 16:56:44.184311",
              "paid_at": "2020-11-30 16:56:44.184311"
            }));

    await Future.delayed(Duration(seconds: 2));

    return contracts;
  }

  Future<List<Invoice>> getInvoiceList() async {
    List<Invoice> invoices = List.generate(
        10,
        (index) => Invoice.fromJson({
              "status": "Paid",
              "uuid": "sadas",
              "description": "Softwear Development",
              "payee_name": "Stephen Blue",
              "payee_id": "stephen.blue",
              "payee_avatar":
                  "https://png.pngtree.com/png-vector/20190704/ourmid/pngtree-businessman-user-avatar-free-vector-png-image_1538405.jpg",
              "amount": "2000",
              "currency": "NGN",
              "created_at": "2020-11-10 16:56:44.184311",
              "due_date": "2020-11-20 16:56:44.184311",
              "paid_at": "2020-11-30 16:56:44.184311"
            }));

    await Future.delayed(Duration(seconds: 2));

    return invoices;
  }
}
