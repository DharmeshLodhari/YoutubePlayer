import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/models/message.dart';
import 'package:Slydo/models/payout.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

final String baseUrl = "http://api.slydo.co";
final String localHostUrl = "https://127.0.0.1:8080";

class AuthService {
  DatabaseHelper _db = DatabaseHelper();

  // This function creates a user object from named args passed in
  User createUser(
      String uuid,
      String url,
      String phoneNumber,
      String fullName,
      String username,
      String avatar,
      String qrCode,
      String password,
      String currency) {
    // Create user instance
    User _user = User(
        uuid: uuid,
        url: url,
        phoneNumber: phoneNumber,
        fullName: fullName,
        userName: username,
        avatar: avatar,
        qrCode: qrCode,
        password: password,
        currency: currency);

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

    var url = baseUrl + "/api/v1/user/auth/get-token/";
    var uuid = Uuid();
    var transactionId = uuid.v4();
    var headers = {
//      "Content-type": "application/json",
      "TransactionId": transactionId,
      "DeviceType": Platform.isAndroid ? "Android" : "IOS",
      "User-Agent": "Slydo-Mobile",
    };
    Map _body = {"password": password, "phone_number": phoneNumber};
    var response = await http.post(url, body: _body, headers: headers);
    if (response.statusCode == 200) {
      // Because the jwt expires every 5 minutes we will take note of the time they
      // where  created and the use that to compute the expiration time of the
      // token. So that we will only use the token if its still valid.
      // We play safe and use 4 minutes
      DateTime now = DateTime.now();
      DateTime expirationTime = now.add(Duration(seconds: 240)); // 4 Minute

      Map<String, String> data = {};
      var jsonResponse = json.decode(response.body);
      var jsonData = jsonResponse["user"];

      // Get `access` and `refresh` Tokens from response
      data["access"] = jsonResponse["access"];
      data["refresh"] = jsonResponse["refresh"];

      // Convert DateTime object to string before passing it in.
      data["expiration"] = expirationTime.toString();

      jsonData["password"] = password;
      jsonData["url"] =
          baseUrl + "/api/v1/user/customer/" + jsonData["username"];

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
        jsonData["password"],
        jsonData["default_currency"],
      );

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
    var url = baseUrl + "/api/v1/user/auth/logout/";
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
  bool hasTokenExpired(String expirationTime) {
    // Will return false if token is still valid and true if token is no longer useful
    DateTime now = DateTime.now();
    DateTime tokenExpirationTime = DateTime.parse(expirationTime);
    return now.isAfter(tokenExpirationTime);
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
      authenticate(_user.phoneNumber, _user.password).then((value) async {
        tokenData = await _db.getJwt(); // get new token now
      });
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
    var url = baseUrl + "/api/v1/user/customer/" + userName;
    var uuid = Uuid();
    var transactionId = uuid.v4();
    var headers = {
      "Content-type": "application/json",
      "TransactionId": transactionId,
      "DeviceType": Platform.isAndroid ? "Android" : "IOS",
      "User-Agent": "Slydo-Mobile",
    };
    var response = await http.get(url, headers: headers);

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
      debugPrint("Can't get https.");
      return null;
    }
  }

  // Update User Avatar
  Future<CustomerProfile> updateCustomerAvatar(File avatar) async {
    User user = await getUser();
    var headers = await getAuthHeaders();
    var url = baseUrl + "/api/v1/user/update-avatar/" + user.userName;

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
    var url = baseUrl + "/api/v1/user/account/";

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

  // Accept Payment with POST method with empty data  post
  Future<bool> acceptPaymentRequests(PaymentRequest paymentRequest) async {
    var url = baseUrl + "/api/v1/transactions/request-payment/accept/";
    var data = {"id": paymentRequest.id};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // Patch payment status with empty data  patch
  Future<bool> rejectPaymentRequests(PaymentRequest paymentRequest) async {
    var url = baseUrl +
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
  Future<bool> createPaymentRequests(Map data) async {
    var url = baseUrl + "/api/v1/transactions/request-payment/create/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return false;
    } else {
      return true;
    }
  }

  Future<Map<String, dynamic>> listPaymentRequests(
      String next, String previous) async {
    Map<String, String> knownCustomers = {};

    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = baseUrl + "/api/v1/transactions/request-payment/list";
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

        try {
          if (knownCustomers.containsKey(payee) == false) {
            var customer = await fetchCustomerProfile(payee);
            knownCustomers[payee] = customer.avatar;
          }
          var avatar = knownCustomers[payee];
          PaymentRequest paymentRequest = PaymentRequest(
              status: item['status'],
              id: item['id'].toString(),
              description: item['description'],
              payee: payee,
              avatar: avatar,
              currency: item['currency'],
              amount: item['amount'],
              isCredit: isCredit);
          paymentRequests.add(paymentRequest);
        } catch (Exception) {}
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
      String next, String previous) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = baseUrl + "/api/v1/transactions/list/";
    } else {
      url = next;
    }
    Map<String, String> knownCustomers = {};
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
    var url = baseUrl + "/api/v1/transactions/make-payment/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    return response;
  }

