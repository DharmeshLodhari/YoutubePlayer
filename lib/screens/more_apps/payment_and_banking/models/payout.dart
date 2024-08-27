class Payout {
  String? status;
  String? uuid;
  String? timeStamp;
  String? bankLogo;
  String? currency;
  String? bankName;
  String? customerUsername;
  String? accountName;
  String? accountNumber;
  String? description;
  int? amount;
  String? referenceNumber;
  String? category;

  // Pass in as named parameter in constructor
  Payout({
    this.status,
    this.uuid,
    this.timeStamp,
    this.bankLogo,
    this.currency,
    this.bankName,
    this.customerUsername,
    this.accountName,
    this.accountNumber,
    this.description,
    this.amount,
    this.referenceNumber,
    this.category,
  });
}
