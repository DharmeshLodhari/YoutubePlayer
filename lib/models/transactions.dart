class BankAccount {
  String uuid;
  String bankAvatar;
  String bankName;
  String accountName;
  int accountNumber;

  BankAccount(
      {this.uuid,
      this.bankAvatar,
      this.bankName,
      this.accountName,
      this.accountNumber});
}

class Transaction {
  String status;
  String uuid;
  String description;
  String payee;
  String avatar;
  String currency;
  String createdAt;
  int amount;
  bool isCredit;

  // Pass in as named parameter in constructor
  Transaction(
      {this.status,
      this.uuid,
      this.description,
      this.payee,
      this.avatar,
      this.currency,
      this.createdAt,
      this.amount,
      this.isCredit});
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

  // Pass in as named parameter in constructor
  PaymentRequest(
      {this.status,
      this.id,
      this.description,
      this.payee,
      this.avatar,
      this.createdAt,
      this.currency,
      this.amount,
      this.isCredit});
}
