import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';

class BankAccount {
  String uuid;
  String bankAvatar;
  String bankName;
  String accountName;
  int accountNumber;
  bool isDefault;

  BankAccount({
    this.uuid,
    this.bankAvatar,
    this.bankName,
    this.accountName,
    this.accountNumber,
    this.isDefault,
  });
}

class Transaction {
  String status;
  String uuid;
  String description;
  String payee;
  String avatar;
  String currency;
  String createdAt;
  String category;
  String note;
  String latitude;
  String longitude;
  String userType;
  int amount;
  bool isCredit;
  bool isAnonymous;

  // Pass in as named parameter in constructor
  Transaction(
      {this.status,
      this.uuid,
      this.description,
      this.payee,
      this.avatar,
      this.currency,
      this.createdAt,
      this.userType = "User",
      this.category,
      this.note,
      this.latitude,
      this.longitude,
      this.isAnonymous,
      this.amount,
      this.isCredit});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    bool isCredit = json["is_credit"];
    var payee = isCredit ? json["from_customer"] : json['to_customer'];
    var avatar =
        isCredit ? json["from_customer_avatar"] : json['to_customer_avatar'];

    return Transaction(
        status: json['status'],
        uuid: json['slug'],
        description: json['description'],
        payee: payee,
        avatar: avatar,
        currency: json['currency'],
        createdAt: json['created_at'],
        category: json['category'],
        note: json['notes'],
        userType: json["user_type"] ?? "User",
        latitude: json['latitude'] ?? "",
        longitude: json['longitude'] ?? "",
        amount: json['amount'],
        isAnonymous: json['is_anonymous'] ?? false,
        isCredit: isCredit);
  }
}

class PaymentRequest {
  String status;
  String id;
  String description;
  String payee;
  String avatar;
  String currency;
  String createdAt;
  int amount;
  bool isCredit;
  String userType;

  // Pass in as named parameter in constructor
  PaymentRequest(
      {this.status,
      this.id,
      this.description,
      this.payee,
      this.avatar,
      this.createdAt,
      this.currency,
      this.userType = "User",
      this.amount,
      this.isCredit});

  factory PaymentRequest.fromJson(Map<String, dynamic> json,
      {User currentUser}) {
    bool isCredit = (json["from_customer"] != currentUser?.userName &&
            json["to_customer"] == currentUser?.userName)
        ? true
        : false;

    var payee = isCredit ? json["from_customer"] : json['to_customer'];
    var avatar =
        isCredit ? json["from_customer_avatar"] : json['to_customer_avatar'];

    return PaymentRequest(
        status: json['status'],
        id: json['id'].toString(),
        description: json['description'],
        payee: payee,
        avatar: avatar,
        userType: json["user_type"] ?? "User",
        currency: json['currency'],
        createdAt: json['created_at'],
        amount: json['amount'],
        isCredit: isCredit);
  }
}