  //Send payout to backend
  Future<http.Response> accountPayout(Map data) async {
    var url = baseUrl + "/api/v1/transactions/payout/";
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
      url = baseUrl + "/api/v1/transactions/payout/";
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

  // TODO: Marge with makePayment
  //Send payment to backend
  Future<bool> addBankAccount(Map data) async {
    var url = baseUrl + "/api/v1/transactions/add-bank-account/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    return response.statusCode == 201;
  }

  Future<bool> registerDevice(Map data) async {
    var url = baseUrl + "/api/v1/notification/register-device/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);

    var response = await http.post(url, headers: headers, body: _data);
    return response.statusCode == 200;
  }

  // it will unregister the device from server
  Future<bool> unRegisterDevice() async {
    var url = baseUrl + "/api/v1/notification/unregister-device/";
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
    var url = baseUrl + "/api/v1/notification/update-app-state/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response;
    try {
      response = await http.patch(url, headers: headers, body: _data);
    } catch (e) {}
    if (response.statusCode != 200) {
      var jsonData = response.body;
      debugPrint(jsonData);
    }
    return response.statusCode == 200;
  }

  // Get Account Balance
  Future<Map> getAccountBalance() async {
    var url = baseUrl + "/api/v1/transactions/check-account-balance/";
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
    var url = baseUrl + "/api/v1/messaging/send/";
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
    var url = baseUrl + "/api/v1/messaging/update/" + id + "/" + action + "/";
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
    var url = baseUrl + "/api/v1/messaging/delete/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
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
    var url = baseUrl + "/api/v1/sms/register-phone-number/";
    var headers = getNonAuthHeader();
    var data = {
      "phone": phoneNumber,
    };
    var _data = jsonEncode(data);
    var response = await http.post(url, body: _data, headers: headers);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw response.body;
    }
  }

  // it will verify the phone number to  OTP
  Future<String> verifyPhoneNumber(String phoneNumber, String OTP) async {
    var url = baseUrl + "/api/v1/sms/verify/";
    var headers = await getAuthHeaders();
    var data = {
      "phone": phoneNumber,
      "code": OTP,
      "password-token": "true",
    };
    var _data = jsonEncode(data);
    var response = await http.post(url, body: _data, headers: headers);
    debugPrint("${response.body}");
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      var resetToken = jsonData['reset-token'];
      return resetToken;
    } else {
      throw jsonData;
    }
  }

  // it will verify the phone number to  OTP
  Future<bool> passwordReset(
      String passwordOne, String passwordTwo, String resetToken) async {
    var url = baseUrl + "/api/v1/user/auth/password-reset/";
    var headers = await getAuthHeaders();
    var data = {
      "password1": passwordOne,
      "password2": passwordTwo,
      "reset-token": resetToken,
    };
    var _data = jsonEncode(data);
    var response = await http.patch(url, body: _data, headers: headers);
    debugPrint("${response.statusCode}");
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw jsonData;
    }
  }

  // Get single message
  Future<Message> getMessage(String id) async {
    var url = baseUrl + "/api/v1/messaging/read/" + id + "/";
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
      url = baseUrl + "/api/v1/messaging/list/" + filter + "/";
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
}
