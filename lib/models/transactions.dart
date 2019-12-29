class BankAccount {
  String uuid;
  String bankAvatar;
  String bankName;
  String accountName;
  int accountNumber;

  BankAccount({ this.uuid,
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
  String payeeUrl;
  String currency;
  int amount;
  bool isCredit;

  // Pass in as named parameter in constructor
  Transaction({this.status, this.uuid, this.description,
    this.payee, this.payeeUrl, this.currency, this.amount, this.isCredit});

}




