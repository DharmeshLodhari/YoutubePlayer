class Invoice {
  String amount;
  String created_at;
  String currency;
  String description;
  String due_date;
  String paid_at;
  String payee_avatar;
  String payee_id;
  String payee_name;
  String status;
  String uuid;

  Invoice(
      {this.amount,
      this.created_at,
      this.currency,
      this.description,
      this.due_date,
      this.paid_at,
      this.payee_avatar,
      this.payee_id,
      this.payee_name,
      this.status,
      this.uuid});

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      amount: json['amount'],
      created_at: json['created_at'],
      currency: json['currency'],
      description: json['description'],
      due_date: json['due_date'],
      paid_at: json['paid_at'],
      payee_avatar: json['payee_avatar'],
      payee_id: json['payee_id'],
      payee_name: json['payee_name'],
      status: json['status'],
      uuid: json['uuid'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['created_at'] = this.created_at;
    data['currency'] = this.currency;
    data['description'] = this.description;
    data['due_date'] = this.due_date;
    data['paid_at'] = this.paid_at;
    data['payee_avatar'] = this.payee_avatar;
    data['payee_id'] = this.payee_id;
    data['payee_name'] = this.payee_name;
    data['status'] = this.status;
    data['uuid'] = this.uuid;
    return data;
  }
}
