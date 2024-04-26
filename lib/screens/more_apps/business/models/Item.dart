class InvoiceItem {
  int? amount;
  int? id;
  String? name;
  int? quantity;
  String? currency;

  InvoiceItem(
      {this.amount,
      this.currency = "NGN",
      this.id,
      this.name,
      this.quantity = 1});

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      amount: json['amount'],
      currency: json['currency'],
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    data['id'] = this.id;
    data['name'] = this.name;
    data['quantity'] = this.quantity;
    return data;
  }
}
