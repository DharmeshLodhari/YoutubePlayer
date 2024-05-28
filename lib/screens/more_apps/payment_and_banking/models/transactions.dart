import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:provider/provider.dart';

class BankAccount {
  String? uuid;
  String? bankAvatar;
  String? bankName;
  String? accountName;
  String? accountNumber;
  bool? isDefault;

  BankAccount({
    this.uuid,
    this.bankAvatar,
    this.bankName,
    this.accountName,
    this.accountNumber,
    this.isDefault,
  });
}

class CreditCard {
  int? cvv;
  int? cardId;
  String? icon;
  String? type;
  bool? isDefault;
  int? cardNumber;
  bool? isVisaCard;
  String? expiryDate;

  CreditCard({
    this.cvv,
    this.type,
    this.icon,
    this.cardId,
    this.isDefault,
    this.isVisaCard,
    this.expiryDate,
    this.cardNumber,
  });

  static String getCreditCardImg(bool isVisa) {
    return isVisa
        ? 'assets/images/visa_icon.png'
        : 'assets/images/master_card_icon.png';
  }

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      cvv: json['cvv'],
      cardId: json['id'],
      type: json['type'],
      cardNumber: json['card_number'],
      expiryDate: json['expiry_date'],
      isDefault: json['is_default_cc'] ?? false,
      isVisaCard: json['type'].toString().toLowerCase().contains('visa'),
      icon: getCreditCardImg(
          json['type'].toString().toLowerCase().contains('visa')),
    );
  }
}

class Transaction {
  String? status;
  String? uuid;
  String? description;
  String? payee;
  String? avatar;
  String? currency;
  String? createdAt;
  String? category;
  String? note;
  String? latitude;
  String? longitude;
  String userType;
  int? amount;
  bool? isCredit;
  bool? isAnonymous;
  String fromCustomer;
  String toCustomer;
  String displayFromCustomer;
  String displayToCustomer;
  String displayCustomer;

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
      this.toCustomer = "",
      this.fromCustomer = "",
      this.displayFromCustomer = "",
      this.displayToCustomer = "",
      this.displayCustomer = "",
      this.category,
      this.note,
      this.latitude,
      this.longitude,
      this.isAnonymous,
      this.amount,
      this.isCredit});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final bool isCredit = json["is_credit"];
    final payee =
        (isCredit ? json["from_customer"] : json['to_customer']) ?? "";

    final avatar = (isCredit
            ? json["from_customer_avatar"]
            : json['to_customer_avatar']) ??
        "";
    final String displayCustomer = (isCredit
            ? json["display_from_customer"]
            : json['display_to_customer']) ??
        "";

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
        displayFromCustomer: json["display_from_customer"] ?? "",
        displayToCustomer: json["display_to_customer"] ?? "",
        displayCustomer: displayCustomer,
        fromCustomer: json['from_customer'] ?? "",
        toCustomer: json['to_customer'] ?? "",
        isAnonymous: json['is_anonymous'] ?? false,
        isCredit: isCredit);
  }
}

class PaymentRequest {
  String? status;
  String? id;
  String? description;
  String? payee;
  String? fromCustomer;
  String? fromCustomerAvatar;
  String? toCustomer;
  String? toCustomerAvatar;

  bool? madeFromChat;
  String? conversationId;
  String? avatar;
  String? currency;
  String? createdAt;
  int? amount;
  bool? isCredit;
  String userType;
  String displayFromCustomer;
  String displayToCustomer;
  String displayCustomer;

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
      this.toCustomer = "",
      this.fromCustomer = "",
      this.displayFromCustomer = "",
      this.displayToCustomer = "",
      this.displayCustomer = "",
      this.conversationId = "",
      this.fromCustomerAvatar = "",
      this.madeFromChat = false,
      this.toCustomerAvatar = "",
      this.isCredit});

  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    final UserBloc currentUser =
        Provider.of(MyGlobals().navigationKey.currentContext!, listen: false);

    //
    final bool isRequested =
        (json["from_customer"] == currentUser.user.userName) ? false : true;

    final payee =
        (isRequested ? json["from_customer"] : json['to_customer']) ?? "";
    final avatar = (isRequested
            ? json["from_customer_avatar"]
            : json['to_customer_avatar']) ??
        "";
    final String displayCustomer = (isRequested
            ? json["display_from_customer"]
            : json['display_to_customer']) ??
        "";

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
        isCredit: isRequested,
        conversationId: json['conversation_id'],
        fromCustomer: json['from_customer'],
        fromCustomerAvatar: json['from_customer_avatar'],
        displayFromCustomer: json["display_from_customer"] ?? "",
        displayToCustomer: json["display_to_customer"] ?? "",
        displayCustomer: displayCustomer,
        madeFromChat: json['made_from_chat'],
        toCustomer: json['to_customer'],
        toCustomerAvatar: json['to_customer_avatar']);
  }
}
