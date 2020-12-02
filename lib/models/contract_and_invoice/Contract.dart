class Contract {
  String amount;
  String createdAt;
  String currency;
  String description;
  String endAt;
  String paidAt;
  String payeeAvatar;
  String payeeId;
  String payeeName;
  String paymentPeriod;
  String status;
  String uuid;

  Contract(
      {this.amount,
      this.createdAt,
      this.currency,
      this.description,
      this.endAt,
      this.paidAt,
      this.payeeAvatar,
      this.payeeId,
      this.payeeName,
      this.paymentPeriod,
      this.status,
      this.uuid});

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      amount: json['amount'],
      createdAt: json['created_at'],
      currency: json['currency'],
      description: json['description'],
      endAt: json['end_at'],
      paidAt: json['paid_at'],
      payeeAvatar: json['payee_avatar'],
      payeeId: json['payee_id'],
      payeeName: json['payee_name'],
      paymentPeriod: json['payment_period'],
      status: json['status'],
      uuid: json['uuid'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['created_at'] = this.createdAt;
    data['currency'] = this.currency;
    data['description'] = this.description;
    data['end_at'] = this.endAt;
    data['paid_at'] = this.paidAt;
    data['payee_avatar'] = this.payeeAvatar;
    data['payee_id'] = this.payeeId;
    data['payee_name'] = this.payeeName;
    data['payment_period'] = this.paymentPeriod;
    data['status'] = this.status;
    data['uuid'] = this.uuid;
    return data;
  }
}
