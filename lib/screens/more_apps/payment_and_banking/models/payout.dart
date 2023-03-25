class Payout {
  String? status;
  String? uuid;
  String? timeStamp;
  String? bankLogo;
  String? currency;
  String? bankName;
  String? accountName;
  String? accountNumber;
  String? description;
  int? amount;

  // Pass in as named parameter in constructor
  Payout(
      {this.status,
      this.uuid,
      this.timeStamp,
      this.bankLogo,
      this.currency,
      this.bankName,
        this.accountName,
        this.accountNumber,
        this.description,
      this.amount});
}
