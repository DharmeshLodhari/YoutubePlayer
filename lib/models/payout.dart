class Payout {
  String status;
  String uuid;
  String description;
  String payee;
  String timeStemp;
  String avatar;
  String currency;
  int amount;
  bool isCredit;

  // Pass in as named parameter in constructor
  Payout(
      {this.status,
      this.uuid,
      this.description,
      this.payee,
      this.timeStemp,
      this.avatar,
      this.currency,
      this.amount,
      this.isCredit});
}
