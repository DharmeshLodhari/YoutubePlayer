class Payout {
  String status;
  String uuid;
  String timeStemp;
  String bankLogo;
  String currency;
  String bankName;
  int amount;

  // Pass in as named parameter in constructor
  Payout(
      {this.status,
      this.uuid,
      this.timeStemp,
      this.bankLogo,
      this.currency,
      this.bankName,
      this.amount});
}
