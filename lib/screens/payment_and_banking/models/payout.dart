class Payout {
  String? id;
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
    this.id,
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

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      id: json['id'],
      uuid: json['id'],
      status: json['status'],
      amount: json['amount'],
      currency: json['currency'],
      timeStamp: json["credited_at"] ?? json["created_at"],
      bankName: json["customer_bank_account"]["bank"]["name"],
      customerUsername: json["customer_bank_account"]["customer_username"],
      bankLogo: json["customer_bank_account"]["bank"]["logo_url"],
      accountName: json["customer_bank_account"]["account_name"],
      accountNumber: json["customer_bank_account"]["account_number"],
      referenceNumber: json["reference_number"] ?? "-",
      category: json["category"] ?? "-",
    );
  }
}
