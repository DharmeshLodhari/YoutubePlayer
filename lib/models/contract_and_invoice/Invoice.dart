class Invoice {
  String amount;
  String createdAt;
  String currency;
  String description;
  String dueDate;
  String paidAt;
  String payeeAvatar;
  String payeeId;
  String payeeName;
  String status;
  String uuid;

  Invoice(
      {this.amount,
      this.createdAt,
      this.currency,
      this.description,
      this.dueDate,
      this.paidAt,
      this.payeeAvatar,
      this.payeeId,
      this.payeeName,
      this.status,
      this.uuid});

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      amount: json['amount'],
      createdAt: json['created_at'],
      currency: json['currency'],
      description: json['description'],
      dueDate: json['due_date'],
      paidAt: json['paid_at'],
      payeeAvatar: json['payee_avatar'],
      payeeId: json['payee_id'],
      payeeName: json['payee_name'],
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
    data['due_date'] = this.dueDate;
    data['paid_at'] = this.paidAt;
    data['payee_avatar'] = this.payeeAvatar;
    data['payee_id'] = this.payeeId;
    data['payee_name'] = this.payeeName;
    data['status'] = this.status;
    data['uuid'] = this.uuid;
    return data;
  }
}
