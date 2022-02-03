class Payout {
  String? status;
  String? uuid;
  String? timeStamp;
  String? bankLogo;
  String? currency;
  String? bankName;
  int? amount;

  // Pass in as named parameter in constructor
  Payout(
      {this.status,
      this.uuid,
      this.timeStamp,
      this.bankLogo,
      this.currency,
      this.bankName,
      this.amount});
}
